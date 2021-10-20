//
//  PhotosCollectionViewController.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import UIKit
import Combine

//TODO: endless feed/scrolling (next page of photos)
//TODO: Add UI to handle slow network response & No Internet
class PhotosCollectionViewController: UICollectionViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let photoListViewModel = PhotoListViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    private var items = [Item]()
    var focusedPhotoIndexPath: IndexPath?
    private let spacing: CGFloat = 5
    private let NumberOfPhotosPerRowPortrait: CGFloat = 4
    private let NumberOfPhotosPerRowLandscape: CGFloat = 8
    
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureDataSource()
        configureRefreshControll()
        setViewModelListeners()
        photoListViewModel.getPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectFocusedPhoto()
    }
    
    //MARK: Setup & Configuration
    private func configureRefreshControll() {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
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
    
    private func setViewModelListeners() {
        Publishers.CombineLatest(photoListViewModel.isFirstLoadingPageSubject, photoListViewModel.photosSubject).sink {[weak self] (isLoading, photos) in
            if isLoading {
                self?.collectionView.refreshControl?.beginRefreshing()
            } else {
                self?.collectionView.restore()
                guard let self = self, self.items.count < photos.count else { return } // refactor
                let newPhotos = photos[self.items.count..<photos.count]
                self.items += self.itemsFromPhotos(photoViewModels: newPhotos)
                self.collectionView.refreshControl?.endRefreshing()
                self.updateDataSource()
                self.loadingMorePhotos = false
                
                if photos.isEmpty {
                    self.collectionView.setEmptyMessage(message: "No character found")
                } else {
                    self.collectionView.restore()
                    
                }
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: Miscellaneous
    private func prepareDetailControllerForSegue(selectedPhotoIndex: IndexPath) -> PhotosDetailCollectionViewController {
        let detailVC = PhotosDetailCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        detailVC.title = title
        detailVC.photos = photoListViewModel.photosSubject.value
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
        photoListViewModel.photosSubject.value = []
        items = []
        photoListViewModel.getPhotos(firstPage: true)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        let previousOffsetPercent = collectionView.contentOffset.y / collectionView.contentSize.height
        collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            let newOffset = CGPoint(x: self.collectionView.contentOffset.x, y: self.collectionView.contentSize.height * previousOffsetPercent)
            self.collectionView.setContentOffset(newOffset, animated: false)
        }
    }
    
    var loadingMorePhotos = false
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let collectionViewContentSizeHeight = collectionView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if position > (collectionViewContentSizeHeight - 100 - (scrollViewHeight * 1.5)) {
            
            if !self.loadingMorePhotos {
                self.photoListViewModel.getPhotos()
                DispatchQueue.main.async {
                    self.loadingMorePhotos = true
                    self.updateDataSource(showSpinner: !self.photoListViewModel.isFirstLoadingPageSubject.value)
                }
            }
        }
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
    
    private func itemsFromPhotos(photoViewModels: ArraySlice<PhotoViewModel>) -> [Item] {
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
        guard indexPath.section == 0 else { return }
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

extension UICollectionView {
    func setEmptyMessage(message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .systemGray2
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension UICollectionView {
    func setLoading(){
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.color = .gray
        self.backgroundView = activityIndicatorView
        activityIndicatorView.startAnimating()
    }
}
