//
//  NationalViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/24/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class NationalViewController: MetroStateViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setupView() {
        super.setupView()
        title = "National Data"
        areaTitleLabel.text = "National Data"
        subAreaHeightConstraint.constant = 0
    }
}
