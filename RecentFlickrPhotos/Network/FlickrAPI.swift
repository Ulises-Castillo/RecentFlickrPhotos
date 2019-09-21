//
//  FlickrAPI.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

struct FlickrAPI {
    // GET recent photos URL
    // https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=fee10de350d1f31d5fec0eaf330d2dba&format=json&nojsoncallback=true&safe_search=true
    static let baseUrlString = "https://api.flickr.com" // called Flickr domain ?
    
    static let apiKey = "fee10de350d1f31d5fec0eaf330d2dba"
    
    static var page = 1

    static var recentPhotosEndpoint: String { return "services/rest/?method=flickr.photos.getRecent&api_key=\(apiKey)&page=\(page)&format=json&nojsoncallback=true&safe_search=true" }
    
    // image URL format: https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
    static func imageUrl(photo: Photo) -> URL? {
        guard let url = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg") else {
            Log.debug("Error: uanable to create URL from id: \(photo.id), secret: \(photo.secret), farm: \(photo.farm), server: \(photo.server)")
            return nil
        }
        return url
    }
}
