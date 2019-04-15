//
//  ItemCESTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 2/19/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ItemCESTableViewCell: UITableViewCell {

    
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var twelveMonthPercentLabel: UILabel!
    @IBOutlet weak var twelveMonthValueLabel: UILabel!
    @IBOutlet weak var oneMonthPercentLabel: UILabel!
    @IBOutlet weak var oneMonthValueLabel: UILabel!
    @IBOutlet weak var nextImageView: UIImageView!

    var value: String = "" {
        didSet {
            valueLabel.text = value
            
            if value == ReportManager.dataNotAvailableStr {
                valueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            }
            else {
                valueLabel.accessibilityLabel = value
            }
        }
    }
    var twelveMonthPercent: String = "" {
        didSet {
            twelveMonthPercentLabel.text = twelveMonthPercent
            
            if twelveMonthPercent == ReportManager.dataNotAvailableStr {
                twelveMonthPercentLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            }
            else {
                twelveMonthPercentLabel.accessibilityLabel = twelveMonthPercent
            }
        }
    }
    var twelveMonthValue: String = "" {
        didSet {
            twelveMonthValueLabel.text = twelveMonthValue
            
            if twelveMonthValue == ReportManager.dataNotAvailableStr {
                twelveMonthValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            }
            else {
                twelveMonthValueLabel.accessibilityLabel = twelveMonthValue
            }
        }
    }
    var oneMonthPercent: String = "" {
        didSet {
            oneMonthPercentLabel.text = oneMonthPercent
            
            if oneMonthPercent == ReportManager.dataNotAvailableStr {
                oneMonthPercentLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            }
            else {
                oneMonthPercentLabel.accessibilityLabel = oneMonthPercent
            }
        }
    }
    var oneMonthValue: String = "" {
        didSet {
            oneMonthValueLabel.text = oneMonthValue
            
            if oneMonthValue == ReportManager.dataNotAvailableStr {
                oneMonthValueLabel.accessibilityLabel = ReportManager.dataNotAvailableAccessibilityStr
            }
            else {
                oneMonthValueLabel.accessibilityLabel = oneMonthValue
            }
        }
    }



    var hasChildren: Bool = false {
        didSet {
            if hasChildren {
                nextImageView.isHidden = false
                accessibilityTraits = UIAccessibilityTraits.button
                nextImageView.isAccessibilityElement = true
                nextImageView.accessibilityTraits = .button
            }
            else {
                nextImageView.isHidden = true
                accessibilityTraits = UIAccessibilityTraits.none
                nextImageView.isAccessibilityElement = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }

    func setupView() {
        dataView.layer.borderWidth = 1
        dataView.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        
        titleLabel.scaleFont(forDataType: .itemTitle)
        valueLabel.scaleFont(forDataType: .itemValue)
        oneMonthValueLabel.scaleFont(forDataType: .itemChangeValue)
        oneMonthPercentLabel.scaleFont(forDataType: .itemChangeValue)
        twelveMonthValueLabel.scaleFont(forDataType: .itemChangeValue)
        twelveMonthPercentLabel.scaleFont(forDataType: .itemChangeValue)
        
        setupAccessibility()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupAccessibility() {
        isAccessibilityElement = false
        nextImageView.accessibilityHint = "Tap to view sub industries"
        accessibilityElements = [titleLabel as Any, valueLabel as Any, oneMonthValueLabel as Any, oneMonthPercentLabel as Any, twelveMonthValueLabel as Any, twelveMonthPercentLabel as Any, nextImageView as Any]
    }
}
