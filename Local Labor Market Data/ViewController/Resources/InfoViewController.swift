//
//  InfoViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/8/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

enum InfoSection: Int {
    case glossary = 0
    case about
    case help
}

class InfoViewController: UIViewController {
    
    @IBOutlet weak var infoSection: UISegmentedControl!
    
    @IBOutlet weak var glossaryContainerView: UIView!
    @IBOutlet weak var aboutContainerView: UIView!
    
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
        title = "Info"
        infoSection.setios12Style()
        displaySection(section: InfoSection.glossary)
    }

    // Actions
    @IBAction func infoSectionChanged(_ sender: Any) {
        guard let section = InfoSection(rawValue: infoSection.selectedSegmentIndex) else { return }
        displaySection(section: section)
    }
    
    func displaySection(section: InfoSection) {
        switch section {
        case .glossary:
            glossaryContainerView.isHidden = false
            aboutContainerView.isHidden = true
        case .about:
            glossaryContainerView.isHidden = true
            aboutContainerView.isHidden = false
        case .help:
            glossaryContainerView.isHidden = true
            aboutContainerView.isHidden = true
        }
    }
    
}
