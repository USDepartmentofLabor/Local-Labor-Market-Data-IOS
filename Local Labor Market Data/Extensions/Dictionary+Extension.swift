//
//  Dictionary+Extension.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 8/11/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

public func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]?) -> [Key: Value] {
    if let rhs = rhs {
        return lhs.merging(rhs) { $1 }
    }

    return lhs
}
