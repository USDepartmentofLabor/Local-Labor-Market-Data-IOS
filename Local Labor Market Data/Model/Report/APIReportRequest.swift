//
//  ReportRequest.swift
//  BaseApp
//
//  Created by Nidhi Chawla on 6/19/18.
//  Copyright © 2018 Khazana Corporation. All rights reserved.
//

import Foundation


struct APIReportRequest : Encodable {
    let seriesid: [String]
    let registrationkey: String
    let startyear: String?
    let endyear: String?
    let catalog: Bool?
    let calculations: Bool?
    let annualaverage: Bool?
//    var latest: Bool? = true

    init(seriesIds: [String], registrationKey: String, startYear: String? = nil,
         endYear: String? = nil, catalog: Bool? = false, calculations: Bool? = true,
         annualAverage: Bool? = false) {
        self.seriesid = seriesIds
        self.registrationkey = registrationKey
        if let startYear = startYear {
            self.startyear = startYear
            if let endYear = endYear {
                self.endyear = endYear
            }
            else {
                self.endyear = startYear
            }
//            self.latest = false
        }
        else {
            self.startyear = nil
            self.endyear = nil
//            self.latest = true
        }
        self.catalog = catalog
        self.calculations = calculations
        self.annualaverage = annualAverage
    }
    
    init(seriesIds: [String], registrationKey: String) {
        self.init(seriesIds: seriesIds, registrationKey: registrationKey, startYear: nil, endYear: nil, catalog: false, calculations: true, annualAverage: false)
    }
    
    var description: String { return """
        SeriesId: \(seriesid)
        StartYear: \(startyear ?? "")
        EndYear: \(endyear ?? "")
        """
}
    
}

