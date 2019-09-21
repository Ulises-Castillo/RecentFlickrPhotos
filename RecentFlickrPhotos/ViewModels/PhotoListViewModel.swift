//
//  PhotoListViewModel.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

@objc class PhotoListViewModel: NSObject {
    @objc dynamic var photos: [PhotoViewModel]?
    
    override init() {
        super.init()
        reloadPhotos()
    }
    
    func reloadPhotos() {
        var request = FlickrGetPhotosRequest()
        
        request.successHandler = { [weak self] photos in
            DispatchQueue.main.async {
                self?.updatePhotoList(photoList: photos)
            }
        }
        request.failureHandler = { error in
            DispatchQueue.main.async {
                let tmp = self.photos
                self.photos = tmp // trigger KVO
                Log.debug(error.localizedDescription)
            }
        }

        request.execute()
    }
    
    private func updatePhotoList(photoList: PhotoList) {
        var tempPhotoList = [PhotoViewModel]()
        for photo in photoList.models {
            guard let photoViewModel = PhotoViewModel(photo: photo) else {
                continue
            }
            tempPhotoList.append(photoViewModel)
        }
        photos = tempPhotoList
    }
}
