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

    var localSeriesId: String?
    var nationalSeriesId: String?
    var currentDate: Date!
    var title: String
    
    init(title: String, localSeriesId: String?, nationalSeriedId: String?, latestDate: Date) {
        self.title = title
        self.localSeriesId = localSeriesId
        self.nationalSeriesId = nationalSeriedId
        self.currentDate = latestDate
        loadHistory()
    }
    
    func loadHistory() {
        var seriesIds =  [String]()
        if let localSeriesId = localSeriesId {
            seriesIds.append(localSeriesId)
        }
        if let nationalSeriesId = nationalSeriesId {
            seriesIds.append(nationalSeriesId)
        }
        ReportManager.getHistory(seriesIds: seriesIds,
                                 monthsHistory: HistoryViewModel.HISTORY_MONTHS) {(apiResult) in
/*                                    [weak self]

            guard let strongSelf = self else {return}

            switch(apiResult) {
            case .success(let seriesReports):
                print(seriesReports)
                
            case .failure(let error):
                print(error)
            }
*/        }
    }
}
