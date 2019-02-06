//
//  LoadDataUtil.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/26/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import CoreData

class LoadDataUtil {
    
    private static let MSATitle = "Metropolitan Statistical Area"
    private static let NECTATitle = "Metropolitan NECTA"
    private static let ZIP_COUNTY_MAP = "ZIP_COUNTY"
    private static let ZIP_NECTA_MAP = "ZIP_NECTA"
    private static let ZIP_CBSA_MAP = "ZIP_CBSA"
    private static let CBSA_COUNTY_MAP = "CBSA_COUNTY"
    private static let NECTA_CBSA_COUNTY_MAP = "NECTACBSA_COUNTY"
    
    var managedObjectContext: NSManagedObjectContext
    
    init(managedContext: NSManagedObjectContext) {
        self.managedObjectContext = managedContext
    }
    // MARK: Load/Parse Files
    class func loadDataResource(resourceName: String, withExtension ext: String = "csv",
                                subdirectory subpath: String? = nil) -> [[String]]? {
        guard let fileContents = loadDataFile(resourceName: resourceName, withExtension: ext, subdirectory: subpath) else {return nil}
        if ext ==  "txt" {
            return parseTXT(dataStr: fileContents)
        }
        
        return parseCSV(dataStr: fileContents)
    }
    
    fileprivate class func loadDataFile(resourceName: String, withExtension ext: String, subdirectory subpath: String?) -> String? {
        
        guard let resourceURL = Bundle.main.url(forResource: resourceName, withExtension:ext, subdirectory: subpath)
            else { return nil }
        
        do {
            var contents = try String(contentsOf: resourceURL, encoding: .utf8)
            //                cleanFile = cleanFile.stringByReplacingOccurrencesOfString("\r", withString: "\n")
            //                cleanFile = cleanFile.stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
            
            contents = contents.replacingOccurrences(of: "\r\n", with: "\n")
            contents = contents.replacingOccurrences(of: "\"", with: "")
            return contents
        }
        catch (let error) {
            print(error.localizedDescription)
            return nil
        }
    }
    
    fileprivate class func parseTXT(dataStr: String) -> [[String]] {
        return parse(dataStr: dataStr, seperator: "\t")
    }
    
    fileprivate class func parseCSV(dataStr: String) -> [[String]] {
        return parse(dataStr: dataStr, seperator: ",")
    }
    
    fileprivate class func parse(dataStr: String, seperator: String) -> [[String]] {
        let rows = dataStr.components(separatedBy: .newlines)
        
        var result = [[String]]()
        for row in rows {
            let columns = row.components(separatedBy: seperator)
            result.append(columns)
        }
        
        return result
    }

}

