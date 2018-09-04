//
//  NSManagedObject+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/2/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    convenience init(context: NSManagedObjectContext) {
        let entityName = type(of: self).entityName()
        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        self.init(entity: entityDescription, insertInto: context)
    }
    
    class public func entityName() -> String {
        let className = NSStringFromClass(self)
        return className.components(separatedBy: ".").last!
    }
    
    @nonobjc public class func deleteAll(managedContext: NSManagedObjectContext)  {
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: self.fetchRequest())
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch {
            print ("There was an error")
        }

    }

    public class func fetchAll(managedContext:NSManagedObjectContext) -> [NSManagedObject]? {
        let fetch = self.fetchRequest()
        do {
            let objects = try managedContext.fetch(fetch)
            return objects as? [NSManagedObject]
            
        } catch let error {
            print(error)
        }
        
        return nil
    }
}

//convenience init(managedObjectContext: NSManagedObjectContext) {
//    let entityName = self.dynamicType.entityName()
//    let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)!
//    self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
//}
