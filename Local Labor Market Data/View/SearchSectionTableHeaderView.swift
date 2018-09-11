//
//  SearchSectionHeaderTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/24/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

protocol SearchSectionHeaderDelegate: class {
    func sectionHeader(_ sectionHeader: SearchSectionTableHeaderView, didSelectSection secton:Int)
}

class SearchSectionTableHeaderView: UITableViewHeaderFooterView {

    class var nibName: String { return "SearchSectionTableHeaderView" }
    class var reuseIdentifier: String { return "SearchSectionTableHeaderView" }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var section: Int = 0
    weak var delegate: SearchSectionHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }

    func setupView() {
        let colorView = UIView(frame: self.bounds)
        colorView.backgroundColor = UIColor.gray
        backgroundView = colorView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer)
        
        titleLabel.scaleFont(forDataType: .areaTypeTitle, for: traitCollection)
    }

    override var contentView: UIView {
        return subviews[0]
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        delegate?.sectionHeader(self, didSelectSection: section)
    }
    
}
