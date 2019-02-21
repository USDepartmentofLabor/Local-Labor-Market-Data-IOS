//
//  ItemViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

class ItemDataType {
    var title: String
    var reportType: ReportType
    var localReport: [ReportType: AreaReport]?
    var nationalReport: [ReportType: AreaReport]?
    
    init(title: String, reportType: ReportType) {
        self.title = title
        self.reportType = reportType
    }
}

enum DataSort {
    case none
    case local(ascending: Bool)
    case national(ascending: Bool)
}

class ItemViewModel: NSObject {
    var area: Area
    var parentItem: Item
    var dataYear: String
    var itemDataTypes: [ItemDataType] = [ItemDataType(title: "Employment Level", reportType: ReportType.industryEmployment(industryCode: "00000000", CESReport.DataTypeCode.allEmployees))]
    
    var currentDataType: ItemDataType
    var dataTitle = "Industry"
    var dataSort = DataSort.none
    
    var isNationalReport: Bool {
        get {
            return area is National
        }
    }
    
    var _items: [Item]?
    var items: [Item]? {
        get {
            switch dataSort {
            case .none:
                return _items
            case .local(let ascending):
                return _items?.sorted {
                    let firstValueStr = getReportData(item: $0)?.value ?? ""
                    let secondValueStr = getReportData(item: $1)?.value ?? ""
                    let firstValue = Double(firstValueStr) ?? 0
                    let secondValue = Double(secondValueStr) ?? 0
                    if ascending {
                        return firstValue < secondValue
                    }
                    return firstValue > secondValue
                }
            case .national(let ascending):
                return _items?.sorted {
                    let firstValueStr = getNationalReportData(item: $0)?.value ?? ""
                    let secondValueStr = getNationalReportData(item: $1)?.value ?? ""
                    let firstValue = Double(firstValueStr) ?? 0
                    let secondValue = Double(secondValueStr) ?? 0
                    if ascending {
                        return firstValue < secondValue
                    }
                    return firstValue > secondValue
                }
            }
        }
    }
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
        
        // Occupations -  except ALL_OCCUPATIONS_CODE, Show only Leaf level occupations
        // for Non National Area
        if !(area is National),
            parentItem is OE_Occupation,
            parentItem.code != OESReport.ALL_OCCUPATIONS_CODE {
            _items = parentItem.getLeafChildren()
            
            print("Parent \(parentItem.title): leaf Count: \(_items?.count)")
        }
        else {
            _items = parentItem.subItems()
        }
        
        currentDataType = itemDataTypes[0]
    }

    func createInstance(forParent parent: Item) -> ItemViewModel {
        let vm = ItemViewModel(area: area, parent: parent, itemType: type(of: parent), dataYear: dataYear)
        
        vm.setCurrentDataType(dataType: currentDataType)
        return vm
    }
    
    func setCurrentDataType(dataType: ItemDataType) {
        currentDataType = itemDataTypes.filter {
            $0.reportType == dataType.reportType
        }.first ?? itemDataTypes[0]
    }
    
    func getReportPeriod() -> String {
        if let latestData = getReportData(item: parentItem) {
            return "\(latestData.periodName) \(latestData.year)"
        }
        
        return ""
    }
    
    func getReportValue(item: Item) -> String? {
        guard let seriesData = getReportData(item: item) else { return nil }
        
        return getReportValue(from: seriesData)
    }
    
    func getReportData(item: Item) -> SeriesData? {
        guard let reportType = getReportType(for: item) else { return nil }
        
        return currentDataType.localReport?[reportType]?.seriesReport?.latestData()
    }

    func getReportValue(from seriesData: SeriesData) -> String? {
        
        if let doubleValue = Double(seriesData.value) {
            return NumberFormatter.localizedString(from: NSNumber(value: doubleValue), number: NumberFormatter.Style.decimal)
        }

        return nil
    }
    
    func getNationalReportValue(item: Item) -> String? {
        guard let seriesData = getNationalReportData(item: item) else { return nil }
        
        return getReportValue(from: seriesData)
    }
    
    
    func getNationalReportData(item: Item) -> SeriesData? {
        let latestData = getReportData(item: parentItem)
        return getNationalReportData(item: item, period: latestData?.period, year: latestData?.year)
    }
    
    func getNationalReportData(item: Item, period: String?, year: String?) -> SeriesData? {
        guard let reportType = getReportType(for: item) else { return nil }
        
        if let period = period, let year = year {
            return currentDataType.nationalReport?[reportType]?.seriesReport?.data(forPeriod: period,
                                                                                   forYear: year)
        }
        return nil
    }

    func getParentNationalReportValue() -> String? {
        guard let seriesData = getParentNationalReportData() else { return nil }
        
        return getReportValue(from: seriesData)
    }

    func getParentNationalReportData() -> SeriesData? {
        return getNationalReportData(item: parentItem)
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
        
        let types = _items?.compactMap{getReportType(for: $0)}
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
    
}

// Mark: Load Report
extension ItemViewModel {
    func loadReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping () -> Void) {
        loadLocalReport(seasonalAdjustment: seasonalAdjustment) {[weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.area is National {
                completion()
            }
                // National Report is required only for OES and QCEW
            else if strongSelf.parentItem is OE_Occupation ||
                strongSelf.parentItem is QCEW_Industry {
                strongSelf.loadNationalReport(seasonalAdjustment: seasonalAdjustment, completion:  completion)
            }
            else {
                completion()
            }
        }
    }
    
    func loadLocalReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping () -> Void) {
        if currentDataType.localReport == nil {
            // Load the report from Server
            loadReport(area: area, seasonalAdjustment: seasonalAdjustment, completion: completion)
        }
        else {
            // return the report
            completion()
        }
    }
    
    func loadNationalReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping () -> Void) {
        guard let context = area.managedObjectContext,
            let nationalArea = DataUtil(managedContext: context).nationalArea()
            else {return }
        
        if currentDataType.nationalReport == nil {
            loadReport(area: nationalArea, seasonalAdjustment: seasonalAdjustment, completion: completion)
        }
        else {
            completion()
        }
        
    }
    
    func loadReport(area: Area, seasonalAdjustment: SeasonalAdjustment, completion: @escaping () -> Void) {
        loadReportFromAPI(area: area, seasonalAdjustment: seasonalAdjustment) {
            [weak self] (apiResult) in
            guard let strongSelf = self else { return }
            
            switch apiResult {
            case .success(let areaReportsDict):
                
                if area == strongSelf.area {
                    strongSelf.currentDataType.localReport = areaReportsDict
                }
                else {
                    strongSelf.currentDataType.nationalReport = areaReportsDict
                }
            case .failure(let error):
                print(error)
            }
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
