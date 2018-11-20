//
//  UIViewController+showSafariViewController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/30.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit
import SafariServices

//extension UIViewController: SFSafariViewControllerDelegate {
extension UIViewController {

    /// Shows the target URL in a Safari view controller rather than an external app.
    ///
    /// - Parameter url: The URL to visit.
    func showSafariViewController(for url: URL) {
        let safariViewController = SFSafariViewController(url: url)

        // Set the view controller which presents the Safari view as its delegate, if it has declared itself one
        safariViewController.delegate = self as? SFSafariViewControllerDelegate
        
        // Throw up a warning if we forgot to have the VC conform to the delegate protocol
        if safariViewController.delegate == nil {
            print(.x, "View controller does not conform to SFSafariViewControllerDelegate.")
        }

        present(safariViewController, animated: true, completion: nil)
    }
    
    // Need to put objc in front here or else compiler complains a bit
    @objc func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print(.n, "Safari view dismissed.")

        // If an engine was added via the action extension, refresh the data when dismissing Safari view
        // TODO: This copies code directly from AppDelegate; refactor
        if let extensionDidChangeData = UserDefaults(suiteName: AppKeys.appGroup)?.bool(forKey: SettingsKeys.extensionDidChangeData),
            extensionDidChangeData {
            print(.o, "Engine previously added via action extension; refreshing data.")
            // Refresh data
            SearchEngines.shared.loadEngines()
            // Toggle setting back to false
            UserDefaults(suiteName: AppKeys.appGroup)?.set(false, forKey: SettingsKeys.extensionDidChangeData)
        }
    }
    
}


//protocol SafariViewControllerDelegate: class, UIViewController, SFSafariViewControllerDelegate {
//    func showSafariViewController(for url: URL)
//}
//
//
////extension SFSafariViewControllerDelegate {
//extension SafariViewControllerDelegate {
//
//    /// Shows the target URL in a Safari view controller rather than an external app.
//    ///
//    /// - Parameter url: The URL to visit.
//    func showSafariViewController(for url: URL) {
//        let safariViewController = SFSafariViewController(url: url)
//        //        present(safariViewController, animated: true, completion: nil)
//
//        // Set the view controller which presents the Safari view as its delegate, if it has declared itself one
//        safariViewController.delegate = self as UIViewController
//
//        self.present(safariViewController, animated: true, completion: nil)
//    }
//
//    // Need to put objc in front here or else compiler complains a bit
//    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
//        print(.n, "Safari view dismissed.")
//
//        // If an engine was added via the action extension, refresh the data when dismissing Safari view
//        // TODO: This copies code directly from AppDelegate; refactor
//        if let extensionDidChangeData = UserDefaults(suiteName: AppKeys.appGroup)?.bool(forKey: SettingsKeys.extensionDidChangeData),
//            extensionDidChangeData {
//            print(.o, "Engine previously added via action extension; refreshing data.")
//            // Refresh data
//            SearchEngines.shared.loadEngines()
//            // Toggle setting back to false
//            UserDefaults(suiteName: AppKeys.appGroup)?.set(false, forKey: SettingsKeys.extensionDidChangeData)
//        }
//    }
//
//}
