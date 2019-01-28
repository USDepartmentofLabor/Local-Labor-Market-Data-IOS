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
    var parentItem: Item?
    var items: [Item]?
    var dataYear: String

    init(area: Area, parent: Item? = nil, itemType: Item.Type, dataYear: String) {
        self.area = area
        self.dataYear = dataYear
        if parent == nil {
            items = itemType.getSuperParents(context:
                CoreDataManager.shared().viewManagedContext)
        }
        else {
            parentItem = parent
            items = parentItem?.subItems()
        }
    }
    
    func reportItems() -> [ReportItem<Item>]? {
        let reportItems = items?.compactMap({ (item) -> ReportItem<Item> in
            return getReportType(for: item)
        })
        return reportItems
    }
    
    func getReportType(for item: Item) -> ReportItem<Item> {
        let reportTypes: [ReportType]?
        if let code = item.code {
            if item is OE_Occupation {
                reportTypes = [ReportType.occupationEmployment(occupationalCode: code, OESReport.DataTypeCode.annualMeanWage),                    ReportType.occupationEmployment(occupationalCode: code, OESReport.DataTypeCode.employment)]
            }
            else if item is CE_Industry {
                reportTypes = [ReportType.industryEmployment(industryCode: code, CESReport.DataTypeCode.allEmployees)]
            }
            else if item is SM_Industry {
                reportTypes = [ReportType.industryEmployment(industryCode: code, CESReport.DataTypeCode.allEmployees)]
            }
            else {
                reportTypes = nil
            }
        }
        else {
            reportTypes = nil
        }
        
        return ReportItem<Item>(item: item, reportTypes: reportTypes)
    }
}
