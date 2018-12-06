//
//  HistoryViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/29/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation


class HistoryViewModel {
    static var HISTORY_MONTHS = 24

    var areaReport: AreaReport
    var localSeriesReport: [SeriesReport]?
    var nationalSeriesReport: [SeriesReport]?
    
    init(areaReport: AreaReport) {
        self.areaReport = areaReport
    }
    
    var title: String {
     get {
        var title = "History"
        switch areaReport.reportType {
        case .unemployment( _):
                title = "Unemployment - \(title)"
        case .industryEmployment(_, _):
            title = "Industry - \(title)"
        default:
            title = "History"
        }
        return title
        }
    }
    
    func loadHistory() {
        ReportManager.getHistory(areaReport: areaReport,
                                 monthsHistory: HistoryViewModel.HISTORY_MONTHS) {
                                    [weak self] (apiResult) in

            guard let strongSelf = self else {return}

            switch(apiResult) {
            case .success(let seriesReport):
                if (strongSelf.areaReport.area is National) {
                    strongSelf.nationalSeriesReport = seriesReport
                }
                else {
                    strongSelf.localSeriesReport = seriesReport
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
