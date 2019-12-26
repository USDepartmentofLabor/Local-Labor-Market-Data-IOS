//
//  SplitViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 12/20/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        preferredDisplayMode = .allVisible
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        return true
    }
}
