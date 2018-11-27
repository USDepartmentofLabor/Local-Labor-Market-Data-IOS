//
//  Industry+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/26/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Industry)
public class Industry: NSManagedObject {
    
    // Sorted SubIndustries
    func subIndustries() -> [Industry]? {
        return (subIndustry?.allObjects as? [Industry])?.sorted()
    }
}

extension Industry: Comparable {
    static func == (lhs: Industry, rhs: Industry) -> Bool {
        return lhs.code == rhs.code
    }
    
    public static func < (lhs: Industry, rhs: Industry) -> Bool {
        return (lhs.code ?? "") < (rhs.code ?? "")
    }
}
