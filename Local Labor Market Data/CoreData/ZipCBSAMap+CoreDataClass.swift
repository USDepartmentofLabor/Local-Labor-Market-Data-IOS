//
//  ZipCBSAMap+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/18/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ZipCBSAMap)
public class ZipCBSAMap: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NSDictionary> {
        return NSFetchRequest<NSDictionary>(entityName: ZipCBSAMap.entityName())
    }
    
    public class func metro(context: NSManagedObjectContext, forZipCode code: String) -> [Metro]? {
        var results: [Metro]?
        let propertyKey = "metro"
        
        let fetchRequest: NSFetchRequest<NSDictionary> = ZipCBSAMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zipCode BEGINSWITH[c] %@", code)
        fetchRequest.resultType = .dictionaryResultType;
        fetchRequest.propertiesToFetch = [propertyKey]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            
            results = fetchedResults.compactMap { (result) -> Metro? in
                var metroArea: Metro?
                if let objectId = result.object(forKey: propertyKey) as? NSManagedObjectID {
                    metroArea = context.object(with: objectId) as? Metro
                }
                
                return metroArea
            }

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return results?.sorted()
    }

    
    public class func fetchResults(context: NSManagedObjectContext, forZipCode code: String) -> [ZipCBSAMap]? {
        var fetchResults: [ZipCBSAMap]?
        
        let fetchRequest: NSFetchRequest<ZipCBSAMap> = ZipCBSAMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zipCode BEGINSWITH[c] %@", code)
        do {
            fetchResults = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchResults
    }

    public class func fetchResults(context: NSManagedObjectContext, forCBSACode code: String) -> [ZipCBSAMap]? {
        var fetchResults: [ZipCBSAMap]?
        
        let fetchRequest: NSFetchRequest<ZipCBSAMap> = ZipCBSAMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cbsaCode == %@", code)
        
        do {
            fetchResults = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchResults
    }
    
    public class func metros(context: NSManagedObjectContext, forZipCodes codes: [String]) -> [Metro]? {
        var results: [Metro]?
        
        let propertyTofetch = "metro"
        let fetchRequest: NSFetchRequest<NSDictionary> = ZipCBSAMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "zipCode IN %@", codes)
        fetchRequest.resultType = .dictionaryResultType;
        fetchRequest.propertiesToFetch = [propertyTofetch]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            
            for fetchedResult in fetchedResults {
                if let objectId = fetchedResult.object(forKey: propertyTofetch) as? NSManagedObjectID,
                    let metro = context.object(with: objectId) as? Metro {
                    if results == nil {
                        results = []
                    }
                    results?.append(metro)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return results?.sorted()
    }

}
