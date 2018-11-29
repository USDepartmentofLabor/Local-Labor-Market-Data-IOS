//
//  ItemViewModel.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 11/28/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation


class ItemViewModel<T: Item>: NSObject {
    var parentItem: T?
    var items: [T]?

    init(parent: T? = nil) {
        if parent == nil {
            items = T.self.getSuperParents(context:
                CoreDataManager.shared().viewManagedContext) as? [T]
        }
        else {
            parentItem = parent
            items = parentItem?.subItems() as? [T]
        }
    }
    
}
