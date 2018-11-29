//
//  HistoryViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/29/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    var viewModel: HistoryViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        title = viewModel?.title ?? "History"
    }
}
