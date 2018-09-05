//
//  CacheManager.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/24/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

class ReportCache {
    var seriesReport: SeriesReport
    var created: Date
    
    init(report: SeriesReport) {
        seriesReport = report
        created = Date()
    }
}

class CacheManager {
    // MARK: - Properties
    var cache = NSCache<NSString, ReportCache>()

    private static var sharedCacheManager: CacheManager = {
        let cacheManager = CacheManager()
        
        return cacheManager
    }()
    
    
    // MARK: - Accessors
    class func shared() -> CacheManager {
        return sharedCacheManager
    }

    func getReport(seriesId: String, forPeriod period: String, year: String) -> SeriesReport? {
        guard let seriesReport = (cache.object(forKey: seriesId as NSString))?.seriesReport
            else {return nil}
        
        
        if let _ = seriesReport.data(forPeriod: period, forYear: year) {
            return seriesReport
        }
        
        return nil
    }
    
    func saveReport(seriesReport: SeriesReport) {
        cache.setObject(ReportCache(report: seriesReport), forKey: seriesReport.seriesID as NSString)
    }
}
