//
//  NeworkService.swift
//  RecentFlickrPhotos
//
//  Created by Ulysses Castillo on 10/20/21.
//  Copyright © 2021 uly. All rights reserved.
//

import Foundation
import Combine

enum HTTPTypes: String {
    case GET = "GET", POST = "POST"
}

// protocol only implemented once, below
// designed this way to facilitate testing
protocol NetworkServiceProtocol: AnyObject {
    var cancellables: Set<AnyCancellable> { get set }
    var customDecoder: JSONDecoder { get }
    func fetchWithURLRequest<T: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<T, Error>
}

// `NetworkService` handles all API requests
// and decoding of responses (JSON)
// made possible by the use of nested generic types `T`
// `Combine` is used to publish responses
class NetworkService: NetworkServiceProtocol {
    
    var cancellables = Set<AnyCancellable>()
    let customDecoder = JSONDecoder()

    init() {
        setCustomDecoder()
    }

    func setCustomDecoder() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        customDecoder.dateDecodingStrategy = .formatted(formatter)
    }

    func fetchWithURLRequest<T: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<T, Error> {
        // use URL session to make `urlRequest` and publish response
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError({ $0 as Error })
            // map response to specified type
            .flatMap({ result -> AnyPublisher<T, Error> in
            // ensure a success status code
            guard let urlResponse = result.response as? HTTPURLResponse, (200...299).contains(urlResponse.statusCode) else {
                // otherwise publish error
                return Just(result.data)
                    .decode(type: APIError.self, decoder: self.customDecoder).tryMap({ errorModel in
                    throw errorModel
                })
                    .eraseToAnyPublisher()
            }
            // publish response data after decoding it to the specified type `T` (generic)
            return Just(result.data).decode(type: T.self, decoder: self.customDecoder)
                .eraseToAnyPublisher()
            })
            // response will change UI, thus it must be received on the main thread
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct APIError: Decodable, Error {
    let errorMessage: String
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error"
    }
}
