//
//  BackendRequest.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

import Foundation

typealias SuccessHandler = () -> Void
typealias FailureHandler = (Error) -> Void

enum BackendRequestMethod: String {
    case get, post, put, delete
}

protocol BackendRequest {
    var endpoint: String { get }
    var method: BackendRequestMethod { get }
    var headers: [String: String]? { get }
    var data: Data? { get }
    func didSucceed(with data: Data)
    func didFail(with error: Error)
    func execute()
}

// default implementaion of the execute() method for the BackendRequest protocol
extension BackendRequest {
    func execute() {
        Task {
            await BackendService.sharedInstance.execute(backendRequest: self)
        }
    }
}
