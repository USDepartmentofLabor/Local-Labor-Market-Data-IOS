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

@objc(Industry)
public class Industry: Item {
    
    class func getSupersectors(context: NSManagedObjectContext) -> [Industry]? {
        let results: [Industry]?
        
        let fetchRequest: NSFetchRequest<Industry> = Industry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "supersector = true")
        
        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            results = nil
        }
        
//        return results?.sorted(by: { ($0.code ?? "") < ($1.code ?? "") })
        return results?.sorted()
    }
}


