//
//  QCEWReport.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 8/8/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
struct QCEWData {
    var areaCode: String
    var ownershipCode: QCEWReport.OwnershipCode
    var industryCode: QCEWReport.IndustryCode
    var size: QCEWReport.EstablishmentSize
    var year: String
    var qtr: String
    var disclosureCode: String
    var month1EmpLevel: String
    var month2EmpLevel: String
    var month3EmpLevel: String
    var totalQtryWage: String
    var avgWeeklyWage: String
    var otyDisclosureCode: String
    var otyMonth1EmplvlChange: String
    var otyMonth1EmplvlPctChange: String
    var otyMonth2EmplvlChange: String
    var otyMonth2EmplvlPctChange: String
    var otyMonth3EmplvlChange: String
    var otyMonth3EmplvlPctChange: String
    var otyTotalQtrlyWageChange: String
    var otyTotalQtrlyWagePctChange: String
    var otyAvgWklyWageChange: String
    var otyAvgWklyWagePctChange: String
}
class QCEWReport {
    enum QCEWDataFileIndex: Int {
        case areaCode = 0
        case ownershipCode = 1
        case industryCode = 2
        case aggLvlCode = 3
        case sizeCode = 4
        case year = 5
        case qtr = 6
        case disclosureCode = 7
        case month1Emplvl = 9
        case month2Emplvl = 10
        case month3Emplvl = 11
        case totalQtrlyWages = 12
        case avgWeeklyWage = 15
        case otyDisclosureCode = 25
        case otyMonth1EmplvlChange = 28
        case otyMonth1EmplvlPctChange = 29
        case otyMonth2EmplvlChange = 30
        case otyMonth2EmplvlPctChange = 31
        case otyMonth3EmplvlChange = 32
        case otyMonth3EmplvlPctChange = 33
        case otyTotalQtrlyWageChange = 34
        case otyTotalQtrlyWagePctChange = 35
        case otyAvgWklyWageChange = 40
        case otyAvgWklyWagePctChange = 41
    }
    
    enum OwnershipCode: String {
        case totalCovered = "0"
        case privateOwnership = "5"
        case federalGovt = "1"
        case stateGovt = "2"
        case localGovt = "3"
    }

    enum IndustryCode: String {
        case allIndustry = "10"
    }

    enum EstablishmentSize: String {
        case all = "0"
    }

    enum AgglvlCode: String {
        case countyTotal = "70"
        case countyTotalByOwnership = "71"
    }
    
    enum DataTypeCode: String {
        case allEmployees = "1"
        case numberOfEstablishments = "2"
        case totalWages = "3"
        case avgWeeklyWage = "4"
        case avgAnnualPay = "5"
    }
    
    func getReport(area: Area, ownership: OwnershipCode, industryCode: IndustryCode = IndustryCode.allIndustry) -> QCEWData? {
        
        let agglCode: AgglvlCode
        if ownership == .totalCovered {
            agglCode = .countyTotal
        }
        else {
            agglCode = .countyTotalByOwnership
        }
        
        return getQCEWData(area: area, ownership: ownership, industryCode: industryCode, aggLevelCode: agglCode)
    }
    
