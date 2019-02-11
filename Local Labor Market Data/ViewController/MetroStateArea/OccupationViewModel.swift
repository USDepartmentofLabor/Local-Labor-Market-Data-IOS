//
//  ItemViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

enum OccupationDataType {
    case MeanAnnualWage
    case EmploymentLevel
}


class OccupationViewModel: ItemViewModel {
    
    var dataTypes: [OESReport.DataTypeCode] = [.annualMeanWage, .employment]
    var localMeanAnnualWageReport:[ReportType: AreaReport]?
    var nationalMeanAnnualWageReport:[ReportType: AreaReport]?
    
    var localEmploymentLevelReport:[ReportType: AreaReport]?
    var nationalEmploymentLevelReport:[ReportType: AreaReport]?
    
    var currentDataType: OESReport.DataTypeCode = .annualMeanWage
    init(area: Area, parent: Item? = nil, dataYear: String) {
        super.init(area: area, parent:parent, itemType: OE_Occupation.self, dataYear: dataYear)
    }
    
    override func createInstance(forParent parent: Item) -> ItemViewModel {
        return OccupationViewModel(area: area, parent: parent, dataYear: dataYear)
    }

    
    override func getReportType(for item: Item) -> ReportType? {
        let reportType: ReportType?
        if let code = item.code {
            reportType = ReportType.occupationEmployment(occupationalCode: code, currentDataType)
        }
        else {
            reportType = nil
        }

        return reportType
    }
    
    
    override func getReportLatestData(item: Item) -> SeriesData? {
        guard let reportType = getReportType(for: item) else { return nil }
        
        if currentDataType == .annualMeanWage {
            return localMeanAnnualWageReport?[reportType]?.seriesReport?.latestData()
        }
        else if currentDataType == .employment {
            return localEmploymentLevelReport?[reportType]?.seriesReport?.latestData()
        }
        
        return nil
    }
    
    override func getNationalReportData(item: Item, period: String?, year: String?) -> SeriesData? {
        guard let reportType = getReportType(for: item) else { return nil }
        
        if currentDataType == .annualMeanWage {
            if let period = period, let year = year {
                return nationalMeanAnnualWageReport?[reportType]?.seriesReport?.data(forPeriod: period, forYear: year)
            }
            else {
                return nationalMeanAnnualWageReport?[reportType]?.seriesReport?.latestData()
            }
        }
        else if currentDataType == .employment {
            if let period = period, let year = year {
                return nationalEmploymentLevelReport?[reportType]?.seriesReport?.data(forPeriod: period, forYear: year)
            }
            else {
                return nationalEmploymentLevelReport?[reportType]?.seriesReport?.latestData()
            }
        }
        
        return nil
    }

    override func loadReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping () -> Void) {
        loadLocalReport(seasonalAdjustment: seasonalAdjustment) {
            self.loadNationalReport(seasonalAdjustment: seasonalAdjustment, completion:  completion)
        }
    }
    
    func loadLocalReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping () -> Void) {
        if currentDataType == .annualMeanWage, localMeanAnnualWageReport == nil {
            // Load the report from Server
            loadReport(area: area, seasonalAdjustment: seasonalAdjustment, completion: completion)
        }
        else if currentDataType == .employment, localMeanAnnualWageReport == nil {
            loadReport(area: area, seasonalAdjustment: seasonalAdjustment, completion: completion)
        }
        else {
            // return the report
            completion()
        }
    }
    
    func loadNationalReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping () -> Void) {
        guard let context = area.managedObjectContext,
            let nationalArea = DataUtil(managedContext: context).nationalArea()
            else {return }
        
        if currentDataType == .annualMeanWage {
            if nationalMeanAnnualWageReport == nil {
                // Load the report from Server
                loadReport(area: nationalArea, seasonalAdjustment: seasonalAdjustment, completion: completion)
            }
            else {
                // return the report
                completion()
            }
        }
        else if currentDataType == .employment {
            if nationalMeanAnnualWageReport == nil {
                loadReport(area: nationalArea, seasonalAdjustment: seasonalAdjustment, completion: completion)
            }
            else {
                // return the report
                completion()
            }
        }
    }
    
    func loadReport(area: Area, seasonalAdjustment: SeasonalAdjustment, completion: @escaping () -> Void) {
        super.loadReportFromAPI(area: area, seasonalAdjustment: seasonalAdjustment) {
            [weak self] (apiResult) in
            guard let strongSelf = self else { return }
            
            switch apiResult {
            case .success(let areaReportsDict):
                
                if strongSelf.currentDataType == .annualMeanWage {
                    if area == strongSelf.area {
                        strongSelf.localMeanAnnualWageReport = areaReportsDict
                    }
                    else {
                        strongSelf.nationalMeanAnnualWageReport = areaReportsDict
                    }
                }
                else if strongSelf.currentDataType == .employment {
                    if area == strongSelf.area {
                        strongSelf.localEmploymentLevelReport = areaReportsDict
                    }
                    else {
                        strongSelf.nationalEmploymentLevelReport = areaReportsDict
                    }
                }
                
            case .failure(let error):
                print(error)
            }
            completion()
        }
    }
}
