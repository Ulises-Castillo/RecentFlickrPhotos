//
//  NetworkService+FlickrPhotos.swift
//  RecentFlickrPhotos
//
//  Created by Ulysses Castillo on 10/20/21.
//  Copyright © 2021 uly. All rights reserved.
//

import Foundation
import Combine

extension NetworkService {
    func getPhotos(for page: Int) -> Future<PhotoList, APIError> {
        
        let url = URL(string: FlickrAPI.baseUrlString + "/" + FlickrAPI.recentPhotosEndpoint(page: page))!
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = HTTPTypes.GET.rawValue
        let publisher: AnyPublisher<PhotoList, Error> = fetchWithURLRequest(urlRequest)
        return Future { promise in
            publisher.sink { (completion) in
                if case .failure(let error) = completion, let apiError = error as? APIError {
                    promise(.failure(apiError))
                }
            } receiveValue: { (responseModel) in
                promise(.success(responseModel))
            }
            .store(in: &self.cancellables)
        }
    }
}
