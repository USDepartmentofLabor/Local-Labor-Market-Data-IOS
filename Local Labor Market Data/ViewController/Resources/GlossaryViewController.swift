//
//  GloassaryViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/8/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class GlossaryViewController: UIViewController {

    let sections =
        [(title:"1-month change", desc: "The change in a data value between the current displayed month and the immediately preceding month.  Note that when viewing not seasonally adjusted data, the 1-month change may be primarily driven by seasonal factors."),
         (title:"12-month change", desc:"The change in a data value between the current displayed month and the same month in the previous calendar year.  The 12-month change value is not affected by seasonal factors."),
         (title:"Metropolitan Statistical Area (MSA)", desc:"A large population nucleus, together with adjacent communities which have a high degree of economic and social integration with that nucleus. These communities are defined by the Office of Management and Budget as a standard for federal agencies in the preparation and publication of statistics relating to metropolitan areas."),
         (title:"N/A", desc:"Data not available.  This may result when data cannot be released due to data confidentiality or quality concerns or when a data element is not produced, due to changes in classifications or other survey changes.  Data are also not available on a seasonally adjusted basis for some data elements."),
         (title:"Seasonally adjusted", desc:"Seasonal adjustment removes the effects of events that follow a more or less regular pattern each year. These adjustments make it easier to observe the cyclical and other nonseasonal movements in a data series.  Only certain data elements are available on a seasonally adjusted basis; when only not seasonally adjusted data are available, the app will display N/A for a data value when seasonally adjusted is selected."),
        (title: "Unemployment rate", desc: "The unemployment rate represents the number of unemployed (persons who had no employment, were available for work, and had made specific efforts to find employment) as a percent of the labor force (all persons employed and unemployed).")]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        tableView.tableFooterView = UIView()
    }
}

extension GlossaryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "glossaryCell")
        
        let section = sections[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cell.textLabel?.text = section.title
        
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        cell.detailTextLabel?.text = section.desc
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
}

extension GlossaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
