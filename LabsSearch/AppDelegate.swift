//
//  AppDelegate.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/18.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // MARK: - Caching
        // We had set some memory caching for when grabbing images via (local) URL,
        //- but apparently this is set by default, and should be enough (500k?)
        
//        let temporaryDirectory = NSTemporaryDirectory()
//        let urlCache = URLCache(memoryCapacity: 25000000, diskCapacity: 0, diskPath: temporaryDirectory)
//        let urlCache = URLCache(memoryCapacity: 25000000, diskCapacity: 0, diskPath: nil)
//        URLCache.shared = urlCache
        
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print(.d, "App(delegate) will enter foreground!")
        // If an engine was added via the action extension, refresh the data when returning to main app
        if let extensionDidChangeData = UserDefaults(suiteName: AppKeys.appGroup)?.bool(forKey: SettingsKeys.extensionDidChangeData),
            extensionDidChangeData {
            print(.o, "Engine previously added via action extension; refreshing data.")
            // Refresh data
            SearchEngines.shared.loadEngines()
        }
        print(.d, "App(delegate) will enter foreground - with \(SearchEngines.shared.allShortcuts)!")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print(.d, "App(delegate) did become active!")
        // extensionDidChangeData is returned to false here to allow active views to first refresh themselves
        if let extensionDidChangeData = UserDefaults(suiteName: AppKeys.appGroup)?.bool(forKey: SettingsKeys.extensionDidChangeData),
            extensionDidChangeData {
            print(.n, "Data and any currently visible tables should have been refreshed; setting extensionDidChangeData to false.")
            UserDefaults(suiteName: AppKeys.appGroup)?.set(false, forKey: SettingsKeys.extensionDidChangeData)
        }
        print(.d, "App(delegate) did become active - with \(SearchEngines.shared.allShortcuts)!")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

