//
//  PhotoListViewModel.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation
import Combine

// top layer enclosing ViewModel
// responsible for fetching & managing the list of ViewModels required to display photos
class PhotoListViewModel: NSObject {
    private var cancellables = Set<AnyCancellable>()
    private var isLoadingPage = false
    
    let photosSubject = CurrentValueSubject<[PhotoViewModel], Never>([])
    let isFirstLoadingPageSubject = CurrentValueSubject<Bool, Never>(true)
    
    var currentPage = 1
//    var canLoadMorePages = true
        
    private var networkService = NetworkService()
    
    //Get phots from API
    func getPhotos(firstPage: Bool = false) {
        if firstPage {
            currentPage = 1
        }
        
        guard !isLoadingPage else { //&& canLoadMorePages
            return
        }
        isLoadingPage = true
        networkService.getPhotos(for: currentPage).sink {[weak self] (completion) in
            if case .failure(let apiError) = completion {
                self?.photosSubject.value.removeAll()
                self?.isFirstLoadingPageSubject.value = false
                self?.isLoadingPage = false
                print(apiError.errorMessage)
            }
        } receiveValue: {[weak self] (photoList) in
            if self?.currentPage == 1 {
                self?.photosSubject.value.removeAll()
            }
//            if characterResponseModel.pageInfo.pageCount == self?.currentPage {
//                self?.canLoadMorePages = false
//            }
            self?.currentPage += 1
            self?.photosSubject.value.append(contentsOf: self?.photoViewModels(from: photoList) ?? [])
            self?.isFirstLoadingPageSubject.value = false
            self?.isLoadingPage = false
        }
        .store(in: &cancellables)
    }
    
    // Takes a PhotoList model and return a list of PhotoViewModels
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
