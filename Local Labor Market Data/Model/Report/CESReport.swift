//
//  CESReport.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/30/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

class CESReport {
    enum DataTypeCode: String {
        case allEmployees = "01"
        case avgWeeklyHours_AllEmployees = "02"
        case avgHourlyEarnings_AllEmployees = "03"
        case production_NonsupervisoryEmployees = "06"
        case avgWeeklyHours_ProductionEmployees = "07"
        case avgHourlyEarnings_ProductionEmployees = "08"
        case avgWeeklyEarnings_AllEmployees = "11"
        case allEmployees_3MonthAvgChange = "26"
        case averageWeeklyEarlnings_ProductionEmployees = "30"
    }

//    class func getEmploymentLevelSeriesId(forArea area: Area,
//                                           adjustment: SeasonalAdjustment) -> SeriesId? {
//        return getSeriesId(forArea: area, measureCode: .UnemploymentRate, adjustment: adjustment)
//    }
    
    class func getSeriesId(forArea area: Area, industryCode: String = "00000000",
                           dataTypeCode: DataTypeCode,
                           adjustment: SeasonalAdjustment) -> SeriesId? {
        if area is National {
            return getNationalSeriesId(dataTypeCode: dataTypeCode, adjustment: adjustment)
        }
        else {
            return getLocalAreaSeriesId(forArea: area, industryCode: industryCode, dataTypeCode: dataTypeCode, adjustment: adjustment)
        }
    }
    
    class func getNationalSeriesId(industryCode: String = "00000000",
                                   dataTypeCode: DataTypeCode,
                                   adjustment: SeasonalAdjustment) -> SeriesId? {
        
        let seriesId = "CE" + adjustment.rawValue  + industryCode + dataTypeCode.rawValue
        return seriesId
    }
    
    class func getLocalAreaSeriesId(forArea area: Area, industryCode: String = "00000000",
                                   dataTypeCode: DataTypeCode,
                                   adjustment: SeasonalAdjustment) -> SeriesId? {
        
        guard let code = area.code else { return nil}
       var areaCode: String = ""
        if let metro = area as? Metro, let stateCode = metro.stateCode {
            areaCode = stateCode
        }
        
        areaCode.append(code)
        areaCode = areaCode.rightPadding(toLength: 7, withPad: "0")
        let seriesId = "SM" + adjustment.rawValue  + areaCode + industryCode + dataTypeCode.rawValue
        return seriesId
    }
}
