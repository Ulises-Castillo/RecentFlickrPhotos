//
//  PhotosCollectionViewController.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import UIKit

//TODO: endless feed/scrolling (next page of photos)
//TODO: Add UI to handle slow network response & No Internet
class PhotosCollectionViewController: UICollectionViewController {
    
    var photos = [PhotoViewModel]()
    var focusedPhotoIndexPath: IndexPath?
    private let photoListViewModel = PhotoListViewModel()
    private var photoListKVO: NSKeyValueObservation? = nil
    private let spacing: CGFloat = 5
    private let NumberOfPhotosPerRowPortrait: CGFloat = 4
    private let NumberOfPhotosPerRowLandscape: CGFloat = 8
    
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureRefreshControll()
        observePhotoListSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectFocusedPhoto()
    }
    
    //MARK: Setup & Configuration
    private func configureRefreshControll() {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl!.beginRefreshing()
    }
    
    private func configureNavigationBar() {
        title = "Flickr | Recent"
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(ThumbnailPhotoCell.self, forCellWithReuseIdentifier: ThumbnailPhotoCell.reuseId)
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.sectionInsetReference = .fromSafeArea
    }
    
    private func observePhotoListSetup() {
        photoListKVO = photoListViewModel.observe(\PhotoListViewModel.photos, options: .new) { [weak self] (photoListViewModel, change) in
            self?.collectionView.refreshControl?.endRefreshing()
            guard let photos = photoListViewModel.photos else { return }
            self?.photos = photos
            self?.collectionView.reloadData()
        }
    }
    
    // MARK: Miscellaneous
    private func prepareDetailControllerForSegue(selectedPhotoIndex: IndexPath) -> PhotosDetailCollectionViewController {
        let detailVC = PhotosDetailCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        detailVC.title = title
        detailVC.photos = photos
        detailVC.setSelectedPhotoIndexPath(selectedPhotoIndex)
        return detailVC
    }
    
    // MARK: UI Related
    func selectFocusedPhoto() {
        guard let indexPath = focusedPhotoIndexPath else { return }
        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        focusedPhotoIndexPath = nil
    }
    
    @objc private func handleRefreshControl() {
        photoListViewModel.reloadPhotos()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        let previousOffsetPercent = collectionView.contentOffset.y / collectionView.contentSize.height
        collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            let newOffset = CGPoint(x: self.collectionView.contentOffset.x, y: self.collectionView.contentSize.height * previousOffsetPercent)
            self.collectionView.setContentOffset(newOffset, animated: false)
        }
    }
    
    //MARK: CollectionView - Data Source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailPhotoCell.reuseId, for: indexPath) as? ThumbnailPhotoCell else {
            return UICollectionViewCell()
        }
        let photo = photos[indexPath.row]
        thumbnailCell.imageView.imageFromURL(photo.imageUrl)
        return thumbnailCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? photos.count : 0
    }
    
    //MARK: CollectionView - Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = prepareDetailControllerForSegue(selectedPhotoIndex: indexPath)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension PhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
    //MARK: CollectionView - FlowLayout Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = UIDevice.current.orientation.isLandscape ? NumberOfPhotosPerRowLandscape : NumberOfPhotosPerRowPortrait
        let totalSpacing = (2 * spacing) + ((numberOfItemsPerRow - 1) * spacing)
        let width = (collectionView.safeAreaLayoutGuide.layoutFrame.width - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
    }
}
