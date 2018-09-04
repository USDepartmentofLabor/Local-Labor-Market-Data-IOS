//
//  ViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/2/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        dataUtil.getCounties(forCBSACode: "47900")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadZipToCounty(_ sender: Any) {
        let dataUtil = LoadDataUtil(managedContext: CoreDataManager.shared().viewManagedContext)
        dataUtil.loadZipCountyMap()
    }
    
    @IBAction func loadZipToCBSA(_ sender: Any) {
        let dataUtil = LoadDataUtil(managedContext: CoreDataManager.shared().viewManagedContext)
        dataUtil.loadZipCBSAMap()
    }
    
    @IBAction func loadLAUSLookup(_ sender: Any) {
        let dataUtil = LoadDataUtil(managedContext: CoreDataManager.shared().viewManagedContext)
        dataUtil.loadLAUSData()
    }
}

