//
//  AboutViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/8/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    let releaseDate = "September 14, 2018"
    
    let about1Str = """
    The Bureau of Labor Statistics (BLS) Local Labor Market Data app presents data on unemployment rates and employment by industry and occupation for states, metro areas, and counties. The most recent figures are presented, although the latest available data will vary by data type and geography.
    """
    let about2Str = """
    National unemployment rate comes from the Current Population Survey (CPS), while state, metro area, and county unemployment rates come from the Local Area Unemployment Statistics (LAUS) program.
    """
    
    let about3Str = """
    National, state, and metro area employment by industry comes from the Current Employment Statistics (CES) program.
    """
    
    let about4Str = """
    County employment and wages by industry come from the Quarterly Census of Employment and Wages (QCEW) program.
    """
    
    let about5Str = """
    National, state, and metro area employment and wages by occupation come from the Occupational Employment Statistics (OES) program.
    """

    let about6Str = """
    The Local Labor Market Data app presents both seasonally adjusted and not seasonally adjusted data where available. Note that seasonally adjusted data are not generally available for metro areas and counties.
    """
    
    @IBOutlet weak var description1Label: UILabel!
    @IBOutlet weak var description2Label: UILabel!
    @IBOutlet weak var description3Label: UILabel!
    @IBOutlet weak var description4Label: UILabel!
    @IBOutlet weak var description5Label: UILabel!
    @IBOutlet weak var description6Label: UILabel!
    
    @IBOutlet weak var versionValueLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
        
    
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
        title = "About"
        
        navigationController?.navigationBar.topItem?.title = ""
        description1Label.text = about1Str
        description2Label.text = about2Str
        description3Label.text = about3Str
        description4Label.text = about4Str
        description5Label.text = about5Str
        description6Label.text = about6Str
        
        versionValueLabel.text = Bundle.main.versionNumber  + "." + Bundle.main.buildNumber
        releaseDateLabel.text = releaseDate
    }
}
