//
//  NSNumberFormatter+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/17/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

extension NumberFormatter {
    class var currencyFormatterWitoutFraction: NumberFormatter {
        get {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = NSLocale.current
            formatter.maximumFractionDigits = 0
            return formatter
        }
    }
    
    class func localisedCurrencyStrWithoutFraction(from value: NSNumber) -> String? {
        return currencyFormatterWitoutFraction.string(from: value)
    }

    class func localisedPercentStr(from valueStr: String?) -> String? {
        guard let valueStr = valueStr else {return nil}
        
        var percentStr = "\(valueStr)%"
        
        if let doubleValue = Double(valueStr), doubleValue > 0 {
            percentStr = percentStr.add(prefix: "+")
        }
        
        return percentStr
    }

    class func localisedDecimalStr(from valueStr: String?) -> String? {
        guard let valueStr = valueStr else {return nil}
        
        var decimalStr = valueStr
        if let doubleValue = Double(valueStr) {
            decimalStr = localisedDecimalStr(from: doubleValue) ?? ""
        }
        
        return decimalStr
    }

    class func localisedDecimalStr(from value: Double?) -> String? {
        guard let value = value else {return nil}
        
        var decimalStr = ""
        decimalStr = NumberFormatter.localizedString(from: NSNumber(value: value),
                                                         number: NumberFormatter.Style.decimal)
            
        if value > 0 {
            decimalStr = decimalStr.add(prefix: "+")
        }
        return decimalStr
    }

}
