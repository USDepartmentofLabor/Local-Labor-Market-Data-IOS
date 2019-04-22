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
    
    @IBOutlet weak var periodOwnershipStackView: UIStackView!
    @IBOutlet weak var reportPeriodLabel: UILabel!
    
    @IBOutlet weak var anscestorsLabel: UILabel!
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemCodeButton: UIButton!
    @IBOutlet weak var parentTitleLabel: UILabel!
    @IBOutlet weak var dataTypeButton: UIButton!

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var parentView: UIView!
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
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: view)
//    }
    
    func setupView() {
        let searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(displaySearchBar(sender:)))
        
        let infoItem = UIBarButtonItem.infoButton(target: self, action: #selector(infoClicked(sender:)))
        navigationItem.rightBarButtonItems = [infoItem, searchBtn]

        searchBtn.accessibilityLabel = "Search"

        if splitViewController?.isCollapsed ?? true {
            let homeItem = UIBarButtonItem(image: #imageLiteral(resourceName: "home"), style: .plain, target: self, action: #selector(homeClicked(sender:)))
            navigationItem.leftBarButtonItem = homeItem
        }

        navigationItem.leftItemsSupplementBackButton = true
        
        areaTitleLabel.scaleFont(forDataType: .reportAreaTitle, for:traitCollection)
        ownershipLabel.scaleFont(forDataType: .itemPeriodName, for:traitCollection)
        reportPeriodLabel.scaleFont(forDataType: .itemPeriodName, for:traitCollection)
        itemTitleLabel.scaleFont(forDataType: .itemColumnTitle)
        itemCodeButton.titleLabel?.scaleFont(forDataType: .itemColumnTitle)
        
        dataTypeButton.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        dataTypeButton.layer.borderWidth = 1.0
        dataTypeButton.layer.cornerRadius = 10
        dataTypeButton.titleLabel?.scaleFont(forDataType: .itemDataType)
        seasonallyAdjustedSwitch.tintColor = #colorLiteral(red: 0.1607843137, green: 0.2117647059, blue: 0.5137254902, alpha: 1)
        seasonallyAdjustedSwitch.onTintColor = #colorLiteral(red: 0.1607843137, green: 0.2117647059, blue: 0.5137254902, alpha: 1)
        seasonallyAdjustedTitle.scaleFont(forDataType: .seasonallyAdjustedSwitch, for: traitCollection)

        parentTitleLabel.scaleFont(forDataType: .itemParentTitle)
        anscestorsLabel.scaleFont(forDataType: .itemAnscestorsList)
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
            searchBtn.accessibilityHint = "Tap to Search for Occupations"
        }
        else if viewModel is QCEWIndustryViewModel {
            setupQCEWView()
            searchBtn.accessibilityHint = "Tap to Search for Industries"
        }
        else {
            setupCESView()
            searchBtn.accessibilityHint = "Tap to Search for Industries"
        }

        displayAnscestors()
        
        let title: String
        if viewModel is QCEWIndustryViewModel {
            title = viewModel.parentItem.title ?? ""
        }
        else if viewModel is OccupationViewModel {
            title = "\(viewModel.parentItem.title ?? "") (\(viewModel.parentItem.displayCode ?? ""))"
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
        displaySort()
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
        occupationLocalTitleButton.accessibilityHint = "Tap to sort"
        
        occupationNationalTitleButton.titleLabel?.scaleFont(forDataType: .itemColumnTitle)
        occupationNationalTitleButton.accessibilityHint = "Tap to sort"
        
        occupationParentValueLabel.scaleFont(forDataType: .itemParentValue)
        occupationParentNationalValueLabel.scaleFont(forDataType: .itemParentValue)

        titleView.isAccessibilityElement = false
        if viewModel.isNationalReport {
            occupationNationalTitleButton.removeFromSuperview()
            occupationParentNationalValueLabel.removeFromSuperview()
            titleView.accessibilityElements = [itemTitleLabel as Any, itemCodeButton as Any, occupationDataTypeTitleLabel as Any, occupationLocalTitleButton as Any]
        }
        else {
            titleView.accessibilityElements = [itemTitleLabel as Any, itemCodeButton as Any, occupationDataTypeTitleLabel as Any, occupationLocalTitleButton as Any, occupationNationalTitleButton as Any]
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
        cesParentOneMonthValueLabel.scaleFont(forDataType: .itemChangeValue)
        cesParentOneMonthPercentLabel.scaleFont(forDataType: .itemChangeValue)
        cesParentTwelveMonthValueLabel.scaleFont(forDataType: .itemChangeValue)
        cesParentTwelveMonthPercentLabel.scaleFont(forDataType: .itemChangeValue)
        
//        cesLocalTitleButton.setTitle(viewModel.area.displayType, for: .normal)
        cesParentValueLabel.text = ""
        
        cesOneMonthChangeTitleButton.titleLabel?.numberOfLines = 0
        cesTwelveMonthChangeTitleButton.titleLabel?.numberOfLines = 0
        titleView.isAccessibilityElement = false
        titleView.accessibilityElements = [itemTitleLabel as Any, itemCodeButton as Any, cesDataTypeTitleLabel as Any, cesLocalTitleButton as Any, cesOneMonthChangeTitleButton as Any, cesTwelveMonthChangeTitleButton as Any]

        parentView.isAccessibilityElement = false
        parentView.accessibilityElements = [parentTitleLabel as Any, cesParentValueLabel as Any, cesParentOneMonthValueLabel as Any, cesParentOneMonthPercentLabel as Any, cesParentTwelveMonthValueLabel as Any, cesParentTwelveMonthPercentLabel as Any]
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
        
        qcewParentValueLabel.scaleFont(forDataType: .itemValue)
        qcewParentTwelveMonthValueLabel.scaleFont(forDataType: .itemChangeValue)
        qcewParentTwelveMonthPercentLabel.scaleFont(forDataType: .itemChangeValue)
        qcewParentNationalValueLabel.scaleFont(forDataType: .itemValue)
        qcewParentNationalTwelveMonthValueLabel.scaleFont(forDataType: .itemChangeValue)
        qcewParentNationalTwelveMonthPercentLabel.scaleFont(forDataType: .itemChangeValue)
        
        qcewParentNationalValueLabel.scaleFont(forDataType: .itemValue)
        if viewModel.isNationalReport {
            qcewNationalTitleStackView.removeFromSuperview()
            qcewNationalParentStackView.removeFromSuperview()
        }

        periodOwnershipStackView.isAccessibilityElement = false
        periodOwnershipStackView.accessibilityElements = [ownershipLabel as Any, reportPeriodLabel as Any]
        titleView.isAccessibilityElement = false
        titleView.accessibilityElements = [itemTitleLabel as Any, itemCodeButton as Any, qcewDataTypeTitleLabel as Any, qcewLocalTitleButton as Any, qcewLocalTwelveMonthChangeTitleButton as Any, qcewNationalTitleButton as Any, qcewNationalTwelveMonthChangeTitleButton as Any]
                                           
        ownershipLabel.isHidden = false
        ownershipLabel.text = "\(vm.ownershipCode.title)"
        qcewLocalTitleButton.setTitle(viewModel.area.displayType, for: .normal)
        
        parentView.isAccessibilityElement = false
        parentView.accessibilityElements = [parentTitleLabel as Any ,qcewParentValueLabel as Any, qcewParentTwelveMonthValueLabel as Any, qcewParentTwelveMonthPercentLabel as Any, qcewParentNationalValueLabel as Any, qcewParentNationalTwelveMonthValueLabel as Any, qcewParentNationalTwelveMonthPercentLabel as Any]
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
    
    @objc func homeClicked(sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.displayHome()
    }

    @IBAction func infoClicked(sender: Any) {
        performSegue(withIdentifier: "showInfo", sender: nil)
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
    
    @IBAction func itemCodeBtnClick(_ sender: Any) {
        
        if case .code(let asc) = viewModel.dataSort {
            viewModel.dataSort = .code(ascending: !asc)
        }
        else {
            viewModel.dataSort = .code(ascending: true)
        }
        
        reloadData()
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
        let noSortImage = #imageLiteral(resourceName: "noSort")
        let ascSort = #imageLiteral(resourceName: "ascSort")
        let descSort = #imageLiteral(resourceName: "descSort")
        var codeSortImage = noSortImage
        var localSortImage = noSortImage
        var nationalSortImage = noSortImage
        var localOneMonthChangeSortImage = noSortImage
        var localTwelveMonthChangeSortImage = noSortImage
        var nationalTwelveMonthChangeSortImage = noSortImage
        
        var codeSortHint = "Tap to Sort ascending"
        var localSortHint = "Tap to Sort ascending"
        var nationalSortHint = "Tap to Sort ascending"
        var localOneMonthSortHint = "Tap to Sort ascending"
        var localTwelveMonthSortHint = "Tap to Sort ascending"
        var nationalTwelveMonthSortHint = "Tap to Sort ascending"
        
        switch viewModel.dataSort {
        case .code(let asc):
            codeSortImage = (asc == true) ? ascSort : descSort
            codeSortHint = (asc == true) ? "Tap to sort descending": "Tap to sort ascending"
        case .local(let asc):
            localSortImage = (asc == true) ? ascSort : descSort
            localSortHint = (asc == true) ? "Tap to sort descending": "Tap to sort ascending"
        case .national(let asc):
            nationalSortImage = (asc == true) ? ascSort : descSort
            nationalSortHint = (asc == true) ? "Tap to sort descending": "Tap to sort ascending"
        case .localOneMonthChange(let asc):
            localOneMonthChangeSortImage = (asc == true) ? ascSort : descSort
            localOneMonthSortHint = (asc == true) ? "Tap to sort descending": "Tap to sort ascending"
        case .localTwelveMonthChange(let asc):
            localTwelveMonthChangeSortImage = (asc == true) ? ascSort : descSort
            localTwelveMonthSortHint = (asc == true) ? "Tap to sort descending": "Tap to sort ascending"
        case .nationalTwelveMonthChange(let asc):
            nationalTwelveMonthChangeSortImage = (asc == true) ? ascSort : descSort
            nationalTwelveMonthSortHint = (asc == true) ? "Tap to sort descending": "Tap to sort ascending"
        case .none: break
            
        }
        
        itemCodeButton.setImage(codeSortImage, for: .normal)
        itemCodeButton.accessibilityHint = codeSortHint
        
        if viewModel is OccupationViewModel {
            occupationLocalTitleButton.setImage(localSortImage, for: .normal)
            occupationLocalTitleButton.accessibilityHint = localSortHint
            if !viewModel.isNationalReport {
                occupationNationalTitleButton.setImage(nationalSortImage, for: .normal)
                occupationNationalTitleButton.accessibilityHint = nationalSortHint
            }
        }
        else if viewModel is QCEWIndustryViewModel {
            qcewLocalTitleButton.setImage(localSortImage, for: .normal)
            qcewLocalTitleButton.accessibilityHint = localSortHint
            qcewLocalTwelveMonthChangeTitleButton.setImage(localTwelveMonthChangeSortImage, for: .normal)
            qcewLocalTwelveMonthChangeTitleButton.accessibilityHint = localOneMonthSortHint
            qcewNationalTitleButton.setImage(nationalSortImage, for: .normal)
            qcewNationalTitleButton.accessibilityHint = nationalSortHint
            qcewNationalTwelveMonthChangeTitleButton.setImage(nationalTwelveMonthChangeSortImage, for: .normal)
            qcewNationalTwelveMonthChangeTitleButton.accessibilityHint = nationalTwelveMonthSortHint
        }
        else {
            cesLocalTitleButton.setImage(localSortImage, for: .normal)
            cesLocalTitleButton.accessibilityHint = localSortHint
            cesOneMonthChangeTitleButton.setImage(localOneMonthChangeSortImage, for: .normal)
            cesOneMonthChangeTitleButton.accessibilityHint = localOneMonthSortHint
            cesTwelveMonthChangeTitleButton.setImage(localTwelveMonthChangeSortImage, for: .normal)
            cesTwelveMonthChangeTitleButton.accessibilityHint = localTwelveMonthSortHint
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
            let title = (item.title ?? "") + " (" + (item.displayCode ?? "") + ")"
            cell.nextImageView.accessibilityLabel = "\(item.title ?? "") more details"
            cell.titleLabel?.text = title

            cell.hasChildren = (item.children?.count ?? 0) > 0

            guard viewModel.isDataDownloaded else {
                cell.value = ""
                cell.nationalValue = ""
                return
            }
            
            cell.value = viewModel.getReportValue(item: item) ?? ReportManager.dataNotAvailableStr
            
            if viewModel.isNationalReport {
                if let nationalValueLabel = cell.nationalValueLabel {
                    nationalValueLabel.removeFromSuperview()
                }
            }
            else {
                cell.nationalValue = viewModel.getNationalReportValue(item: item) ?? ReportManager.dataNotAvailableStr
            }
        }
    }
    
    func configureCell(cell: ItemCESTableViewCell, indexPath: IndexPath) {
        if let item = viewModel.items?[indexPath.row] {
            let title = (item.title ?? "") + " (" + (item.code ?? "") + ")"
            cell.titleLabel?.text = title
            cell.nextImageView.accessibilityLabel = "\(item.title ?? "") more details"
            cell.hasChildren = (item.children?.count ?? 0) > 0

            guard viewModel.isDataDownloaded else {
                cell.value = ""
                cell.oneMonthValue = ""
                cell.oneMonthPercent = ""
                cell.twelveMonthValue = ""
                cell.twelveMonthPercent = ""
                return
            }
            
            if let seriesData = viewModel.getReportData(item: item) {
                cell.value = viewModel.getReportValue(from: seriesData) ?? ReportManager.dataNotAvailableStr
                
                // Display Percent Change
                if let percentChange = seriesData.calculations?.percentChanges {
                    cell.oneMonthPercent =
                        NumberFormatter.localisedPercentStr(from: percentChange.oneMonth) ??  ReportManager.dataNotAvailableStr
                    cell.twelveMonthPercent = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
                }
                if let netChange = seriesData.calculations?.netChanges {
                    if let oneMonthChange = netChange.oneMonth, let doubleValue = Double(oneMonthChange) {
                        cell.oneMonthValue = NumberFormatter.localisedDecimalStr(from: doubleValue) ?? ""
                    }
                    else {
                        cell.oneMonthValue = ReportManager.dataNotAvailableStr
                    }
                    
                    if let twelveMonthChange = netChange.twelveMonth, let doubleValue = Double(twelveMonthChange) {
                        cell.twelveMonthValue = NumberFormatter.localisedDecimalStr(from: doubleValue) ?? ""
                    }
                    else {
                        cell.twelveMonthValue = ReportManager.dataNotAvailableStr
                    }
                }
                else {
                    cell.oneMonthValue = ReportManager.dataNotAvailableStr
                    cell.twelveMonthValue = ReportManager.dataNotAvailableStr
                }
            }
            else {
                cell.value = ReportManager.dataNotAvailableStr
                cell.oneMonthValue = ""
                cell.oneMonthPercent = ""
                cell.twelveMonthValue = ""
                cell.twelveMonthPercent = ""
            }
        }
    }
    
    func configureCell(cell: ItemQCEWTableViewCell, indexPath: IndexPath) {
        if let item = viewModel.items?[indexPath.row] {
            cell.titleLabel?.text = item.title
            cell.nextImageView.accessibilityLabel = "\(item.title ?? "") more details"
            cell.hasChildren = (item.children?.count ?? 0) > 0
            
            guard viewModel.isDataDownloaded else {
                cell.value = ""
                cell.twelveMonthValue = ""
                cell.twelveMonthPercent = ""
                cell.nationalValue = ""
                cell.nationalTwelveMonthValue = ""
                cell.nationalTwelveMonthPercent = ""
                return
            }
            
            if let seriesData = viewModel.getReportData(item: item) {
                cell.value = viewModel.getReportValue(from: seriesData) ?? ReportManager.dataNotAvailableStr
                
                // Display Percent Change
                if seriesData.isNotDisclosable {
                    cell.twelveMonthPercent = ""
                    cell.twelveMonthValue = ""
                }
                else {
                    if let percentChange = seriesData.calculations?.percentChanges {
                        cell.twelveMonthPercent = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
                    }
                    else {
                        cell.twelveMonthPercentLabel.text = ReportManager.dataNotAvailableStr
                    }

                    if let netChange = seriesData.calculations?.netChanges {
                        if let twelveMonthChange = netChange.twelveMonth, let doubleValue = Double(twelveMonthChange) {
                            cell.twelveMonthValue = NumberFormatter.localisedDecimalStr(from: doubleValue) ?? ""
                        }
                        else {
                            cell.twelveMonthValue = ReportManager.dataNotAvailableStr
                        }
                    }
                    else {
                        cell.twelveMonthValue = ReportManager.dataNotAvailableStr
                    }
                }
            }
            else {
                cell.value = ReportManager.dataNotAvailableStr
                cell.twelveMonthValue = ""
                cell.twelveMonthPercent = ""
            }
            
            if let seriesData = viewModel.getNationalReportData(item: item) {
                cell.nationalValue = viewModel.getReportValue(from: seriesData) ?? ReportManager.dataNotAvailableStr
                
                // Display Percent Change
                if seriesData.isNotDisclosable {
                    cell.nationalTwelveMonthPercent = ""
                    cell.nationalTwelveMonthValue = ""
                }
                else {
                    if let percentChange = seriesData.calculations?.percentChanges {
                        cell.nationalTwelveMonthPercent = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
                    }
                    else {
                        cell.nationalTwelveMonthPercent = ReportManager.dataNotAvailableStr
                    }
                    if let netChange = seriesData.calculations?.netChanges {
                        if let twelveMonthChange = netChange.twelveMonth, let doubleValue = Double(twelveMonthChange) {
                            cell.nationalTwelveMonthValue = NumberFormatter.localisedDecimalStr(from: doubleValue) ?? ""
                        }
                        else {
                            cell.nationalTwelveMonthValue = ReportManager.dataNotAvailableStr
                        }
                    }
                    else {
                        cell.nationalTwelveMonthValue = ReportManager.dataNotAvailableStr
                    }
                }
            }
            else {
                cell.nationalValue = ReportManager.dataNotAvailableStr
                cell.nationalTwelveMonthValue = ""
                cell.nationalTwelveMonthPercent = ""
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
            cesDataTypeTitleLabel.accessibilityLabel = "\(title) in thousands"
        }
        
        
        let seasonalAdjustedTitle = (seasonalAdjustment == .adjusted) ?
                                    "Seasonally Adjusted" : " Not Seasonally Adjusted"
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement,
                                 argument: "Loading \(seasonalAdjustedTitle) \(title) Reports")

        activityIndicator.startAnimating(disableUI: true)
        viewModel.loadReport(seasonalAdjustment: seasonalAdjustment) { [weak self] (reportError) in
            guard let strongSelf = self else {return}
            strongSelf.activityIndicator.stopAnimating()
            
            if let error = reportError {
                strongSelf.handleError(error: error)
            }
            else {
                let announcementStr = "Loaded  Report"
                UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementStr)

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
            cesParentValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
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

//MARK: UIPopoverPresentationController Delegate
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


