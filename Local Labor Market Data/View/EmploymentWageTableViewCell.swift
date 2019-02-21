//
//  EmploymentWageTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/1/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class EmploymentWageTableViewCell: UITableViewCell {

    class var nibName: String { return "EmploymentWageTableViewCell" }
    class var reuseIdentifier: String { return "EmploymentWageTableViewCell" }
    
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var qtrYearLabel: UILabel!
    
    @IBOutlet weak var employmentView: UIView!
    @IBOutlet weak var employmentValueView: UIView!
    @IBOutlet weak var employmentTitleLabel: UILabel!
    @IBOutlet weak var employmentValueLabel: UILabel!
    @IBOutlet weak var employmentChangeView: UIView!
    
    @IBOutlet weak var wageView: UIView!
    @IBOutlet weak var wageValueView: UIView!
    @IBOutlet weak var wageTitleLabel: UILabel!
    @IBOutlet weak var wageValueLabel: UILabel!
    @IBOutlet weak var wageChangeView: UIView!
    
    @IBOutlet weak var employmentChangeTitleLabel: UILabel!
    @IBOutlet weak var employmentLevelNetChangeLabel: UILabel!
    @IBOutlet weak var employmentLevelRateChangeLabel: UILabel!

    @IBOutlet weak var areaView: UIView!
    @IBOutlet weak var wageChangeTitleLabel: UILabel!
    @IBOutlet weak var wageChangeLabel: UILabel!
    @IBOutlet weak var wageRateChangeLabel: UILabel!
    
    var outlineBackgroundColor: UIColor = UIColor(hex: 0xD8D8D8) {
        didSet {
            outlineView.backgroundColor = outlineBackgroundColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        let borderColor = UIColor(hex: 0x979797)

        dataView.addBorder(size: 1, color: borderColor)
        outlineView.addBorder(size: 1, color: borderColor)
        
        employmentView.addBorder(size: 1, color: borderColor)
        wageView.addBorder(size: 1, color: borderColor)
        outlineView.backgroundColor = outlineBackgroundColor
        
        areaLabel.scaleFont(forDataType: .reportAreaDataTitle, for:traitCollection)
        qtrYearLabel.scaleFont(forDataType: .reportPeriodName, for:traitCollection)
        
        employmentTitleLabel.scaleFont(forDataType: .reportDataTitle, for: traitCollection)
        employmentValueLabel.scaleFont(forDataType: .reportSubData, for: traitCollection)
        
        wageTitleLabel.scaleFont(forDataType: .reportDataTitle, for: traitCollection)
        wageValueLabel.scaleFont(forDataType: .reportSubData, for: traitCollection)
        
        employmentChangeTitleLabel.scaleFont(forDataType: .reportChangeTitle, for: traitCollection)
        wageChangeTitleLabel.scaleFont(forDataType: .reportChangeTitle, for: traitCollection)
        
        employmentLevelNetChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        employmentLevelRateChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        wageChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        wageRateChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        employmentView.isAccessibilityElement = false
        employmentView.shouldGroupAccessibilityChildren = true
        employmentView.accessibilityElements = [employmentTitleLabel, employmentValueLabel, employmentChangeTitleLabel, employmentLevelNetChangeLabel, employmentLevelRateChangeLabel]
        wageView.isAccessibilityElement = false
        wageView.shouldGroupAccessibilityChildren = true
        wageTitleLabel.accessibilityLabel = "Average Weekly Wage"
        wageView.accessibilityElements = [wageTitleLabel, wageValueLabel, wageChangeTitleLabel, wageChangeLabel, wageRateChangeLabel]
        accessibilityElements = [areaLabel, qtrYearLabel, employmentView, wageView]
    }
}


extension EmploymentWageTableViewCell {
    
