//
//  CE_Industry+CoreDataClass.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/16/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CE_Industry)
public class CE_Industry: Industry {
    
    class func getSupersectors(context: NSManagedObjectContext) -> [CE_Industry]? {
        let results: [CE_Industry]?
        
        let fetchRequest: NSFetchRequest<CE_Industry> = CE_Industry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "supersector = true")
        
        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            results = nil
        }
        
        return results?.sorted()
    }
}


