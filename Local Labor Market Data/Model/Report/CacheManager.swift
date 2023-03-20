//
//  CacheManager.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/24/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

class ReportCache1 {
    var seriesReport: SeriesReport
    var created: Date
    
    init(report: SeriesReport) {
        seriesReport = report
        created = Date()
    }
}

class ReportCache {
    var apiReportResponse: APIReportResponse
    var created: Date

    init(apiResponse: APIReportResponse) {
        apiReportResponse = apiResponse
        created = Date()
    }
}

class CacheManager {
    // MARK: - Properties
    var cache = NSCache<NSString, ReportCache>()
    //let expireyTimeInterval: TimeInterval = 2 * 3600
    let expireyTimeInterval: TimeInterval = 20
    private static var sharedCacheManager: CacheManager = {
        let cacheManager = CacheManager()
        
        return cacheManager
    }()
    
    
    // MARK: - Accessors
    class func shared() -> CacheManager {
        return sharedCacheManager
    }
    
    private func key(for request: APIReportRequest) -> String? {
        guard let requestData = try? JSONEncoder().encode(request)
            else { return nil }

        return String(data: requestData, encoding: .utf8)
    }
    
    func get(for request: APIReportRequest) -> APIReportResponse? {
        guard let key = key(for: request)
            else { return nil }
        
        guard let cachedResponse = cache.object(forKey: key as NSString)
            else {return nil}
        
        let timeSinceCache = Date().timeIntervalSince(cachedResponse.created)
        if timeSinceCache > expireyTimeInterval {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        
        return cachedResponse.apiReportResponse
    }

    func put(response: APIReportResponse, for request: APIReportRequest) {
        guard let key = key(for: request)
            else { return }

        let reportCache = ReportCache(apiResponse: response)
        cache.setObject(reportCache, forKey: key as NSString)
    }
    
//    func getReport(seriesId: String, forPeriod period: String, year: String) -> SeriesReport? {
//        guard let seriesReport = (cache.object(forKey: seriesId as NSString))?.seriesReport
//            else {return nil}
//
//
//        if let _ = seriesReport.data(forPeriod: period, forYear: year) {
//            return seriesReport
//        }
//
//        return nil
//    }
//
//    func saveReport(seriesReport: SeriesReport) {
////        cache.setObject(ReportCache(report: seriesReport), forKey: seriesReport.seriesID as NSString)
//    }
    
}
