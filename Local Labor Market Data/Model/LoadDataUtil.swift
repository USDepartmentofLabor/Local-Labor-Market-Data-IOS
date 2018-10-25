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
    
    static let MSATitle = "Metropolitan Statistical Area"
    static let ZIP_COUNTY_MAP = "ZIP_COUNTY"
    static let ZIP_CBSA_MAP = "ZIP_CBSA"
    
    var managedObjectContext: NSManagedObjectContext
    
    init(managedContext: NSManagedObjectContext) {
        self.managedObjectContext = managedContext
    }
    
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
    func loadZipCBSAMap() {
//        guard let items = loadDataResource(resourceName: "zcta_cbsa_rel_10") else { return }
        guard let items = LoadDataUtil.loadDataResource(resourceName: LoadDataUtil.ZIP_CBSA_MAP) else { return }
        
        ZipCBSAMap.deleteAll(managedContext: managedObjectContext)
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
    
    // #MARK: QCEW
    // Load All QCEW Lookup Data Files
    func loadAllQCEWData() {
    }
    
    
    // MARK: LAUS
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
                let title = item[2]
                
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
                else if type == "B", title.contains(LoadDataUtil.MSATitle) { // Set the Links to ZipCBSA Table
                    // Get the CBSA/Metropolitan Code
                    // Code is of Format MT + StateCode + CBSACode
                    let metro = Metro(context: managedObjectContext)
                    let start = code.index(code.startIndex, offsetBy: 4)
                    let end = code.index(start, offsetBy: 5)
                    let cbsaCode = String(code[start..<end])

                    if let results = ZipCBSAMap.fetchResults(context: managedObjectContext, forCBSACode: cbsaCode), results.count > 0 {
                        metro.addToZip(NSSet(array: results))
                    }
                    metro.code = cbsaCode
                    metro.stateCode = stateCode
                    
                    metro.title = title
                    if title.contains(LoadDataUtil.MSATitle) {
                        metro.title = title.replacingOccurrences(of: LoadDataUtil.MSATitle, with: "").trimmingCharacters(in: .whitespaces)
                    }
                    area = metro
                }
                else if type == "F" {
                    let county = County(context: managedObjectContext)
                    // Get the county Code
                    let start = code.index(code.startIndex, offsetBy: 2)
                    let end = code.index(start, offsetBy: 5)
                    let countyCode = String(code[start..<end])
                    
                    if let results = ZipCountyMap.fetchResults(context: managedObjectContext, forCountyCode: countyCode), results.count > 0 {
                        county.addToZip(NSSet(array: results))
                    }
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

/*
 func convertCSV(file:String){
 let rows = cleanRows(file).componentsSeparatedByString("\n")
 if rows.count > 0 {
 data = []
 columnTitles = getStringFieldsForRow(rows.first!,delimiter:",")
 for row in rows{
 let fields = getStringFieldsForRow(row,delimiter: ",")
 if fields.count != columnTitles.count {continue}
 var dataRow = [String:String]()
 for (index,field) in fields.enumerate(){
 let fieldName = columnTitles[index]
 dataRow[fieldName] = field
 }
 data += [dataRow]
 }
 } else {
 print("No data in file")
 }
 }
 https://makeapppie.com/2016/05/23/reading-and-writing-text-and-csv-files-in-swift/
 */

