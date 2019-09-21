//
//  Photo.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

struct Photo: Codable {
    let id: String
    let title: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
}
