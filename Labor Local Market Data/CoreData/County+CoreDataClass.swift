//
//  County+CoreDataClass.swift
//  Labor Local Data
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
    
    class func counties(context: NSManagedObjectContext, forZipCodes zipCodes: [String]) -> [County]? {
        // Get Counties belonging to those ZipCodes
        return ZipCountyMap.counties(context: context, forZipCodes: zipCodes)
    }
    
    class func counties(context: NSManagedObjectContext, forZipCode zipCode: String) -> [County]? {
        return ZipCountyMap.counties(context: context, forZipCode: zipCode)
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
        // Step 1 - Get Zip codes for this county
        guard let zipCodes = getZipCodes(), let context = managedObjectContext else { return nil }
        
        // Step2 - From ZipCodes, find the metro Areas these zip Codes are part of
        return ZipCBSAMap.metros(context: context, forZipCodes: zipCodes)
    }
    
    // Get All ZipCodes that are part of this County
    func getZipCodes() -> [String]? {
        guard let zipCountyMap = zip else { return nil }
        
        let zipCodes = zipCountyMap.compactMap({ (item) -> String? in
            if let zipCountyMap = item as? ZipCountyMap {
                return zipCountyMap.zipCode
            }
            return nil
        })
        
        return zipCodes
    }
    
    class func getZipCodes(context: NSManagedObjectContext, countyCodes: [String]) -> [String]? {
        var results: [String]?
        let propertyKey = "zipCode"
        
        let fetchRequest: NSFetchRequest<NSDictionary> = ZipCountyMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "countyCode IN %@", countyCodes)
        fetchRequest.resultType = .dictionaryResultType;
        fetchRequest.propertiesToFetch = [propertyKey]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            
            results = fetchedResults.map {$0.value(forKey: propertyKey)} as? [String]

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return results
    }
}
