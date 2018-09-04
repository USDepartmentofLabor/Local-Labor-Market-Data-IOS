//
//  UICustomSwitch.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/31/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable

class UICustomSwitch: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}
