//
//  UILabel+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/21/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func scaleFont(forDataType type: Style.DataType, for traitCollection: UITraitCollection? = nil) {
        font = Style.scaledFont(forDataType: type, for: traitCollection)
        adjustsFontForContentSizeCategory = true
    }
}
