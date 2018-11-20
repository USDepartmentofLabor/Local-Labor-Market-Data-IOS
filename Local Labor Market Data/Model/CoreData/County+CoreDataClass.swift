//
//  County+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(County)
public class County: Area {
    
    public class func getAreas(context: NSManagedObjectContext, forText searchText: String? = nil) -> [County]? {
        let results: [County]?
        
        let fetchRequest: NSFetchRequest<County> = County.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let searchText = searchText, !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "title BEGINSWITH[c] %@", searchText)
            fetchRequest.predicate = searchPredicate
        }
        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            results = nil
        }
        
        return results
    }

    public class func getAreas(context: NSManagedObjectContext, forCodes codes: [String]? = nil) -> [County]? {
        guard let codes = codes else { return nil }
        
        let results: [County]?
        
        let fetchRequest: NSFetchRequest<County> = County.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "code IN %@", codes)
        fetchRequest.returnsDistinctResults = true
        
        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            results = nil
        }
        
        return results
    }

    class func counties(context: NSManagedObjectContext, forZipCodes zipCodes: [String]) -> [County]? {
        // Get Counties belonging to those ZipCodes
        let zipCounties = ZipCountyMap.fetchResults(context: context, forZipCodes: zipCodes)
        let countyCodes = zipCounties?.compactMap {$0.countyCode}.removingDuplicates()
        return County.getAreas(context: context, forCodes: countyCodes)
    }
    
    class func counties(context: NSManagedObjectContext, forZipCode zipCode: String) -> [County]? {
        let zipCounties = ZipCountyMap.fetchResults(context: context, forZipCode: zipCode)
        let countyCodes = zipCounties?.compactMap {$0.countyCode}.removingDuplicates()
        return County.getAreas(context: context, forCodes: countyCodes)
    }
}

// MARK: State
extension County {
    // County is in one state, First 2 digits of County Code is state Code
    func getState() -> State? {
        guard let code = code, let context = managedObjectContext else { return nil }
        
        let stateCode = String(code.prefix(2))
        return State.getState(context: context, forStateCode: stateCode)
    }
    
    class func counties(context: NSManagedObjectContext, forStateCode stateCode: String) -> [County]? {
        // Get Counties belonging to the state Code
        let results: [County]?
        
        let fetchRequest: NSFetchRequest<County> = County.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let searchPredicate = NSPredicate(format: "code BEGINSWITH[c] %@", stateCode)
        fetchRequest.predicate = searchPredicate
        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            results = nil
        }
        
        return results
    }
    

}

// MARK: Metro
extension County {
    // A County can be in multiple Metro areas
    func getMetros() -> [Metro]? {
        //Use CBSA-County mapping
        guard let areaCode = code, let context = managedObjectContext else { return nil }
        let cbsaCodes = CbsaCountyMap.getCbsaCodes(context: context, fromCountyCode: areaCode)
        
        if let cbsaCodes = cbsaCodes {
            return Metro.getAreas(context: context, forAreaCodes: cbsaCodes) as? [Metro]
        }
        
        return nil
    }
    
}
