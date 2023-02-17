//
//  HistoryBarViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 10/30/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import Charts

class HistoryBarChartViewController: UIViewController, HistoryViewProtocol {

    static let ITEM_COUNT = 13
    var viewModel: HistoryViewModel?
    
    @IBOutlet weak var chartView: HistoryBarChartView!
    @IBOutlet weak var xAxisTitleLabel: UILabel!
    @IBOutlet weak var yAxisTitleLabel: UILabel!
    
    @IBOutlet weak var xAxisView: UIView!
    @IBOutlet weak var leftNavBtn: UIButton!
    @IBOutlet weak var rightNavBtn: UIButton!

    var dataEntry: [BarChartDataEntry] = []

    lazy var yAxisFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.negativeSuffix = " %"
        formatter.positiveSuffix = " %"
        
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    @IBAction func leftClick(_ sender: Any) {
        chartView.moveViewToX(chartView.lowestVisibleX - 1)
        refreshNavigation()
    }
    
    @IBAction func rightClick(_ sender: Any) {
        chartView.moveViewToX(chartView.lowestVisibleX + 1)
        refreshNavigation()
    }
    
    func setupView() {
        xAxisTitleLabel.scaleFont(forDataType: .itemParentTitle)
        yAxisTitleLabel.scaleFont(forDataType: .itemParentTitle)
        
        setupChartView()
        setupAccessibility()
    }
    
    func setupAccessibility() {
        view.accessibilityElements = [yAxisTitleLabel as Any, chartView as Any, xAxisView as Any]
        xAxisView.accessibilityElements = [leftNavBtn as Any, xAxisTitleLabel as Any, rightNavBtn as Any]
        
        leftNavBtn.accessibilityHint = "Tap to display previous month"
        rightNavBtn.accessibilityHint = "Tap to display next month"
    }

    func refreshNavigation() {
        if chartView.lowestVisibleX > chartView.chartXMin {
            leftNavBtn.isHidden = false
        }
        else {
            leftNavBtn.isHidden = true
        }
        
        if chartView.highestVisibleX < chartView.chartXMax {
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
        
//        chartView.drawBarShadowEnabled = false
//        chartView.drawValueAboveBarEnabled = false
        chartView.maxVisibleCount = HistoryBarChartViewController.ITEM_COUNT
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = Style.scaledFont(forDataType: .graphAxisLabel)
        xAxis.granularity = 1.0
        xAxis.granularityEnabled = true
        xAxis.axisMinimum = 0.0
        xAxis.drawGridLinesEnabled = false
        xAxis.labelCount = HistoryBarChartViewController.ITEM_COUNT
        xAxis.centerAxisLabelsEnabled = true
        if #available(iOS 13.0, *) {
            xAxis.labelTextColor = .label
        }

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

        if let seriesDataArr = seriesDataArr {
            xAxis.valueFormatter = BarDayAxisValueFormatter(chart: chartView, seriesDataArr: seriesDataArr) as! any AxisValueFormatter
        }
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = Style.scaledFont(forDataType: .graphAxisLabel)
//        leftAxis.labelCount = 8
        leftAxis.labelPosition = .outsideChart
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: yAxisFormatter)
        leftAxis.drawGridLinesEnabled = false
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

        chartView.legend.enabled = true
        
