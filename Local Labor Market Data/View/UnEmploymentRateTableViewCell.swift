//
//  UnEmploymentRateTableViewCell.swift
//  Local Labor Market Data
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
    @IBOutlet weak var seasonallyAdjustedLabel: UILabel!
    
    @IBOutlet weak var dataTitleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var percentPointTitle: UILabel!
    
    @IBOutlet weak var oneMonthChangeTitleLabel: UILabel!
    @IBOutlet weak var oneMonthNetChangeLabel: UILabel!
    @IBOutlet weak var twelveMonthChangeTitleLabel: UILabel!
    @IBOutlet weak var twelveMonthNetChangeLabel: UILabel!
    
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
        seasonallyAdjustedLabel.scaleFont(forDataType: .seasonalAdjustmentValue, for:traitCollection)
        
        dataTitleLabel.scaleFont(forDataType: .reportDataTitle, for: traitCollection)
        valueLabel.scaleFont(forDataType: .reportData, for: traitCollection)
        
        percentPointTitle.scaleFont(forDataType: .reportPercentPointTitle, for: traitCollection)
        oneMonthChangeTitleLabel.scaleFont(forDataType: .reportChangeTitle, for: traitCollection)
        twelveMonthChangeTitleLabel.scaleFont(forDataType: .reportChangeTitle, for: traitCollection)
        
        oneMonthNetChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
        twelveMonthNetChangeLabel.scaleFont(forDataType: .reportChangeValue, for: traitCollection)
  
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [areaLabel as Any, monthYearLabel as Any, seasonallyAdjustedLabel as Any, valueView as Any, percentPointTitle as Any, oneMonthChangeView as Any, twelveMonthChangeView as Any]
    }
}

extension UnEmploymentRateTableViewCell: ReportTableViewCell {
    
    func displaySeries(area: Area?, seriesReport: SeriesReport?, periodName: String? = nil,
                       year: String? = nil, seasonallyAdjusted: SeasonalAdjustment?) {
        guard let area = area else { return }
        
        areaLabel.text = "\(area.displayType) Data"
        
        guard let seriesReport = seriesReport else {
            monthYearLabel.text = ""
            valueLabel.text = ""
            oneMonthNetChangeLabel.text = ""
            twelveMonthNetChangeLabel.text = ""
            seasonallyAdjustedLabel.text = ""
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
            seasonallyAdjustedLabel.text = ""
            valueLabel.text = ReportManager.dataNotAvailableStr
            valueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            oneMonthNetChangeLabel.text = ReportManager.dataNotAvailableStr
            oneMonthNetChangeLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            twelveMonthNetChangeLabel.text = ReportManager.dataNotAvailableStr
            twelveMonthNetChangeLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            monthYearLabel.accessibilityElementsHidden = true
            return
        }
        
        monthYearLabel.accessibilityElementsHidden = false
        monthYearLabel.text = "\(seriesData.periodName) \(seriesData.year)"
        seasonallyAdjustedLabel.text = seasonallyAdjusted?.description
        

        valueLabel.text = "\(seriesData.value)%"
        
        if let netChange = seriesData.calculations?.netChanges {
            oneMonthNetChangeLabel.text = NumberFormatter.localisedDecimalStr(from: netChange.oneMonth) ?? ReportManager.dataNotAvailableStr
            twelveMonthNetChangeLabel.text = NumberFormatter.localisedDecimalStr(from: netChange.twelveMonth) ?? ReportManager.dataNotAvailableStr
        }
    }
    
    func applyAccessibility() {
        areaView.accessibilityLabel = areaLabel.text

        var valueAccessibilityStr = "Unemployment Level,"
        if valueLabel.text == ReportManager.dataNotAvailableStr {
            valueAccessibilityStr += ReportManager.dataNotAvailableAccessibilityStr
            accessibilityElements = [areaView as Any, valueView as Any, percentPointTitle as Any, oneMonthChangeView as Any, twelveMonthChangeView as Any]
        }
        else {
            valueAccessibilityStr += valueLabel.text ?? ""
            accessibilityElements = [areaView as Any, monthYearLabel as Any, valueView as Any, percentPointTitle as Any, oneMonthChangeView as Any, twelveMonthChangeView as Any]
        }
        
        valueView.accessibilityLabel = valueAccessibilityStr
        
        // One Month Change
        var oneMonthAccessibilityStr = "One Month Change,"
        if oneMonthNetChangeLabel.text == ReportManager.dataNotAvailableStr {
            oneMonthAccessibilityStr += ReportManager.dataNotAvailableAccessibilityStr
        }
        else {
            oneMonthAccessibilityStr += oneMonthNetChangeLabel.text ?? ""
        }
        oneMonthChangeView.accessibilityLabel = oneMonthAccessibilityStr
        
        // Twelve Month Change
        var twelveMonthAccessibilityStr = "Twelve Month Change,"
        if twelveMonthNetChangeLabel.text == ReportManager.dataNotAvailableStr {
            twelveMonthAccessibilityStr += ReportManager.dataNotAvailableAccessibilityStr
        }
        else {
            twelveMonthAccessibilityStr += twelveMonthNetChangeLabel.text ?? ""
        }
        
        twelveMonthChangeView.accessibilityLabel = twelveMonthAccessibilityStr
    }
}
