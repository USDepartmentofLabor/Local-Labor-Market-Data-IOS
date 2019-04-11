//
//  ReportManager.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/30/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import os.log

typealias SeriesId = String

enum ReportError: Error, CustomStringConvertible {
    case jsonParsingError(String)
    case network(reason: String)
    case httpError(statusCode: Int)
    case noResponse
    case requestError(reportStatus: ReportStatus, messages: [String])
    
    var description: String {
        let desc: String
        switch self {
        case .jsonParsingError( _):
            desc = NSLocalizedString("Error retrieving data.", comment: "Error retrieving data.")
        case .network(let reason):
            desc = reason
        case .httpError( _):
            desc = NSLocalizedString("Error retrieving data.", comment: "Error retrieving data.")
        case .noResponse:
            desc = NSLocalizedString("Error retrieving data.", comment: "Error retrieving data.")
        case .requestError(_,  _):
            desc = NSLocalizedString("Error retrieving data.", comment: "Error retrieving data.")
        }

        return desc + " Please try again later."
    }
    
    var title: String {
        let title: String
        switch self {
        case .network( _):
            title = NSLocalizedString("Network Error", comment: "Network Error")
        default:
            title = ""
        }
        return title
    }

}

struct AreaReport {
    var reportType: ReportType
    var area: Area?
    var seriesId: String?
    var seriesReport: SeriesReport?
    
    init(reportType: ReportType, area: Area?) {
        self.reportType = reportType
        self.area = area
    }
}

enum SeasonalAdjustment: String, CustomStringConvertible {
    case adjusted = "S"
    case notAdjusted = "U"
    
    var description: String {
        let desc: String
        switch self {
        case .adjusted:
            desc = "Seasonally Adjusted"
        case .notAdjusted:
            desc = "Not Seasonally Adjusted"
        }
        
        return desc
    }
}

enum ReportType {
    case unemployment(measureCode: LAUSReport.MeasureCode)
    case industryEmployment(industryCode: String, CESReport.DataTypeCode)
    case occupationEmployment(occupationalCode: String, OESReport.DataTypeCode)
    case quarterlyEmploymentWage(ownershipCode: QCEWReport.OwnershipCode, industryCode: String, establishmentSize: QCEWReport.EstablishmentSize, dataType: QCEWReport.DataTypeCode)
    
    public static func quarterlyEmploymentWageFrom(ownershipCode: QCEWReport.OwnershipCode, industryCode: String = QCEWReport.ALL_INDUSTRY_CODE, establishmentSize: QCEWReport.EstablishmentSize = .all, dataType: QCEWReport.DataTypeCode) -> ReportType {
        return ReportType.quarterlyEmploymentWage(ownershipCode: ownershipCode, industryCode:industryCode, establishmentSize: establishmentSize, dataType: dataType)
    }
    
    func seriesId(forArea area: Area,
                  adjustment: SeasonalAdjustment = .notAdjusted) -> SeriesId? {
        
        let seriesId: SeriesId?

        switch self {
        case .unemployment(let measureCode):
            // National Unemployment report comes from CPS report
            if let nationalArea = area as? National {
                seriesId = CPSReport.getSeriesId(forArea: nationalArea, lfstCode: .unemploymentRate, adjustment: adjustment)
            }
            else { // Local Unemployment report comes from LAUS report
                seriesId = LAUSReport.getSeriesId(forArea: area, measureCode: measureCode, adjustment: adjustment)
            }
        case .industryEmployment(let industryCode, let dataTypeCode):
            seriesId = CESReport.getSeriesId(forArea: area, industryCode: industryCode, dataTypeCode: dataTypeCode, adjustment: adjustment)
        case .occupationEmployment(let occupationalCode, let dataTypeCode):
            seriesId = OESReport.getSeriesId(forArea: area, occupationCode: occupationalCode, dataTypeCode: dataTypeCode, adjustment: adjustment)
            
        case .quarterlyEmploymentWage(let ownershipCode, let industryCode, let establishmentSize, let dataType):
            seriesId = QCEWReport.getSeriesId(forArea: area, ownershipCode: ownershipCode, industryCode: industryCode, establishmentSize: establishmentSize, dataTypeCode: dataType, adjustment: adjustment)
        }
        
        return seriesId
    }
}


class ReportManager {
    static let dataNotAvailableStr = "N/A"
    static let dataNotDisclosable = "ND"
    static let dataNotAvailableAccessibilityStr = "Data Not Available"
//    static var seasonalAdjustment: SeasonalAdjustment = .notAdjusted

    class func getReports(forArea area: Area, reportTypes: [ReportType],
                          seasonalAdjustment: SeasonalAdjustment = .notAdjusted,
                          period: String? = nil, year: String? = nil,
                          annualAverage: Bool = false,
                          completion: ((APIResult<[ReportType: AreaReport], ReportError>) -> Void)?) {
        getReports(forArea: area, reportTypes: reportTypes, seasonalAdjustment: seasonalAdjustment,
                   period: period, startYear: year, endYear: year, annualAverage: annualAverage, completion: completion)
    }
    
