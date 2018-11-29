//
//  ItemViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/26/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

struct ReportItem<T> {
    var item: T
    var reportTypes: [ReportType]?
}

class ItemViewController<T: Item>: UITableViewController {
    var area: Area
    var parentItem: T?
    var reportItems: [ReportItem<T>]?
    
    var reportResultsdict: [ReportType : AreaReport]?
    
    init(area: Area, parentItem: T? = nil, title: String) {
        self.area = area
        self.parentItem = parentItem
        super.init(style: .plain)
        self.title = title
        
        let items: [T]?
        if parentItem == nil {
            items = T.getSuperParents(context: CoreDataManager.shared().viewManagedContext)
        }
        else {
            items = parentItem?.subItems() as? [T]
        }
        reportItems = items?.compactMap({ (item) -> ReportItem<T> in
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
            
            return ReportItem<T>(item: item, reportTypes: reportTypes)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        loadReports()
    }
    
// MARK: TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")

        if let reportItem = reportItems?[indexPath.row] {
            cell.textLabel?.text = reportItem.item.title
        
            if (reportItem.item.children?.count ?? 0) > 0 {
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            }
            else {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let reportItem = reportItems?[indexPath.row] {
            let item = reportItem.item
            if (item.children?.count ?? 0) > 0 {
                let vc = ItemViewController(area: area, parentItem: item, title: item.title ?? "")
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


// MARK: SeriesId
extension ItemViewController {
    func loadReports() {

        if let reportTypes = reportItems?.compactMap({$0.reportTypes}).flatMap({$0}) {
            ReportManager.getReports(forArea: area, reportTypes: reportTypes,
                                 seasonalAdjustment: SeasonalAdjustment.adjusted) {
                [weak self] (apiResult) in
                guard let strongSelf = self else {return}
                
                switch apiResult {
                case .success(let areaReportsDict):
                    strongSelf.displayReportResults(areaReportsDict: areaReportsDict)
                case .failure(let error):
                    strongSelf.handleError(error: error)
                }
            }
        }
    }
    
    func displayReportResults(areaReportsDict: ([ReportType : AreaReport])) {
        print("Reports")
        reportResultsdict = areaReportsDict
        tableView.reloadData()
    }
}