// MARK: Load ZIP->County, ZIP_Metro mapping, MSA_COUNTY mapping
extension LoadDataUtil {
    // MARK: ZIP County Mapping
    func loadZipCountyMap() {
        guard let items = LoadDataUtil.loadDataResource(resourceName: LoadDataUtil.ZIP_COUNTY_MAP) else { return }
        
        ZipCountyMap.deleteAll(managedContext: managedObjectContext)
        //        ZipCountyMap.deleteRecords(context: managedObjectContext)
        for (index, item) in items.enumerated() {
            // Ignore header
            if index < 1 || item.count < 2 {
                continue
            }
            let ziptoCounty = ZipCountyMap(context: managedObjectContext)
            
            ziptoCounty.setValue(item[0], forKey: "zipCode")
            ziptoCounty.setValue(item[1], forKey: "countyCode")
        }
        
        do {
            try managedObjectContext.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: Zip Metro Mapping
    func loadZipNectaMap() {
        guard let items = LoadDataUtil.loadDataResource(resourceName: LoadDataUtil.ZIP_NECTA_MAP)
            else { return }
        
        ZipCBSAMap.deleteAll(managedContext: managedObjectContext)
        for (index, item) in items.enumerated() {
            // Ignore header
            if index < 1 || item.count < 2 {
                continue
            }
            let ziptoCBSA = ZipCBSAMap(context: managedObjectContext)
            
            ziptoCBSA.setValue(item[0], forKey: "zipCode")
            ziptoCBSA.setValue(item[1], forKey: "cbsaCode")
            ziptoCBSA.setValue(true, forKey: "isNecta")
        }
        
        do {
            try managedObjectContext.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    // MARK: Zip Metro Mapping
    func loadZipCBSAMap() {
        guard let items = LoadDataUtil.loadDataResource(resourceName: LoadDataUtil.ZIP_CBSA_MAP)
            else { return }
        
        for (index, item) in items.enumerated() {
            // Ignore header
            if index < 1 || item.count < 2 {
                continue
            }
            let ziptoCBSA = ZipCBSAMap(context: managedObjectContext)
            
            ziptoCBSA.setValue(item[0], forKey: "zipCode")
            ziptoCBSA.setValue(item[1], forKey: "cbsaCode")
        }
        
        do {
            try managedObjectContext.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: ZIP County Mapping
    func loadMSACountyMap() {
        guard let items = LoadDataUtil.loadDataResource(resourceName: LoadDataUtil.CBSA_COUNTY_MAP,
                                                        withExtension: "txt")
            else { return }

        CbsaCountyMap.deleteAll(managedContext: managedObjectContext)
        for (index, item) in items.enumerated() {
            // Ignore header
            if index < 1 || item.count < 5 {
                continue
            }
            let cbsaCounty = CbsaCountyMap(context: managedObjectContext)
            let countyCode = item[4]+item[5]
            cbsaCounty.setValue(item[1], forKey: "cbsaCode")
            cbsaCounty.setValue(countyCode, forKey: "countyCode")
        }
        
        // necta
        guard let nectaItems = LoadDataUtil.loadDataResource(resourceName: LoadDataUtil.NECTA_CBSA_COUNTY_MAP,
                                                        withExtension: "txt")
            else { return }
        
        for (index, item) in nectaItems.enumerated() {
            // Ignore header
            if index < 1 || item.count < 5 {
                continue
            }
            let cbsaCounty = CbsaCountyMap(context: managedObjectContext)
            let countyCode = item[4]+item[5]
            cbsaCounty.setValue(item[1], forKey: "cbsaCode")
            cbsaCounty.setValue(countyCode, forKey: "countyCode")
        }
        
    }
    
}


// MARK: Load LAUS Area
extension LoadDataUtil {
    // Load All LAUS Lookup Data Files
    // https://download.bls.gov/pub/time.series/la/la.area
    func loadLAUSData() {
        guard let items = LoadDataUtil.loadDataResource(resourceName: "la.area",
                                           withExtension: "txt", subdirectory: "LAUS")
            else { return }
        
        Area.deleteAll(managedContext: managedObjectContext)
        LAUS_Area.deleteAll(managedContext: managedObjectContext)
        for (index, item) in items.enumerated() {
            // Ignore header
            if index < 1 {
                continue
            }
            
            // First item has Area Type - https://download.bls.gov/pub/time.series/la/la.area_type
            // A - State
            // B - Metropolitan Area
            // F - County and Equivalents
            let areaType = item[0]
            
            // Save only State, Metropolitan Area and County
            if areaType == "A" || areaType == "B" || areaType == "F" {
                
                let type = item[0]
                let code =  item[1]
                var title = item[2]
                
                let start = code.index(code.startIndex, offsetBy: 2)
                let end = code.index(start, offsetBy: 2)
                let stateCode = String(code[start..<end])
                
                let area: Area?
                if type == "A" { // get the State Code
                    let state = State(context: managedObjectContext)
                    state.code = stateCode
                    state.title = title
                    area = state
                }
                else if type == "B",
                    (title.contains(LoadDataUtil.MSATitle) ||
                        title.contains(LoadDataUtil.NECTATitle)) { // Set the Links to ZipCBSA Table
                    // Get the CBSA/Metropolitan Code
                    // Code is of Format MT + StateCode + CBSACode
                    let metro = Metro(context: managedObjectContext)
                    let start = code.index(code.startIndex, offsetBy: 4)
                    let end = code.index(start, offsetBy: 5)
                    let cbsaCode = String(code[start..<end])

                    metro.code = cbsaCode
                    metro.stateCode = stateCode
                    
                    title = title.replacingOccurrences(of: LoadDataUtil.MSATitle, with: "")
                    title = title.replacingOccurrences(of: LoadDataUtil.NECTATitle, with: "").trimmingCharacters(in: .whitespaces)
                    metro.title = title
                    area = metro
                }
                else if type == "F" {
                    let county = County(context: managedObjectContext)
                    // Get the county Code
                    let start = code.index(code.startIndex, offsetBy: 2)
                    let end = code.index(start, offsetBy: 5)
                    let countyCode = String(code[start..<end])
                    
                    county.code = countyCode
                    county.title = title
                    area = county
                }
                else {
                    area = nil
                }
                
                let lausArea = LAUS_Area(context: managedObjectContext)
                lausArea.areaType = type
                lausArea.areaCode = code
                lausArea.area = area
            }
        }
        
        // Add National Data
        let national = National(context: managedObjectContext)
        national.code = "00000"
        national.title = "National"
        
        do {
            try managedObjectContext.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}


// MARK: Load CES Industry
extension LoadDataUtil {
    private static let CE_INDUSTRY_MAP = "ce.industry"
    private static let SM_INDUSTRY_MAP = "sm.industry"
    
    func loadCESIndustries() {
        Industry.deleteAll(managedContext: managedObjectContext)
        loadIndustry(resourceName: LoadDataUtil.CE_INDUSTRY_MAP, withExt: "txt", type: CE_Industry.self)
        loadIndustry(resourceName: LoadDataUtil.SM_INDUSTRY_MAP, withExt: "txt", type: SM_Industry.self)
    }
    
    private func loadIndustry<T: Industry>(resourceName: String, withExt ext: String, type: T.Type) {
        guard let industryItems =
            LoadDataUtil.loadDataResource(resourceName: resourceName,
                                          withExtension: ext)
            else { return }

        var currentIndex = 2
        while currentIndex < industryItems.count-1 {
            let industryItem = industryItems[currentIndex]
            if let supersector = NSEntityDescription.insertNewObject(forEntityName: type.entityName(),
                                                                     into: managedObjectContext) as? T {
                
                let code = industryItem[0]
                let title: String
                var parentCode: String = ""
                
                if resourceName == LoadDataUtil.CE_INDUSTRY_MAP {
                    title = industryItem[3]
                    if industryItem.count > 7 {
                        parentCode = industryItem[7]
                    }
                }
                else {
                    title = industryItem[1]
                    if industryItem.count > 2 {
                        parentCode = industryItem[2]
                    }
                }
            supersector.code = code
            supersector.title = title
            if !parentCode.isEmpty {
                let parent = T.getItem(context: managedObjectContext, code: parentCode)
                supersector.parent = parent
            }
            else  {
                supersector.supersector = true
            }
                
            currentIndex = currentIndex+1
            loadSubIndustry(parent: supersector, industryItems: industryItems,
                            currentIndex: &currentIndex)
            }
        }
        
        do {
            try managedObjectContext.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func loadSubIndustry<T: Industry>(parent: T, industryItems: [[String]], currentIndex: inout Int) {
        guard let code = parent.code else { return }
        
        guard currentIndex < industryItems.count - 1 else { return }
        
        var parentCode: String
        // If this is a supersector then use 2 digit code
//        if parent.parent == nil {
//            parentCode = String(code.prefix(2))
//        }
//        else {
           parentCode = code.trailingTrim(CharacterSet(charactersIn: "0"))
//        }
        
        if parentCode.count == 1 {
            parentCode.append("0")
        }

        while currentIndex < industryItems.count - 1 &&
            industryItems[currentIndex][0].hasPrefix(parentCode) {
            if let obj = NSEntityDescription.insertNewObject(forEntityName: T.entityName(), into: managedObjectContext) as? T {
                
                let code = industryItems[currentIndex][0]
                let title: String
                if parent is CE_Industry {
                    title = industryItems[currentIndex][3]
                }
                else {
                    title = industryItems[currentIndex][1]
                }
                
                obj.code = code
                obj.title = title
                obj.parent = parent
                currentIndex = currentIndex+1
                loadSubIndustry(parent: obj, industryItems: industryItems, currentIndex: &currentIndex)
            }
        }        
    }
}

// MARK: Load OES Occupation
extension LoadDataUtil {
    static let OE_OCCUPATION_MAP = "oe.occupation"
    
    func loadOESOccupations() {
        OE_Occupation.deleteAll(managedContext: managedObjectContext)
        loadOccupations(resourceName: LoadDataUtil.OE_OCCUPATION_MAP, withExt: "txt")
    }
    
    private func loadOccupations(resourceName: String, withExt ext: String) {
        guard let occupationItems =
            LoadDataUtil.loadDataResource(resourceName: resourceName,
                                          withExtension: ext)
            else { return }

        var currentIndex = 2
        while currentIndex < occupationItems.count {
            loadOccupation(occupationItems: occupationItems, currentIndex: &currentIndex)
        }
        
        do {
            try managedObjectContext.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func loadOccupation(occupationItems: [[String]], parent: OE_Occupation? = nil,
                                currentIndex: inout Int) {
        
        let occupationItem = occupationItems[currentIndex]
        
        currentIndex = currentIndex+1
        guard occupationItem.count > 1 else { return }

        
        let occupation = OE_Occupation(context: managedObjectContext)
        occupation.code = occupationItem[0]
        occupation.title = occupationItem[1]
        occupation.parent = parent
        
        // Load Children
        let parentCode = occupation.code?.trailingTrim(CharacterSet(charactersIn: "0")) ?? ""
        while occupationItems[currentIndex][0].hasPrefix(parentCode) {
            loadOccupation(occupationItems: occupationItems, parent: occupation, currentIndex: &currentIndex)
        }
    }
}


// MARK: Load QCEW Industry
extension LoadDataUtil {
    static let QCEW_INDUSTRY_MAP = "industry_titles"

    func loadQCEWIndustries() {
        QCEW_Industry.deleteAll(managedContext: managedObjectContext)
        loadIndustry(resourceName: LoadDataUtil.QCEW_INDUSTRY_MAP, withExt: "csv", type: QCEW_Industry.self)
    }
}
