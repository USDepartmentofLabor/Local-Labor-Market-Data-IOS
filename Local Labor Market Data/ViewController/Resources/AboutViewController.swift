//
//  AboutViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/8/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    let releaseDate = "Dec 15, 2019"
    
    let about1Str = """
    The Bureau of Labor Statistics (BLS) Local Labor Market Data app presents data on unemployment rates and employment by industry and occupation for states, metro areas, and counties. The most recent figures are presented, although the latest available data will vary by data type and geography.
    """
    let about2Str = """
    New England metro areas shown in this app are delineated by New England cities and towns (NECTAs).  In all other states, metropolitan areas are county-based.
    """
    let about3Str = """
    National unemployment rate comes from the Current Population Survey (CPS), while state, metro area, and county unemployment rates come from the Local Area Unemployment Statistics (LAUS) program.
    """
    
    let about4Str = """
    National, state, and metro area employment by industry comes from the Current Employment Statistics (CES) program.
    """
    
    let about5Str = """
    County employment and wages by industry come from the Quarterly Census of Employment and Wages (QCEW) program.
    """
    
    let about6Str = """
    National, state, and metro area employment and wages by occupation come from the Occupational Employment Statistics (OES) program.
    """

    let about7Str = """
    The Local Labor Market Data app presents both seasonally adjusted and not seasonally adjusted data where available. Note that seasonally adjusted data are not generally available for metro areas and counties.
    """

    let about8Str = """
    Find detailed information from BLS about the duties, education and training, pay, job outlook, and more for hundreds of occupations through the CareerInfo app.
    """

    @IBOutlet weak var description1Label: UILabel!
    @IBOutlet weak var description2Label: UILabel!
    @IBOutlet weak var description3Label: UILabel!
    @IBOutlet weak var description4Label: UILabel!
    @IBOutlet weak var description5Label: UILabel!
    @IBOutlet weak var description6Label: UILabel!
    @IBOutlet weak var description7Label: UILabel!
    @IBOutlet weak var description8TextView: UITextView!
    
    @IBOutlet weak var versionValueLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        displayInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupView() {
        title = "About"
        
        description1Label.scaleFont(forDataType: .infoLabel)
        description2Label.scaleFont(forDataType: .infoLabel)
        description3Label.scaleFont(forDataType: .infoLabel)
        description4Label.scaleFont(forDataType: .infoLabel)
        description5Label.scaleFont(forDataType: .infoLabel)
        description6Label.scaleFont(forDataType: .infoLabel)
        description7Label.scaleFont(forDataType: .infoLabel)
        description8TextView.textContainerInset = UIEdgeInsets.zero
        description8TextView.textContainer.lineFragmentPadding = 0
    }
    
    func displayInfo() {
        description1Label.text = about1Str
        description2Label.text = about2Str
        description3Label.text = about3Str
        description4Label.text = about4Str
        description5Label.text = about5Str
        description6Label.text = about6Str
        description7Label.text = about7Str

        let attributedString = NSMutableAttributedString(string:about8Str)
        if #available(iOS 13.0, *) {
            attributedString.addAttributes(
                [NSAttributedString.Key.font: Style.scaledFont(forDataType: .infoLabel),
                 NSAttributedString.Key.foregroundColor: UIColor.label],
                range: NSRange(location: 0, length: attributedString.length))
        } else {
            attributedString.addAttribute(.font, value: Style.scaledFont(forDataType: .infoLabel), range: NSRange(location: 0, length: attributedString.length))
        }
        let appLinked = attributedString.setAsLink(textToFind: "CareerInfo app", linkURL: "")

        if appLinked {
            description8TextView.attributedText = attributedString
        }
        else {
            description8TextView.text = about8Str
        }
        description8TextView.delegate = self
        
        versionValueLabel.text = Bundle.main.versionNumber  + "." + Bundle.main.buildNumber
        releaseDateLabel.text = releaseDate
    }
    
    func openCareerInfo() {
        let openURL = URL(string: "careerInfo://")
        let installURL = URL(string: "https://apps.apple.com/us/app/careerinfo/id1476300397")
        
        if UIApplication.shared.canOpenURL(openURL!) {
            UIApplication.shared.open(openURL!, options: [:], completionHandler: nil)
        } else if UIApplication.shared.canOpenURL(installURL!) {
            UIApplication.shared.open(installURL!, options: [:], completionHandler: nil)
        }
    }
}

extension AboutViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        DispatchQueue.main.async { [weak self] in
            self?.openCareerInfo()
        }
        
        return false
    }

}
