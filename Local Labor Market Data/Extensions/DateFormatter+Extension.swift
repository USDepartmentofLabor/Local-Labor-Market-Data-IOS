//
//  DateFormatter+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 9/4/18.
//  Copyright © 2018 Department Of Labor. All rights reserved.
//

import Foundation


extension DateFormatter {
    class func shortMonthName(fromMonth name: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        dateFormatter.dateFormat = "MMMM"
        
        if let date = dateFormatter.date(from: name) {
            dateFormatter.dateFormat = "MMM"
            return dateFormatter.string(from: date)
        }
        
        return nil
    }
    
    class func quarter(fromMonth name: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        dateFormatter.dateFormat = "MMMM"
        
        if let date = dateFormatter.date(from: name) {
            let calendar = Calendar.current
            let month = calendar.component(.month, from: date)
            return (month-1)/3 + 1
        }
        
        return nil
    }
    
    class func month(fromMonth name: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        dateFormatter.dateFormat = "MMMM"
        
        if let date = dateFormatter.date(from: name) {
            let calendar = Calendar.current
            let month = calendar.component(.month, from: date)
            return month
        }
        
        return nil
    }
    
    class func date(fromMonth month: String, fromYear year: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.date(from: "\(month) \(year)")        
    }

}