    class func getReports(forArea area: Area, reportTypes: [ReportType],
                          seasonalAdjustment: SeasonalAdjustment = .notAdjusted,
                          period: String? = nil,
                          startYear: String?, endYear: String?,
                          annualAverage: Bool = false,
                          completion: ((APIResult<[ReportType: AreaReport], ReportError>) -> Void)?) {
        
        var seriesIds = [SeriesId]()
        var areaReportsDict = [ReportType: AreaReport]()
        for reportType in reportTypes {
            var areaReport = AreaReport(reportType: reportType, area: area)
            if let seriesId = reportType.seriesId(forArea: area, adjustment: seasonalAdjustment) {
                areaReport.seriesId = seriesId
                // Check if seriesID exist in cache
//                if let year = endYear, let period = period,
//                    let report = CacheManager.shared().getReport(seriesId: seriesId, forPeriod: period, year: year) {
//                    // If Yes, the no need to get it again from network
//                    areaReport.seriesReport = report
//                }
//                else {
                    seriesIds.append(seriesId)
//                }
            }

            areaReportsDict[reportType] = areaReport
        }

        if seriesIds.count < 1 {
            completion?(.success(areaReportsDict))
            return
        }
        _ = API().getReports(seriesIds: seriesIds, startYear: startYear, endYear: endYear, annualAverage: annualAverage,
                             completion: { response in
            switch response {
            case .success(let reportResponse):
                
                // Map the series from response to request
                if reportResponse.status == .REQUEST_SUCCEEDED,
                    let seriesReports = reportResponse.series {

                    seriesReports.forEach({ (seriesReport) in
                        let dict = areaReportsDict.filter{
                                                $0.value.seriesId == seriesReport.seriesID
                            }.first
                        
                        if let dict = dict {
                            areaReportsDict[dict.key]?.seriesReport = seriesReport
                        }
                        // If this is national Report then save it on Cache.
                        // And it is for Year. If just latest requested then don't cache
//                        if area is National, startYear != nil {
//                            CacheManager.shared().saveReport(seriesReport: seriesReport)
//                        }
                    })
                    completion?(.success(areaReportsDict))
                }
                else {
                    os_log("Report Error: %@", reportResponse.message)
                    let reportError = ReportError.requestError(reportStatus: reportResponse.status, messages: reportResponse.message)
                    completion?(.failure(reportError))
                }
            case .failure(let error):
                os_log("Report Error: %@", error.localizedDescription)

                completion?(.failure(error))
            }
            
        })
    }
}

// Mark: History
extension ReportManager {
    // Get
    class func getHistory(seriesIds: [String], seasonalAdjustment: SeasonalAdjustment? = nil,
                          currentDate : Date = Date(),
                          monthsHistory: Int,
                          completion: ((APIResult<[SeriesReport]?, ReportError>) -> Void)?) {
        guard seriesIds.count > 0 else { return }
        
        // Get Month and Year of SeriesReport
        // If SeriesReport doesn't have Year/Month then use today.
        let calendar = Calendar.current
//        let latestDate: Date
        
//        // If Latest SeriesReport is available, use that as End Year
//        let latestData = areaReport.seriesReport?.latestData()
//        if let latestData = latestData {
//            latestDate = DateFormatter.date(fromMonth: latestData.periodName, fromYear: latestData.year)
//                ?? Date()
//        }
//        else {
//            latestDate = Date()
//        }

        let startDate = calendar.date(byAdding: .month, value: monthsHistory, to: currentDate)
        let endYear = calendar.component(.year, from: currentDate)
        let startYear: Int? = (startDate != nil) ? calendar.component(.year, from: startDate!) : nil
        
        if let startYear = startYear {
            getHistory(seriesIds: seriesIds,
                       startYear: String(startYear),
                        endYear:String(endYear),
                        completion: completion)
        }
    }
    
    class func getHistory(seriesIds: [String], seasonalAdjustment: SeasonalAdjustment? = nil,
                          startYear: String, endYear: String,
                          completion: ((APIResult<[SeriesReport]?, ReportError>) -> Void)?) {
        
        _ = API().getReports(seriesIds: seriesIds, startYear: startYear, endYear: endYear, annualAverage: false,
                             completion: { response in
                                switch response {
                                case .success(let reportResponse):
            
                                    // Map the series from response to request
                                    if reportResponse.status == .REQUEST_SUCCEEDED {
                                        let seriesReports = reportResponse.series
                                        completion?(.success(seriesReports))
                                    }
                                case .failure(let error):
                                    os_log("Report Error: %@", error.localizedDescription)
            
                                    completion?(.failure(error))
                        }
        })
    }

}

extension ReportType: Hashable, Equatable {
    public var hashValue: Int {
        switch self {
        case .unemployment(let measureCode):
            return "unemploymennt \(measureCode)".hashValue
        case .industryEmployment(let industryCode, let dataType):
            return "industryEmployment \(industryCode) \(dataType)".hashValue
        case .occupationEmployment(let occupationalCode, let dataType):
            return "occupationEmployment \(occupationalCode) \(dataType)".hashValue
        case .quarterlyEmploymentWage(let ownershipCode, let industryCode, let establishmentSize, let dataType):
            return "quarterlyEmploymentWage \(ownershipCode) \(industryCode), \(establishmentSize) \(dataType)".hashValue
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .unemployment(let measureCode):
            hasher.combine("unemploymennt \(measureCode)")
        case .industryEmployment(let industryCode, let dataType):
            hasher.combine("industryEmployment \(industryCode) \(dataType)")
        case .occupationEmployment(let occupationalCode, let dataType):
            hasher.combine("occupationEmployment \(occupationalCode) \(dataType)")
        case .quarterlyEmploymentWage(let ownershipCode, let industryCode, let establishmentSize, let dataType):
            hasher.combine("quarterlyEmploymentWage \(ownershipCode) \(industryCode), \(establishmentSize) \(dataType)")
        }
    }
    
//    public static func ==(lhs: ReportType, rhs: ReportType) -> Bool {
//        return lhs.hashValue == rhs.hashValue
//    }
}
