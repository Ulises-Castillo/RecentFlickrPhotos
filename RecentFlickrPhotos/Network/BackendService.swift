//
//  BackendService.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

class BackendService {
    static let sharedInstance = BackendService()
    
    private let baseUrl = FlickrAPI.baseUrlString
    private let session = URLSession.shared
    private let backendQueue = DispatchQueue(label: "Flickr.Api.Request.Queue") // Serial Queue - FIFO
    
    func execute(backendRequest: BackendRequest) {
        
        backendQueue.async(qos: .userInteractive, flags: []) { [unowned self] () -> Void in
            guard let url = URL(string: self.baseUrl + "/" + backendRequest.endpoint) else {
                return
            }
            
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
            urlRequest.httpMethod = backendRequest.method.rawValue
            
            if let data = backendRequest.data {
                urlRequest.httpBody = data
            }
            
            if let headers = backendRequest.headers {
                for (key, value) in headers {
                    urlRequest.addValue(value, forHTTPHeaderField: key)
                }
            }
            
            self.session.dataTask(with: urlRequest) { (data, resposnse, error) in
                guard let data = data, let _ = resposnse, error == nil else {
                    if let error = error {
                        Log.debug("Flickr | API Request | \(backendRequest.method) | \(backendRequest.endpoint) | FAIL | Error: \(error.localizedDescription)")
                        backendRequest.didFail(with: error)
                    }
                    return
                }
                Log.debug("Flickr | API Request | \(backendRequest.method) | \(backendRequest.endpoint) | SUCCESS")
                backendRequest.didSucceed(with: data)
            }.resume()
        }
    }
}

