//
//  IndustryEmploymentTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/1/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class IndustryEmploymentTableViewCell: UITableViewCell {

    class var nibName: String { return "IndustryEmploymentTableViewCell" }
    class var reuseIdentifier: String { return "IndustryEmploymentTableViewCell" }

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var seasonalAdjustmentLabel: UILabel!
    
    @IBOutlet weak var dataTitleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var oneMonthChangeTitleLabel: UILabel!
    @IBOutlet weak var oneMonthNetChangeLabel: UILabel!
    @IBOutlet weak var oneMonthRateChangeLabel: UILabel!
    @IBOutlet weak var twelveMonthChangeTitleLabel: UILabel!
    @IBOutlet weak var twelveMonthNetChangeLabel: UILabel!
    @IBOutlet weak var twelveMonthRateChangeLabel: UILabel!
    
    @IBOutlet weak var areaView: UIView!
    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var oneMonthChangeView: UIView!
    @IBOutlet weak var twelveMonthChangeView: UIView!
    
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

        dataView.layer.borderWidth = 1
        dataView.layer.borderColor = borderColor.cgColor
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.borderColor = borderColor.cgColor
        outlineView.backgroundColor = outlineBackgroundColor
        
        areaLabel.scaleFont(forDataType: .reportAreaDataTitle, for:traitCollection)
        monthYearLabel.scaleFont(forDataType: .reportPeriodName, for:traitCollection)
        dataTitleLabel.scaleFont(forDataType: .reportDataTitle, for: traitCollection)
        valueLabel.scaleFont(forDataType: .reportData, for: traitCollection)
        
        oneMonthChangeTitleLabel.scaleFont(forDataType: .reportChangeTitle, for: traitCollection)
        twelveMonthChangeTitleLabel.scaleFont(forDataType: .reportChangeTitle, for: traitCollection)
        
        oneMonthRateChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        oneMonthNetChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        twelveMonthRateChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        twelveMonthNetChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [areaLabel, monthYearLabel, dataTitleLabel, valueLabel, oneMonthChangeTitleLabel, oneMonthNetChangeLabel, oneMonthRateChangeLabel, twelveMonthChangeTitleLabel, twelveMonthNetChangeLabel, twelveMonthRateChangeLabel]
    }
}

extension IndustryEmploymentTableViewCell: ReportTableViewCell {
    
    func displaySeries(area: Area?, seriesReport: SeriesReport?, periodName: String?, year: String?,
                       seasonallyAdjusted: SeasonalAdjustment?) {
//        defer {applyAccessibility()}
        
        guard let area = area else { return }
        areaLabel.text = "\(area.displayType) Data"
        
        guard let seriesReport = seriesReport else {
            monthYearLabel.text = ""
            valueLabel.text = ""
            oneMonthRateChangeLabel.text = ""
            oneMonthNetChangeLabel.text = ""
            twelveMonthRateChangeLabel.text = ""
            twelveMonthNetChangeLabel.text = ""
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

        guard let seriesData = data else {
            monthYearLabel.text = ""
            oneMonthRateChangeLabel.text = ""
            oneMonthNetChangeLabel.text = ReportManager.dataNotAvailableStr
            twelveMonthRateChangeLabel.text = ""
            twelveMonthNetChangeLabel.text = ReportManager.dataNotAvailableStr
            valueLabel.text = ReportManager.dataNotAvailableStr
            return
        }
        
        monthYearLabel.text = "\(seriesData.periodName) \(seriesData.year)"
        seasonalAdjustmentLabel.text = seasonallyAdjusted?.description

        if var doubleValue = Double(seriesData.value) {
            doubleValue = doubleValue * 1000
            valueLabel.text = NumberFormatter.localizedString(from: NSNumber(value: doubleValue), number: NumberFormatter.Style.decimal)
        }
        else {
            valueLabel.text = ReportManager.dataNotAvailableStr
        }
        
        if let percentChange = seriesData.calculations?.percentChanges {
            oneMonthRateChangeLabel.text =
                NumberFormatter.localisedPercentStr(from: percentChange.oneMonth) ??  ReportManager.dataNotAvailableStr
            twelveMonthRateChangeLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
        }
        if let netChange = seriesData.calculations?.netChanges {
            if let oneMonthChange = netChange.oneMonth, var doubleValue = Double(oneMonthChange) {
                doubleValue = doubleValue * 1000
                oneMonthNetChangeLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
            }
            else {
                oneMonthNetChangeLabel.text = ReportManager.dataNotAvailableStr
            }
            
            if let twelveMonthChange = netChange.twelveMonth, var doubleValue = Double(twelveMonthChange) {
                doubleValue = doubleValue * 1000
                twelveMonthNetChangeLabel.text = NumberFormatter.localisedDecimalStr(from: doubleValue)
            }
            else {
                twelveMonthNetChangeLabel.text = ReportManager.dataNotAvailableStr
            }
        }
        else {
            oneMonthNetChangeLabel.text = ReportManager.dataNotAvailableStr
            twelveMonthNetChangeLabel.text = ReportManager.dataNotAvailableStr
        }
    }
    
    func applyAccessibility() {
        var valueAccessibilityStr = "Employment Level,"
        
        if valueLabel.text == ReportManager.dataNotAvailableStr {
            valueAccessibilityStr += ReportManager.dataNotAvailableAccessibilityStr
            accessibilityElements = [areaView, valueView, oneMonthChangeView, twelveMonthChangeView]
        }
        else {
            valueAccessibilityStr += valueLabel.text ?? ""
            accessibilityElements = [areaView, monthYearLabel, valueView, oneMonthChangeView, twelveMonthChangeView]
        }
        var oneMonthChangeStr = "One month change,"
        if oneMonthNetChangeLabel.text == ReportManager.dataNotAvailableStr {
            oneMonthChangeStr += ReportManager.dataNotAvailableAccessibilityStr
        }
        else {
            oneMonthChangeStr += "Net Change,\(oneMonthNetChangeLabel.text ?? "")"
            oneMonthChangeStr += ",Rate Change,\(oneMonthRateChangeLabel.text ?? "")"
        }
        oneMonthChangeView.accessibilityLabel = oneMonthChangeStr

        var twelveMonthChangeStr = "Twelve month change,"
        if twelveMonthNetChangeLabel.text == ReportManager.dataNotAvailableStr {
            twelveMonthChangeStr += ReportManager.dataNotAvailableAccessibilityStr
        }
        else {
            twelveMonthChangeStr += "Net Change,\(twelveMonthNetChangeLabel.text ?? "")"
            twelveMonthChangeStr += ",Rate Change,\(twelveMonthRateChangeLabel.text ?? "")"
        }
        twelveMonthChangeView.accessibilityLabel = twelveMonthChangeStr

        valueView.accessibilityLabel = valueAccessibilityStr
        areaView.accessibilityLabel = areaLabel.text
    }
}
