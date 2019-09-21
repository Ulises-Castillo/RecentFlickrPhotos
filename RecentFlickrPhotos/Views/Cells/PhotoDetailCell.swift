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
protocol PhotoZoomDelegate: class {
    func zoomBegain()
    func zoomEnded()
}

class PhotoDetailCell: UICollectionViewCell {
    static let reuseId = "PhotoDetailCell"
    
    let imageView = FPImageView()
    let titleLabel = UILabel()
    private var isZooming = false
    private var originalImageCenter: CGPoint?
//    weak var zoomDelegate: PhotoZoomDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        clipsToBounds = false
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.addSubview(titleLabel)
        addEngulfingSubview(imageView)
        configureTitleLabel()
        configureGestureRecognizers()
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

extension PhotoDetailCell: UIGestureRecognizerDelegate {
    func configureGestureRecognizers() {
        imageView.isUserInteractionEnabled = true
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        pinch.delegate = self
        imageView.addGestureRecognizer(pinch)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        pan.delegate = self
        imageView.addGestureRecognizer(pan)
    }
    
    func resetImageSizeAndCenter() {
        guard let center = originalImageCenter else { return }
        isZooming = false
        imageView.center = center
        imageView.transform = CGAffineTransform.identity
    }
    
    @objc func pan(sender: UIPanGestureRecognizer) {
        if self.isZooming && sender.state == .began {
            self.originalImageCenter = sender.view?.center
        } else if self.isZooming && sender.state == .changed {
            let translation = sender.translation(in: self)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            sender.setTranslation(CGPoint.zero, in: imageView.superview)
        }
    }
    
    @objc func pinch(sender:UIPinchGestureRecognizer) {
        if sender.state == .began {
//            zoomDelegate?.zoomBegain()
//            self.originalImageCenter = sender.view?.center
            let currentScale = imageView.frame.size.width / imageView.bounds.size.width
            let newScale = currentScale*sender.scale
            if newScale > 1 {
                self.isZooming = true
            }
        } else if sender.state == .changed {
            guard let view = sender.view else {return}
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            let currentScale = imageView.frame.size.width / imageView.bounds.size.width
            var newScale = currentScale*sender.scale
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.imageView.transform = transform
                sender.scale = 1
            }else {
                view.transform = transform
                sender.scale = 1
            }
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            guard let center = self.originalImageCenter else { return }
            self.originalImageCenter = nil
//            zoomDelegate?.zoomEnded()
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.transform = CGAffineTransform.identity
                self.imageView.center = center
            }, completion: { _ in
                self.isZooming = false
            })
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
