//
//  PhotosDetailCollectionViewController.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import UIKit

//TODO: add pinch to zoom
class PhotosDetailCollectionViewController: UICollectionViewController, PhotoZoomDelegate {

    var photos = [PhotoViewModel]()
    var currentPhotoIndexPath = IndexPath(row: 0, section: 0)
    private var overlayIsHidden = false
    
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        guard let photosVC = navigationController?.topViewController as? PhotosCollectionViewController else { return }
        photosVC.focusedPhotoIndexPath = currentPhotoIndexPath
    }
    
    //MARK: Setup & Configuration
    private func configureCollectionView() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.register(PhotoDetailCell.self, forCellWithReuseIdentifier: PhotoDetailCell.reuseId)
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInsetReference = .fromSafeArea
    }
    
    //MARK: Miscellaneous
    func setSelectedPhotoIndexPath(_ indexPath: IndexPath) {
        currentPhotoIndexPath = indexPath
        self.collectionView.scrollToItem(at: currentPhotoIndexPath, at: .centeredHorizontally, animated: false)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = view.frame.width
        currentPhotoIndexPath.row = Int(ceil(x/w))
    }
    
    func zoomBegain() {
        collectionView.isScrollEnabled = false
    }
    
    func zoomEnded() {
        collectionView.isScrollEnabled = true
    }
    
    // MARK: UI Related
    override var prefersStatusBarHidden: Bool {
        return overlayIsHidden
    }
    
    private func toggleOverlayIsHidden(indexPath: IndexPath) {
        overlayIsHidden = !overlayIsHidden
        guard let navController = navigationController else { return }
        navController.setNavigationBarHidden(overlayIsHidden, animated: true)
        guard let detailCell = collectionView.cellForItem(at: indexPath) as? PhotoDetailCell else { return }
        detailCell.setOverlayHidden(overlayIsHidden, animated: true)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: self.currentPhotoIndexPath, at: .centeredHorizontally, animated: false)
        }
    }

    //MARK: CollectionView - Data Source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let detailCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoDetailCell.reuseId, for: indexPath) as? PhotoDetailCell else {
            return UICollectionViewCell()
        }
        let photo = photos[indexPath.row]
        detailCell.imageView.imageFromURL(photo.imageUrl)
        detailCell.titleLabel.text = photo.title
        detailCell.setOverlayHidden(overlayIsHidden)
//        detailCell.zoomDelegate = self
        return detailCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? photos.count : 0
    }
    
    //MARK: CollectionView - Delegate
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let detailCell = cell as? PhotoDetailCell else { return }
        detailCell.resetImageSizeAndCenter()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let detailCell = cell as? PhotoDetailCell else { return }
        detailCell.resetImageSizeAndCenter()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (view.frame.width - view.safeAreaLayoutGuide.layoutFrame.width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleOverlayIsHidden(indexPath: indexPath)
    }
}

extension PhotosDetailCollectionViewController: UICollectionViewDelegateFlowLayout {
    //MARK: CollectionView - FlowLayout Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let safeArea = view.safeAreaLayoutGuide.layoutFrame
        return CGSize(width: safeArea.width, height: safeArea.height)
    }
}
