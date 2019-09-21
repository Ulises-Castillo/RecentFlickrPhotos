//
//  AppDelegate.swift
//  RecentFlickrPhotos
//
//  Created by Ulises Castillo on 9/13/19
//  Copyright © 2019 uly. All rights reserved.
//

import UIKit

@UIApplicationMain

//TODO: unit tests
//TODO: handle app states
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        
        let photosVC = PhotosCollectionViewController(collectionViewLayout:  UICollectionViewFlowLayout())
        window!.rootViewController = UINavigationController.init(rootViewController: photosVC)
        return true
    }
}

