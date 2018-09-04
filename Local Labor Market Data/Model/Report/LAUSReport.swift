//
//  LAUSReport.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 7/30/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

class LAUSReport {
    enum MeasureCode: String {
        case unemploymentRate = "03"
        case unnemployment = "04"
        case employment = "05"
        case laborForce = "06"
    }
    

    class func getUnemploymentRateSeriesId(forArea area: Area,
                                           adjustment: SeasonalAdjustment) -> SeriesId? {
        return getSeriesId(forArea: area, measureCode: .unemploymentRate, adjustment: adjustment)
    }
    
    class func getSeriesId(forArea area: Area, measureCode: MeasureCode,
                         adjustment: SeasonalAdjustment) -> SeriesId? {
     
        guard let areaCode = area.laus?.areaCode else { return nil}
        let seriesId = "LA" + adjustment.rawValue  + areaCode + measureCode.rawValue
        return seriesId
    }
}
