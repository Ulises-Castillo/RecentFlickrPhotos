//
//  PhotoDetailCell.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import UIKit

//TODO: zoom (pinch, pan gesture recognizers)
//TODO: container view for titleLabel, to enforce consistent leading/tailing insets
class PhotoDetailCell: UICollectionViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    static let reuseId = "PhotoDetailCell"
    
    let imageView = FPImageView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3.5
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        
        scrollView.addEngulfingSubview(imageView)
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.addSubview(titleLabel)
        imageView.isUserInteractionEnabled = true
        addEngulfingSubview(scrollView)
        configureTitleLabel()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private func configureTitleLabel() {
        titleLabel.textColor = .white
        titleLabel.backgroundColor = UIColor(white: 0, alpha: 0.6)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 70)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.sizeToFit()
        let labelConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ]
        NSLayoutConstraint.activate(labelConstraints)
    }
    
    func setOverlayHidden(_ isHidden: Bool, animated: Bool = false) {
        if !animated {
            titleLabel.isHidden = isHidden
            return
        }
        UIView.animate(withDuration: 0.25) {
            self.titleLabel.isHidden = isHidden
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
