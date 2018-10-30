//
//  CbsaCountyMap+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 10/30/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CbsaCountyMap)
public class CbsaCountyMap: NSManagedObject {
    
    func fetchResults() -> [CbsaCountyMap]? {
        var fetchResults: [CbsaCountyMap]?
        
        do {
            fetchResults = try managedObjectContext?.fetch(CbsaCountyMap.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchResults
    }

    public class func getCbsaCodes(context: NSManagedObjectContext, fromCountyCode countyCode: String) -> [String]? {
        var fetchResults: [CbsaCountyMap]?
        
        let fetchRequest: NSFetchRequest<CbsaCountyMap> = CbsaCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "countyCode == %@", countyCode)
        
        do {
            fetchResults = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let cbsaCodes = fetchResults?.map { $0.cbsaCode } as? [String]
        return cbsaCodes?.removingDuplicates()
    }

    public class func getCbsaCodes(context: NSManagedObjectContext, fromCountyCodes countyCodes: [String]) -> [String]? {
        var fetchResults: [CbsaCountyMap]?
        
        let fetchRequest: NSFetchRequest<CbsaCountyMap> = CbsaCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "countyCode IN %@", countyCodes)
        
        do {
            fetchResults = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let cbsaCodes = fetchResults?.map { $0.cbsaCode } as? [String]
        return cbsaCodes?.removingDuplicates()
    }

    public class func getCountyCodes(context: NSManagedObjectContext, fromCbsaCode cbsaCode: String) -> [String]? {
        var fetchResults: [CbsaCountyMap]?
        
        let fetchRequest: NSFetchRequest<CbsaCountyMap> = CbsaCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cbsaCode == %@", cbsaCode)
        
        do {
            fetchResults = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let countyCodes = fetchResults?.map { $0.countyCode } as? [String]
        return countyCodes?.removingDuplicates()
    }
}
