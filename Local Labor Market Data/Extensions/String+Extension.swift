//
//  String+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/2/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = self.count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return String(self[index(self.startIndex, offsetBy: newLength - toLength)...])
        }
    }

    func rightPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = self.count
        if newLength < toLength {
            return self + String(repeatElement(character, count: toLength - newLength))
        } else {
            return String(self[index(self.startIndex, offsetBy: newLength - toLength)...])
        }
    }

    func isNumber() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func add(prefix: String) -> String {
        return prefix + self
    }
    
    func trailingTrim(_ characterSet : CharacterSet) -> String {
        if let range = rangeOfCharacter(from: characterSet, options: [.anchored, .backwards]) {
            return String(self[..<range.lowerBound]).trailingTrim(characterSet)
        }
        return self
    }
}
