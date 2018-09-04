//
//  Network.swift
//  BaseApp
//
//  Created by Nidhi Chawla on 6/15/18.
//  Copyright © 2018 Khazana Corporation. All rights reserved.
//

import Foundation
import os.log

enum NetworkResult<T> {
    case success(Data)
    case failure(T)
}

typealias FileResult = ((NetworkResult<Error>) -> Void)

class NetworkAPI {
    
    struct APIConstants {
        static let APIScheme = "https"
        static let APIHost = "api.bls.gov"
        static let APIPath = "/publicAPI/v2/timeseries/data/"
    }
    
    func urlFrom(paramPath: String?, params: [String: Any]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = APIConstants.APIScheme
        components.host = APIConstants.APIHost
        components.path = APIConstants.APIPath
        
        if let paramPath = paramPath {
            components.path = APIConstants.APIPath + "\(paramPath)"
        }
        
        if let params = params, !params.isEmpty {
            var queryItems = [URLQueryItem]()
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
            
            components.queryItems = queryItems
        }
        
        return components.url
    }
    
    func get(paramPath: String?, params: [String: Any]?,
             completion: ((NetworkResult<ReportError>?) -> Void)?) -> URLSessionDataTask {
        
        // Build URL
        guard let url: URL = urlFrom(paramPath: paramPath, params: params) else { fatalError("Could not create URL")}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        os_log("Request: %@", request.description)
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request, completion: completion)
        task.resume()
        return task
    }
    
    func post(requestData: Data, completion: ((NetworkResult<ReportError>?) -> Void)?) -> URLSessionDataTask {
        // Build URL
        guard let url: URL = urlFrom(paramPath: nil) else { fatalError("Could not create URL")}

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-type"] = "application/JSON"
        
        request.allHTTPHeaderFields = headers
        request.httpBody = requestData
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request, completion: completion)
        task.resume()
        return task
    }
}


extension URLSession {
    func dataTask(with request:URLRequest, completion: ((NetworkResult<ReportError>?) -> Void)?) -> URLSessionDataTask {
        return dataTask(with: request, completionHandler: { (responseData, response, error) in
            let httpResponse = response as? HTTPURLResponse
            
            if httpResponse?.statusCode == 200, let jsonData = responseData {
                DispatchQueue.main.async {
                    completion?(.success(jsonData))
                }
            }
            else {
                if let error = error {
                    DispatchQueue.main.async {
                        completion?(.failure(ReportError.network(reason: error.localizedDescription)))
                    }
                }
                else if httpResponse?.statusCode != 200 {
                    let error: ReportError = .httpError(statusCode: (httpResponse?.statusCode)!)
                    DispatchQueue.main.async {
                        completion?(.failure(error))
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion?(.failure(.noResponse))
                    }
                }
            }
            
        })
    }
}

extension NetworkAPI {
    func getFile(forURL url: URL, completion: @escaping FileResult) -> URLSessionDownloadTask {
        let request = URLRequest(url: url)
        
        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: request) { (fileURL, response, error) in
            guard let fileURL = fileURL else {
                completion(NetworkResult.failure(ReportError.network(reason: error!.localizedDescription)))
                return
            }
            if let data = try? Data(contentsOf: fileURL) {
                completion(NetworkResult.success(data))
            }
            else {
                completion(NetworkResult.failure(ReportError.noResponse))
            }
        }
        
        task.resume()
        return task
    }
}
