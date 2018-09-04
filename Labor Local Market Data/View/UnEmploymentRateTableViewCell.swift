//
//  UnEmploymentRateTableViewCell.swift
//  Labor Local Data
//
//  Created by Nidhi Chawla on 8/1/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class UnEmploymentRateTableViewCell: UITableViewCell {

    class var nibName: String { return "UnEmploymentRateTableViewCell" }
    class var reuseIdentifier: String { return "UnEmploymentRateTableViewCell" }

    
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var monthYearLabel: UILabel!
    
    @IBOutlet weak var dataTitleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var percentPointTitle: UILabel!
    
    @IBOutlet weak var oneMonthChangeTitleLabel: UILabel!
    @IBOutlet weak var oneMonthRateChangeLabel: UILabel!
    @IBOutlet weak var twelveMonthChangeTitleLabel: UILabel!
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
        
        percentPointTitle.scaleFont(forDataType: .reportPercentPointTitle, for: traitCollection)
        oneMonthChangeTitleLabel.scaleFont(forDataType: .reportChangeTitle, for: traitCollection)
        twelveMonthChangeTitleLabel.scaleFont(forDataType: .reportChangeTitle, for: traitCollection)
        
        oneMonthRateChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        twelveMonthRateChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
  
//        isAccessibilityElement = true
//        accessibilityLabel = "Unnemployment"
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
//        shouldGroupAccessibilityChildren = true
//        areaView.isAccessibilityElement = true
//        areaView.accessibilityTraits = UIAccessibilityTraitStaticText
//        valueView.isAccessibilityElement = true
//        valueView.accessibilityTraits = UIAccessibilityTraitStaticText
//        oneMonthChangeView.isAccessibilityElement = true
//        oneMonthChangeView.accessibilityTraits = UIAccessibilityTraitStaticText
//        twelveMonthChangeView.isAccessibilityElement = true
//        twelveMonthChangeView.accessibilityTraits = UIAccessibilityTraitStaticText
        accessibilityElements = [areaLabel, monthYearLabel, valueView, percentPointTitle, oneMonthChangeView, twelveMonthChangeView]
    }
}

extension UnEmploymentRateTableViewCell: ReportTableViewCell {
    
    func displaySeries(area: Area?, seriesReport: SeriesReport?, periodName: String? = nil, year: String? = nil) {
        
        let areaTitle = area is National ? "National Data" : "Local Data"
        areaLabel.text = areaTitle
        
        guard let seriesReport = seriesReport else {
            monthYearLabel.text = ""
            valueLabel.text = ""
            oneMonthRateChangeLabel.text = ""
            twelveMonthRateChangeLabel.text = ""
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
            valueLabel.text = ReportManager.dataNotAvailableStr
            valueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            oneMonthRateChangeLabel.text = ReportManager.dataNotAvailableStr
            oneMonthRateChangeLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            twelveMonthRateChangeLabel.text = ReportManager.dataNotAvailableStr
            twelveMonthRateChangeLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            monthYearLabel.accessibilityElementsHidden = true
            return
        }
        
        monthYearLabel.accessibilityElementsHidden = false
        monthYearLabel.text = "\(seriesData.periodName) \(seriesData.year)"
        valueLabel.text = "\(seriesData.value)%"
        
        if let percentChange = seriesData.calculations?.percentChanges {
            oneMonthRateChangeLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.oneMonth) ?? ReportManager.dataNotAvailableStr
            twelveMonthRateChangeLabel.text = NumberFormatter.localisedPercentStr(from: percentChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
        }
    }
    
    func applyAccessibility() {
        areaView.accessibilityLabel = areaLabel.text

        var valueAccessibilityStr = "Unemployment Level,"
        if valueLabel.text == ReportManager.dataNotAvailableStr {
            valueAccessibilityStr += ReportManager.dataNotAvailableAccessibilityStr
            accessibilityElements = [areaView, valueView, percentPointTitle, oneMonthChangeView, twelveMonthChangeView]
        }
        else {
            valueAccessibilityStr += valueLabel.text ?? ""
            accessibilityElements = [areaView, monthYearLabel, valueView, percentPointTitle, oneMonthChangeView, twelveMonthChangeView]
        }
        
        valueView.accessibilityLabel = valueAccessibilityStr
        
        // One Month Change
        var oneMonthAccessibilityStr = "One Month Change,"
        if oneMonthRateChangeLabel.text == ReportManager.dataNotAvailableStr {
            oneMonthAccessibilityStr += ReportManager.dataNotAvailableAccessibilityStr
        }
        else {
            oneMonthAccessibilityStr += oneMonthRateChangeLabel.text ?? ""
        }
        oneMonthChangeView.accessibilityLabel = oneMonthAccessibilityStr
        
        // Twelve Month Change
        var twelveMonthAccessibilityStr = "Twelve Month Change,"
        if twelveMonthRateChangeLabel.text == ReportManager.dataNotAvailableStr {
            twelveMonthAccessibilityStr += ReportManager.dataNotAvailableAccessibilityStr
        }
        else {
            twelveMonthAccessibilityStr += twelveMonthRateChangeLabel.text ?? ""
        }
        
        twelveMonthChangeView.accessibilityLabel = twelveMonthAccessibilityStr
    }
}
