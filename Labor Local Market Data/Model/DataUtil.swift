//
//  DataUtil.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/2/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import CoreData


enum AreaType: String {
    case national = "N"
    case state = "S"
    case metro = "M"
    case county = "C"
    
    var title: String {
        get {
            let titleStr:String
            
            switch self {
            case .national:
                titleStr = "National"
            case .metro:
                titleStr = "Metro Area"
            case .state:
                titleStr = "State"
            case .county:
                titleStr = "County"
            }
            
            return titleStr
        }
    }
}

class DataUtil {
    
    var managedObjectContext: NSManagedObjectContext
    
    init(managedContext: NSManagedObjectContext) {
        self.managedObjectContext = managedContext
    }
    
    // MARK: Seacrch wih String
    func searchArea(forArea type: AreaType, forText searchText: String? = nil) -> [Area]? {
        if let searchText = searchText, searchText.isNumber() {
            return searchArea(forArea:type, forZipCode:searchText)
        }
        
        let results: [Area]?
        switch type {
        case .metro:
            let metroResults: [Metro]? = Metro.getAreas(context: managedObjectContext, forText: searchText)
            results = metroResults
        case .state:
            let stateResults: [State]? = State.getAreas(context: managedObjectContext, forText: searchText)
            results = stateResults
        case .county:
            let countyResults: [County]?  = County.getAreas(context: managedObjectContext, forText: searchText)
            results = countyResults
        default:
            results = Area.getAreas(context: managedObjectContext, forText: "National")
        }
        return results
    }

    func nationalArea() -> National? {
        return National.fetchAll(managedContext: managedObjectContext)?.first as? National
    }
    
    // MARK: Search With ZipCode
    func searchArea(forArea type: AreaType, forZipCode zipCode: String) -> [Area]? {
        let searchResults: [Area]?
        
        switch type {
        case .metro:
            searchResults = searchMetroAreas(forZipCode: zipCode)
        case .state:
            searchResults = searchState(forZipCode: zipCode)
        case .county:
            searchResults = searchCounties(forZipCode: zipCode)
        default:
            searchResults = nil
        }
        return searchResults
    }
    
    func searchMetroAreas(forZipCode zipCode: String) -> [Metro]? {
        return Metro.search(context: managedObjectContext, forZipCode: zipCode)
    }
    
    func searchState(forZipCode zipCode: String) -> [State]? {
        return State.search(context: managedObjectContext, forZipCode: zipCode)
    }
    
    
    func searchCounties(forZipCode zipCode: String) -> [Area]? {
        // if zipCode is null, return all Metropolitan Area
        return County.counties(context: managedObjectContext, forZipCode: zipCode)
    }
}
