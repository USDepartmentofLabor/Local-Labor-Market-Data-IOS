//
//  OwnershipTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/14/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

protocol OwnershipTableViewCellDelegate: class {
    func contentDidChange(cell: UITableViewCell)
}


class OwnershipTableViewCell: UITableViewCell {

    class var nibName: String { return "OwnershipTableViewCell" }
    class var reuseIdentifier: String { return "OwnershipTableViewCell" }

    var reportSections: [ReportSection]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewheightConstraint: NSLayoutConstraint!
    weak var delegate: OwnershipTableViewCellDelegate?
    @IBOutlet weak var dataView: UIView!
    lazy var dataUtil = DataUtil(managedContext: CoreDataManager.shared().viewManagedContext)
    lazy var nationalArea = dataUtil.nationalArea()

    var area: Area?
    var localAreaReportsDict: [ReportType: AreaReport]?
    var nationalAreaReportsDict: [ReportType: AreaReport]?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        let borderColor = UIColor(hex: 0x979797)
        contentView.addBorder(size: 1.0, color: borderColor)
        dataView.addBorder(size: 1.0, color: borderColor)
        
        setupTableView()
        setupAccessibility()
    }

    func setupAccessibility() {
        tableView.isAccessibilityElement = false
        isAccessibilityElement = false
        accessibilityElements = [tableView]
    }
    
    func contentHeight() -> CGFloat {
        return tableView.contentSize.height + 20
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        tableViewheightConstraint.constant = tableView.contentSize.height
        
    }
    func setupTableView() {
        tableView.register(UINib(nibName: OwnershipDataTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: OwnershipDataTableViewCell.reuseIdentifier)
        
        tableView.register(UINib(nibName: AreaSectionHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: "OwnershipHeader")

        tableView.sectionHeaderHeight = UITableView.automaticDimension;
        tableView.estimatedSectionHeaderHeight = 44
        
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.tableFooterView?.backgroundColor = .red
    }
    
}


extension OwnershipTableViewCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return reportSections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        if let ownershipSection = reportSections?[section] {
            if ownershipSection.collapsed == false {
                numRows = 1
                if (nationalAreaReportsDict != nil) {
                    numRows = numRows + 1
                }
            }
        }
        
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OwnershipDataTableViewCell.reuseIdentifier) as! OwnershipDataTableViewCell
        
        configureCell(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return reportSections?[section].title ?? ""
    }
    
    func configureCell(cell: OwnershipDataTableViewCell, atIndexPath indexPath: IndexPath) {
        guard let reportSections = reportSections else {return}

        var currentArea = area
        if indexPath.row == 1 {
            currentArea = nationalArea
        }

        let reportTypes = reportSections[indexPath.section].reportTypes
        let reportsDict = localAreaReportsDict?.filter {
            (reportTypes?.contains($0.key)) ?? false
        }
        
        guard reportsDict != nil, reportsDict!.count > 0 else {
            cell.displayEmploymentLevel(area: currentArea, seriesReport: nil, periodName: nil, year: nil)
            cell.displayAverageWage(area: currentArea, seriesReport: nil, periodName: nil, year: nil)
            return
        }
        
        
        reportsDict?.forEach { (reportType, areaReport) in
            switch reportType {
            case .quarterlyEmploymentWage( _, _, _, let dataType):
                let latestLocalSeriesData = localAreaReportsDict![reportType]?.seriesReport?.latestData()
                
                let seriesReport: SeriesReport?
                if currentArea is National {
                    seriesReport = nationalAreaReportsDict?[reportType]?.seriesReport
                }
                else {
                    seriesReport = localAreaReportsDict?[reportType]?.seriesReport
                }
                
                if dataType == QCEWReport.DataTypeCode.allEmployees {
                    cell.displayEmploymentLevel(area: currentArea, seriesReport: seriesReport, periodName: latestLocalSeriesData?.periodName, year: latestLocalSeriesData?.year)
                }
                else if dataType == QCEWReport.DataTypeCode.avgWeeklyWage {
                    cell.displayAverageWage(area: currentArea, seriesReport: seriesReport, periodName: latestLocalSeriesData?.periodName, year: latestLocalSeriesData?.year)
                }
                
            default: break
                
            }
        }

    }
}

extension OwnershipTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeaderView =
            tableView.dequeueReusableHeaderFooterView(withIdentifier: "OwnershipHeader") as? AreaSectionHeaderView
            else { return nil }

        sectionHeaderView.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        sectionHeaderView.section = section
        sectionHeaderView.titleLabel.textAlignment = .left
        sectionHeaderView.titleLabel.scaleFont(forDataType: .reportOwnershipTitle, for: traitCollection)
        sectionHeaderView.collapseSection(collapse: reportSections?[section].collapsed ?? true)
        sectionHeaderView.delegate = self
        sectionHeaderView.sectionBackgroundColor = UIColor(hex: 0xEFEFEF)
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
}

extension OwnershipTableViewCell: AreaSectionHeaderDelegate {
    
    // If user opens a section, close any previous opened Section
    func sectionHeader(_ sectionHeader: AreaSectionHeaderView, toggleExpand section: Int) {
        guard  Util.isVoiceOverRunning == false else {
            return
        }
        guard let ownershipSections = reportSections else {return}
        
        var reloadSections = IndexSet(integer: section)
        
        // If user is toggling collapsed section, the collapse already opened Sections
        if ownershipSections[section].collapsed {
            for (index, currentSection) in ownershipSections.enumerated() {
                if false == currentSection.collapsed {
                    currentSection.collapsed = true
                    reloadSections.update(with: index)
                }
            }
        }
        ownershipSections[section].collapsed = !ownershipSections[section].collapsed
        tableView.reloadSections(reloadSections, with: .automatic)
        tableViewheightConstraint.constant = tableView.contentSize.height
        delegate?.contentDidChange(cell: self)
    }
    
}



