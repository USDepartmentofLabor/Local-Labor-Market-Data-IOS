//
//  UITableView+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/31/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

extension UITableView: UIAccessibilityContainerDataTable {
    public func accessibilityDataTableCellElement(forRow row: Int, column: Int) -> UIAccessibilityContainerDataTableCell? {
        return nil
    }
    
    public func accessibilityRowCount() -> Int {
        return 2
    }
    
    public func accessibilityColumnCount() -> Int {
        return 3
    }
    
    override open func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        return true
    }

}
