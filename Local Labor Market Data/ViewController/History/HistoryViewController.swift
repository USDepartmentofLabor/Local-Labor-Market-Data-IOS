//
//  HistoryViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/29/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit
import Charts

enum DisplayFormat: Int {
    case barGraph = 0
    case linearGraph
    case tabular
}

class HistoryViewController: UIViewController {

    var viewModel: HistoryViewModel?
//    @IBOutlet weak var chartView: BarChartView!
    
    
    @IBOutlet weak var containerDataView: UIView!
    @IBOutlet weak var seasonallyAdjustedTitle: UILabel!
    @IBOutlet weak var seasonallyAdjustedSwitch: UISwitch!

    @IBOutlet weak var areaTitleLabel: UILabel!
    @IBOutlet weak var displayFormatSegment: UISegmentedControl!
    
    var currentContentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    func setupView() {
        title = viewModel?.title ?? "History"
        
        areaTitleLabel.scaleFont(forDataType: .reportAreaTitle, for:traitCollection)
        seasonallyAdjustedSwitch.onTintColor = #colorLiteral(red: 0.1607843137, green: 0.2117647059, blue: 0.5137254902, alpha: 1)
        seasonallyAdjustedTitle.scaleFont(forDataType: .seasonallyAdjustedSwitch, for: traitCollection)

        areaTitleLabel.text = viewModel?.area.title
        areaTitleLabel.accessibilityLabel = viewModel?.area.accessibilityStr
    }
    
    @IBAction func displayTypeChanged(_ sender: Any) {
        guard let format = DisplayFormat(rawValue: displayFormatSegment.selectedSegmentIndex) else { return }
        
        switch format {
        case .barGraph:
            displayBarGraph()
        case .linearGraph:
            displayLinearGraph()
        case .tabular:
            displayTable()
        }
    }
}

//# MARK - Display Formats
extension HistoryViewController {
    func displayBarGraph() {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        
        let barGraphVC = HistoryBarGraphViewController.instantiateFromStoryboard()
        barGraphVC.viewModel = viewModel
        displayContentController(contentVC: barGraphVC)
    }
    
    func displayLinearGraph() {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func displayTable() {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        
        let historyTableVC = HistoryTableViewController.instantiateFromStoryboard()
        historyTableVC.viewModel = viewModel
        displayContentController(contentVC: historyTableVC)
    }
    
    
    func displayContentController(contentVC: UIViewController) {
        if let oldViewController = currentContentViewController {
            hideContentController(contentVC: oldViewController)
        }
        
        addChild(contentVC)
        containerDataView.addSubview(contentVC.view)
        
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerDataView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":contentVC.view]))
        containerDataView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view":contentVC.view]))
        
        contentVC.didMove(toParent: self)
    }
    
    func hideContentController(contentVC: UIViewController) {
        contentVC.willMove(toParent: nil)
        contentVC.view.removeFromSuperview()
        contentVC.removeFromParent()
    }
}
