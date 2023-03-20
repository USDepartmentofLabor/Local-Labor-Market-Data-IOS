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
    case code(ascending: Bool)
    case local(ascending: Bool)
    case national(ascending: Bool)
    case localOneMonthChange(ascending: Bool)
    case localTwelveMonthChange(ascending: Bool)
    case nationalTwelveMonthChange(ascending: Bool)
}

class ItemViewModel: NSObject {
    var area: Area
    var parentItem: Item
    var currentYear: String?
    var currentPeriodName: String?
    var seasonalAdjustment: SeasonalAdjustment
    
    var itemDataTypes: [ItemDataType] = [ItemDataType(title: "Employment Level", reportType: ReportType.industryEmployment(industryCode: "00000000", CESReport.DataTypeCode.allEmployees))]
    
    var currentDataType: ItemDataType
    var dataTitle = "Industry"
    var dataSort = DataSort.code(ascending: true)
    var annualAverage = false
    
    var isNationalReport: Bool {
        get {
            return area is National
        }
    }
    
    var isDataDownloaded: Bool {
        get {
            return currentDataType.localReport != nil
        }
    }
    
    var _items: [Item]?
    private var _displayLeaf: Bool
    
    var displayLeaf: Bool {
        get{
            return _displayLeaf
        }
        set {
            _displayLeaf = newValue
            if _displayLeaf {
                _items = parentItem.getLeafChildren()
            }
            else {
                _items = parentItem.subItems()
            }
        }
    }
    
    init(area: Area, parent: Item? = nil, itemType: Item.Type, dataYear: String? = nil, periodName: String? = nil, seasonalAdjustment: SeasonalAdjustment? = nil) {
        self.area = area
        self.currentYear = dataYear
        self.currentPeriodName = periodName
        
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
                _displayLeaf = true
                _items = parentItem.getLeafChildren()
        }
        else {
            _displayLeaf = false
            _items = parentItem.subItems()
        }
    
        currentDataType = itemDataTypes[0]
        
