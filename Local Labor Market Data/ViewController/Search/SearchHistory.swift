//
//  SearchHistory.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 1/3/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation


struct SearchHistory {
    var searchText: String
    var searchDate: Date
    
    init(searchText text: String) {
        searchText = text
        searchDate = Date()
    }
}

