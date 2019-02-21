//
//  Item+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
    class func getSuperParents<T: Item>(context: NSManagedObjectContext) -> [T]?
    {
        let results: [T]?
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parent == nil")
        let sortDescriptor = NSSortDescriptor(key: "code", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.entity = self.entity()
        do {
            results = try context.fetch(fetchRequest) as? [T]
        } catch let error as NSError {
            print("context.fetch error in getWholeEntity(): " + error.debugDescription)
            results = nil
        }
        
        return results?.sorted()
    }
    
    class func getItem<T: Item>(context: NSManagedObjectContext, code: String) -> T? {
        let results: [T]?

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "code == %@", code)
        fetchRequest.entity = self.entity()
        do {
            results = try context.fetch(fetchRequest) as? [T]
        } catch let error as NSError {
            print("context.fetch error in getWholeEntity(): " + error.debugDescription)
            results = nil
        }
        
        return results?.first
    }
    
    // Sorted SubItems
    func subItems() -> [Item]? {
        return (children?.allObjects as? [Item])?.sorted()
    }
    
    func getLeafChildren() -> [Item]? {
        guard let children = children else { return nil }

        var results = [Item]()
        for case let item as Item in children {
            // If this item has no children then it is leaf item
            if item.isLeaf {
                results.append(item)
            }
            else if let leaftChildren = item.getLeafChildren() {
                results.append(contentsOf: leaftChildren)
            }
        }
        
        return results.sorted()
    }
    
    var isLeaf: Bool {
        var isLeaf = true
        if let children = children, children.count > 0 {
            isLeaf = false
        }
        return isLeaf
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
