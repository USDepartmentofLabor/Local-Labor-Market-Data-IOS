//
//  HistoryUnemploymentTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/18/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class HistoryUnemploymentTableViewCell: UITableViewCell {

    @IBOutlet weak var timePeriodLabel: UILabel!
    @IBOutlet weak var localValueLabel: UILabel!
    @IBOutlet weak var nationalValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupView() {
        timePeriodLabel.scaleFont(forDataType: .itemTitle)
        localValueLabel.scaleFont(forDataType: .itemValue)
        nationalValueLabel.scaleFont(forDataType: .itemValue)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [timePeriodLabel as Any, localValueLabel as Any, nationalValueLabel as Any]
    }
}
