//
//  HistoryViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/29/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import Charts

class HistoryViewModel {
    static var HISTORY_MONTHS = -24

    var localAreaReport: AreaReport
    var nationalAreaReport: AreaReport?
    var currentDate: Date!
    var area: Area!
    var seasonalAdjustment: SeasonalAdjustment
    
    init(area: Area, localAreaReport: AreaReport, nationalAreaReport: AreaReport?, seasonalAdjustment: SeasonalAdjustment) {
        self.area = area
        self.localAreaReport = localAreaReport
        self.nationalAreaReport = nationalAreaReport
        self.seasonalAdjustment = seasonalAdjustment
    }
    
    var title: String {
        var titleStr = "History"
        switch(localAreaReport.reportType) {
        case .unemployment (_):
            titleStr += "- Unemployment"
        case .industryEmployment(_, _):
            titleStr += "- Industry"
        default:
            titleStr = "History"
        }
        
        return titleStr
    }
    
    func loadHistory(completion: ((APIResult<[AreaReport]?, ReportError>) -> Void)?) {

        ReportManager.getHistory(forArea: area,
                                 reportType: localAreaReport.reportType,
                                 seasonalAdjustment: seasonalAdjustment) {
                                    [weak self] (apiResult) in

            guard let strongSelf = self else {return}

            switch(apiResult) {
            case .success(let areaReports):
                
                if let localReport = areaReports?.filter({ $0.area == strongSelf.localAreaReport.area}).first {
                    strongSelf.localAreaReport = localReport
                }
                strongSelf.nationalAreaReport = areaReports?.filter{ $0.area == strongSelf.nationalAreaReport?.area}.first
                

            case .failure(let error):
                strongSelf.localAreaReport.seriesReport = nil
                strongSelf.nationalAreaReport?.seriesReport = nil
                print(error)
            }
                                    
            completion?(apiResult)
        }
    }
}

extension HistoryViewModel {
    func generateChartData<T: ChartDataEntry>(type: T.Type) -> (localDataEntry: [T]?, nationalDataEntry: [T]?)? {
        guard let localSeriesReport = localAreaReport.seriesReport else {
            return nil
        }
        let nationalSeriesReport = nationalAreaReport?.seriesReport

        let dataEntry: [(localDataEntry: T?, nationalDataEntry: T?)]
        if localSeriesReport.data.count > 0 {
            let localReportData = localSeriesReport.data.reversed()
            dataEntry = localReportData.enumerated().map {  (index, element) -> (localDataEntry: T, nationalDataEntry: T?) in
                let value = Double(element.value)!
                let localDataEntry = T()
                localDataEntry.x = Double(index)
                localDataEntry.y = value
                localDataEntry.data = "local" as AnyObject
                
                var nationalDataEntry: T? = nil
                if let nationalData = nationalSeriesReport?.data(forPeriod: element.period, forYear: element.year) {
                    nationalDataEntry = T()
                    nationalDataEntry?.x = Double(index)
                    nationalDataEntry?.y = Double(nationalData.value)!
                    nationalDataEntry?.data = "national" as AnyObject
                }
                
                return (localDataEntry:localDataEntry, nationalDataEntry: nationalDataEntry)
            }
            
        }
        else if let nationalSeriesReport = nationalSeriesReport, nationalSeriesReport.data.count > 0 {
            let nationalReportData = nationalSeriesReport.data.reversed()
            
            dataEntry = nationalReportData.enumerated().map { (arg) -> (localDataEntry: T?, nationalDataEntry: T?) in
                let (index, element) = arg
                let value = Double(element.value)!
                let nationalDataEntry = T()
                nationalDataEntry.x = Double(index)
                nationalDataEntry.y = value
                nationalDataEntry.data = "national" as AnyObject
                return (localDataEntry: nil, nationalDataEntry: nationalDataEntry)
            }
        }
        else {
            dataEntry = [(localDataEntry: nil, nationalDataEntry: nil)]
        }

        let localDataEntry = dataEntry.compactMap { (element) -> T? in
            return (element.localDataEntry )
        }
        let nationalDataEntry = dataEntry.compactMap { (element) -> T? in
            return element.nationalDataEntry
        }

        return (localDataEntry: localDataEntry, nationalDataEntry: nationalDataEntry)
    }
}
