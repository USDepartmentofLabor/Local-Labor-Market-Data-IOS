//
//  UISegmentControl+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 10/30/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    func setios12Style() {
        if #available(iOS 13.0, *) {
            selectedSegmentTintColor = UIColor(named: "AppColor")
            setTitleTextAttributes([.foregroundColor : tintColor as Any], for: .normal)
            setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
            layer.borderWidth = 1
            layer.borderColor = tintColor.cgColor
        }
    }
}
