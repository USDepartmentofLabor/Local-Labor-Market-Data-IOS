//
//  Local_Labor_Market_DataTests.swift
//  Local Labor Market DataTests
//
//  Created by Nidhi Chawla on 9/4/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import XCTest
@testable import Local_Labor_Market_Data

class Local_Labor_Market_DataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearchMetroArea() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let context = CoreDataManager.shared().viewManagedContext
        let results = DataUtil(managedContext: context).searchArea(forArea: .metro, forText: "New")
        assert(results?.count == 9)
        assert(results?[0].title == "Kennewick-Richland, WA")
    }
    
    
    func testSearchState() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let context = CoreDataManager.shared().viewManagedContext
        let results = DataUtil(managedContext: context).searchArea(forArea: .state, forText: "New")
        assert(results?.count == 4)
        assert(results?[0].title == "New Hampshire")
    }
    
    func testSearchCounty() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let context = CoreDataManager.shared().viewManagedContext
        let results = DataUtil(managedContext: context).searchArea(forArea: .county, forText: "New")
        assert(results?.count == 17)
        assert(results?[0].title == "New Castle County, DE")
    }
    
    func testSearchMetroForZipCode() {
        let context = CoreDataManager.shared().viewManagedContext
        let results = DataUtil(managedContext: context).searchArea(forArea: .metro, forZipCode: "34135")
        assert(results?.count == 2)
        assert(results?[0].title == "Cape Coral-Fort Myers, FL")
    }
    func testSearchStateZipCode() {
        let context = CoreDataManager.shared().viewManagedContext
        let results = DataUtil(managedContext: context).searchArea(forArea: .state, forZipCode: "34135")
        assert(results?.count == 1)
        assert(results?[0].title == "Florida")
    }
    func testSearchCountyForZipCode() {
        let context = CoreDataManager.shared().viewManagedContext
        let results = DataUtil(managedContext: context).searchArea(forArea: .county, forZipCode: "34135")
        assert(results?.count == 2)
        assert(results?[0].title == "Collier County, FL")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
