//
//  ItemViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation

enum OccupationDataType {
    case MeanAnnualWage
    case EmploymentLevel
}


class OccupationViewModel: ItemViewModel {
    
    var dataTypes: [OESReport.DataTypeCode] = [.annualMeanWage, .employment]
    var localMeanAnnualWageReport:[ReportType: AreaReport]?
    var localEmploymentLevelReport:[ReportType: AreaReport]?
    
    var currentDataType: OESReport.DataTypeCode = .annualMeanWage
    init(area: Area, parent: Item? = nil, dataYear: String) {
        super.init(area: area, parent:parent, itemType: OE_Occupation.self, dataYear: dataYear)
    }
    
    override func createInstance(forParent parent: Item) -> ItemViewModel {
        return OccupationViewModel(area: area, parent: parent, dataYear: dataYear)
    }

    
    override func getReportType(for item: Item) -> ReportType? {
        let reportType: ReportType?
        if let code = item.code {
            reportType = ReportType.occupationEmployment(occupationalCode: code, currentDataType)
        }
        else {
            reportType = nil
        }

        return reportType
    }
    
    override func getReportValue(item: Item) -> String? {
        
        guard let reportType = getReportType(for: item) else { return nil }
        
        if currentDataType == .annualMeanWage {
            return localMeanAnnualWageReport?[reportType]?.seriesReport?.latestData()?.value
        }
        else if currentDataType == .employment {
            return localEmploymentLevelReport?[reportType]?.seriesReport?.latestData()?.value
        }
        
        return nil
    }
    
    override func loadReport(completion: @escaping () -> Void) {
        if currentDataType == .annualMeanWage {
            if localMeanAnnualWageReport == nil {
                // Load the report from Server
                loadReportFromAPI(completion: completion)
            }
            else {
                    // return the report
                completion()
            }
        }
        else if currentDataType == .employment {
            if localMeanAnnualWageReport == nil {
                loadReportFromAPI(completion: completion)
            }
            else {
                // return the report
                completion()
            }
        }
    }
    
    func loadReportFromAPI(completion: @escaping () -> Void) {
        super.loadReportFromAPI {
            [weak self] (apiResult) in
            guard let strongSelf = self else { return }
            
            switch apiResult {
                case .success(let areaReportsDict):
                    if strongSelf.currentDataType == .annualMeanWage {
                        strongSelf.localMeanAnnualWageReport = areaReportsDict
                    }
                case .failure(let error):
                    print(error)
            }
            completion()
        }
    }
}
