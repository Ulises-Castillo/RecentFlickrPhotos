//
//  ActivityIndicatorCell.swift
//  RecentFlickrPhotos
//
//  Created by Ulysses Castillo on 9/21/19.
//  Copyright © 2019 uly. All rights reserved.
//

import UIKit

class ActivityIndicatorCell: UICollectionViewCell {
    static let reuseId = "ActivityIndicatorCell"
    
    let spinner = UIActivityIndicatorView(style: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addEngulfingSubview(spinner)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
