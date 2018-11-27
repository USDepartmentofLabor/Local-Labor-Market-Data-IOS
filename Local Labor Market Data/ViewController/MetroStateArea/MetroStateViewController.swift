//
//  MetroStateViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/27/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

extension ReportTableViewCell {
    func displaySeries(area: Area?, seriesReport: SeriesReport?,
                       periodName: String? = nil, year: String? = nil) {
        displaySeries(area: area, seriesReport: seriesReport, periodName: periodName, year: year)
    }
}

class MetroStateViewController: AreaViewController {
    struct Section {
        static let UnemploymentRateTitle = "Unemployment Rate"
        static let IndustryEmploymentTitle = "Industry Employment"
        static let OccupationEmploymentTitle = "Occupational Employment & Wages"
    }

    var seasonalAdjustment: SeasonalAdjustment {
        get {
            return ReportManager.seasonalAdjustment
        }
        set(newValue) {
            ReportManager.seasonalAdjustment = newValue
            localAreaReportsDict?.removeAll()
            nationalAreaReportsDict.removeAll()
            tableView.reloadData()
            
            loadReports()
        }
    }
    
    var openSectionIndex: Int = -1
    var sections = [
        ReportSection(title: Section.UnemploymentRateTitle, collapsed: false,
                      reportTypes: [.unemployment(measureCode: .unemploymentRate)]),
        ReportSection(title: Section.IndustryEmploymentTitle, collapsed: true,
                      reportTypes:[.industryEmployment(industryCode: "00000000", .allEmployees)]),
        ReportSection(title: Section.OccupationEmploymentTitle, collapsed: true,
                reportTypes: [.occupationEmployment(occupationalCode: "000000", .annualMeanWage)])]
    
    var localAreaReportsDict: [ReportType: AreaReport]?
    var nationalAreaReportsDict = [ReportType: AreaReport]()
    lazy var dataUtil = DataUtil(managedContext: CoreDataManager.shared().viewManagedContext)
    lazy var nationalArea = dataUtil.nationalArea()
    @IBOutlet weak var subAreaHeightConstraint: NSLayoutConstraint!
    
    lazy var spinnner = ActivityIndicatorView(text: "Loading", inView: view)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func setupView() {
        super.setupView()
        title = area is Metro ? "Metro Area": "State"

        let leftSubAreaTitle = area is Metro ? "State": "Metro"
        
        rightSubArea.titleLabel?.text = "County"
        leftSubArea.setTitle(leftSubAreaTitle, for: .normal)
        if area is State {
            leftSubArea.setImage(#imageLiteral(resourceName: "leftDownArrow"), for: .normal)
        }

        tableView.register(UINib(nibName: UnEmploymentRateTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: UnEmploymentRateTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: IndustryEmploymentTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: IndustryEmploymentTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: OccupationalEmploymentTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: OccupationalEmploymentTableViewCell.reuseIdentifier)
        
        tableView.estimatedRowHeight = 215
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: AreaSectionHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: AreaSectionHeaderView.reuseIdentifier)
        tableView.sectionHeaderHeight = UITableView.automaticDimension;
        tableView.estimatedSectionHeaderHeight = 44
        seasonallyAdjustedSwitch.isOn = (seasonalAdjustment == .adjusted) ? true:false

        setupAccessbility()
        loadReports()
    }
    
    override func setupAccessbility() {
        super.setupAccessbility()
        leftSubArea.accessibilityHint = "Tap to View \( area is Metro ? "State": "Metro") report for \( area is Metro ? "Metro": "State")"
        rightSubArea.accessibilityHint = "Tap to View Counties for \(area is Metro ? "Metro": "State")"
        
    }
    
    // MARK: Actions
    
    @IBAction func seasonallyAdjustClick(_ sender: Any) {
        seasonalAdjustment = seasonallyAdjustedSwitch.isOn ? .adjusted : .notAdjusted
    }
    
    @IBAction func leftSubAreaClicked(_ sender: Any) {
        area is Metro ? displayStates() : displayMetros()
    }

    @IBAction func rightSubAreaClicked(_ sender: Any) {
        displayCounties()
    }

    func displayStates() {
        
        guard let metroArea = area as? Metro, let states = metroArea.getStates() else { return }
        
        if states.count > 1 {
            let resultsVC = ResultsViewController.instantiateFromStoryboard()
            resultsVC.currentArea = metroArea
            resultsVC.resultAreas = states
            
            navigationController?.pushViewController(resultsVC, animated: true)
        }
        else if states.count == 1 {
            let stateVC = MetroStateViewController.instantiateFromStoryboard()
            stateVC.area = states[0]
            navigationController?.pushViewController(stateVC, animated: true)
        }
    }
    
    func displayMetros() {
        guard let state = area as? State, let metros = state.getMetros() else { return }
        
        if metros.count > 1 {
            let resultsVC = ResultsViewController.instantiateFromStoryboard()
            resultsVC.currentArea = state
            resultsVC.resultAreas = metros
            
            navigationController?.pushViewController(resultsVC, animated: true)
        }
        else if metros.count == 1 {
            let metroVC = MetroStateViewController.instantiateFromStoryboard()
            metroVC.area = metros[0]
            navigationController?.pushViewController(metroVC, animated: true)
        }

    }

    // if Number of counties in 
    func displayCounties() {
        let areaCounties: [County]?
        
        if let metroArea = area as? Metro {
            areaCounties = metroArea.getCounties()
        }
        else if let state = area as? State {
            areaCounties = state.getCounties()
        }
        else {
            areaCounties = nil
        }
        
        guard let counties = areaCounties else { return }
        
        if counties.count > 1 {
            let resultsVC = ResultsViewController.instantiateFromStoryboard()
            resultsVC.currentArea = area!
            resultsVC.resultAreas = counties
            
            navigationController?.pushViewController(resultsVC, animated: true)
        }
        else if counties.count == 1 {
            let countyVC = CountyViewController.instantiateFromStoryboard()
            countyVC.area = counties[0]
            navigationController?.pushViewController(countyVC, animated: true)
        }
    }
}


// Load Reports
extension MetroStateViewController {
    
