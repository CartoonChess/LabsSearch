//
//  SearchController+showSearchInExternalApp.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/07.
//  Copyright © 2018 Distant Labs. All rights reserved.
//


/*
 * UIApplication.shared can't be present within files in app extension's target.
 * We need to share the main SearchController struct, so this function is declared here.
 *
 * Because the main struct can't access this, opening URLs (whether in Safari view or external)
 * is now entirely handled by the view via the completion handler.
 */


import UIKit

extension SearchController {

    /// Open search results in external app (fallback to Safari app)
    ///
    /// - Parameter url: The URL, with queries, to display.
    func showSearchInExternalApp(for url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                if success {
                    print(.o, "URL successfully opened in external app: \(url)")
                } else {
                    print(.x, "Failed to open URL in external app: \(url)")
                }
            }
        } else {
            // Support for iOS below 10.0
            print(.n, "Opening URL using deprecated method for older OS versions.")
            UIApplication.shared.openURL(url)
        }
    }

}
