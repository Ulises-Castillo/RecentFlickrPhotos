//
//  PhotoList.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

struct PhotoList: Codable {
    private let photos: Photos
    
    var models: [Photo] {
        return photos.photo
    }
}

struct Photos: Codable {
    private let page: Int
    private let pages: Int
    private let perpage: Int
    private let total: Int
    fileprivate let photo: [Photo]
}
