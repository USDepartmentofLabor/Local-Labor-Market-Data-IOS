//
//  State+CoreDataClass.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 7/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(State)
public class State: Area {

    public class func getAreas(context: NSManagedObjectContext, forText searchText: String? = nil) -> [State]? {
        let results: [State]?
        
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
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

    
    // Get CountyCodes from ZipCountyMap, County Codes first 2 digits have state Code
    class func search(context: NSManagedObjectContext, forZipCode zipCode: String) -> [State]? {
        let countyCodes = ZipCountyMap.countyCodes(context: context, forZipCode: zipCode)
        
        let results = countyCodes?.compactMap{ (countyCode) -> State? in
            let stateCode = String(countyCode.prefix(2))
            return self.getState(context: context, forStateCode: stateCode)
        }
        
        if let results = results?.removingDuplicates() {
            return results.sorted()
        }
        
        return nil
    }
    
    class func getState(context: NSManagedObjectContext, forStateCode stateCode: String) -> State? {
        let results: [State]?
        
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let searchPredicate = NSPredicate(format: "code == %@", stateCode)
        fetchRequest.predicate = searchPredicate
        
        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            results = nil
        }
        
        if let results = results, results.count > 0 {
            return results[0]
        }
        
        return nil
    }
    
    class func getStates(context: NSManagedObjectContext, forStateCodes stateCodes: [String]) -> [State]? {
        let results: [State]?
        
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let searchPredicate = NSPredicate(format: "code IN %@", stateCodes)
        fetchRequest.predicate = searchPredicate
        fetchRequest.returnsDistinctResults = true
        
        do {
            results = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            results = nil
        }
        
        return results?.sorted()
    }
    
    // Get All ZipCodes that are part of this State
    func getZipCodes() -> [String]? {
        guard let counties = getCounties() else {return nil}

        let zipCodes = counties.compactMap{ $0.getZipCodes() }.flatMap{$0}
        return zipCodes.removingDuplicates()
    }

    class func lausStateCode(stateCode: String) -> String {
        let code = "ST" + stateCode
        
        return code.rightPadding(toLength: 15, withPad: "0")
    }

}

// MARK: Counties
extension State {
    // Get Counties for StateCode
    func getCounties() -> [County]? {
        guard let stateCode = code, let context = managedObjectContext else { return nil }
        
        return County.counties(context: context, forStateCode: stateCode)
    }
}

// MARK: Metro
extension State {
//    func getMetros() -> [Metro]? {
//
//        guard let counties = getCounties()  else { return nil}
//        let zipCodes1 = counties.compactMap { $0.getZipCodes()}
//
//        let zipCodes = zipCodes1.flatMap{$0}
//        let metros1 = counties.compactMap{ $0.getMetros()}
//
//        let metros = metros1.flatMap{$0}
//
//        return metros.removingDuplicates().sorted()
//
//    }

    func getMetros() -> [Metro]? {
        guard let context = managedObjectContext else { return nil }
        guard let counties = getCounties()  else { return nil}
        
        let zipCodes = County.getZipCodes(context: context, countyCodes: counties.compactMap{$0.code})
        return ZipCBSAMap.metros(context: context, forZipCodes: zipCodes!)
        
    }
}

extension State {
    static let stateName: [String: String] = ["AL": "Alabama",
                                              "AK":"alaska",
                                              "AZ":"arizona",
                                              "AR":"arkansas",
                                              "CA":"california",
                                              "CO":"colorado",
                                              "CT":"connecticut",
                                              "DE":"delaware",
                                              "DC":"district of columbia",
                                              "FL":"florida",
                                              "GA":"georgia",
                                              "HI":"hawaii",
                                              "ID":"idaho",
                                              "IL":"illinois",
                                              "IN":"indiana",
                                              "IA":"iowa",
                                              "KS":"kansas",
                                              "KY":"kentucky",
                                              "LA":"louisiana",
                                              "ME":"maine",
                                              "MD":"maryland",
                                              "MA":"massachusetts",
                                              "MI":"michigan",
                                              "MN":"minnesota",
                                              "MS":"mississippi",
                                              "MO":"missouri",
                                              "MT":"montana",
                                              "NE":"nebraska",
                                              "NV":"nevada",
                                              "NH":"new hampshire",
                                              "NJ":"new jersey",
                                              "NM":"new mexico",
                                              "NY":"new york",
                                              "NC":"north carolina",
                                              "ND":"north dakota",
                                              "OH":"ohio",
                                              "OK":"oklahoma",
                                              "OR":"oregon",
                                              "PA":"pennsylvania",
                                              "RI":"rhode island",
                                              "SC":"south carolina",
                                              "SD":"south dakota",
                                              "TN":"tennessee",
                                              "TX":"texas",
                                              "UT":"utah",
                                              "VT":"vermont",
                                              "VA":"virginia",
                                              "WA":"washington",
                                              "WV":"west virginia",
                                              "WI":"wisconsin",
                                              "WY":"wyoming"]
    
    static func stateName(fromCode stateCode: String) -> String? {
        return stateName[stateCode]
    }
}
