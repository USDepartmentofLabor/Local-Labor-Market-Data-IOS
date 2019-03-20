//
//  ItemViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation


class OccupationViewModel: ItemViewModel {
    
    init(area: Area, parent: Item? = nil, dataYear: String?) {
        super.init(area: area, parent:parent, itemType: OE_Occupation.self, dataYear: dataYear)
        
        itemDataTypes = [ItemDataType(title: "Mean Annual Wage", reportType: ReportType.occupationEmployment(occupationalCode: OESReport.ALL_OCCUPATIONS_CODE, .annualMeanWage)),
        ItemDataType(title: "Employment Level", reportType: ReportType.occupationEmployment(occupationalCode: OESReport.ALL_OCCUPATIONS_CODE, .employment))]
        
        dataTitle = "Occupation (Code)"
        currentDataType = itemDataTypes[0]
    }
    
    override func createInstance(forParent parent: Item) -> ItemViewModel {
        let viewModel = OccupationViewModel(area: area, parent: parent, dataYear: dataYear)
        
        viewModel.setCurrentDataType(dataType: currentDataType)
        return viewModel
    }
    
    override func getReportPeriod() -> String {
        if let latestData = getReportData(item: parentItem) {
            return latestData.year
        }
        
        return ""
    }

    override func getReportType(for item: Item) -> ReportType? {
        let reportType: ReportType?
        
        if let code = item.code,
            case .occupationEmployment(_, let value) = currentDataType.reportType {
            reportType = ReportType.occupationEmployment(occupationalCode: code, value)
        }
        else {
            reportType = nil
        }

        return reportType
    }
    
    
    override func getReportValue(from seriesData: SeriesData) -> String? {
        var reportValueStr: String? = nil
        if case .occupationEmployment(_, let value) = currentDataType.reportType {
            if value == .employment {
                if let doubleValue = Double(seriesData.value) {
                    reportValueStr = NumberFormatter.localizedString(from: NSNumber(value: doubleValue), number: NumberFormatter.Style.decimal)
                }
                else {
                    reportValueStr = seriesData.value
                }
            }
            else if value == .annualMeanWage {
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
