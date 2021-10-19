//
//  Log.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import Foundation

struct Log {
    static func debug(_ string: String) {
        #if DEBUG
        print(Date(), string)
        #endif
    }
}
