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

    func getReports(seriesIds: [String], year: String? = nil, annualAverage: Bool, completion: ((APIResult<APIReportResponse, ReportError>) -> Void)?) -> URLSessionDataTask? {
        return getReports(seriesIds: seriesIds, startYear: year, endYear: year, annualAverage:annualAverage, completion: completion)
    }
    
    func getReports(seriesIds: [String], startYear: String?, endYear: String?,
                    annualAverage: Bool, completion: ((APIResult<APIReportResponse, ReportError>) -> Void)?) -> URLSessionDataTask? {
        
        var reportResponse: APIResult<APIReportResponse, ReportError>? = nil
        var seriesIdsCopy = seriesIds
        let requestIds = Array(seriesIdsCopy.prefix(50))
        seriesIdsCopy = seriesIdsCopy.count > 50 ? Array(seriesIdsCopy.suffix(from: 50)): [String]()

        return postReport1(seriesIds: requestIds, startYear: startYear, endYear: endYear, annualAverage:annualAverage, completion: { (apiResult) in
            switch apiResult {
            case .success( _):
                if seriesIdsCopy.count > 0 {
                    if reportResponse == nil {
                        reportResponse = apiResult
                    }
                    _ = self.getReports(seriesIds: seriesIdsCopy, startYear: startYear, endYear: endYear, annualAverage: annualAverage,
                                        completion: { (result) in
                        switch result {
                        case .success(let report):
                            if case .success(var prevReport)? = reportResponse {
                                prevReport.series?.append(contentsOf: report.series!)
                                completion?(.success(prevReport))
                            }

                        case .failure(let error):
                            completion?(.failure(error))
                        }
                    })
                }
                else {
                    completion?(apiResult)
                }
                
            case .failure(_):
                completion?(apiResult)
            }
        })
    
    }
    
    private func postReport1(seriesIds: [String], startYear: String?, endYear: String?, annualAverage: Bool, completion: ((APIResult<APIReportResponse, ReportError>) -> Void)?) -> URLSessionDataTask? {
        
        let reportRequest = APIReportRequest(seriesIds: seriesIds, registrationKey: Constants.REGISTRATION_KEY, startYear: startYear, endYear: endYear, annualAverage: annualAverage)

        if let cachedResponse = CacheManager.shared().get(for: reportRequest) {
            completion?(.success(cachedResponse))
            return nil
        }
        
        return postReport(reportRequest: reportRequest, completion:{ (result) in
            guard let result = result else {return}
            
            switch result {
            case .success(let jsonData):
                do {
                    let report = try JSONDecoder().decode(APIReportResponse.self, from: jsonData)
                    
                    if report.status == .REQUEST_SUCCEEDED {
                        CacheManager.shared().put(response: report, for: reportRequest)
                    }
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
    
    fileprivate func postReport(reportRequest: APIReportRequest, completion: @escaping ((NetworkResult<ReportError>?) -> Void)) -> URLSessionDataTask {
//        print("Request: \(reportRequest.description)")
        let requestData = try? JSONEncoder().encode(reportRequest)
        
        return NetworkAPI.shared().post(requestData: requestData!, completion: { (result) in
            completion(result)
        })
    }
    
    func getReport(seriesId: String, completion: @escaping ((NetworkResult<ReportError>?) -> Void)) -> URLSessionDataTask {
        return NetworkAPI.shared().get(paramPath: seriesId, params: nil, completion: { (result) in
            
            completion(result)
        })
    }
        
}


