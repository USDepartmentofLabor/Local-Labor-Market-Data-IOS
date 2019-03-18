//
//  OccupationalEmploymentTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/1/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class OccupationalEmploymentTableViewCell: UITableViewCell {

    class var nibName: String { return "OccupationalEmploymentTableViewCell" }
    class var reuseIdentifier: String { return "OccupationalEmploymentTableViewCell" }

    
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dataTitleLabel: UILabel!
    @IBOutlet weak var dataValueLabel: UILabel!
    
    @IBOutlet weak var areaView: UIView!
    @IBOutlet weak var valueView: UIView!
    
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
        yearLabel.scaleFont(forDataType: .reportPeriodName, for:traitCollection)
        dataTitleLabel.scaleFont(forDataType: .reportDataTitle, for: traitCollection)
        dataValueLabel.scaleFont(forDataType: .reportData, for: traitCollection)
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [areaLabel, yearLabel, dataTitleLabel, dataValueLabel]
    }
}

extension OccupationalEmploymentTableViewCell: ReportTableViewCell {
    func displaySeries(area: Area?, seriesReport: SeriesReport?, periodName: String?, year: String?, seasonallyAdjusted: SeasonalAdjustment? = nil) {
        
//        defer {applyAccessibility()}

        guard let area = area else { return }
        areaLabel.text = "\(area.displayType) Data"

        
        guard let seriesReport = seriesReport else {
            yearLabel.text = ""
            dataValueLabel.text = ""
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
            dataValueLabel.text = ReportManager.dataNotAvailableStr
            dataValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            yearLabel.text = ""
            accessibilityElements = [areaLabel, dataTitleLabel, dataValueLabel]
            return
        }
        
        accessibilityElements = [areaLabel, yearLabel, dataTitleLabel, dataValueLabel]
        yearLabel.text = seriesData.year

        if let doubleValue = Double(seriesData.value) {
            dataValueLabel.text = NumberFormatter.localisedCurrencyStrWithoutFraction(from: NSNumber(value: doubleValue))
        }
        else {
            dataValueLabel.text = "$\(seriesData.value)"
        }
    }
}
