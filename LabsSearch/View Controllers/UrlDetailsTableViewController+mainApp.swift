//
//  UrlDetailsTableViewController+mainApp.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/30.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

extension UrlDetailsTableViewController {

    // MARK: - Methods

    // Main app is able to launch URLs with app-specific schemes, so override here.
    func schemeIsValid(url: URL) -> Bool {
        return url.schemeIsValid
    }

    // Main app is able to launch external apps from special URL schemes, so implement here.
    func urlRequiresExternalApp(url: URL) {
        print(.n, "Testing URL in external app because scheme is not http(s).")
        let searchController = SearchController()
        searchController.showSearchInExternalApp(for: url)
    }

}

