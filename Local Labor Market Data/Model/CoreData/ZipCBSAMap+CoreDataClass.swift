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
}
