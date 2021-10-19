//
//  PhotoViewModel.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

// most elemental ViewModel
@objc class PhotoViewModel: NSObject {
    // only propertied required for UI
    let imageUrl: URL
    let title: String
    
    // Takes a PhotoModel and returns a PhotoViewModel
    init?(photo: Photo) {
        guard let url = FlickrAPI.imageUrl(photo: photo) else {
            return nil
        }
        imageUrl = url
        title = photo.title
    }
}
