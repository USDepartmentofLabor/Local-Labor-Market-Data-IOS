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
    
    @IBOutlet weak var seasonallyAdjustedView: UIView!
    @IBOutlet weak var seasonallyAdjustedSwitch: UICustomSwitch!
    @IBOutlet weak var seasonallyAdjustedTitle: UILabel!
    
    @IBOutlet weak var reportPeriodLabel: UILabel!
    
    @IBOutlet weak var anscestorsLabel: UILabel!
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var parentTitleLabel: UILabel!
    @IBOutlet weak var dataTypeButton: UIButton!

    @IBOutlet weak var tableView: UITableView!

    // Occupation
        // Title View
    @IBOutlet weak var occupationalTitleStackView: UIStackView!
    @IBOutlet weak var occupationDataTypeTitleLabel: UILabel!
    @IBOutlet weak var occupationLocalTitleButton: UIButton!
    @IBOutlet weak var occupationNationalTitleButton: UIButton!
        //Parent View
    @IBOutlet weak var occupationParentStackView: UIStackView!
    @IBOutlet weak var occupationParentValueLabel: UILabel!
    @IBOutlet weak var occupationParentNationalValueLabel: UILabel!

    // CES Industry
        //Title
    @IBOutlet weak var cesTitleStackView: UIStackView!
    @IBOutlet weak var cesDataTypeTitleLabel: UILabel!
    @IBOutlet weak var cesLocalTitleButton: UIButton!
    @IBOutlet weak var cesOneMonthChangeTitleButton: UIButton!
    @IBOutlet weak var cesTwelveMonthChangeTitleButton: UIButton!
        //Parent
    @IBOutlet weak var cesParentStackView: UIStackView!
    @IBOutlet weak var cesParentValueLabel: UILabel!
    @IBOutlet weak var cesParentOneMonthValueLabel: UILabel!
    @IBOutlet weak var cesParentOneMonthPercentLabel: UILabel!
    @IBOutlet weak var cesParentTwelveMonthValueLabel: UILabel!
    @IBOutlet weak var cesParentTwelveMonthPercentLabel: UILabel!

    
    // QCEW Industry
        //Title
    @IBOutlet weak var qcewTitleStackView: UIStackView!
    @IBOutlet weak var qcewDataTypeTitleLabel: UILabel!
    @IBOutlet weak var qcewNationalTitleStackView: UIStackView!
    @IBOutlet weak var qcewLocalTitleButton: UIButton!
    @IBOutlet weak var qcewLocalTwelveMonthChangeTitleButton: UIButton!
    @IBOutlet weak var qcewNationalTitleButton: UIButton!
    @IBOutlet weak var qcewNationalTwelveMonthChangeTitleButton: UIButton!
        // Parent
    @IBOutlet weak var qcewParentStackView: UIStackView!
    
    @IBOutlet weak var qcewNationalParentStackView: UIStackView!
    @IBOutlet weak var qcewParentValueLabel: UILabel!
    @IBOutlet weak var qcewParentTwelveMonthValueLabel: UILabel!
    @IBOutlet weak var qcewParentTwelveMonthPercentLabel: UILabel!
    @IBOutlet weak var qcewParentNationalValueLabel: UILabel!
    @IBOutlet weak var qcewParentNationalTwelveMonthValueLabel: UILabel!
    @IBOutlet weak var qcewParentNationalTwelveMonthPercentLabel: UILabel!

    @IBOutlet weak var ownershipLabel: UILabel!
    
    lazy var activityIndicator = ActivityIndicatorView(text: "Loading", inView: view)
    
    var seasonalAdjustment: SeasonalAdjustment = .notAdjusted {
        didSet {
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
        ownershipLabel.scaleFont(forDataType: .itemPeriodName, for:traitCollection)
        reportPeriodLabel.scaleFont(forDataType: .itemPeriodName, for:traitCollection)
        itemTitleLabel.scaleFont(forDataType: .itemColumnTitle)
        dataTypeButton.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        dataTypeButton.layer.borderWidth = 1.0
        dataTypeButton.layer.cornerRadius = 10
        dataTypeButton.titleLabel?.scaleFont(forDataType: .itemDataType)
        seasonallyAdjustedSwitch.tintColor = #colorLiteral(red: 0.1607843137, green: 0.2117647059, blue: 0.5137254902, alpha: 1)
        seasonallyAdjustedSwitch.onTintColor = #colorLiteral(red: 0.1607843137, green: 0.2117647059, blue: 0.5137254902, alpha: 1)
        seasonallyAdjustedTitle.scaleFont(forDataType: .seasonallyAdjustedSwitch, for: traitCollection)

        parentTitleLabel.scaleFont(forDataType: .itemParentTitle)
        
        itemTitleLabel.text = viewModel.dataTitle
        areaTitleLabel.text = viewModel.area.title
        setupAccessbility()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        if viewModel.items?.count ?? 0 > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        
        if viewModel is OccupationViewModel {
            setupOccupationView()
        }
        else if viewModel is QCEWIndustryViewModel {
            setupQCEWView()
        }
        else {
            setupCESView()
        }

        displayAnscestors()
        
        let title: String
        if viewModel is QCEWIndustryViewModel {
            title = viewModel.parentItem.title ?? ""
        }
        else {
            title = "\(viewModel.parentItem.title ?? "") (\(viewModel.parentItem.code ?? ""))"
        }
        parentTitleLabel.text = title
        reportPeriodLabel.text = ""
        
        if viewModel.itemDataTypes.count > 1 {
            dataTypeButton.isHidden = false
        }
        else {
            dataTypeButton.isHidden = true
            dataTypeButton.removeFromSuperview()
        }

        if viewModel is OccupationViewModel || viewModel is QCEWIndustryViewModel {
            seasonalAdjustment = .notAdjusted
        }
        else {
            if viewModel.area is National || viewModel.area is State {
                seasonalAdjustment = .adjusted
            }
            else {
                seasonalAdjustment = .notAdjusted
            }
        }

        seasonallyAdjustedSwitch.isOn = (seasonalAdjustment == .adjusted) ? true:false
    }
    
    func setupOccupationView() {
        cesTitleStackView.removeFromSuperview()
        cesParentStackView.removeFromSuperview()
        
        qcewTitleStackView.removeFromSuperview()
        qcewParentStackView.removeFromSuperview()
        
        seasonallyAdjustedView.removeFromSuperview()
        ownershipLabel.removeFromSuperview()

        occupationDataTypeTitleLabel.scaleFont(forDataType: .itemColumnTitle)
        occupationLocalTitleButton.titleLabel?.scaleFont(forDataType: .itemColumnTitle)
        occupationNationalTitleButton.titleLabel?.scaleFont(forDataType: .itemColumnTitle)
        occupationParentValueLabel.scaleFont(forDataType: .itemParentValue)
        occupationParentNationalValueLabel.scaleFont(forDataType: .itemParentValue)

        if viewModel.isNationalReport {
            occupationNationalTitleButton.removeFromSuperview()
            occupationParentNationalValueLabel.removeFromSuperview()
        }
        
        occupationLocalTitleButton.setTitle(viewModel.area.displayType, for: .normal)
        occupationParentValueLabel.text = ""
    }
    
    func setupCESView() {
        occupationalTitleStackView.removeFromSuperview()
        occupationParentStackView.removeFromSuperview()
        
        qcewTitleStackView.removeFromSuperview()
        qcewParentStackView.removeFromSuperview()
        ownershipLabel.removeFromSuperview()


        cesDataTypeTitleLabel.scaleFont(forDataType: .itemColumnTitle)
        cesLocalTitleButton.titleLabel?.scaleFont(forDataType: .itemColumnTitle)
        cesOneMonthChangeTitleButton.titleLabel?.scaleFont(forDataType: .itemSubColumnTitle)
        cesTwelveMonthChangeTitleButton.titleLabel?.scaleFont(forDataType: .itemSubColumnTitle)
        
        cesParentValueLabel.scaleFont(forDataType: .itemParentValue)
        
        cesLocalTitleButton.setTitle(viewModel.area.displayType, for: .normal)
        cesParentValueLabel.text = ""
    }
    
    func setupQCEWView() {
        guard let vm = viewModel as? QCEWIndustryViewModel else {
            return
        }

        occupationalTitleStackView.removeFromSuperview()
        occupationParentStackView.removeFromSuperview()

        cesTitleStackView.removeFromSuperview()
        cesParentStackView.removeFromSuperview()

        qcewDataTypeTitleLabel.scaleFont(forDataType: .itemColumnTitle)
        qcewLocalTitleButton.titleLabel?.scaleFont(forDataType: .itemColumnTitle)
        qcewNationalTitleButton.titleLabel?.scaleFont(forDataType: .itemColumnTitle)
        qcewLocalTwelveMonthChangeTitleButton.titleLabel?.scaleFont(forDataType: .itemSubColumnTitle)
        qcewNationalTwelveMonthChangeTitleButton.titleLabel?.scaleFont(forDataType: .itemSubColumnTitle)
        
        if viewModel.isNationalReport {
            qcewNationalTitleStackView.removeFromSuperview()
            qcewNationalParentStackView.removeFromSuperview()
        }

        ownershipLabel.isHidden = false
        ownershipLabel.text = "\(vm.ownershipCode.title)"
        qcewLocalTitleButton.setTitle(viewModel.area.displayType, for: .normal)
    }
    
    func setupAccessbility() {
        seasonallyAdjustedSwitch.accessibilityLabel = "Seasonally Adjusted"
        seasonallyAdjustedTitle.isAccessibilityElement = false
        tableView.isAccessibilityElement = false
        areaTitleLabel.accessibilityTraits = UIAccessibilityTraits.header
        areaTitleLabel.accessibilityLabel = viewModel.area.accessibilityStr
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIndustries" || segue.identifier == "showCESIndustries" ||
                        segue.identifier == "showQCEWIndustries",
            let destVC = segue.destination as? ItemViewController {
            
            var selectedItem: Item?
            
            if let item = sender as? Item {
                selectedItem = item
            }
            else if let selectedIndexPath = tableView.indexPathForSelectedRow {
                selectedItem = viewModel.items?[selectedIndexPath.row]
            }
            if let selectedItem = selectedItem {
                let vm = viewModel.createInstance(forParent: selectedItem)
                destVC.viewModel = vm
                destVC.title = selectedItem.title
            }
        }
        else if segue.identifier == "showDataTypes" {
            if let popoverViewController = segue.destination as? DataTypeViewController {
                popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                popoverViewController.itemDataTypes = viewModel.itemDataTypes
                popoverViewController.delegate = self
                popoverViewController.popoverPresentationController!.delegate = self
                popoverViewController.popoverPresentationController?.sourceRect = (sender as! UIView).bounds
            }
        }
        else if segue.identifier == "searchItem",
            let destVC = segue.destination as? SearchItemViewController {
            let searchViewModel = SearchItemViewModel(itemViewModel: viewModel)
            destVC.viewModel = searchViewModel
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showIndustries" || identifier == "showCESIndustries" ||
            identifier == "showQCEWIndustries" {
            
            if sender is Item {
                return true
            }
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow,
                let selectedItem = viewModel.items?[selectedIndexPath.row],
                selectedItem.children?.count ?? 0 > 0 {
                return true
            }
            return false
        }
        
        return true
    }
    
    @IBAction func displaySearchBar(sender: Any) {
        if let searchController = navigationController?.containsViewController(ofKind: SearchItemViewController.self) {
            navigationController?.popToViewController(searchController, animated: false)
        }
        else {
            performSegue(withIdentifier: "searchItem", sender: nil)
        }

    }
    
    @IBAction func seasonallyAdjustClick(_ sender: Any) {
        seasonalAdjustment = seasonallyAdjustedSwitch.isOn ? .adjusted : .notAdjusted
    }
    
    @IBAction func localBtnClick(_ sender: Any) {
        guard viewModel.currentDataType.localReport != nil else {
            return
        }
        if case .local(let asc) = viewModel.dataSort {
            viewModel.dataSort = .local(ascending: !asc)
        }
        else {
            viewModel.dataSort = .local(ascending: true)
        }
        
        reloadData()
    }
    
    @IBAction func nationalBtnClick(_ sender: Any) {
        guard viewModel.currentDataType.nationalReport != nil else {
            return
        }
        
        if case .national(let asc) = viewModel.dataSort {
            viewModel.dataSort = .national(ascending: !asc)
        }
        else {
            viewModel.dataSort = .national(ascending: true)
        }
        reloadData()
    }
    
    @IBAction func oneMonthBtnClick(_ sender: Any) {
        guard viewModel.currentDataType.localReport != nil else {
            return
        }

        if case .localOneMonthChange(let asc) = viewModel.dataSort {
            viewModel.dataSort = .localOneMonthChange(ascending: !asc)
        }
        else {
            viewModel.dataSort = .localOneMonthChange(ascending: true)
        }
        
        reloadData()
    }
    @IBAction func twelveMonthBtnClick(_ sender: Any) {
        guard viewModel.currentDataType.localReport != nil else {
            return
        }

        if case .localTwelveMonthChange(let asc) = viewModel.dataSort {
            viewModel.dataSort = .localTwelveMonthChange(ascending: !asc)
        }
        else {
            viewModel.dataSort = .localTwelveMonthChange(ascending: true)
        }
        
        reloadData()
    }
    @IBAction func natioanlTwelveMonthBtnClick(_ sender: Any) {
        guard viewModel.currentDataType.nationalReport != nil else {
            return
        }

        if case .nationalTwelveMonthChange(let asc) = viewModel.dataSort {
            viewModel.dataSort = .nationalTwelveMonthChange(ascending: !asc)
        }
        else {
            viewModel.dataSort = .nationalTwelveMonthChange(ascending: true)
        }
        
        reloadData()
    }

    func reloadData() {
        displaySort()
        tableView.reloadData()
    }
    
    func displaySort() {
        var localSortImage = #imageLiteral(resourceName: "noSort")
        var nationalSortImage = #imageLiteral(resourceName: "noSort")
        var localOneMonthChangeSortImage = #imageLiteral(resourceName: "noSort")
        var localTwelveMonthChangeSortImage = #imageLiteral(resourceName: "noSort")
        var nationalTwelveMonthChangeSortImage = #imageLiteral(resourceName: "noSort")
        
        switch viewModel.dataSort {
        case .local(let asc):
            localSortImage = (asc == true) ? #imageLiteral(resourceName: "ascSort") : #imageLiteral(resourceName: "descSort")
        case .national(let asc):
            nationalSortImage = (asc == true) ? #imageLiteral(resourceName: "ascSort") : #imageLiteral(resourceName: "descSort")
        case .localOneMonthChange(let asc):
            localOneMonthChangeSortImage = (asc == true) ? #imageLiteral(resourceName: "ascSort") : #imageLiteral(resourceName: "descSort")
        case .localTwelveMonthChange(let asc):
            localTwelveMonthChangeSortImage = (asc == true) ? #imageLiteral(resourceName: "ascSort") : #imageLiteral(resourceName: "descSort")
        case .nationalTwelveMonthChange(let asc):
            nationalTwelveMonthChangeSortImage = (asc == true) ? #imageLiteral(resourceName: "ascSort") : #imageLiteral(resourceName: "descSort")
        case .none: break
            
        }
        
        if viewModel is OccupationViewModel {
            occupationLocalTitleButton.setImage(localSortImage, for: .normal)
            occupationNationalTitleButton.setImage(nationalSortImage, for: .normal)
        }
        else if viewModel is QCEWIndustryViewModel {
            qcewLocalTitleButton.setImage(localSortImage, for: .normal)
            qcewLocalTwelveMonthChangeTitleButton.setImage(localTwelveMonthChangeSortImage, for: .normal)
            qcewNationalTitleButton.setImage(nationalSortImage, for: .normal)
            qcewNationalTwelveMonthChangeTitleButton.setImage(nationalTwelveMonthChangeSortImage, for: .normal)
        }
        else {
            cesLocalTitleButton.setImage(localSortImage, for: .normal)
            cesOneMonthChangeTitleButton.setImage(localOneMonthChangeSortImage, for: .normal)
            cesTwelveMonthChangeTitleButton.setImage(localTwelveMonthChangeSortImage, for: .normal)
        }
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
        let cell: UITableViewCell
        
        if case .industryEmployment(_, _) = viewModel.currentDataType.reportType {
            let cesCell = tableView.dequeueReusableCell(withIdentifier: "CESCellId") as! ItemCESTableViewCell
            configureCell(cell: cesCell, indexPath: indexPath)
            cell = cesCell
        }
        else if case .quarterlyEmploymentWage(_, _, _, _) = viewModel.currentDataType.reportType {
            let qcewCell = tableView.dequeueReusableCell(withIdentifier: "QCEWCellId") as! ItemQCEWTableViewCell
            configureCell(cell: qcewCell, indexPath: indexPath)
            cell = qcewCell
        }
        else {
            let itemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCellId") as! ItemTableViewCell
            configureCell(cell: itemCell, indexPath: indexPath)
            cell = itemCell
        }
        return cell
    }
    
    func configureCell(cell: ItemTableViewCell, indexPath: IndexPath) {
        if let item = viewModel.items?[indexPath.row] {
            let title = item.title ?? "" + "(" + item.code! + ")"
            cell.titleLabel?.text = title

            if (item.children?.count ?? 0) > 0 {
                cell.nextImageView.isHidden = false
            }
            else {
                cell.nextImageView.isHidden = true
            }

            guard viewModel.isDataDownloaded else {
                cell.valueLabel.text = ""
                if cell.nationalValueLabel != nil {
                    cell.nationalValueLabel.text = ""
                }
                return
            }
            
             cell.valueLabel.text = viewModel.getReportValue(item: item) ?? ReportManager.dataNotAvailableStr
            
            if viewModel.isNationalReport {
                if let nationalValueLabel = cell.nationalValueLabel {
                    nationalValueLabel.removeFromSuperview()
                }
            }
            else {
                cell.nationalValueLabel.text = viewModel.getNationalReportValue(item: item) ?? ReportManager.dataNotAvailableStr
            }
        }
    }
    
    func configureCell(cell: ItemCESTableViewCell, indexPath: IndexPath) {
        if let item = viewModel.items?[indexPath.row] {
            let title = item.title ?? "" + "(" + item.code! + ")"
            cell.titleLabel?.text = title
            if (item.children?.count ?? 0) > 0 {
                cell.nextImageView.isHidden = false
            }
            else {
                cell.nextImageView.isHidden = true
            }

            guard viewModel.isDataDownloaded else {
                cell.valueLabel.text = ""
                cell.oneMonthValueLabel.text = ""
                cell.oneMonthPercentLabel.text = ""
                cell.twelveMonthValueLabel.text = ""
                cell.twelveMonthPercentLabel.text = ""
                return
            }
            
            if let seriesData = viewModel.getReportData(item: item) {
                cell.valueLabel.text = viewModel.getReportValue(from: seriesData) ?? ReportManager.dataNotAvailableStr
                
                // Display Percent Change
                if let percentChange = seriesData.calculations?.percentChanges {
                    cell.oneMonthPercentLabel.text =
                        NumberFormatter.localisedPercentStr(from: percentChange.oneMonth) ??  ReportManager.dataNotAvailableStr
                    cell.twelveMonthPercentLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
                }
                if let netChange = seriesData.calculations?.netChanges {
                    if let oneMonthChange = netChange.oneMonth, let doubleValue = Double(oneMonthChange) {
                        cell.oneMonthValueLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
                    }
                    else {
                        cell.oneMonthValueLabel.text = ReportManager.dataNotAvailableStr
                    }
                    
                    if let twelveMonthChange = netChange.twelveMonth, let doubleValue = Double(twelveMonthChange) {
                        cell.twelveMonthValueLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
                    }
                    else {
                        cell.twelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
                    }
                }
                else {
                    cell.oneMonthValueLabel.text = ReportManager.dataNotAvailableStr
                    cell.twelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
                }
            }
            else {
                cell.valueLabel.text = ReportManager.dataNotAvailableStr
                cell.oneMonthValueLabel.text = ""
                cell.oneMonthPercentLabel.text = ""
                cell.twelveMonthValueLabel.text = ""
                cell.twelveMonthPercentLabel.text = ""
            }
        }
    }
    
    func configureCell(cell: ItemQCEWTableViewCell, indexPath: IndexPath) {
        if let item = viewModel.items?[indexPath.row] {
            cell.titleLabel?.text = item.title
            if (item.children?.count ?? 0) > 0 {
                cell.nextImageView.isHidden = false
            }
            else {
                cell.nextImageView.isHidden = true
            }

            guard viewModel.isDataDownloaded else {
                cell.valueLabel.text = ""
                cell.twelveMonthValueLabel.text = ""
                cell.twelveMonthPercentLabel.text = ""
                cell.nationalValueLabel.text = ""
                cell.nationalTwelveMonthValueLabel.text = ""
                cell.nationalTwelveMonthPercentLabel.text = ""
                return
            }
            
            if let seriesData = viewModel.getReportData(item: item) {
                cell.valueLabel.text = viewModel.getReportValue(from: seriesData) ?? ReportManager.dataNotAvailableStr
                
                // Display Percent Change
                if seriesData.isNotDisclosable {
                    cell.twelveMonthPercentLabel.text = ""
                    cell.twelveMonthValueLabel.text = ""
                }
                else {
                    if let percentChange = seriesData.calculations?.percentChanges {
                        cell.twelveMonthPercentLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
                    }
                    else {
                        cell.twelveMonthPercentLabel.text = ReportManager.dataNotAvailableStr
                    }

                    if let netChange = seriesData.calculations?.netChanges {
                        if let twelveMonthChange = netChange.twelveMonth, let doubleValue = Double(twelveMonthChange) {
                        cell.twelveMonthValueLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
                        }
                        else {
                            cell.twelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
                        }
                    }
                    else {
                        cell.twelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
                    }
                }
            }
            else {
                cell.valueLabel.text = ReportManager.dataNotAvailableStr
                cell.twelveMonthValueLabel.text = ""
                cell.twelveMonthPercentLabel.text = ""
            }
            
            if let seriesData = viewModel.getNationalReportData(item: item) {
                cell.nationalValueLabel.text = viewModel.getReportValue(from: seriesData) ?? ReportManager.dataNotAvailableStr
                
                // Display Percent Change
                if seriesData.isNotDisclosable {
                    cell.nationalTwelveMonthPercentLabel.text = ""
                    cell.nationalTwelveMonthValueLabel.text = ""
                }
                else {
                    if let percentChange = seriesData.calculations?.percentChanges {
                        cell.nationalTwelveMonthPercentLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
                    }
                    else {
                        cell.nationalTwelveMonthPercentLabel.text = ReportManager.dataNotAvailableStr
                    }
                    if let netChange = seriesData.calculations?.netChanges {
                        if let twelveMonthChange = netChange.twelveMonth, let doubleValue = Double(twelveMonthChange) {
                            cell.nationalTwelveMonthValueLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
                        }
                        else {
                            cell.nationalTwelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
                        }
                    }
                    else {
                        cell.nationalTwelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
                    }
                }
            }
            else {
                cell.nationalValueLabel.text = ReportManager.dataNotAvailableStr
                cell.nationalTwelveMonthValueLabel.text = ""
                cell.nationalTwelveMonthPercentLabel.text = ""
            }
        }
    }
}

extension ItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


// MARK: SeriesId
extension ItemViewController {
    func loadReports() {
        let title = viewModel.currentDataType.title
        if viewModel is OccupationViewModel {
            occupationDataTypeTitleLabel.text = title
            dataTypeButton.setTitle(title, for: .normal)
        }
        else if viewModel is QCEWIndustryViewModel {
            qcewDataTypeTitleLabel.text = title
            dataTypeButton.setTitle(title, for: .normal)
        }
        else {
            cesDataTypeTitleLabel.text = title
        }
        
        activityIndicator.startAnimating(disableUI: true)
        viewModel.loadReport(seasonalAdjustment: seasonalAdjustment) { [weak self] (reportError) in
            guard let strongSelf = self else {return}
            strongSelf.activityIndicator.stopAnimating()
            
            if let error = reportError {
                strongSelf.handleError(error: error)
            }
            else {
                strongSelf.tableView.reloadData()
                strongSelf.displayParentReport()
                strongSelf.reportPeriodLabel.text = strongSelf.viewModel.getReportPeriod()
            }
        }
    }
    
    func displayParentReport() {
        if viewModel is OccupationViewModel {
            displayOccupationParentReport()
        }
        else if viewModel is QCEWIndustryViewModel {
            displayQCEWParentReport()
        }
        else {
            displayCESParentReport()
        }
    }
    
    func displayOccupationParentReport() {
        occupationParentValueLabel.text = viewModel.getParentReportValue() ?? ReportManager.dataNotAvailableStr
        if !viewModel.isNationalReport {
            occupationParentNationalValueLabel.text = viewModel.getParentNationalReportValue() ?? ReportManager.dataNotAvailableStr
        }
    }
    
    func displayCESParentReport() {
        guard let seriesData = viewModel.getReportData(item: viewModel.parentItem) else {
            cesParentValueLabel.text = ReportManager.dataNotAvailableStr
            cesParentOneMonthValueLabel.text = ""
            cesParentOneMonthPercentLabel.text = ""
            cesParentTwelveMonthValueLabel.text = ""
            cesParentTwelveMonthPercentLabel.text = ""
            return
        }
        
        cesParentValueLabel.text = viewModel.getReportValue(from: seriesData) ?? ReportManager.dataNotAvailableStr
            
        // Display Percent Change
        if let percentChange = seriesData.calculations?.percentChanges {
            cesParentOneMonthPercentLabel.text =
                NumberFormatter.localisedPercentStr(from: percentChange.oneMonth) ??  ReportManager.dataNotAvailableStr
            cesParentTwelveMonthPercentLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
        }
        if let netChange = seriesData.calculations?.netChanges {
            if let oneMonthChange = netChange.oneMonth, let doubleValue = Double(oneMonthChange) {
                cesParentOneMonthValueLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
            }
            else {
                cesParentOneMonthValueLabel.text = ReportManager.dataNotAvailableStr
            }
            
            if let twelveMonthChange = netChange.twelveMonth, let doubleValue = Double(twelveMonthChange) {
                cesParentTwelveMonthValueLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
            }
            else {
                cesParentTwelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
            }
        }
        else {
            cesParentOneMonthValueLabel.text = ReportManager.dataNotAvailableStr
            cesParentTwelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
        }
    }
    
    func displayQCEWParentReport() {
        if let seriesData = viewModel.getReportData(item: viewModel.parentItem) {
            qcewParentValueLabel.text = viewModel.getReportValue(from: seriesData) ?? ReportManager.dataNotAvailableStr

            // Display Percent Change
            if let percentChange = seriesData.calculations?.percentChanges {
                qcewParentTwelveMonthPercentLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
            }
            if let netChange = seriesData.calculations?.netChanges {
                if let twelveMonthChange = netChange.twelveMonth, let doubleValue = Double(twelveMonthChange) {
                    qcewParentTwelveMonthValueLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
                }
                else {
                    qcewParentTwelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
                }
            }
            else {
                qcewParentTwelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
            }
        }
        else {
            qcewParentValueLabel.text = ReportManager.dataNotAvailableStr
            qcewParentTwelveMonthValueLabel.text = ""
            qcewParentTwelveMonthPercentLabel.text = ""
        }
        
        
        // National
        if !viewModel.isNationalReport, let seriesData = viewModel.getParentNationalReportData() {
            qcewParentNationalValueLabel.text = viewModel.getReportValue(from: seriesData) ?? ReportManager.dataNotAvailableStr
        
            // Display Twelve Month Change
            if let percentChange = seriesData.calculations?.percentChanges {
                qcewParentNationalTwelveMonthPercentLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
            }
            if let netChange = seriesData.calculations?.netChanges {
                if let twelveMonthChange = netChange.twelveMonth, let doubleValue = Double(twelveMonthChange) {
                    qcewParentNationalTwelveMonthValueLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
                }
                else {
                    qcewParentNationalTwelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
                }
            }
            else {
                qcewParentNationalTwelveMonthValueLabel.text = ReportManager.dataNotAvailableStr
            }
        }
        else {
            qcewParentNationalValueLabel.text = ReportManager.dataNotAvailableStr
            qcewParentNationalTwelveMonthValueLabel.text = ""
            qcewParentNationalTwelveMonthPercentLabel.text = ""
        }
    }
    
    func displayReportResults(areaReportsDict: ([ReportType : AreaReport])) {
        print("Reports")
//        reportResultsdict = areaReportsDict
        tableView.reloadData()
    }
}

extension ItemViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
       return UIModalPresentationStyle.none
    }
}

