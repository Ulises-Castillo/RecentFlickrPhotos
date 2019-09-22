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
        
        request.successHandler = { [unowned self] photos in
            DispatchQueue.main.async {
                self.updatePhotoList(photoList: photos)
            }
        }
        request.failureHandler = { [unowned self] error in
            DispatchQueue.main.async {
                let tmp = self.photos
                self.photos = tmp // trigger KVO
                Log.debug(error.localizedDescription)
            }
        }

        request.execute()
    }
    
    func fetchMorePhotos() {
        FlickrAPI.page += 1 // next page of photos
        var request = FlickrGetPhotosRequest()
        
        request.successHandler = { [unowned self] photos in
            DispatchQueue.main.async {
                self.addToPhotosList(photoList: photos)
            }
        }
        request.failureHandler = { [unowned self] error in
            DispatchQueue.main.async {
                FlickrAPI.page -= 1
                let tmp = self.photos
                self.photos = tmp // trigger KVO
                Log.debug(error.localizedDescription)
            }
        }
        
        request.execute()
    }
    
    private func updatePhotoList(photoList: PhotoList) {
        photos = photoViewModels(from: photoList)
    }
    
    private func addToPhotosList(photoList: PhotoList) {
        guard let _ = photos else { return }
        photos! += photoViewModels(from: photoList)
    }
    
    private func photoViewModels(from photoList: PhotoList) -> [PhotoViewModel] {
        var viewModels = [PhotoViewModel]()
        for photo in photoList.models {
            guard let photoViewModel = PhotoViewModel(photo: photo) else {
                continue
            }
            viewModels.append(photoViewModel)
        }
        return viewModels
    }
}
