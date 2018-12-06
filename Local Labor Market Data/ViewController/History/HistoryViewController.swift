//
//  HistoryViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/29/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit
import Charts

class HistoryViewController: UIViewController {

    var viewModel: HistoryViewModel?
    @IBOutlet weak var chartView: BarChartView!
    
    var dataEntry: [BarChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        title = viewModel?.title ?? "History"
        
        setupChartView()
    }
    
    func setupChartView() {
//        chartView.delegate = self
        chartView.noDataTextColor = .black
        chartView.noDataText = "No Data for Chart"
        chartView.backgroundColor = .white
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        setBarChart(dataPoints: ["1", "2", "4"], values: ["30", "40", "10"])
    }
    
    func setBarChart(dataPoints: [String], values: [String]) {
        
        for i in 0..<dataPoints.count {
            let dataPoint =  BarChartDataEntry(x: Double(i), y: Double(values[i])!)
            dataEntry.append(dataPoint)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntry, label: "BPM")
        chartDataSet.colors = [.blue]
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.setDrawValues(false)
     
        
        let xAxis = XAxis()
//        xAxis.valueFormatter = Formatter
//        chartView.xAxis.valueFormatter = xAxis.valueFormatter
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.legend.enabled = true
        chartView.rightAxis.enabled = false
        chartView.data = chartData
    }
}
