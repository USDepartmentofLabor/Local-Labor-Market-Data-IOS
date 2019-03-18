//
//  QCEWIndustryViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 2/13/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation

class QCEWIndustryViewModel: ItemViewModel {
    
    var ownershipCode: QCEWReport.OwnershipCode
    
    init(area: Area, parent: Item? = nil, ownershipCode: QCEWReport.OwnershipCode, dataYear: String) {
        self.ownershipCode = ownershipCode
        super.init(area: area, parent:parent, itemType: QCEW_Industry.self, dataYear: dataYear)
        
        itemDataTypes = [ItemDataType(title: "Employment Level", reportType:        ReportType.quarterlyEmploymentWageFrom(ownershipCode: ownershipCode, dataType: .allEmployees)),
            ItemDataType(title: "Avg Weekly Wage", reportType: .quarterlyEmploymentWageFrom(ownershipCode: ownershipCode, dataType: .avgWeeklyWage))]
        
        currentDataType = itemDataTypes[0]
        dataTitle = "Industry"
    }
    
    override func createInstance(forParent parent: Item) -> ItemViewModel {
        let viewModel = QCEWIndustryViewModel(area: area, parent: parent, ownershipCode: ownershipCode, dataYear: dataYear)
        
        viewModel.setCurrentDataType(dataType: currentDataType)
        return viewModel
    }
    
    override func getReportType(for item: Item) -> ReportType? {
        let reportType: ReportType?
        
        if let code = item.code,
            case .quarterlyEmploymentWage(_, _, _, let value) = currentDataType.reportType {
            reportType = ReportType.quarterlyEmploymentWageFrom(ownershipCode: ownershipCode, industryCode: code, dataType: value)
        }
        else {
            reportType = nil
        }
        
        return reportType
    }

    override func getReportValue(from seriesData: SeriesData) -> String? {
        var reportValueStr: String? = nil
        if case .quarterlyEmploymentWage(_, _, _, let value) = currentDataType.reportType {
            if value == .allEmployees {
                if let doubleValue = Double(seriesData.value) {
                    reportValueStr = NumberFormatter.localizedString(from: NSNumber(value: doubleValue), number: NumberFormatter.Style.decimal)
                }
                else {
                    reportValueStr = seriesData.value
                }
            }
            else if value == .avgWeeklyWage {
                if let doubleValue = Double(seriesData.value) {
                    reportValueStr = NumberFormatter.localisedCurrencyStrWithoutFraction(from: NSNumber(value: doubleValue))
                }
                else {
                    reportValueStr = seriesData.value
                }
            }
        }
        
        return reportValueStr
    }

}
