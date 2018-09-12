//
//  AreaSectionHeaderView.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/31/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

protocol AreaSectionHeaderDelegate: class {
    func sectionHeader(_ sectionHeader: AreaSectionHeaderView, toggleExpand section:Int)
}


class AreaSectionHeaderView: UITableViewHeaderFooterView {
    class var nibName: String { return "AreaSectionHeaderView" }
    class var reuseIdentifier: String { return "AreaSectionHeaderView" }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var expandCollapseImageView: UIImageView!
    
    var section: Int = 0
    weak var delegate: AreaSectionHeaderDelegate?
    var sectionBackgroundColor: UIColor = UIColor(hex: 0xD8D8D8) {
        didSet {
            dataView.backgroundColor = sectionBackgroundColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }
    
    override var contentView: UIView {
        return subviews[0]
    }

    
    func setupView() {
        dataView.layer.borderWidth = 1
        dataView.layer.borderColor = UIColor(hex: 0x969696).cgColor
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleOpen(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer)
        
        titleLabel.scaleFont(forDataType: .reportSectionTitle, for: traitCollection)
        
    }

    @objc private func toggleOpen(_ sender: UITapGestureRecognizer) {
        toggleExpand(withUserAction: true)
    }
    
    func configure(title: String, section: Int, collapse: Bool) {
        titleLabel.text = title
        self.section = section
        collapseSection(collapse: collapse)
        applyAccessibility()
    }
    
    func applyAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = titleLabel.text
        accessibilityTraits = UIAccessibilityTraitHeader
        titleLabel.isAccessibilityElement = false
        expandCollapseImageView.isAccessibilityElement = false
        
        if Util.isVoiceOverRunning {
            expandCollapseImageView.isHidden = true
        }
        else {
            expandCollapseImageView.isHidden = false
        }
    }

    
    func toggleExpand(withUserAction userAction: Bool) {
        
        // if this was a user action, send the delegate the appropriate message
        if (userAction) {
            delegate?.sectionHeader(self, toggleExpand: section)
        }
    }
    
    func collapseSection(collapse: Bool) {
        if collapse {
            expandCollapseImageView.image = #imageLiteral(resourceName: "rightChevron")
        }
        else {
            expandCollapseImageView.image = #imageLiteral(resourceName: "downChevron")
        }
    }
    
}