        let legend = chartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = false
        if #available(iOS 13.0, *) {
            legend.textColor = .label
        }
        legend.form = .square
        legend.formSize = 9
        legend.font = Style.scaledFont(forDataType: .graphLegendLabel)
        legend.wordWrapEnabled = true
        legend.xEntrySpace = 8
        
        let marker = XYMarkerView(color: UIColor.systemBlue,
                                  font: Style.scaledFont(forDataType: .graphLegendLabel),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker

//        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        displayHistoryData()
    }
    
    func displayHistoryData() {
        if let localSeriesReport = viewModel?.localAreaReport.seriesReport {
            let nationalseriesReport = viewModel?.nationalAreaReport?.seriesReport
            setBarChart(localSeriesReport: localSeriesReport, nationalSeriesReport: nationalseriesReport)
        }
        
//        chartView.xAxis.axisMaximum = (chartView.data?.xMax)! + 1
        
        if let entriesCount = chartView.data?.dataSets[0].entryCount {
            chartView.moveViewToX(Double(entriesCount - HistoryBarChartViewController.ITEM_COUNT))
        }
    }
    
    func setBarChart(localSeriesReport: SeriesReport, nationalSeriesReport: SeriesReport?) {

        guard let chartDataEntry = viewModel?.generateChartData(type: BarChartDataEntry.self) else {
            return
        }
        
        let chartData = BarChartData()

        if let localDataEntry = chartDataEntry.localDataEntry, localDataEntry.count > 0 {
            let localChartDataSet = BarChartDataSet(entries: localDataEntry, label: viewModel?.area.displayType ?? "")
            localChartDataSet.colors = [UIColor(named: "graphColorLocal")!]
            chartData.append(localChartDataSet)
        }

        if let nationalDataEntry = chartDataEntry.nationalDataEntry, nationalDataEntry.count > 0,
           let nationalDataEntry = chartDataEntry.nationalDataEntry{
            let nationalChartDataSet = BarChartDataSet(entries: nationalDataEntry, label: "National")
            nationalChartDataSet.colors = [UIColor(named: "AppBlue")!]
            chartData.append(nationalChartDataSet)
        }

        if chartData.dataSets.count > 1 {
            let groupSpace = 0.36
            let barSpace = 0.02 // x2 dataset
            let barWidth = 0.30 // x2 dataset
            // (0.30 + 0.02) * 2 + 0.36 = 1.00 -> interval per "group"
            
            // make this BarData object grouped
            chartData.barWidth = barWidth
            chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
            chartView.xAxis.axisMaximum = Double(chartData.dataSets[0].entryCount)
            chartView.xAxis.axisMinimum = 0.0
            chartView.xAxis.centerAxisLabelsEnabled = true
        }
        else if chartData.dataSets.count == 1 {

            chartData.barWidth = 0.4
            chartView.xAxis.centerAxisLabelsEnabled = false
            chartView.xAxis.axisMaximum = Double(chartData.dataSets[0].entryCount) - 0.5
            chartView.xAxis.axisMinimum = -0.5
        }

        chartData.setDrawValues(false)
        chartData.setValueFormatter(DefaultValueFormatter(formatter: yAxisFormatter))
        
        if #available(iOS 13.0, *) {
            chartData.setValueTextColor(.label)
        }

        chartView.data = chartData
        chartView.setVisibleXRange(minXRange: 5, maxXRange: Double(HistoryBarChartViewController.ITEM_COUNT))
    }
}


extension HistoryBarChartViewController: HistoryChartViewDelegate {
    func didUpdateView() {
        refreshNavigation()
    }
}

public class BarDayAxisValueFormatter: NSObject, AxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    var seriesDataArr: [SeriesData]?
    
    init(chart: BarLineChartViewBase, seriesDataArr: [SeriesData]) {
        self.chart = chart
        self.seriesDataArr = seriesDataArr
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard value >= 0, value.rounded(.down) < Double(seriesDataArr!.count) else {
            return ""
        }

        guard let seriesData = seriesDataArr?[Int(value.rounded(.down))] else {
            return ""
        }
        
        return seriesData.shortPeriodYearStr
    }
}

open class XYMarkerView: BalloonMarker
{
    fileprivate var yFormatter = NumberFormatter()
    
    @objc public override init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        super.init(color: color, font: font, textColor: textColor, insets: insets)
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        setLabel(yFormatter.string(from: NSNumber(floatLiteral: entry.y))! + "%")
        
        if let dataStr = entry.data as? String {
            color = (dataStr == "local") ? UIColor(named: "graphColorLocal")! : UIColor(named: "graphColorNational")!
        }
    }
    
}

open class BalloonMarker: MarkerImage
{
    open var color: UIColor
    open var arrowSize = CGSize(width: 15, height: 11)
    open var font: UIFont
    open var textColor: UIColor
    open var insets: UIEdgeInsets
    open var minimumSize = CGSize()
    
    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key : AnyObject]()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }
    
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        var size = self.size
        
        if size.width == 0.0 && image != nil
        {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image!.size.height
        }
        
        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        if origin.x + offset.x < 0.0
        {
            offset.x = -origin.x + padding
        }
        else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }
        
        if origin.y + offset.y < 0
        {
            offset.y = height + padding;
        }
        else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height
        {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }
        
        return offset
    }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        context.saveGState()
        
        context.setFillColor(color.cgColor)

        if offset.y > 0
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.fillPath()
        }
        else
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.fillPath()
        }

        if offset.y > 0 {
            rect.origin.y += self.insets.top + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }

        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        setLabel(String(entry.y))
    }
    
    open func setLabel(_ newLabel: String)
    {
        label = newLabel
        
        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor
        
        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}


