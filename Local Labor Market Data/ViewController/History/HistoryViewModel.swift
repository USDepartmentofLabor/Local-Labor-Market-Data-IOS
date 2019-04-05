//
//  HistoryViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/29/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation


class HistoryViewModel {
    static var HISTORY_MONTHS = -24

    var area: Area!
    var localAreaReport: AreaReport
    var nationalAreaReport: AreaReport?
    var title: String
    
    init(title: String, area: Area, localAreaReport: AreaReport, nationalAreaReport: AreaReport?) {
        self.title = title
        self.area = area
        self.localAreaReport = localAreaReport
        self.nationalAreaReport = nationalAreaReport
        loadHistory()
    }
    
    func loadHistory() {
/*
        var seriesIds =  [String]()
        if let localSeriesId = localSeriesId {
            seriesIds.append(localSeriesId)
        }
        if let nationalSeriesId = nationalSeriesId {
            seriesIds.append(nationalSeriesId)
        }
        ReportManager.getHistory(seriesIds: seriesIds,
                                 monthsHistory: HistoryViewModel.HISTORY_MONTHS) {
                                    [weak self] (apiResult) in

            guard let strongSelf = self else {return}

            switch(apiResult) {
            case .success(let seriesReports):
                print(seriesReports)
                
            case .failure(let error):
                print(error)
            }
        }
 */
    }

}
