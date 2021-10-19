//
//  FlickrGetPhotosRequest.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

typealias GetPhotosSuccessHandler = (PhotoList) -> Void

struct FlickrGetPhotosRequest {
    var successHandler: GetPhotosSuccessHandler?
    var failureHandler: FailureHandler?
}

extension FlickrGetPhotosRequest: BackendRequest {
    var endpoint: String {
        return FlickrAPI.recentPhotosEndpoint
    }
    
    var method: BackendRequestMethod {
        return .get
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var data: Data? {
        return nil
    }
    
    func didSucceed(with data: Data) {
        do {
            let decoder = JSONDecoder()
            let photoList = try decoder.decode(PhotoList.self, from: data)
            guard let successHandler = successHandler else {
                Log.debug("Error: success handler not set")
                return
            }
            successHandler(photoList)
        } catch let parseError {
            didFail(with: parseError)
        }
    }
    
    func didFail(with error: Error) {
        if let failureHandler = failureHandler {
            failureHandler(error)
        }
    }
}
