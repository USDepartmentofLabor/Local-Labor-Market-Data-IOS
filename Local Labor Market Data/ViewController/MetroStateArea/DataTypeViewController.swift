//
//  DataTypeViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 2/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol DataTypeViewDelegate: class {
    func didSelect(for controller: DataTypeViewController, dataTpe: ItemDataType)
}

class DataTypeViewController: UIViewController {

    var itemDataTypes: [ItemDataType]?
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: DataTypeViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let height = tableView.contentSize.height
        let size =  CGSize(width: super.preferredContentSize.width, height: height)
        preferredContentSize = size
    }
}

extension DataTypeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDataTypes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if let c = tableView.dequeueReusableCell(withIdentifier: "cellID") {
            cell = c
        }
        else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        }

        cell.textLabel?.textAlignment = .center
        cell.textLabel?.scaleFont(forDataType: .itemDataType)
        cell.textLabel?.text = itemDataTypes?[indexPath.row].title ?? ""
        
        return cell
    }
}

extension DataTypeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selected = itemDataTypes?[indexPath.row] {
            delegate?.didSelect(for: self, dataTpe: selected)
        }
    }
}
