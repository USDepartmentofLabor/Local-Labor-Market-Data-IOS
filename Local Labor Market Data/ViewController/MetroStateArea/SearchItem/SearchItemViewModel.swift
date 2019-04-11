//
//  SearchItemViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 2/28/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation

class SearchItemViewModel {
    
    var searchResults: [Item]?
    var selectedItem: Item?
    
    var itemViewModel: ItemViewModel
    
    init(itemViewModel: ItemViewModel) {
        self.itemViewModel = itemViewModel
    }
    
    var hasSearchResults: Bool {
        return (searchResults?.count ?? 0) > 0
    }
}
