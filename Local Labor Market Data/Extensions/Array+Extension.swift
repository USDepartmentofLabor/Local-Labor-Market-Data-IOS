//
//  Array+Extension.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 7/26/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
