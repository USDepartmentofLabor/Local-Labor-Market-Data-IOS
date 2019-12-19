//
//  HistoryViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/29/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

enum HistoryFormat: Int {
    case lineChart = 0
    case barChart
    case table
}

protocol HistoryViewProtocol {
    var viewModel: HistoryViewModel? {get set}
    func displayHistoryData()
}

protocol OrientationProtocol {
    var orientation: UIInterfaceOrientationMask {get}
}

class HistoryViewController: UIViewController, OrientationProtocol {

    @IBOutlet weak var areaTitleLabel: UILabel!
    @IBOutlet weak var formatSegmentController: UISegmentedControl!
    @IBOutlet weak var seasonallyAdjustedView: UIView!
    @IBOutlet weak var seasonallyAdjustedSwitch: UICustomSwitch!
    @IBOutlet weak var seasonallyAdjustedTitle: UILabel!

    @IBOutlet weak var historyContainerView: UIView!
    var viewModel: HistoryViewModel?
    weak var currentHistoryViewController: UIViewController? = nil
    
    var currentHistoryFormat: HistoryFormat = .barChart
    
    lazy var activityIndicator = ActivityIndicatorView(text: "Loading", inView: view)
    var seasonalAdjustment: SeasonalAdjustment = .notAdjusted {
        didSet {
            viewModel?.seasonalAdjustment = seasonalAdjustment
            loadReports()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        title = viewModel?.title ?? "History"
        areaTitleLabel.text = viewModel?.area.title
        
        areaTitleLabel.scaleFont(forDataType: .reportAreaTitle, for:traitCollection)
        
        seasonallyAdjustedSwitch.tintColor = UIColor(named: "AppBlue")
        seasonallyAdjustedSwitch.onTintColor = UIColor(named: "AppBlue")
        seasonallyAdjustedTitle.scaleFont(forDataType: .seasonallyAdjustedSwitch, for: traitCollection)
        
        formatSegmentController.setios12Style()
        if Util.isVoiceOverRunning {
            formatSegmentController.selectedSegmentIndex = HistoryFormat.table.rawValue
            showHistoryController(format: .table)
        }
        else {
            formatSegmentController.selectedSegmentIndex = HistoryFormat.lineChart.rawValue
            showHistoryController(format: .lineChart)
        }
        
        let seasonalAdjustment: SeasonalAdjustment = viewModel?.seasonalAdjustment ?? .adjusted
        seasonallyAdjustedSwitch.isOn = (seasonalAdjustment == .adjusted) ? true:false
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        areaTitleLabel.accessibilityTraits = UIAccessibilityTraits.header
        areaTitleLabel.accessibilityLabel = viewModel?.area.accessibilityStr
        seasonallyAdjustedSwitch.accessibilityLabel = "Seasonally Adjusted"
        seasonallyAdjustedTitle.isAccessibilityElement = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if currentHistoryFormat == .table {
            return .portrait
        }
        else {
            return UIInterfaceOrientationMask.landscapeLeft
        }
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if currentHistoryFormat == .table {
            return .portrait
        }
        else {
            return .landscapeLeft
        }
    }
    
    var orientation: UIInterfaceOrientationMask {
        return supportedInterfaceOrientations
    }
    
    @IBAction func seasonallyAdjustClick(_ sender: Any) {
        seasonalAdjustment = seasonallyAdjustedSwitch.isOn ? .adjusted : .notAdjusted
    }

    @IBAction func didChangeFormat(_ sender: Any) {
        if let format = HistoryFormat.init(rawValue: formatSegmentController.selectedSegmentIndex) {
            showHistoryController(format: format)
        }
    }
    
    func showHistoryController(format: HistoryFormat) {
        if format == currentHistoryFormat {
            return
        }
        
        if let controller = currentHistoryViewController {
            hideContentController(controller: controller)
            currentHistoryViewController = nil
        }
        
        currentHistoryFormat = format
        let viewController: UIViewController
        let orientation: UIInterfaceOrientation
        switch currentHistoryFormat {
        case .table:
            viewController = HistoryTabularViewController.instantiateFromStoryboard()
             orientation = UIInterfaceOrientation.portrait
        case .barChart:
            viewController = HistoryBarChartViewController.instantiateFromStoryboard()
            orientation = UIInterfaceOrientation.landscapeLeft
        case .lineChart:
            viewController = HistoryLineChartViewController.instantiateFromStoryboard()
            orientation = UIInterfaceOrientation.landscapeLeft
        }
        
        if var historyView = viewController as? HistoryViewProtocol {
            historyView.viewModel = viewModel
        }

        UIDevice.current.setValue(Int(orientation.rawValue), forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()

        currentHistoryViewController = viewController
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        historyContainerView.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: historyContainerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: historyContainerView.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: historyContainerView.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: historyContainerView.bottomAnchor)
            ])
        
        viewController.didMove(toParent: self)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func hideContentController(controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
}

extension HistoryViewController {
    func loadReports() {
        let seasonalAdjustedTitle = (seasonalAdjustment == .adjusted) ?
                                "Seasonally Adjusted" : " Not Seasonally Adjusted"
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement,
                             argument: "Loading \(seasonalAdjustedTitle) \(title) Reports")

        loadHistoryReport()
    }
    
    func loadHistoryReport() {
        activityIndicator.startAnimating(disableUI: true)
        
        viewModel?.loadHistory { [weak self] (apiResult) in

            guard let strongSelf = self else {return}
            strongSelf.activityIndicator.stopAnimating()

            switch(apiResult) {
            case .success( _):
                let announcementStr = "Loaded  Report"
                UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementStr)
                
            case .failure(let error):
                strongSelf.handleError(error: error)
            }
            
            if let historyView = strongSelf.currentHistoryViewController as? HistoryViewProtocol {
                historyView.displayHistoryData()
            }
        }
    }
}
