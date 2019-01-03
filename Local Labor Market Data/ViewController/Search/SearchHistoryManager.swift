//
//  SearchHistoryManager.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 1/3/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation


class SearchHistoryManager {
    static let MAX_SIZE = 5
    
    private static var sharedHistoryMgr: SearchHistoryManager = {
        
        let shared = SearchHistoryManager()
        return shared
    }()
    
    
    // MARK: - Accessors
    class func shared() -> SearchHistoryManager {
        return sharedHistoryMgr
    }
    
    var searches = [SearchHistory]()
    
    
    // if SearchText already exists, update its time to latest
    // If SearchText doesn't exist
        // if History length is MAX Size, remove the oldest item to keep history Size to MAX Size
    func add(searchText text:String) {
        remove(searchText: text)
        
        if searches.count >= SearchHistoryManager.MAX_SIZE {
            removeOldest()
        }
        searches.insert(SearchHistory(searchText: text), at: 0)
    }
    
    func remove(searchText text: String) {
        searches.removeAll(where: {$0.searchText.localizedCaseInsensitiveCompare(text) == .orderedSame})
    }
    
    func removeOldest(){
        searches.removeLast()
    }
}