    func loadReports() {
        if seasonalAdjustment == .adjusted {
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "Loading Seasonally Adjusted Reports")
        }
        else {
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "Loading Not Seasonally Adjusted Reports")
        }
        
        // Empty Local/Nationa Area Reports
        loadLocalReports()
    }
    
    func loadLocalReports() {
        let reportTypes = sections.compactMap {$0.reportTypes}.flatMap{$0}

        spinnner.startAnimating(disableUI: true)
        ReportManager.getReports(forArea: area, reportTypes: reportTypes,
                                 seasonalAdjustment: seasonalAdjustment) {
            [weak self] (apiResult) in

            guard let strongSelf = self else {return}
            strongSelf.spinnner.stopAnimating()

            switch apiResult {
            case .success(let areaReportsDict):
                strongSelf.displayLocalReportResults(areaReportsDict: areaReportsDict)
            case .failure(let error):
                strongSelf.handleError(error: error)
            }
        }
    }
    
    func displayLocalReportResults(areaReportsDict: [ReportType: AreaReport]) {
        localAreaReportsDict = areaReportsDict
        tableView.reloadData()
        
        let announcementStr: String
        if area is National {
            announcementStr = "Loaded National Report"
        }
        else {
            announcementStr = "Loaded Local Report"
        }
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: announcementStr)

        // If current Area is National, no need to load National Report
        if (area is National) == false {
            loadNationalReports()
        }
    }
    
    func loadNationalReports() {
        guard let localAreaReportsDict =  localAreaReportsDict, let nationalArea = nationalArea else {
            return
        }
        
        for (_, areaReport) in localAreaReportsDict {
            let reportYear = areaReport.seriesReport?.latestDataYear()
            let period = areaReport.seriesReport?.latestDataPeriod()
            ReportManager.getReports(forArea: nationalArea,
                                     reportTypes: [areaReport.reportType],
                                     seasonalAdjustment: seasonalAdjustment,
                                     period: period,
                                     year: reportYear) {[weak self] (apiResult) in
                guard let strongSelf = self else {return}
                switch apiResult {
                case .success(let areaReportsDict):
                    areaReportsDict.forEach{ (arg) in
                        let (key, value) = arg
                        strongSelf.nationalAreaReportsDict[key] = value
                        strongSelf.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }

            }
        }
    }
}


