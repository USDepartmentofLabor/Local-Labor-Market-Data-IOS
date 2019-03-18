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
        oneMonthValueLabel.scaleFont(forDataType: .itemValue)
        oneMonthPercentLabel.scaleFont(forDataType: .itemValue)
        twelveMonthValueLabel.scaleFont(forDataType: .itemValue)
        twelveMonthPercentLabel.scaleFont(forDataType: .itemValue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
