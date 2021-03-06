//
//  SeriesReport.swift
//  BaseApp
//
//  Created by Nidhi Chawla on 6/18/18.
//  Copyright © 2018 Khazana Corporation. All rights reserved.
//

import Foundation

struct SeriesReport : Decodable {
    var seriesID: String
    var data: [SeriesData]
    
    func seriesData(forMonth month: String, forYear year: String) -> SeriesData? {
        return data.filter { $0.periodName == month && $0.year == year }.first
    }
    
    func latestData() -> SeriesData? {
//        return data.filter {$0.latest == true}.first
        // Some Reports (example QCEW do not have latest Value when StartYear and EndYear are specified. Hence  sort the report on Year and Period.
        
        return data.sorted {
            if $0.year == $1.year { // first, compare by Year
                return $0.period > $1.period
            }
            else {
                return $0.year > $1.year
            }
            }.first
    }

    func data(forPeriod period: String, forYear year: String) -> SeriesData? {
        return data.filter {$0.period == period && $0.year == year}.first
    }

    func data(forPeriodName periodName: String, forYear year: String) -> SeriesData? {
        return data.filter {$0.periodName == periodName && $0.year == year}.first
    }
    
    // Return Year for the Latest Data
    func latestDataYear() -> String? {
        guard let latestData = latestData() else {
            return nil
        }
        
        return latestData.year
    }

    func latestDataPeriod() -> String? {
        guard let latestData = latestData() else {
            return nil
        }
        
        return latestData.period
    }

    // Return PeriodName for the latest Data
    func latestDataPeriodName() -> String? {
        guard let latestData = latestData() else {
            return nil
        }
        
        return latestData.periodName
    }
    
    // get Latest Annual Data if Available
    func latestAnnualData(year: String? = nil) -> SeriesData? {
//        return data.filter{$0.period == "M13"}.sorted {
        if let year = year {
            return data.filter{$0.periodName == "Annual" && $0.year == year}.first
        }
        return data.filter{$0.periodName == "Annual"}.sorted {
                return $0.year > $1.year
            }.first
    }
}

