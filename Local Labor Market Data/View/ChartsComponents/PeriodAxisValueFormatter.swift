//
//  PeriodAxisValueFormatter.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 4/3/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import Charts

public class PeriodValueFormatter: NSObject, IAxisValueFormatter {
    
    var periods: [String]
    public init(periods: [String]) {
        self.periods = periods
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let periodInt = Int(value)
        
        return periodInt < periods.count ? periods[Int(value)]: "0"
    }
}
