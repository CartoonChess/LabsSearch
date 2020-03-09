//
//  ActionExtensionUrlDetailsTableViewController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/30.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

extension UrlDetailsTableViewController {
    
    /// Determines whether the URL can be tested from within the current view.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: A boolean value based on whether the view will be able to load the URL.
    ///
    /// By default, this will only be true when the scheme is `http(s)`. While this is the only option for app extensions, the full app can and should override this method to return the value of `url.schemeIsValid` instead.
    func schemeIsValid(url: URL) -> Bool {
        return url.schemeIsCompatibleWithSafariView
    }
    
    
    /// Provide the option for subclasses to open the URL in an external app, if available.
    ///
    /// App extensions cannot launch external apps, and so should not implement this method. Use `updateEngineTestibleStatus()` to check that URLs use the `http` or `https` schemes and update engineIsTestible accordingly. This method should never have to be called in app extensions.
    func urlRequiresExternalApp(url: URL) {
        print(.x, "Attempted to open URL but view controller provides no means to open URLs with scheme \(url.scheme ?? "nil").")
    }
    
}
