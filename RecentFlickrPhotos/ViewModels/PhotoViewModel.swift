//
//  PhotoViewModel.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

@objc class PhotoViewModel: NSObject {
    let imageUrl: URL
    let title: String
    
    init?(photo: Photo) {
        guard let url = FlickrAPI.imageUrl(photo: photo) else {
            return nil
        }
        imageUrl = url
        title = photo.title
    }
}
