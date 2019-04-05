//
//  HistoryBarGraphViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 4/3/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import Charts

class HistoryBarGraphViewController: UIViewController {

    var currentPage: Int = 0
    var viewModel: HistoryViewModel!
    var dataEntry: [BarChartDataEntry] = []

    @IBOutlet weak var barChartView: BarChartView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func setupView() {
        setupChartView()
    }
}


extension HistoryBarGraphViewController {
    func setupChartView() {
        
        barChartView.delegate = self
        barChartView.noDataTextColor = .black
        barChartView.noDataText = "No Data for Chart"
        barChartView.backgroundColor = .white
        
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 12
        //        xAxis.valueFormatter =
        
        xAxis.drawGridLinesEnabled = false
        barChartView.legend.enabled = true
        barChartView.rightAxis.enabled = false
        
        let legend = barChartView.legend
        legend.enabled = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = true
        legend.yOffset = 5.0
        legend.xOffset = 10.0
        legend.yEntrySpace = 0.0
        
        
        let marker = BalloonMarker(color: .red, font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)
        barChartView.marker = marker
        
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.labelPosition = .outsideChart
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
//        setBarChart(dataPoints: ["1", "2", "4"], values: ["0.2", "2.5", "3.7"])
        setBarChart(seriesReport: viewModel!.localAreaReport.seriesReport!)
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
        
        barChartView.data = chartData
    }
    
    func setBarChart(seriesReport: SeriesReport) {
        
        var nationalDataEntry = [BarChartDataEntry]()
        var periods =  [String]()
        
        let count = 13
        let fromIndex = 0
        
        for (index, seriesData) in seriesReport.data.reversed().enumerated() {

            if index < 13 {
                let dataPoint = BarChartDataEntry(x: Double(index), y: Double(seriesData.value) as! Double)
            
                dataEntry.append(dataPoint)
                periods.append(seriesData.periodName)
            
                let nationalDataPoint = BarChartDataEntry(x: Double(index), y: 3.0)
                nationalDataEntry.append(nationalDataPoint)
            }
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntry, label: "\(viewModel.area.displayType)")
        chartDataSet.colors = [.blue]
        
        let chartDataSet2 = BarChartDataSet(values: nationalDataEntry, label: "National")
        chartDataSet2.colors = [.red]
        
        let chartData = BarChartData(dataSets: [chartDataSet, chartDataSet2])
        
        
        let groupSpace = 0.5
        let barSpace = 0.03
        let barWidth = groupSpace
        
        
        let groupCount = 13
        let startYear = 0
        
        
        chartData.barWidth = barWidth;
        barChartView.xAxis.axisMinimum = Double(startYear)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        
        barChartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        barChartView.xAxis.valueFormatter = PeriodValueFormatter(periods: periods)
        
        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        
        barChartView.data = chartData
        
        barChartView.setVisibleXRangeMaximum(15)
        chartData.setDrawValues(false)
    
        barChartView.data = chartData
    }

}


extension HistoryBarGraphViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
}
