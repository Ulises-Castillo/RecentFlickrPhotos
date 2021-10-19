//
//  FPImageView.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import UIKit

class FPImageView: UIImageView {
    private static let imageCache = NSCache<NSString, UIImage>()
    
    private var imageUrlString: String?
    
    public static func dumpCache() {
        imageCache.removeAllObjects()
    }
    
    public func imageFromURL(_ url: URL) {
        // prevent flashing incorrect image on
        // imageView reuse (within a cell)
        image = nil
        // check cache for image
        let imageKey = url.absoluteString as NSString
        if let cachedImage = FPImageView.imageCache.object(forKey: imageKey) {
            self.image = cachedImage
            return
        }
        // store intended image url
        imageUrlString = url.absoluteString
        
        // add activity indicator
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activityIndicator.startAnimating()
        if self.image == nil {
            self.addEngulfingSubview(activityIndicator)
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                Log.debug(error!.localizedDescription)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                Log.debug("Error: image data")
                return
            }
            DispatchQueue.main.async {
                // prevent wrong image being set on imageView
                // happens on slow network responses when imageView
                // is reused within tableView/collectionView cell
                if self.imageUrlString == url.absoluteString {
                    self.image = image
                    activityIndicator.removeFromSuperview()
                }
                // cache image
                let imageKey = url.absoluteString as NSString
                FPImageView.imageCache.setObject(image, forKey: imageKey)
            }
        }.resume()
    }
}
