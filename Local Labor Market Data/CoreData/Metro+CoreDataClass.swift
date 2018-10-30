//
//  Metro+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Metro)
public class Metro: Area {
    
    public class func getAreas(context: NSManagedObjectContext, forText searchText: String? = nil) -> [Metro]? {
        let results: [Metro]?
        
        let fetchRequest: NSFetchRequest<Metro> = Metro.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let searchText = searchText, !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@", searchText)
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

    class func search(context: NSManagedObjectContext, forZipCode zipCode: String) -> [Metro]? {
        return ZipCBSAMap.metro(context: context, forZipCode: zipCode)
    }
    
    /*
    
    // Get All ZipCodes that are part of this Metro Area
    func getZipCodes() -> [String]? {
        guard let zipCbsaMaps = zip else { return nil }
        
        let zipCodes = zipCbsaMaps.compactMap({ (item) -> String? in
            if let zipCBSAMap = item as? ZipCBSAMap {
                return zipCBSAMap.zipCode
            }
            return nil
        })
        
        return zipCodes
    }

    
    // To get County Codes from Metro Area
    func getCountyCodes() -> [String]? {
        guard let zipCodes = getZipCodes(), let context = managedObjectContext else { return nil }
        return ZipCountyMap.countyCodes(context: context, forZipCodes: zipCodes)
    }
    */
    
    
    // Get the States, This Metro area is spanned in
    func getStates() -> [State]? {
        
        guard let areaCode = code, let context = managedObjectContext,
            let countyCodes = CbsaCountyMap.getCountyCodes(context: context, fromCbsaCode: areaCode)
                else { return nil}
        
        // From county Code, extract State Code - First 2 digits
        let stateCodes = countyCodes.compactMap{
            return String($0.prefix(2))
        }
        
        return State.getStates(context: context, forStateCodes: stateCodes.removingDuplicates())
    }
    
    // To get Counties that are part of this Metro Area
    func getCounties() -> [County]? {
        
        guard let areaCode = code, let context = managedObjectContext,
            let countyCodes = CbsaCountyMap.getCountyCodes(context: context, fromCbsaCode: areaCode)
                else { return nil}
        
        return County.getAreas(context: context, forAreaCodes: countyCodes) as? [County]
    }
}


