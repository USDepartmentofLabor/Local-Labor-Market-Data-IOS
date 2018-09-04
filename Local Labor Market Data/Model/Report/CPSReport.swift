//
//  CPSReport.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 8/3/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation


class CPSReport {
    enum lfstCode: String {
        case unemployment = "30"
        case unemploymentRate = "40"
    }
    
    class func getUnemploymentRateSeriesId(forArea area: Area,
                                           adjustment: SeasonalAdjustment) -> SeriesId? {
        guard let nationalArea = area as? National else {return nil}
        
        return getSeriesId(forArea: nationalArea, lfstCode: .unemploymentRate, adjustment: adjustment)
    }
    
    class func getSeriesId(forArea area: National, lfstCode: lfstCode,
                           adjustment: SeasonalAdjustment) -> SeriesId? {
        
        var adjustmentCode = adjustment.rawValue
        adjustmentCode.append(adjustment == .adjusted ? "1" : "0")
        let seriesId = "LN" + adjustmentCode + lfstCode.rawValue + "00000"
        return seriesId
    }

}
