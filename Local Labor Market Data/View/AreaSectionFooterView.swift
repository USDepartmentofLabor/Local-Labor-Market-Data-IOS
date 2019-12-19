//
//  AreaSectionFooterView.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 2/20/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol AreaSectionFooterDelegate: class {
    func sectionFooter(_ sectionFooter: AreaSectionFooterView, displayHistory section:Int)
}

class AreaSectionFooterView: UITableViewHeaderFooterView {

    class var nibName: String { return "AreaSectionFooterView" }
    class var reuseIdentifier: String { return "AreaSectionFooterView" }

    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: AreaSectionFooterDelegate?

    var section: Int = 0

    @IBOutlet weak var historyView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }
    
    override var contentView: UIView {
        return subviews[0]
    }
    
    
    func setupView() {
        titleLabel.scaleFont(forDataType: .reportSectionTitle)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sectionClick(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        historyView.addGestureRecognizer(tapGestureRecognizer)
        
        historyView.isAccessibilityElement = true
        historyView.accessibilityTraits = .button
        historyView.accessibilityLabel = "History"
    }
    
    @objc private func sectionClick(_ sender: UITapGestureRecognizer) {
        delegate?.sectionFooter(self, displayHistory: section)
    }

}
