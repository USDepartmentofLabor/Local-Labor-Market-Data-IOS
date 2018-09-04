//
//  Area+CoreDataClass.swiftArea+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/23/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Area)
public class Area: NSManagedObject {
    
    class func getAreas(context: NSManagedObjectContext, forText searchText: String? = nil) -> [Area]? {
        let results: [Area]?
        
        let fetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
        if let searchText = searchText, !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "title BEGINSWITH[c] %@", searchText)
            if let predicate = fetchRequest.predicate {
                let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, searchPredicate])
                fetchRequest.predicate = andPredicate
            }
        }
        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            results = nil
        }
        
        return results
    }
    
    var areaType: String {
        get {
            if self is Metro {
                return "Metro Area"
            }
            else if self is State {
                return "State"
            }
            else if self is County {
                return "County"
            }
        
            return "National"
        }
    }
}

extension Area: Comparable {
    static func == (lhs: Area, rhs: Area) -> Bool {
        return lhs.title == rhs.title
    }
    
    public static func < (lhs: Area, rhs: Area) -> Bool {
        return (lhs.title ?? "") < (rhs.title ?? "")
        
    }
}
