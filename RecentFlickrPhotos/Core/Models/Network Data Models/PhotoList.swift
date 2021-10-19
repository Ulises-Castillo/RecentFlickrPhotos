//
//  PhotoList.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

// Enclosing model contain list of models required
struct PhotoList: Codable {
    // raw list of models hidden
    private let photos: Photos
    
    // only required list of photos exposed publicly
    var models: [Photo] {
        return photos.photo
    }
}

// Enclosing layer of data to be recieved from the API
struct Photos: Codable {
    private let page: Int
    private let pages: Int
    private let perpage: Int
    private let total: Int
    fileprivate let photo: [Photo]
}
