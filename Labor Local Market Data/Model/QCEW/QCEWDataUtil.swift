//
//  QCEWDataUtil.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 8/8/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

class QCEWDataUtil {
    
    struct Constants {
        static let YEAR_QUARTER_INFO_FILENAME = "https://data.bls.gov/cew/apps/ref/year_qtr_info.csv"
        static let QCEW_API_PATH = "http://data.bls.gov/cew/data/api"
    }

    class func latestReport() {
//        guard let fileURL = URL(string: Constants.YEAR_QUARTER_INFO_FILENAME) else {return}
        
//        NetworkAPI().getFile(forURL: fileURL) { (result) in
//            switch result {
//            case .success(let data):
//
//            }
//        }
    }
    
//    func parseYearQtrInfo(data: Data) -> (year: String, qtr: String) {
//        var contents = try String(data: data, encoding: .utf8)
//        contents = contents?.replacingOccurrences(of: "\r\n", with: "\n")
//    }
//
        // craete File with path - http://data.bls.gov/cew/data/api/2017/1/area/US000.csv
    func qcewFilePath(forArea area: Area, qtr: String, year: String) -> String {
        guard var areaCode = area.code else { return ""}
        
        if area is National {
            areaCode = "US000"
        }
        
        return "\(Constants.QCEW_API_PATH)/\(year)/\(qtr)/area/\(areaCode).csv"
    }
    
    func qcewGetAreaData(forArea area: Area, qtr: String, year: String) {
//        let url = URL(string: qcewFilePath(forArea: area, qtr: qtr, year: year))
    }
}
