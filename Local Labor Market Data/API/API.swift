//
//  API.swift
//  BaseApp
//
//  Created by Nidhi Chawla on 6/15/18.
//  Copyright © 2018 Khazana Corporation. All rights reserved.
//

import Foundation
import os.log

enum APIResult<T,U> {
    case success(T)
    case failure(U)
}


class API {
    struct Constants {
        static let REGISTRATION_KEY = Settings.API_REGISTRATION_KEY
    }

    func getReports(seriesIds: [String], year: String? = nil, completion: ((APIResult<APIReportResponse, ReportError>) -> Void)?) -> URLSessionDataTask {
        return getReports(seriesIds: seriesIds, startYear: year, endYear: year, completion: completion)
    }
    
    func getReports(seriesIds: [String], startYear: String?, endYear: String?, completion: ((APIResult<APIReportResponse, ReportError>) -> Void)?) -> URLSessionDataTask {
        return postReport(seriesIds: seriesIds, startYear:startYear, endYear: endYear, completion:{ (result) in
            guard let result = result else {return}
            
            switch result {
            case .success(let jsonData):
                do {
                    let report = try JSONDecoder().decode(APIReportResponse.self, from: jsonData)
                    completion?(.success(report))
                }
                catch(let error) {
                    completion?(.failure(.jsonParsingError(error.localizedDescription)))
                }
            case .failure(let error):
                os_log("Error retrieving report: %@", error.localizedDescription)
                completion?(.failure(error))
            }
        })
    }
    
    fileprivate func postReport(seriesIds: [String], startYear: String?, endYear: String?, completion: @escaping ((NetworkResult<ReportError>?) -> Void)) -> URLSessionDataTask {
        let reportRequest = APIReportRequest(seriesIds: seriesIds, registrationKey: Constants.REGISTRATION_KEY, startYear: startYear, endYear: endYear)
        let requestData = try? JSONEncoder().encode(reportRequest)
        
        return NetworkAPI().post(requestData: requestData!, completion: { (result) in
            completion(result)
        })
    }
    
    func getReport(seriesId: String, completion: @escaping ((NetworkResult<ReportError>?) -> Void)) -> URLSessionDataTask {
        return NetworkAPI().get(paramPath: seriesId, params: nil, completion: { (result) in
            
            completion(result)
        })
    }
        
}
