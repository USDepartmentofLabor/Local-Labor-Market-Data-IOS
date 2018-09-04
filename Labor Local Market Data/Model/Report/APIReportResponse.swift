//
//  APIReportResult.swift
//  BaseApp
//
//  Created by Nidhi Chawla on 6/18/18.
//  Copyright © 2018 Khazana Corporation. All rights reserved.
//

import Foundation

enum ReportStatus: String, Decodable {
    case REQUEST_SUCCEEDED
    case REQUEST_FAILED
    case REQUEST_NOT_PROCESSED
    case REQUEST_FAILED_INVALID_PARAMETERS
}
struct APIReportResponse: Decodable {
    let status: ReportStatus
    let message: [String]
    let series: [SeriesReport]?
    
//    // Coding Keys
    enum CodingKeys: String, CodingKey {
        case results = "Results"
        case series
        case message
        case status
    }
    
    // Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode([String].self, forKey: .message)
        status = try container.decode(ReportStatus.self, forKey: .status)

        if status == .REQUEST_SUCCEEDED {
            let results = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .results)
            series = try results.decode([SeriesReport].self, forKey: .series)
        }
        else {
            series = nil
        }
    }
}

extension APIReportResponse: CustomStringConvertible {
    var description: String {
        if status != .REQUEST_SUCCEEDED {
            return message.description
        }
        else {
            return series?.description ?? "No series information"
        }
    }
}