        if let adjustment = seasonalAdjustment {
            self.seasonalAdjustment = adjustment
        }
        else if area is National || area is State {
            self.seasonalAdjustment = .adjusted
        }
        else {
            self.seasonalAdjustment = .notAdjusted
        }
    }

    func createInstance(forParent parent: Item) -> ItemViewModel {
        let vm = ItemViewModel(area: area, parent: parent, itemType: type(of: parent), dataYear: currentYear, periodName: currentPeriodName, seasonalAdjustment: seasonalAdjustment)
        
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
        
        return "\(currentPeriodName ?? "") \(currentYear ?? "")"
    }
    
    func getReportValue(item: Item) -> String? {
        guard let seriesData = getReportData(item: item) else { return nil }
        
        return getReportValue(from: seriesData)
    }
    
    func getReportData(item: Item) -> SeriesData? {
        guard let reportType = getReportType(for: item) else { return nil }
        
        currentPeriodName = getBestCurrentPeriod(from: currentDataType.localReport, reportType)
        
        if let year = currentYear, let periodName = currentPeriodName {
            return currentDataType.localReport?[reportType]?.seriesReport?.data(forPeriodName: periodName, forYear: year)
        }
        
        return currentDataType.localReport?[reportType]?.seriesReport?.latestData()
    }
    
    func getBestCurrentPeriod(from areaReportsDict: [ReportType: AreaReport]?, _ reportType: ReportType) -> String? {
        var retPeriod = currentPeriodName
        guard let areaReports = areaReportsDict else { return retPeriod }
        
        var periodMap:Dictionary = [currentPeriodName: 0]
        for (_, areaReport) in areaReports {
            if (areaReport.seriesReport?.data != nil && !areaReport.seriesReport!.data.isEmpty) {
                let periodKey = areaReport.seriesReport!.data[0].periodName
                let periodItem = periodMap[periodKey]
                if (periodItem != nil) {
                    periodMap[periodKey] = periodMap[periodKey]! + 1
                } else {
                    periodMap[periodKey] = 1
                }
            }
        }

        var currentPeriodCnt = 0
        for (periodKey, value) in periodMap {
           if (value >= currentPeriodCnt) {
               retPeriod = periodKey
               currentPeriodCnt = value
           }
        }
       // print("GGG: Ret Period \(retPeriod) \nin dictionary \(periodMap)")
        return retPeriod
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
//        let latestData = getReportData(item: parentItem)
//        return getNationalReportData(item: item, period: latestData?.period, year: latestData?.year)
        return getNationalReportData(item: item, periodName: currentPeriodName, year: currentYear)
    }
    
    func getNationalReportData(item: Item, periodName: String?, year: String?) -> SeriesData? {
        guard let reportType = getReportType(for: item) else { return nil }
        
        if let periodName = periodName, let year = year {
            return currentDataType.nationalReport?[reportType]?.seriesReport?.data(forPeriodName: periodName,
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
    func loadReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping (ReportError?) -> Void) {
        loadLocalReport(seasonalAdjustment: seasonalAdjustment) { [weak self] (reportError) in
            guard let strongSelf = self else { return }
            
            guard reportError == nil else {
                completion(reportError)
                return
            }
            if strongSelf.area is National {
                completion(nil)
            }
                // National Report is required only for OES and QCEW
            else if strongSelf.parentItem is OE_Occupation ||
                strongSelf.parentItem is QCEW_Industry {
                strongSelf.loadNationalReport(seasonalAdjustment: seasonalAdjustment, completion:  completion)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func loadLocalReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping (ReportError?) -> Void) {
            // Load the report from Server
        loadReport(area: area, seasonalAdjustment: seasonalAdjustment, completion: completion)
    }
    
    func loadNationalReport(seasonalAdjustment: SeasonalAdjustment, completion: @escaping (ReportError?) -> Void) {
        guard let context = area.managedObjectContext,
            let nationalArea = DataUtil(managedContext: context).nationalArea()
            else {return }
        
        loadReport(area: nationalArea, seasonalAdjustment: seasonalAdjustment, completion: completion)
    }
    
    func loadReport(area: Area, seasonalAdjustment: SeasonalAdjustment, completion: @escaping (ReportError?) -> Void) {
        loadReportFromAPI(area: area, seasonalAdjustment: seasonalAdjustment) {
            [weak self] (apiResult) in
            guard let strongSelf = self else { return }
            
            switch apiResult {
            case .success(let areaReportsDict):
                
                if area == strongSelf.area {
                    strongSelf.currentDataType.localReport = areaReportsDict
                    if strongSelf.currentYear == nil, let seriesData = strongSelf.getReportData(item: strongSelf.parentItem) {
                        strongSelf.currentYear = seriesData.year
                        strongSelf.currentPeriodName = seriesData.periodName
                    }
                }
                else {
                    strongSelf.currentDataType.nationalReport = areaReportsDict
                }
            completion(nil)
            case .failure(let error):
                print(error)
                completion(error)
            }
        }
    }

    func loadReportFromAPI(area: Area, seasonalAdjustment: SeasonalAdjustment,
                           completion: ((APIResult<[ReportType: AreaReport], ReportError>) -> Void)?) {
        if let reportTypes = getReportTypes() {
            ReportManager.getReports(forArea: area, reportTypes: reportTypes,
                                     seasonalAdjustment: seasonalAdjustment, year:currentYear,
                                     annualAverage: annualAverage, completion: completion)
        }
    }
    
}

extension ItemViewModel {
    var items: [Item]? {
        get {
            switch dataSort {
            case .none:
                return _items
            case .code(let ascending):
                return _items?.sorted {
                    return compareValues(firstValueStr: $0.code, secondValueStr: $1.code, ascending: ascending)
                }
            case .local(let ascending):
                return _items?.sorted {
                    return compareValues(firstValueStr: getReportData(item: $0)?.value,
                                         secondValueStr: getReportData(item: $1)?.value,
                                         ascending: ascending)
                }
            case .national(let ascending):
                return _items?.sorted {
                    return compareValues(firstValueStr: getNationalReportData(item: $0)?.value,
                                         secondValueStr: getNationalReportData(item: $1)?.value,
                                         ascending: ascending)
                }
            case .localOneMonthChange(let ascending):
                return _items?.sorted {
                    return compareValues(firstValueStr: getReportData(item: $0)?.calculations?.percentChanges?.oneMonth,
                    secondValueStr: getReportData(item: $1)?.calculations?.percentChanges?.oneMonth,
                    ascending: ascending)
                }
            case .localTwelveMonthChange(let ascending):
                return _items?.sorted {
                    return compareValues(firstValueStr: getReportData(item: $0)?.calculations?.percentChanges?.twelveMonth,
                            secondValueStr: getReportData(item: $1)?.calculations?.percentChanges?.twelveMonth,
                            ascending: ascending)
                }
            case .nationalTwelveMonthChange(let ascending):
                return _items?.sorted {
                    return compareValues(firstValueStr: getNationalReportData(item: $0)?.calculations?.percentChanges?.twelveMonth,
                                         secondValueStr: getNationalReportData(item: $1)?.calculations?.percentChanges?.twelveMonth, ascending: ascending)
                }
            }
        }
    }
    
    fileprivate func compareValues(firstValueStr: String?,
                                   secondValueStr: String?,
                                   ascending: Bool) -> Bool {
        
        guard let firstValueStr = firstValueStr else {return false}
        guard let secondValueStr = secondValueStr else {return true}
        
        let firstValue = Double(firstValueStr) ?? 0
        let secondValue = Double(secondValueStr) ?? 0
        
        if ascending {
            return firstValue < secondValue
        }
        return firstValue > secondValue
    }
}
