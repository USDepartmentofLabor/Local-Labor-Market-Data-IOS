//
//  ItemViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/26/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {
    var viewModel: ItemViewModel!
    
    @IBOutlet weak var areaTitleLabel: UILabel!
    @IBOutlet weak var seasonallyAdjustedSwitch: UICustomSwitch!
    @IBOutlet weak var seasonallyAdjustedTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var reportPeriodLabel: UILabel!
    @IBOutlet weak var parentTitleLabel: UILabel!
    @IBOutlet weak var parentValueLabel: UILabel!
    
    lazy var activityIndicator = ActivityIndicatorView(text: "Loading", inView: view)
//    lazy var searchController = UISearchController(searchResultsController: nil)
    var searchController = UISearchController(searchResultsController: nil)

    var seasonalAdjustment: SeasonalAdjustment {
        get {
            return ReportManager.seasonalAdjustment
        }
        set(newValue) {
            ReportManager.seasonalAdjustment = newValue
            loadReports()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(displaySearchBar(sender:)))
        
        areaTitleLabel.scaleFont(forDataType: .reportAreaTitle, for:traitCollection)
        seasonallyAdjustedSwitch.tintColor = #colorLiteral(red: 0.1607843137, green: 0.2117647059, blue: 0.5137254902, alpha: 1)
        seasonallyAdjustedSwitch.onTintColor = #colorLiteral(red: 0.1607843137, green: 0.2117647059, blue: 0.5137254902, alpha: 1)
        seasonallyAdjustedTitle.scaleFont(forDataType: .seasonallyAdjustedSwitch, for: traitCollection)

        areaTitleLabel.text = viewModel.area.title
        seasonallyAdjustedSwitch.isOn = (seasonalAdjustment == .adjusted) ? true:false
        setupAccessbility()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        if viewModel.items?.count ?? 0 > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }

        parentTitleLabel.text = viewModel.parentItem.title
        parentValueLabel.text = ""
        reportPeriodLabel.text = ""
        
        loadReports()
    }
    
    func setupAccessbility() {
        seasonallyAdjustedSwitch.accessibilityLabel = "Seasonally Adjusted"
        seasonallyAdjustedTitle.isAccessibilityElement = false
        tableView.isAccessibilityElement = false
        areaTitleLabel.accessibilityTraits = UIAccessibilityTraits.header
        areaTitleLabel.accessibilityLabel = viewModel.area.accessibilityStr
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIndustries",
            let destVC = segue.destination as? ItemViewController {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow,
                let selectedItem = viewModel.items?[selectedIndexPath.row] {
            
                let vm = viewModel.createInstance(forParent: selectedItem)
                destVC.viewModel = vm
                destVC.title = selectedItem.title
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showIndustries" {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow,
                let selectedItem = viewModel.items?[selectedIndexPath.row],
                selectedItem.children?.count ?? 0 > 0 {
                return true
            }
            return false
        }
        
        return true
    }
    
    @IBAction func seasonallyAdjustClick(_ sender: Any) {
        seasonalAdjustment = seasonallyAdjustedSwitch.isOn ? .adjusted : .notAdjusted
    }
    
    @objc func displaySearchBar(sender: Any) {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

// MARK: TableView DataSource
extension ItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCellId") as! ItemTableViewCell

        if let item = viewModel.items?[indexPath.row] {
            let title = item.title! + "(" + item.code! + ")"
            cell.titleLabel?.text = title

            let latestData = viewModel.getReportLatestData(item: item)
            cell.valueLabel.text = latestData?.value ?? ReportManager.dataNotAvailableStr
            if let seriesData = viewModel.getNationalReportData(item: item, period: latestData?.period, year: latestData?.year) {
                cell.nationalValueLabel.text = seriesData.value
            }
            else {
                cell.nationalValueLabel.text = ""
            }
        
            if (item.children?.count ?? 0) > 0 {
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
}

extension ItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
/*
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView =
            tableView.dequeueReusableHeaderFooterView(withIdentifier: ItemHeaderView.reuseIdentifier) as? ItemHeaderView
            else { return nil }
        
        
        let currentSection = sections[section]
        sectionHeaderView.configure(title: currentSection.title, section: section,
                                    collapse: currentSection.collapsed)
        
        if currentSection.title != Section.UnemploymentRateTitle {
            sectionHeaderView.infoButton.isHidden = false
        }
        else {
            sectionHeaderView.infoButton.isHidden = true
        }
        
        sectionHeaderView.delegate = self
        return sectionHeaderView
    }
*/
}


// MARK: SeriesId
extension ItemViewController {
    func loadReports() {
        activityIndicator.startAnimating(disableUI: true)
        viewModel.loadReport(seasonalAdjustment: seasonalAdjustment) {
            [weak self] () in
            guard let strongSelf = self else {return}
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.tableView.reloadData()
            strongSelf.parentValueLabel.text = strongSelf.viewModel.getParentReportValue()
            strongSelf.reportPeriodLabel.text = strongSelf.viewModel.getReportPeriod()
        }
    }
    
    func displayReportResults(areaReportsDict: ([ReportType : AreaReport])) {
        print("Reports")
//        reportResultsdict = areaReportsDict
        tableView.reloadData()
    }
}

extension ItemViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
}
