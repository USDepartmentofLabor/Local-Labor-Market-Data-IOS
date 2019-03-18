//
//  OwnershipDataTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/1/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class OwnershipDataTableViewCell: UITableViewCell {

    class var nibName: String { return "OwnershipDataTableViewCell" }
    class var reuseIdentifier: String { return "OwnershipDataTableViewCell" }

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var qtrYearLabel: UILabel!
    
    @IBOutlet weak var seasonalAdjustmentLabel: UILabel!
    @IBOutlet weak var employmentTitleLabel: UILabel!
    @IBOutlet weak var employmentValueLabel: UILabel!
    @IBOutlet weak var wageTitleLabel: UILabel!
    @IBOutlet weak var wageValueLabel: UILabel!
    
    
    @IBOutlet weak var areaView: UIView!
    @IBOutlet weak var employmentView: UIView!
    @IBOutlet weak var wageView: UIView!
    
    
    var outlineBackgroundColor: UIColor = UIColor(hex: 0xEFEFEF) {
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

        dataView.addBorder(size: 1.0, color: borderColor)
        outlineView.addBorder(size: 1.0, color: borderColor)
        
        employmentView.addBorder(size: 1.0, color: borderColor)
        wageView.addBorder(size: 1.0, color: borderColor)
        outlineView.backgroundColor = outlineBackgroundColor
        
        areaLabel.scaleFont(forDataType: .reportAreaDataTitle, for:traitCollection)
        qtrYearLabel.scaleFont(forDataType: .reportPeriodName, for:traitCollection)

        employmentTitleLabel.scaleFont(forDataType: .reportDataTitle, for: traitCollection)
        employmentValueLabel.scaleFont(forDataType: .reportSubData, for: traitCollection)

        wageTitleLabel.scaleFont(forDataType: .reportDataTitle, for: traitCollection)
        wageValueLabel.scaleFont(forDataType: .reportSubData, for: traitCollection)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        wageTitleLabel.accessibilityLabel = "Average Weekly Wage"
        accessibilityElements = [areaLabel, qtrYearLabel, employmentView, wageView]
    }
}
    

extension OwnershipDataTableViewCell {
    func displayEmploymentLevel(area: Area?, seriesReport: SeriesReport?,
                                periodName: String?, year: String?,
                                seasonalAdjustment: SeasonalAdjustment) {

        guard let area = area else { return }
        areaLabel.text = "\(area.displayType) Data"
        
        // If Series doesn't exist, it hasn't been downloaded yet
        guard let seriesReport = seriesReport else {
            qtrYearLabel.text = ""
            employmentValueLabel.text = ""
            seasonalAdjustmentLabel.text = ""
            return
        }
        
        let data: SeriesData?
        if let periodName = periodName, let year = year {
            data = seriesReport.data(forPeriodName: periodName, forYear: year)
        }
        else {
            data = seriesReport.latestData()
        }
        
        // If Series exist but there is not SeriesData, then Data is not Available
        guard let seriesData = data else {
            qtrYearLabel.text = ""
            seasonalAdjustmentLabel.text = ""
            employmentValueLabel.text = ReportManager.dataNotAvailableStr
            employmentValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            return
        }
        
        if let quarter = DateFormatter.quarter(fromMonth: seriesData.periodName) {
            qtrYearLabel.text = "Q\(quarter) \(seriesData.periodName) \(seriesData.year)"
        }
        else {
            qtrYearLabel.text = "\(seriesData.periodName) \(seriesData.year)"
        }

        seasonalAdjustmentLabel.text = seasonalAdjustment.description
        
        if let doubleValue = Double(seriesData.value) {
            employmentValueLabel.text = NumberFormatter.localizedString(from: NSNumber(value: doubleValue), number: NumberFormatter.Style.decimal)
        }
        else {
            employmentValueLabel.text = ReportManager.dataNotAvailableStr
            employmentValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
        }
    }
    

    func displayAverageWage(area: Area?, seriesReport: SeriesReport?,
                            periodName: String?, year: String?) {
        
        guard let seriesReport = seriesReport else {
            wageValueLabel.text = ""
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
            return
        }
        
        if let doubleValue = Double(seriesData.value) {
            wageValueLabel.text = NumberFormatter.localisedCurrencyStrWithoutFraction(from: NSNumber(value: doubleValue))
        }
        else {
            wageValueLabel.text = ReportManager.dataNotAvailableStr
            wageValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
        }
    }
}
