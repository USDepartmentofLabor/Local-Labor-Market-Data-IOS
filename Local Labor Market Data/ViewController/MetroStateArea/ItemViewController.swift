//
//  ItemViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/26/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var parentItem: Item?
    var items: [Item]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    

    func setupView() {
        if parentItem == nil {
//            occupations = CE_Industry.getSupersectors(context:
//                CoreDataManager.shared().viewManagedContext)
            title = "Supersectors"
        }
        else {
            items = parentItem?.subItems() as? [OE_Occupation]
            title = parentItem?.title
        }
    }
}

// MARK: TableView DataSource
extension ItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if (item.children?.count ?? 0) > 0 {
                cell.accessoryType = .disclosureIndicator
            }
            else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
}

extension ItemViewController: UITableViewDelegate {
}

extension ItemViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showOccupation" {
            if let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell),
                let destViewController = segue.destination as? ItemViewController,
                let item = items?[indexPath.row] {
                    destViewController.parentItem = item
            }
        }
    }
}
