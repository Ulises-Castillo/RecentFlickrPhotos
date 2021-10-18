//
//  Photo.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

// most elemental model of the data to be recieved from the API
struct Photo: Codable {
    let id: String
    let title: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
}