    fileprivate func getQCEWData(area: Area, ownership: OwnershipCode, industryCode: IndustryCode, aggLevelCode: AgglvlCode, size: EstablishmentSize = .all) -> QCEWData? {
        guard let items = LoadDataUtil.loadDataResource(resourceName: "51107") else { return nil }

        let filteredResults = items.filter { (item) -> Bool in
            if item.count < 41 {
                return false
            }
            
            let itemOwnership = item[QCEWDataFileIndex.ownershipCode.rawValue]
            let itemIndustryCode = item[QCEWDataFileIndex.industryCode.rawValue]
            let itemAggLvlCode = item[QCEWDataFileIndex.aggLvlCode.rawValue]
            let itemEstablishmentSize = item[QCEWDataFileIndex.sizeCode.rawValue]
            
            if ownership.rawValue == itemOwnership &&
                industryCode.rawValue == itemIndustryCode &&
                aggLevelCode.rawValue == itemAggLvlCode &&
                size.rawValue == itemEstablishmentSize {
                return true
            }
            
            return false
        }
            
        guard filteredResults.count > 0, let item = filteredResults.first else {return nil}
        
        let areaCode = item[QCEWDataFileIndex.areaCode.rawValue]
        let ownershipCode = OwnershipCode(rawValue: item[QCEWDataFileIndex.ownershipCode.rawValue])!
        let industryCode = IndustryCode(rawValue:item[QCEWDataFileIndex.industryCode.rawValue])!
        let size = EstablishmentSize(rawValue:  item[QCEWDataFileIndex.sizeCode.rawValue])!
        let year = item[QCEWDataFileIndex.year.rawValue]
        let qtr = item[QCEWDataFileIndex.qtr.rawValue]
        let disclosureCode = item[QCEWDataFileIndex.disclosureCode.rawValue]
        let month1EmpLevel = item[QCEWDataFileIndex.month1Emplvl.rawValue]
        let month2EmpLevel = item[QCEWDataFileIndex.month2Emplvl.rawValue]
        let month3EmpLevel = item[QCEWDataFileIndex.month3Emplvl.rawValue]
        let totalQtryWage = item[QCEWDataFileIndex.totalQtrlyWages.rawValue]
        let avgWeeklyWage = item[QCEWDataFileIndex.avgWeeklyWage.rawValue]
        let otyDisclosureCode = item[QCEWDataFileIndex.otyDisclosureCode.rawValue]
        let otyMonth1EmplvlChange = item[QCEWDataFileIndex.otyMonth1EmplvlChange.rawValue]
        let otyMonth1EmplvlPctChange = item[QCEWDataFileIndex.otyMonth1EmplvlPctChange.rawValue]
        let otyMonth2EmplvlChange = item[QCEWDataFileIndex.otyMonth2EmplvlChange.rawValue]
        let otyMonth2EmplvlPctChange = item[QCEWDataFileIndex.otyMonth2EmplvlPctChange.rawValue]
        let otyMonth3EmplvlChange = item[QCEWDataFileIndex.otyMonth3EmplvlChange.rawValue]
        let otyMonth3EmplvlPctChange = item[QCEWDataFileIndex.otyMonth3EmplvlPctChange.rawValue]
        let otyTotalQtrlyWageChange = item[QCEWDataFileIndex.otyTotalQtrlyWageChange.rawValue]
        let otyTotalQtrlyWagePctChange = item[QCEWDataFileIndex.otyTotalQtrlyWagePctChange.rawValue]
        let otyAvgWklyWageChange = item[QCEWDataFileIndex.otyAvgWklyWageChange.rawValue]
        let otyAvgWklyWagePctChange = item[QCEWDataFileIndex.otyAvgWklyWagePctChange.rawValue]

        return QCEWData(areaCode: areaCode, ownershipCode: ownershipCode, industryCode: industryCode, size: size, year: year, qtr: qtr, disclosureCode: disclosureCode, month1EmpLevel: month1EmpLevel, month2EmpLevel: month2EmpLevel, month3EmpLevel: month3EmpLevel, totalQtryWage: totalQtryWage, avgWeeklyWage: avgWeeklyWage, otyDisclosureCode: otyDisclosureCode, otyMonth1EmplvlChange: otyMonth1EmplvlChange, otyMonth1EmplvlPctChange: otyMonth1EmplvlPctChange, otyMonth2EmplvlChange: otyMonth2EmplvlChange, otyMonth2EmplvlPctChange: otyMonth2EmplvlPctChange, otyMonth3EmplvlChange: otyMonth3EmplvlChange, otyMonth3EmplvlPctChange: otyMonth3EmplvlPctChange, otyTotalQtrlyWageChange: otyTotalQtrlyWageChange, otyTotalQtrlyWagePctChange: otyTotalQtrlyWagePctChange, otyAvgWklyWageChange: otyAvgWklyWageChange, otyAvgWklyWagePctChange: otyAvgWklyWagePctChange)
    }
    
    class func getSeriesId(forArea area: Area, ownershipCode: OwnershipCode, industryCode:
                IndustryCode, establishmentSize: EstablishmentSize,
                dataTypeCode: DataTypeCode, adjustment: SeasonalAdjustment) -> SeriesId? {
        
        guard var areaCode = area.code else { return nil}
        
        if area is National {
            areaCode = "US000"
        }
        
        let seriesId = "EN" + adjustment.rawValue  + areaCode + dataTypeCode.rawValue + establishmentSize.rawValue + ownershipCode.rawValue + industryCode.rawValue
        
        return seriesId
    }
}
