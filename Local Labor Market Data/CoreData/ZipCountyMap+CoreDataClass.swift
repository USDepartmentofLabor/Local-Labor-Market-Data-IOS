//
//  ZipCountyMap+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/2/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ZipCountyMap)
public class ZipCountyMap: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NSDictionary> {
        return NSFetchRequest<NSDictionary>(entityName: ZipCountyMap.entityName())
    }
    

    func fetchResults() -> [ZipCountyMap]? {
        var fetchResults: [ZipCountyMap]?
        
        do {
            fetchResults = try managedObjectContext?.fetch(ZipCountyMap.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchResults
    }

    public class func fetchResults(context: NSManagedObjectContext, forCountyCode code: String) -> [ZipCountyMap]? {
        var fetchResults: [ZipCountyMap]?
        
        let fetchRequest: NSFetchRequest<ZipCountyMap> = ZipCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "countyCode == %@", code)
        
        do {
            fetchResults = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchResults
    }

    public class func fetchResults(context: NSManagedObjectContext, forZipCode code: String) -> [ZipCountyMap]? {
        var fetchResults: [ZipCountyMap]?
        
        let fetchRequest: NSFetchRequest<ZipCountyMap> = ZipCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zipCode == %@", code)
        
        do {
            fetchResults = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchResults
    }

    public class func counties(context: NSManagedObjectContext, forZipCode code: String) -> [County]? {
        var results: [County]?
        
        let propertyToFetch = "county"
        let fetchRequest: NSFetchRequest<NSDictionary> = ZipCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zipCode BEGINSWITH[c] %@", code)
        fetchRequest.resultType = .dictionaryResultType;
        fetchRequest.propertiesToFetch = [propertyToFetch]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            
            for fetchedResult in fetchedResults {
                if let objectId = fetchedResult.object(forKey: propertyToFetch) as? NSManagedObjectID,
                    let county = context.object(with: objectId) as? County {
                    if results == nil {
                        results = []
                    }
                    results?.append(county)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return results?.sorted()
    }

    public class func countyCodes(context: NSManagedObjectContext, forZipCode code: String) -> [String]? {
        var results: [String]?
        
        let fetchRequest: NSFetchRequest<NSDictionary> = ZipCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zipCode BEGINSWITH[c] %@", code)
        fetchRequest.resultType = .dictionaryResultType;
        fetchRequest.propertiesToFetch = ["countyCode"]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            results = fetchedResults.compactMap { $0.object(forKey: "countyCode")} as? [String]
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return results
    }

    public class func counties(context: NSManagedObjectContext, forZipCodes codes: [String]) -> [County]? {
        var results: [County]?
        
        let propertyTofetch = "county"
        let fetchRequest: NSFetchRequest<NSDictionary> = ZipCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zipCode IN %@", codes)
        fetchRequest.resultType = .dictionaryResultType;
        fetchRequest.propertiesToFetch = [propertyTofetch]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            
            for fetchedResult in fetchedResults {
                if let objectId = fetchedResult.object(forKey: propertyTofetch) as? NSManagedObjectID,
                    let county = context.object(with: objectId) as? County {
                    if results == nil {
                        results = []
                    }
                    results?.append(county)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return results?.sorted()
    }
    
    public class func countyCodes(context: NSManagedObjectContext, forZipCodes codes: [String]) -> [String]? {
        var results: [String]?
        
        let propertyTofetch = "countyCode"
        let fetchRequest: NSFetchRequest<NSDictionary> = ZipCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zipCode IN %@", codes)
        fetchRequest.resultType = .dictionaryResultType;
        fetchRequest.propertiesToFetch = [propertyTofetch]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            
            for fetchedResult in fetchedResults {
                if let countyCode = fetchedResult.object(forKey: propertyTofetch) as? String {
                    if results == nil {
                        results = []
                    }
                    results?.append(countyCode)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    
        return results
    }

}
