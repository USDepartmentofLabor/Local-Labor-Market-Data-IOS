//
//  SeriasData.swift
//  BaseApp
//
//  Created by Nidhi Chawla on 6/15/18.
//  Copyright © 2018 Khazana Corporation. All rights reserved.
//

import Foundation

struct SeriesData : Decodable {
    //    var title: String
    //    var dataTypeDesc: String
    //    var surveyName: String
    //
    var year: String
    var period: String
    var periodName: String
    var value: String
    var latest: Bool
    
    var footnotes: [FootNote]?
    var calculations: Calculations?
    //    // Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case year
        case period
        case periodName
        case value
        case latest
        case footnotes
        case calculations
    }
    
    
}

extension SeriesData {
    
    // MARK: Decoder (custom)
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let isLatest: String = try container.decodeIfPresent(String.self, forKey: .latest) {
            latest = isLatest.lowercased() == "true" ? true : false
        } else {
            latest = false
        }
        year = try container.decode(String.self, forKey: .year)
        period = try container.decode(String.self, forKey: .period)
        periodName = try container.decode(String.self, forKey: .periodName)
        value = try container.decode(String.self, forKey: .value)
        footnotes = try container.decodeIfPresent([FootNote].self, forKey: .footnotes)
        calculations = try container.decodeIfPresent(Calculations.self, forKey: .calculations)
    }
}

struct FootNote : Decodable {
    var code: String?
    var text: String?
}

struct Calculations : Decodable {
    var netChanges: NetChanges?
    var percentChanges: PercentChanges?
    
    enum CodingKeys: String, CodingKey {
        case netChanges = "net_changes"
        case percentChanges = "pct_changes"
    }
}

struct NetChanges : Decodable {
    var oneMonth: String?
    var threeMonth: String?
    var sixMonth: String?
    var twelveMonth: String?
    
    enum CodingKeys: String, CodingKey {
        case oneMonth = "1"
        case threeMonth = "3"
        case sixMonth = "6"
        case twelveMonth = "12"
    }
}

struct PercentChanges : Decodable {
    var oneMonth: String?
    var threeMonth: String?
    var sixMonth: String?
    var twelveMonth: String?
    
    enum CodingKeys: String, CodingKey {
        case oneMonth = "1"
        case threeMonth = "3"
        case sixMonth = "6"
        case twelveMonth = "12"
    }
}

struct Footnotes: Decodable {
    var code: String?
    var text: String?
}

