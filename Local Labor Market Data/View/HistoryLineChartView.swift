//
//  HistoryLineChartView.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/27/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import Charts

protocol HistoryChartViewDelegate: class {
    func didUpdateView()
}

class HistoryLineChartView: LineChartView {

    weak var historyDelegate: HistoryChartViewDelegate?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        historyDelegate?.didUpdateView()
    }

}