extension ItemViewController: DataTypeViewDelegate {
    func didSelect(for controller: DataTypeViewController, dataTpe: ItemDataType) {
        viewModel.currentDataType = dataTpe
        controller.dismiss(animated: true, completion: nil)
        loadReports()
    }
}


// Anscestors
extension ItemViewController {
    func displayAnscestors() {
        guard viewModel.parentItem.parent != nil else {
            anscestorsLabel.text = ""
            return
        }
        let parentStr = viewModel.parentItem.allParents
        let parents = parentStr.components(separatedBy: ">")
        let underlineAttriString = NSMutableAttributedString(string: parentStr)
        
        parents.forEach { (str) in
            let range = parentStr.range(of: str)!
            let nsRange = NSRange(range, in: parentStr)
            underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
            underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: nsRange)
            
        }
        
        anscestorsLabel.attributedText = underlineAttriString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnAnscestor(_:)))
        anscestorsLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapOnAnscestor(_ sender: UITapGestureRecognizer) {
        if let parentStr = anscestorsLabel.text {
            
            var currentParent: Item? = viewModel.parentItem.parent
            while let parent = currentParent,
                let range = parentStr.range(of: parent.title!) {
                    let nsRange = NSRange(range, in: parentStr)
                    if sender.didTapAttributedTextInLabel(label: anscestorsLabel,
                                                          inRange: nsRange) {
                        performSegue(withIdentifier: "showIndustries", sender: parent)
                        return
                    }
                    
                    currentParent = parent.parent
            }
        }
    }

}
