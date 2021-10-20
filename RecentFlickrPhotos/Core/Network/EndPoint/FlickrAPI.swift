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
    static private let baseUrlString = "https://api.flickr.com" // called Flickr domain ?
    
    static private let apiKey = "fee10de350d1f31d5fec0eaf330d2dba"
    
    static func recentPhotosUrl(page: Int) -> URL {
        let endpoint = "services/rest/?method=flickr.photos.getRecent&api_key=\(apiKey)&page=\(page)&format=json&nojsoncallback=true&safe_search=true"
        let urlString = baseUrlString + "/" + endpoint
        guard let url = URL(string: urlString) else {
            preconditionFailure("Invalid URL: \(urlString)")
        }
        return url
    }
    
    // image URL format: https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
    static func imageUrl(photo: Photo) -> URL? {
        guard let url = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg") else {
            Log.debug("Error: uanable to create URL from id: \(photo.id), secret: \(photo.secret), farm: \(photo.farm), server: \(photo.server)")
            return nil
        }
        return url
    }
}
