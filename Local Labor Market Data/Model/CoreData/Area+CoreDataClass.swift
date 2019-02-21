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
    
    class func getAreas(context: NSManagedObjectContext, forAreaCodes areaCodes: [String]) -> [Area]? {
        let results: [Area]?
        
        let fetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "code IN %@", areaCodes)
        fetchRequest.returnsDistinctResults = true
        
        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            results = nil
        }
        
        return results?.sorted()
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
    
    var accessibilityStr: String? {
        var accessibleStr = ""
        let separators = CharacterSet(charactersIn: " ,-")
        let components = title?.components(separatedBy: separators)
        components?.forEach({ (str) in
            if str.count == 2 {
               accessibleStr += State.stateName(fromCode: str) ?? str
            }
            else {
                accessibleStr += str
            }
            accessibleStr += ","
        })
        return accessibleStr
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

extension Area {
    var displayType: String {
        get {
            var type = ""
            if self is National {
                type = "National"
            }
            else if self is Metro {
                type = "Metro"
            }
            if self is State {
                type = "State"
            }
            if self is County {
                type = "County"
            }

            return type
        }
    }
}
