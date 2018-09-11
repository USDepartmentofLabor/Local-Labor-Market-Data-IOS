//
//  OESReport.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/31/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

class OESReport {
    enum DataTypeCode: String {
        case employment = "01"
        case employmentPercentRelativeStdError = "02"
        case hourlyMeanWage = "03"
        case annualMeanWage = "04"
        case wagePercentRelativeStdError = "05"
        case hourly10PercentileWage = "06"
        case hourly25PercentileWage = "07"
        case hourlyMedianWage = "08"
        case hourly75PercentileWage = "09"
        case hourly90PercentileWage = "10"
        case annual10PercentileWage = "11"
        case annual25PercentileWage = "12"
        case annualMedianWage = "13"
        case annual75PercentileWage = "14"
        case annual90PercentileWage = "15"
        case employmentPer1000Jobs = "16"
        case locationQuotient = "17"
    }
    
    class func getSeriesId(forArea area: Area, occupationCode: String = "000000",
                           dataTypeCode: DataTypeCode,
                           adjustment: SeasonalAdjustment) -> SeriesId? {

        guard let code = area.code else { return nil}
        
        let areaType: String
        let areaCode: String
        if area is Metro {
            areaType = "M"
            areaCode = code.leftPadding(toLength: 7, withPad: "0")
        }
        else if area is State {
            areaType = "S"
            areaCode = code.rightPadding(toLength: 7, withPad: "0")
        }
        else {
            areaType = "N"
            areaCode = code.rightPadding(toLength: 7, withPad: "0")
        }
        
        let industryCode = "000000"
        let seriesId = "OE" + adjustment.rawValue  + areaType + areaCode + industryCode + occupationCode + dataTypeCode.rawValue
        return seriesId
    }
}
