//
//  CEIndustryViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/26/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class CEIndustryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var parentIndustry: CE_Industry?
    var industries: [CE_Industry]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    

    func setupView() {
        if parentIndustry == nil {
            industries = CE_Industry.getSupersectors(context:
                CoreDataManager.shared().viewManagedContext)
            title = "Supersectors"
        }
        else {
            industries = parentIndustry?.subIndustries() as? [CE_Industry]
            title = parentIndustry?.title
        }
    }
}

// MARK: TableView DataSource
extension CEIndustryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return industries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        if let industry = industries?[indexPath.row] {
            cell.textLabel?.text = industry.title
            
            if (industry.subIndustry?.count ?? 0) > 0 {
                cell.accessoryType = .disclosureIndicator
            }
            else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
}

extension CEIndustryViewController: UITableViewDelegate {
}

extension CEIndustryViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showIndustry" {
            if let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell),
                let destViewController = segue.destination as? CEIndustryViewController,
                let industry = industries?[indexPath.row] {
                    destViewController.parentIndustry = industry
            }
        }
    }
}
