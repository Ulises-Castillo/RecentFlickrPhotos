//
//  Endpoint.swift
//  RecentFlickrPhotos
//
//  Created by Ulysses Castillo on 10/20/21.
//  Copyright © 2021 uly. All rights reserved.
//

import Foundation

struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "rickandmortyapi.com"
        components.path = "/" + path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }
        
        return url
    }
}

extension Endpoint {
    static func getLocations(for name: String, page: Int) -> Self {
        Endpoint(
            path: "/api/location/",
            queryItems: [URLQueryItem(name: "page", value: String(page)),
                         URLQueryItem(name: "name", value: name)]
        )
    }
    static func getEpisodes(for name: String, page: Int) -> Self {
        Endpoint(
            path: "/api/episode/",
            queryItems: [URLQueryItem(name: "page", value: String(page)),
                         URLQueryItem(name: "name", value: name)]
        )
    }
    static func getCharacters(name: String, status: String, gender: String, page: Int) -> Self {
        Endpoint(
            path: "/api/character/",
            queryItems: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "name", value: name),
                URLQueryItem(name: "status", value: status),
                URLQueryItem(name: "gender", value: gender),
            ]
        )
    }
}
