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

    var hasChildren: Bool = false {
        didSet {
            if hasChildren {
                nextImageView.isHidden = false
                accessibilityTraits = UIAccessibilityTraits.button
            }
            else {
                nextImageView.isHidden = true
                accessibilityTraits = UIAccessibilityTraits.none
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
        accessibilityElements = [titleLabel as Any, valueLabel as Any, oneMonthValueLabel as Any, oneMonthPercentLabel as Any, twelveMonthValueLabel as Any, twelveMonthPercentLabel as Any]
    }
}
