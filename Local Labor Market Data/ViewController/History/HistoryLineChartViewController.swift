//
//  HistoryLineChartViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 10/30/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import Charts

class HistoryLineChartViewController: UIViewController, HistoryViewProtocol {
    static let ITEM_COUNT = 24.0
    
    var viewModel: HistoryViewModel?
    
    @IBOutlet weak var chartView: HistoryLineChartView!
    @IBOutlet weak var xAxisTitleLabel: UILabel!
    @IBOutlet weak var yAxisTitleLabel: UILabel!

    @IBOutlet weak var xAxisView: UIView!
    @IBOutlet weak var leftNavBtn: UIButton!
    @IBOutlet weak var rightNavBtn: UIButton!
    
    lazy var yAxisFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.negativeSuffix = "%"
        formatter.positiveSuffix = "%"
        
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        xAxisTitleLabel.scaleFont(forDataType: .itemParentTitle)
        yAxisTitleLabel.scaleFont(forDataType: .itemParentTitle)

        setupChartView()
        setupAccessibility()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let entriesCount = chartView.data?.dataSets[0].entryCount {
            chartView.moveViewToX(Double(entriesCount-HistoryBarChartViewController.ITEM_COUNT) + 1.0)
        }
    }
        
    func setupAccessibility() {
        view.accessibilityElements = [yAxisTitleLabel as Any, chartView as Any, xAxisView as Any]
        xAxisView.accessibilityElements = [leftNavBtn as Any, xAxisTitleLabel as Any, rightNavBtn as Any]
        
        leftNavBtn.accessibilityHint = "Tap to display previous month"
        rightNavBtn.accessibilityHint = "Tap to display next month"
    }
    
    @IBAction func leftClick(_ sender: Any) {
        chartView.moveViewToX(chartView.lowestVisibleX - 1)
        refreshNavigation()
    }
    
    @IBAction func rightClick(_ sender: Any) {
        chartView.moveViewToX(chartView.lowestVisibleX + 1)
        refreshNavigation()
    }
    
    func refreshNavigation() {
        if chartView.lowestVisibleX > chartView.chartXMin {
            leftNavBtn.isHidden = false
        }
        else {
            leftNavBtn.isHidden = true
        }
        
        if chartView.highestVisibleX.rounded() < chartView.chartXMax {
            rightNavBtn.isHidden = false
        }
        else {
            rightNavBtn.isHidden = true
        }
    }

    func setupChartView() {
        chartView.historyDelegate = self
        
        chartView.noDataTextColor = .darkText
        chartView.noDataText = "No Data for Chart"
        if #available(iOS 13.0, *) {
            chartView.backgroundColor = .systemBackground
        }
        else {
            chartView.backgroundColor = .white
        }
        chartView.keepPositionOnRotation = true
        
        chartView.legend.enabled = true
        let legend = chartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.form = .square
        legend.font = Style.scaledFont(forDataType: .graphLegendLabel)
        if #available(iOS 13.0, *) {
            legend.textColor = .label
        }
        legend.wordWrapEnabled = true
        legend.xEntrySpace = 8
        
        let marker = XYMarkerView(color: UIColor.systemBlue,
                                  font: Style.scaledFont(forDataType: .graphLegendLabel),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker

        let xAxis = chartView.xAxis
        xAxis.drawAxisLineEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelFont = Style.scaledFont(forDataType: .graphAxisLabel)
        if #available(iOS 13.0, *) {
            xAxis.labelTextColor = .label
        }
        xAxis.granularity = 2.0
        xAxis.granularityEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.setLabelCount(Int(HistoryLineChartViewController.ITEM_COUNT/2 + 1), force: true)
