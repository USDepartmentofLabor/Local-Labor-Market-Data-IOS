//
//  ItemViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation


class ItemViewModel: NSObject {
    
    var area: Area
    var parentItem: Item?
    var items: [Item]?

    init(area: Area, parent: Item? = nil, itemType: Item.Type) {
        self.area = area
        if parent == nil {
            items = itemType.getSuperParents(context:
                CoreDataManager.shared().viewManagedContext)
        }
        else {
            parentItem = parent
            items = parentItem?.subItems()
        }
    }
}
