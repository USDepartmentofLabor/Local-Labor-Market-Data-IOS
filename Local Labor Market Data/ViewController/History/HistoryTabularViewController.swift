//
//  HistoryTabularViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 10/30/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class HistoryTabularViewController: UIViewController, HistoryViewProtocol {
    var viewModel: HistoryViewModel?

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var monthYearTitleLabel: UILabel!
    @IBOutlet weak var localTitleLabel: UILabel!
    @IBOutlet weak var nationalTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        displayInfo()
    }
    
    func setupView() {
        monthYearTitleLabel.scaleFont(forDataType: .itemParentTitle)
        localTitleLabel.scaleFont(forDataType: .itemParentTitle)
        nationalTitleLabel.scaleFont(forDataType: .itemParentTitle)
        
        localTitleLabel.text = viewModel?.area.displayType ?? ""
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        view.accessibilityElements = [monthYearTitleLabel as Any, localTitleLabel as Any, nationalTitleLabel as Any, tableView as Any]
    }
    
    func displayInfo() {
        if viewModel?.area is National {
            nationalTitleLabel.isHidden = true
        }
    }
}


extension HistoryTabularViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if let localSeriesReport = viewModel?.localAreaReport.seriesReport,
            localSeriesReport.data.count > 0 {
            rowCount = localSeriesReport.data.count
            
        }
        else if let nationaSeriesReport = viewModel?.nationalAreaReport?.seriesReport {
            rowCount = nationaSeriesReport.data.count
        }
        
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryUnemploymentCellId") as! HistoryUnemploymentTableViewCell

        if let localSeriesReport = viewModel?.localAreaReport.seriesReport,
        localSeriesReport.data.count > indexPath.row  {
            let seriesData = localSeriesReport.data[indexPath.row]
            cell.timePeriodLabel.text = "\(seriesData.periodName) \(seriesData.year)"
            cell.localValueLabel.text = "\(seriesData.value)%"
            cell.localValueLabel.accessibilityLabel = "\(viewModel?.area.displayType ?? "") \(seriesData.value)%"
            
            // If area is National, don't display National Data again
            if viewModel?.area is National {
                cell.nationalValueLabel.isHidden = true
            }
            else {
            let nationalSeriesData = viewModel?.nationalAreaReport?.seriesReport?.data(forPeriodName: seriesData.periodName, forYear: seriesData.year)
            
            if let nationalValue = nationalSeriesData?.value {
                cell.nationalValueLabel.text = "\(nationalValue)%"
                cell.nationalValueLabel.accessibilityLabel = "National \(nationalValue)%"
            }
            else {
                cell.nationalValueLabel.text = ReportManager.dataNotAvailableStr
                cell.nationalValueLabel.accessibilityLabel = "National  \(ReportManager.dataNotAvailableAccessibilityStr)"
            }
            }
        }
        else if let nationaSeriesReport = viewModel?.nationalAreaReport?.seriesReport,
            nationaSeriesReport.data.count > indexPath.row {
            let nationalSeriesData = nationaSeriesReport.data[indexPath.row] 
            cell.timePeriodLabel.text = "\(nationalSeriesData.periodName) \(nationalSeriesData.year)"
            cell.localValueLabel.text = (ReportManager.dataNotAvailableStr)
            cell.localValueLabel.accessibilityLabel = "\(viewModel?.area.displayType ?? "") \(ReportManager.dataNotAvailableAccessibilityStr)"
            cell.nationalValueLabel.text = "\(nationalSeriesData.value)%"
            cell.nationalValueLabel.accessibilityLabel = "National \(nationalSeriesData.value)%"
        }

        return cell
    }
    
    func displayHistoryData() {
        tableView.reloadData()
    }
}