//        xAxis.labelCount = Int(HistoryLineChartViewController.ITEM_COUNT/2 + 1)
        xAxis.axisMinimum = 0.0

        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = Style.scaledFont(forDataType: .graphAxisLabel)
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawGridLinesEnabled = false
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: yAxisFormatter)
        if #available(iOS 13.0, *) {
            leftAxis.labelTextColor = .label
        }

        let rightAxis = chartView.rightAxis
        rightAxis.labelFont = Style.scaledFont(forDataType: .graphAxisLabel)
        rightAxis.labelPosition = .outsideChart
        rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: yAxisFormatter)
        if #available(iOS 13.0, *) {
            rightAxis.labelTextColor = .label
        }

        displayHistoryData()
    }
    
    func displayHistoryData() {
        let seriesDataArr: [SeriesData]?
        if let seriesReport = viewModel?.localAreaReport.seriesReport,
            seriesReport.data.count > 0 {
            seriesDataArr = seriesReport.data.reversed()
        }
        else if let nationalSeriesReport = viewModel?.nationalAreaReport?.seriesReport, nationalSeriesReport.data.count > 0 {
            seriesDataArr =  nationalSeriesReport.data.reversed()
        }
        else {
            seriesDataArr = nil
        }

        
        chartView.data = generateLineData()
        chartView.xAxis.axisMinimum = 0.0
        chartView.setVisibleXRange(minXRange: 5, maxXRange: Double(HistoryLineChartViewController.ITEM_COUNT))
        if let seriesDataArr = seriesDataArr {
            chartView.xAxis.valueFormatter = LineDayAxisValueFormatter(chart: chartView, seriesDataArr: seriesDataArr)
        }

        if let entriesCount = chartView.data?.dataSets[0].entryCount {
            chartView.xAxis.axisMaximum = Double(entriesCount) - 1.0
            chartView.moveViewToX(Double(entriesCount-HistoryBarChartViewController.ITEM_COUNT) + 1.0)
        }
    }
    
    func generateLineData() -> LineChartData? {
        
        guard let chartDataEntry = viewModel?.generateChartData(type: ChartDataEntry.self) else {
            return nil
        }
        
        let lineChartData = LineChartData()

        if let localDataEntry = chartDataEntry.localDataEntry, localDataEntry.count > 0 {
            let localChartDataSet = LineChartDataSet(entries: localDataEntry, label: viewModel?.area.displayType ?? "")
            localChartDataSet.colors = [UIColor(named: "graphColorLocal")!]
            localChartDataSet.lineWidth = 2.5
            localChartDataSet.circleRadius = 4.0
            localChartDataSet.drawIconsEnabled = false
            lineChartData.append(localChartDataSet)
        }
        

        if let nationalDataEntry = chartDataEntry.nationalDataEntry, nationalDataEntry.count > 0 {
            let nationalChartDataSet = LineChartDataSet(entries: nationalDataEntry, label: "National")
            nationalChartDataSet.colors = [UIColor(named: "AppBlue")!]
            nationalChartDataSet.lineWidth = 2.5
            nationalChartDataSet.circleRadius = 4.0
        
            lineChartData.append(nationalChartDataSet)
        }

        lineChartData.setDrawValues(false)
        lineChartData.setValueFormatter(DefaultValueFormatter(formatter: yAxisFormatter))
        if #available(iOS 13.0, *) {
            lineChartData.setValueTextColor(.label)
        }
        lineChartData.setValueFont(Style.scaledFont(forDataType: .graphValueLabel))

        return lineChartData
    }
}

extension HistoryLineChartViewController: HistoryChartViewDelegate {
    func didUpdateView() {
        refreshNavigation()
    }
}

public class LineDayAxisValueFormatter: NSObject, AxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    var seriesDataArr: [SeriesData]?
    
    init(chart: BarLineChartViewBase, seriesDataArr: [SeriesData]) {
        self.chart = chart
        self.seriesDataArr = seriesDataArr
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard value >= 0, value.rounded() < Double(seriesDataArr!.count) else {
            return ""
        }

        guard let seriesData = seriesDataArr?[Int(value.rounded())] else {
            return ""
        }
        
        return seriesData.shortPeriodYearStr
    }
}
