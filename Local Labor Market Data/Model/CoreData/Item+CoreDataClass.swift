//
//  Item+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/26/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
    
    // Sorted SubItems
    func subItems() -> [Item]? {
        return (children?.allObjects as? [Item])?.sorted()
    }
}

extension Item: Comparable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.code == rhs.code
    }
    
    public static func < (lhs: Item, rhs: Item) -> Bool {
        return (lhs.code ?? "") < (rhs.code ?? "")
    }
}
