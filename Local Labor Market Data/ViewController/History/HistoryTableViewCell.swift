//
//  HistoryTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 4/2/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    class var reuseIdentifier: String { return "HistoryTableViewCell" }

    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var localValueLabel: UILabel!
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
