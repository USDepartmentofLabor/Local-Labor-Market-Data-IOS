//
//  HistoryTableViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 4/2/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class HistoryTableViewController: UIViewController {

    var viewModel: HistoryViewModel!

    @IBOutlet weak var localTitleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        displayInfo()
    }
    

    func setupView() {
        
    }
    
    func displayInfo() {
        localTitleLabel.text = "\(viewModel.area.displayType) Data"
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HistoryTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.localAreaReport.seriesReport?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.reuseIdentifier) as! HistoryTableViewCell
        
        if let seriesData = viewModel.localAreaReport.seriesReport?.data[indexPath.row] {
            cell.monthYearLabel.text = "\(seriesData.periodName) \(seriesData.year)"
            
            let suffix: String
            switch viewModel.localAreaReport.reportType {
            case .unemployment(_):
                suffix = "%"
            default:
                suffix = ""
            }
            
            cell.localValueLabel.text = "\(seriesData.value)\(suffix)"
            
            let nationalSeriesData = viewModel.nationalAreaReport?.seriesReport?.data(forPeriod: seriesData.period, forYear: seriesData.year)
            if let nationalValue = nationalSeriesData?.value {
                cell.nationalValueLabel.text = "\(nationalValue)\(suffix)"
            }
            else {
                cell.nationalValueLabel.text = ""
            }
        }
        
        return cell
    }
}
