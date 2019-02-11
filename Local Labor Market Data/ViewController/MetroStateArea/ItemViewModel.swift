//
//  ItemViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation


class ItemViewModel: NSObject {
    
    var area: Area
    var parentItem: Item
    var items: [Item]?
    var dataYear: String

    init(area: Area, parent: Item? = nil, itemType: Item.Type, dataYear: String) {
        self.area = area
        self.dataYear = dataYear
        if parent == nil {
            parentItem = itemType.getSuperParents(context:
                CoreDataManager.shared().viewManagedContext)!.first!
        }
        else {
            parentItem = parent!
        }
        items = parentItem.subItems()
    }

    func createInstance(forParent parent: Item) -> ItemViewModel {
        return ItemViewModel(area: area, parent: parent, itemType: type(of: parent), dataYear: dataYear)
    }
    
    func getReportPeriod() -> String {
        if let latestData = getReportLatestData(item: parentItem) {
            return "\(latestData.periodName) \(latestData.year)"
        }
        
        return ""
    }
    
    func getReportValue(item: Item) -> String? {
        
        if let latestData = getReportLatestData(item: item) {
            return latestData.value
        }
        return nil
    }
    
    func getReportLatestData(item: Item) -> SeriesData? {
        return nil
    }
    
    func getNationalReportData(item: Item, period: String?, year: String?) -> SeriesData? {
        return nil
    }
    
    func getParentReportValue() -> String? {
        return getReportValue(item: parentItem)
    }

    func getParentReportType() -> ReportType? {
        return getReportType(for: parentItem)
    }
    
    func getReportTypes() -> [ReportType]? {
        var reportTypes =  [ReportType]()
        
        if let parentReportType = getParentReportType() {
            reportTypes.append(parentReportType)
        }
        
        let types = items?.compactMap{getReportType(for: $0)}
        if let types = types {
            reportTypes.append(contentsOf: types)
        }
        return reportTypes
    }
    
    func getReportType(for item: Item) -> ReportType? {
        let reportType: ReportType?
        
        if let code = item.code {
            if item is CE_Industry {
                reportType = ReportType.industryEmployment(industryCode: code, CESReport.DataTypeCode.allEmployees)
            }
            else if item is SM_Industry {
                reportType = ReportType.industryEmployment(industryCode: code, CESReport.DataTypeCode.allEmployees)
            }
            else if item is QCEW_Industry {
                reportType = ReportType.quarterlyEmploymentWageFrom(ownershipCode: .totalCovered, dataType: QCEWReport.DataTypeCode.allEmployees)
            }
            else {
                reportType = nil
            }
        }
        else {
            reportType = nil
        }
  
        return reportType
    }
    
    func loadReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping () -> Void) {
        loadReportFromAPI(area: area, seasonalAdjustment: seasonalAdjustment) { (apiResult) in
            completion()
        }
    }
    func loadReportFromAPI(area: Area, seasonalAdjustment: SeasonalAdjustment,
                           completion: ((APIResult<[ReportType: AreaReport], ReportError>) -> Void)?) {
        if let reportTypes = getReportTypes() {
            ReportManager.getReports(forArea: area, reportTypes: reportTypes,
                                     seasonalAdjustment: seasonalAdjustment, year:dataYear, completion: completion)
        }
    }
}