    func displayEmploymentLevel(area: Area?, seriesReport: SeriesReport?,
                                periodName: String?, year: String?) {

        defer {applyEmploymentAccessibility()}
        
        guard let area = area else { return }
        areaLabel.text = "\(area.displayType) Data"
        
        guard let seriesReport = seriesReport else {
            qtrYearLabel.text = ""
            employmentValueLabel.text = ""
            employmentLevelNetChangeLabel.text = ""
            employmentLevelRateChangeLabel.text = ""
            return
        }
        
        let data: SeriesData?
        if let periodName = periodName, let year = year {
            data = seriesReport.data(forPeriodName: periodName, forYear: year)
        }
        else {
            data = seriesReport.latestData()
        }
        
        guard let seriesData = data else {
            qtrYearLabel.text = ""
            employmentValueLabel.text = ReportManager.dataNotAvailableStr
            employmentValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            employmentLevelNetChangeLabel.text = ReportManager.dataNotAvailableStr
            employmentLevelNetChangeLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            employmentLevelRateChangeLabel.text = ""
            return
        }
        
        if let quarter = DateFormatter.quarter(fromMonth: seriesData.periodName) {
            qtrYearLabel.text = "Q\(quarter) \(seriesData.periodName) \(seriesData.year)"
        }
        else {
            qtrYearLabel.text = "\(seriesData.periodName) \(seriesData.year)"
        }
        

        if let doubleValue = Double(seriesData.value) {
            employmentValueLabel.text = NumberFormatter.localizedString(from: NSNumber(value: doubleValue), number: NumberFormatter.Style.decimal)
        }
        else {
            employmentValueLabel.text = ReportManager.dataNotAvailableStr
            employmentValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
        }
        
        if let netChange = seriesData.calculations?.netChanges {
            employmentLevelNetChangeLabel.text = NumberFormatter.localisedDecimalStr(from: netChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
            if employmentLevelNetChangeLabel.text == ReportManager.dataNotAvailableStr {
                employmentLevelNetChangeLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            }
        }
        else {
            employmentLevelNetChangeLabel.text = ReportManager.dataNotAvailableStr
            employmentLevelNetChangeLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
        }

        
        if let percentChange = seriesData.calculations?.percentChanges {
            employmentLevelRateChangeLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ""
        }
        else {
            employmentLevelRateChangeLabel.text = ""
        }
        
    }
    
    func applyEmploymentAccessibility() {
        
        if employmentValueLabel.text != ReportManager.dataNotAvailableStr {
           accessibilityElements = [areaLabel, qtrYearLabel, employmentView, wageView]
        }
        else {
            accessibilityElements = [areaLabel, employmentView, wageView]
        }
        
        
        if employmentLevelNetChangeLabel.text != ReportManager.dataNotAvailableStr {
            employmentView.accessibilityElements = [employmentTitleLabel, employmentValueLabel, employmentChangeTitleLabel, employmentLevelNetChangeLabel, employmentLevelRateChangeLabel]
        }
        else {
            employmentView.accessibilityElements = [employmentTitleLabel, employmentValueLabel, employmentChangeTitleLabel, employmentLevelNetChangeLabel]
        }
    }
    func applyWageAccessibility() {
        
        if wageChangeLabel.text != ReportManager.dataNotAvailableStr {
            wageView.accessibilityElements = [wageTitleLabel, wageValueLabel, wageChangeTitleLabel, wageChangeLabel, wageRateChangeLabel]            
        }
        else {
            wageView.accessibilityElements = [wageTitleLabel, wageValueLabel, wageChangeTitleLabel, wageChangeLabel]
        }
    }

    func displayAverageWage(area: Area?, seriesReport: SeriesReport?,
                            periodName: String?, year: String?) {

        defer {applyWageAccessibility()}
        
        guard let seriesReport = seriesReport else {
            wageValueLabel.text = ""
            wageChangeLabel.text = ""
            wageRateChangeLabel.text = ""
            return
        }
        
        let data: SeriesData?
        if let periodName = periodName, let year = year {
            data = seriesReport.data(forPeriodName: periodName, forYear: year)
        }
        else {
            data = seriesReport.latestData()
        }
        
        guard let seriesData = data else {
            wageValueLabel.text = ReportManager.dataNotAvailableStr
            wageValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            wageChangeLabel.text = ReportManager.dataNotAvailableStr
            wageChangeLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            wageRateChangeLabel.text = ""
            return
        }

        if let doubleValue = Double(seriesData.value) {
            wageValueLabel.text = NumberFormatter.localisedCurrencyStrWithoutFraction(from: NSNumber(value: doubleValue))
        }
        else {
            wageValueLabel.text = ReportManager.dataNotAvailableStr
        }
        
        if let netChange = seriesData.calculations?.netChanges {
            wageChangeLabel.text = NumberFormatter.localisedDecimalStr(from: netChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
        }
        else {
            wageChangeLabel.text = ReportManager.dataNotAvailableStr
            wageChangeLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
        }
        
        if let percentChange = seriesData.calculations?.percentChanges {
            wageRateChangeLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ""
        }
        else {
            wageRateChangeLabel.text = ""
        }
        
        if wageRateChangeLabel.text == "" {
            wageRateChangeLabel.accessibilityElementsHidden = true
        }
        else {
            wageRateChangeLabel.accessibilityElementsHidden = false
        }

    }
}



