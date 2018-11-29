//
//  HistoryViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/29/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation


class HistoryViewModel {
    var areaReport: AreaReport
    
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
        
    }
}
