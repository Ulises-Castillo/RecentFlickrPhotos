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
    
    private var items = [Item]()
    var focusedPhotoIndexPath: IndexPath?
    private var fetchingMorePhotos = false
    private let photoListViewModel = PhotoListViewModel()
    private var photoListKVO: NSKeyValueObservation? = nil
    private let spacing: CGFloat = 5
    private let NumberOfPhotosPerRowPortrait: CGFloat = 4
    private let NumberOfPhotosPerRowLandscape: CGFloat = 8
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureDataSource()
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
        collectionView.register(ActivityIndicatorCell.self, forCellWithReuseIdentifier: ActivityIndicatorCell.reuseId)
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.sectionInsetReference = .fromSafeArea
    }
    
    private func observePhotoListSetup() {
        photoListKVO = photoListViewModel.observe(\PhotoListViewModel.photos, options: .new) { [unowned self] (photoListViewModel, change) in
            DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
                self.fetchingMorePhotos = false
                guard let photos = photoListViewModel.photos else { return }
                self.items = itemsFromPhotos(photoViewModels: photos)
                updateDataSource()
            }
        }
    }
    
    // MARK: Miscellaneous
    private func prepareDetailControllerForSegue(selectedPhotoIndex: IndexPath) -> PhotosDetailCollectionViewController {
        let detailVC = PhotosDetailCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        detailVC.title = title
        detailVC.photos = photoListViewModel.photos!
        detailVC.setSelectedPhotoIndexPath(selectedPhotoIndex)
        return detailVC
    }
    
    override func didReceiveMemoryWarning() {
        FPImageView.dumpCache()
    }
    
    // MARK: UI Related
    func selectFocusedPhoto() {
        guard let indexPath = focusedPhotoIndexPath else { return }
        self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        focusedPhotoIndexPath = nil
    }
    
    @objc private func handleRefreshControl() {
        photoListViewModel.fetchPhotos()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        let previousOffsetPercent = collectionView.contentOffset.y / collectionView.contentSize.height
        collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            let newOffset = CGPoint(x: self.collectionView.contentOffset.x, y: self.collectionView.contentSize.height * previousOffsetPercent)
            self.collectionView.setContentOffset(newOffset, animated: false)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        // Do we need to fetch more photos ?
        if !items.isEmpty && !fetchingMorePhotos && offsetY > contentHeight - scrollView.frame.height * 2  {
            DispatchQueue.main.async {
                self.fetchMorePhotos()
            }
        }
    }
    
    func fetchMorePhotos() {
        fetchingMorePhotos = true
        self.updateDataSource(showSpinner: true)
        photoListViewModel.fetchMorePhotos()
    }
    
    //MARK: CollectionView - Data Source
    fileprivate enum Section {
        case main
        case spinner
    }
    
    struct Item: Hashable {
        let uuid = UUID()
        var photoViewModel: PhotoViewModel?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
    }
    
    private func itemsFromPhotos(photoViewModels: [PhotoViewModel]) -> [Item] {
        var items = [Item]()
        for photo in photoViewModels {
            items.append(Item(photoViewModel: photo))
        }
        return items
    }
    
    private func configureDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {(collectionView, indexPath, item) -> UICollectionViewCell? in
            let section: Section = indexPath.section == 0 ? .main : .spinner
            
            switch section {
            case .main:
                guard let thumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailPhotoCell.reuseId, for: indexPath) as? ThumbnailPhotoCell,
                      let photo = item.photoViewModel else {
                    return UICollectionViewCell()
                }
                thumbnailCell.imageView.imageFromURL(photo.imageUrl)
                return thumbnailCell
            case .spinner:
                guard let activityCell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityIndicatorCell.reuseId, for: indexPath) as? ActivityIndicatorCell else {
                    return UICollectionViewCell()
                }
                activityCell.spinner.startAnimating()
                return activityCell
            }
        }
    }
    
    private func updateDataSource(showSpinner: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.items)
        
        if showSpinner {
            snapshot.appendSections([.spinner])
            snapshot.appendItems([Item()])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    //MARK: CollectionView - Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = prepareDetailControllerForSegue(selectedPhotoIndex: indexPath)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

//MARK: CollectionView - FlowLayout Delegate
extension PhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = UIDevice.current.orientation.isLandscape ? NumberOfPhotosPerRowLandscape : NumberOfPhotosPerRowPortrait
        let totalSpacing = (2 * spacing) + ((numberOfItemsPerRow - 1) * spacing)
        let width = (collectionView.safeAreaLayoutGuide.layoutFrame.width - totalSpacing) / numberOfItemsPerRow
        if indexPath.section == 1 {
            return CGSize(width: collectionView.safeAreaLayoutGuide.layoutFrame.width, height: width / 1.5)
        }
        return CGSize(width: width, height: width)
    }
}
