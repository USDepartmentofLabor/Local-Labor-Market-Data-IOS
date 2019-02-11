//
//  ItemTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 1/3/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
@IBOutlet weak var nationalValueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
