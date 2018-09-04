//
//  QCEWReportManager.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 8/10/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

class QCEWReportManager {
    class func getReports(forArea area: Area, reportTypesDict: [String: ReportType],
                          seasonalAdjustment: SeasonalAdjustment = .notAdjusted,
                          year: String? = nil,
                          completion: ((APIResult<[String: AreaReport], ReportError>) -> Void)?) {
    }

}