// MARK: - TableView Datasource
extension MetroStateViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        
        let currentSection = sections[section]
        if currentSection.collapsed == false {
            numRows = 1
            if !nationalAreaReportsDict.isEmpty {
                numRows = numRows + 1
            }
        }
        
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        let section = sections[indexPath.section]
        if section.title == MetroStateViewController.Section.UnemploymentRateTitle {
            cell = tableView.dequeueReusableCell(withIdentifier: UnEmploymentRateTableViewCell.reuseIdentifier) as! UnEmploymentRateTableViewCell
        }
        else if section.title == MetroStateViewController.Section.IndustryEmploymentTitle {
            cell = tableView.dequeueReusableCell(withIdentifier: IndustryEmploymentTableViewCell.reuseIdentifier) as! IndustryEmploymentTableViewCell
        }
        else if section.title == MetroStateViewController.Section.OccupationEmploymentTitle {
            cell = tableView.dequeueReusableCell(withIdentifier: OccupationalEmploymentTableViewCell.reuseIdentifier) as! OccupationalEmploymentTableViewCell
        }
        
        configure(cell: cell!, forIndexPath: indexPath)
        
        return cell!
    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sections[section].title
//    }
    
    func configure(cell: UITableViewCell, forIndexPath indexPath:IndexPath) {
        
        guard let reportCell = cell as? ReportTableViewCell else { return }
        guard let reportType = sections[indexPath.section].reportTypes?.first else { return }

         let localAreaSeriesReport = localAreaReportsDict?[reportType]?.seriesReport
        if indexPath.row == 0 {
            reportCell.displaySeries(area: area, seriesReport: localAreaSeriesReport, periodName: nil, year: nil)
        }
        else if indexPath.row == 1 {
            let seriesReport = nationalAreaReportsDict[reportType]?.seriesReport
            reportCell.displaySeries(area: nationalArea, seriesReport: seriesReport, periodName: localAreaSeriesReport?.latestDataPeriodName(), year: localAreaSeriesReport?.latestDataYear())
        }
    }
}

// MARK: TableView Delegate
extension MetroStateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeaderView =
            tableView.dequeueReusableHeaderFooterView(withIdentifier: "AreaSectionHeaderView") as? AreaSectionHeaderView
            else { return nil }
        
        
//        sectionHeaderView.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        sectionHeaderView.configure(title: sections[section].title, section: section,
                                    collapse: sections[section].collapsed)
        sectionHeaderView.delegate = self
        return sectionHeaderView
    }
}

extension MetroStateViewController: AreaSectionHeaderDelegate {
    // If user opens a section, close any previous opened Section
    func sectionHeader(_ sectionHeader: AreaSectionHeaderView, toggleExpand section: Int) {
        guard Util.isVoiceOverRunning == false else { return }
        
        var addIndexPaths = [IndexPath]()
        var removeIndexPaths = [IndexPath]()
        var reloadSections = IndexSet(integer: section)
        
        // If user is toggling collapsed section, the collapse already opened Sections
        if sections[section].collapsed {
            for (index, currentSection) in sections.enumerated() {
                if false == currentSection.collapsed {
                    let rows = tableView(tableView, numberOfRowsInSection: index)
                    for row in 0..<rows {
                        removeIndexPaths.append(IndexPath(row: row, section: index))
                    }
                    currentSection.collapsed = true
                    reloadSections.update(with: index)
                }
            }
        }
        if sections[section].collapsed {
            sections[section].collapsed = !sections[section].collapsed
            let rows = tableView(tableView, numberOfRowsInSection: section)
            for row in 0..<rows {
                addIndexPaths.append(IndexPath(row: row, section: section))
            }
        }
        else {
            let rows = tableView(tableView, numberOfRowsInSection: section)
            for row in 0..<rows {
                removeIndexPaths.append(IndexPath(row: row, section: section))
            }
            sections[section].collapsed = !sections[section].collapsed

        }
        tableView.reloadSections(reloadSections, with: .automatic)
        
        tableView.beginUpdates()
//        tableView.insertRows(at: addIndexPaths, with: .automatic)
//        tableView.deleteRows(at: removeIndexPaths, with: .automatic)
        tableView.endUpdates()
    }
    
    func sectionHeader(_ sectionHeader: AreaSectionHeaderView, displayDetails section: Int) {
        let section = sections[section]
        
        // For Industry Title
        if section.title == Section.IndustryEmploymentTitle {
            displayCEIndustry()
        }
    }
    
    func displayCEIndustry() {
        performSegue(withIdentifier: "showIndustry", sender: self)
    }
}

extension MetroStateViewController: UIAccessibilityContainerDataTable {
    func accessibilityDataTableCellElement(forRow row: Int, column: Int) -> UIAccessibilityContainerDataTableCell? {
        return nil
    }
    
    func accessibilityRowCount() -> Int {
        return 2
    }
    
    func accessibilityColumnCount() -> Int {
        return 4
    }
    
    override open func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        return true
    }

}


