//
//  ItemTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 1/3/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var nationalValueLabel: UILabel!
    
    @IBOutlet weak var nextImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        dataView.layer.borderWidth = 1
        dataView.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        
        titleLabel.scaleFont(forDataType: .itemTitle)
        valueLabel.scaleFont(forDataType: .itemValue)
        nationalValueLabel.scaleFont(forDataType: .itemValue)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
