//
//  CodeDataManager.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/2/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import CoreData
import os.log

class CoreDataManager {
    
    private static var sharedCoreDataManager: CoreDataManager = {
        preloadDBData()
        
        let coreDataManager = CoreDataManager()
        return coreDataManager
    }()
    
    
    // MARK: - Accessors
    class func shared() -> CoreDataManager {
        return sharedCoreDataManager
    }

    private init() {
//        os_log("Documents Directory: %@", FileManager.default.urls(for: .documentationDirectory, in: .userDomainMask).description)
    }
    
    lazy var model: NSManagedObjectModel = {
        return persistentContainer.managedObjectModel
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Local_Labor_Market_Data")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    lazy var viewManagedContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = viewManagedContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    class func preloadDBData() {
        if !FileManager.default.fileExists(atPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/Local_Labor_Market_Data.sqlite") {

            guard let sqlitePath = Bundle.main.path(forResource: "Local_Labor_Market_Data", ofType: "sqlite") else { return }
            let sqlitePath_shm = Bundle.main.path(forResource: "Local_Labor_Market_Data", ofType: "sqlite-shm")
            let sqlitePath_wal = Bundle.main.path(forResource: "Local_Labor_Market_Data", ofType: "sqlite-wal")
            
            let URL1 = URL(fileURLWithPath: sqlitePath)
            let URL2 = URL(fileURLWithPath: sqlitePath_shm!)
            let URL3 = URL(fileURLWithPath: sqlitePath_wal!)
            let URL4 = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/Local_Labor_Market_Data.sqlite")
            let URL5 = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/Local_Labor_Market_Data.sqlite-shm")
            let URL6 = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/Local_Labor_Market_Data.sqlite-wal")
            
            // Copy 3 files
            do {
                try FileManager.default.copyItem(at: URL1, to: URL4)
                try FileManager.default.copyItem(at: URL2, to: URL5)
                try FileManager.default.copyItem(at: URL3, to: URL6)
                
            } catch {
                print("=======================")
                print("ERROR IN COPY OPERATION")
                print("=======================")
            }
        }
    }

}
