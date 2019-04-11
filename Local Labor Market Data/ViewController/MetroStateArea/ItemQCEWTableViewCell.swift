//
//  ItemQCEWTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 2/19/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ItemQCEWTableViewCell: UITableViewCell {
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var twelveMonthValueLabel: UILabel!
    @IBOutlet weak var twelveMonthPercentLabel: UILabel!
    
    
    @IBOutlet weak var nationalValueStackView: UIStackView!
    @IBOutlet weak var nationalValueLabel: UILabel!
    @IBOutlet weak var nationalTwelveMonthValueLabel: UILabel!
    @IBOutlet weak var nationalTwelveMonthPercentLabel: UILabel!
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
        twelveMonthValueLabel.scaleFont(forDataType: .itemChangeValue)
        twelveMonthPercentLabel.scaleFont(forDataType: .itemChangeValue)
        
        nationalValueLabel.scaleFont(forDataType: .itemValue)
        nationalTwelveMonthValueLabel.scaleFont(forDataType: .itemChangeValue)
        nationalTwelveMonthPercentLabel.scaleFont(forDataType: .itemChangeValue)
        
        setupAccessibility()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [titleLabel as Any, valueLabel as Any, twelveMonthValueLabel as Any, twelveMonthPercentLabel as Any, nationalValueLabel as Any, nationalTwelveMonthValueLabel as Any, nationalTwelveMonthPercentLabel as Any]
    }
}
