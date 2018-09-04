//
//  ReportViewCell.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 8/14/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import UIKit


protocol ReportTableViewCell {
    func displaySeries(area: Area?, seriesReport: SeriesReport?, periodName: String?, year: String?)
}


class ReportSection {
    var title: String
    
    private var _collapsed: Bool = false
    var collapsed: Bool {
        get {
            return Util.isVoiceOverRunning ? false : _collapsed
        }
        set {
            if Util.isVoiceOverRunning {
                _collapsed = false
            }
            else {
                self._collapsed = newValue
            }
        }
    }
    
    var reportTypes:[ReportType]?
    var children: [ReportSection]? = nil
    
    func allReportTypes() -> [ReportType]? {
        var allReportTypes = [ReportType]()
        let childredReportTypes = children?.compactMap {$0.reportTypes}.flatMap {$0}
        
        if let reportTypes = reportTypes {
            allReportTypes = allReportTypes + reportTypes
        }
        if let reportTypes = childredReportTypes {
            allReportTypes = allReportTypes + reportTypes
        }
        
        return allReportTypes
    }
    
    init(title: String, collapsed: Bool = true, reportTypes: [ReportType]?, children: [ReportSection]? = nil) {
        self.title = title
        self.collapsed = collapsed
        self.reportTypes = reportTypes
        self.children = children
    }
}

