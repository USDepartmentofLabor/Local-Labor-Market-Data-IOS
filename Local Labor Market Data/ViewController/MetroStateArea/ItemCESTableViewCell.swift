//
//  ItemCESTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 2/19/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ItemCESTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var tweleveMonthPercentLabel: UILabel!
    @IBOutlet weak var tweleveMonthValueLabel: UILabel!
    @IBOutlet weak var oneMonthPercentLabel: UILabel!
    @IBOutlet weak var oneMonthValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
