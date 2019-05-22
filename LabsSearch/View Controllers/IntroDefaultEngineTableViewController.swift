//
//  IntroDefaultEngineTableViewController.swift
//  Chears
//
//  Created by Xcode on ’19/05/17.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

/// Shows a short list of most used engines so that the user can select the default engine.
class IntroDefaultEngineTableViewController: DefaultEngineTableViewController, DefaultEngineTableViewControllerDelegate {
    
    // MARK: - Properties
    
    // Only offer up the most common engines for the given region
    // FIXME: Compute this based on region!
    var commonShortcuts: [String] {
        return [
            NSLocalizedString("SearchEngine.defaultEngines-GoogleShortcut", comment: ""),
            NSLocalizedString("SearchEngine.defaultEngines-WikipediaShortcut", comment: ""),
            NSLocalizedString("SearchEngine.defaultEngines-NaverShortcut", comment: "")
        ]
    }
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent common shortcuts from being overwritten by all enabled shortcuts if user leaves app during intro
        // FIXME: Check this actually works!
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Replace enabled shortcuts in this VC only with common shortcuts
        enabledShortcuts = commonShortcuts
        
        // This VC will act as its own delegate to send default engine selection
        delegate = self
    }
    
    func didSelectDefaultEngine(_ engine: SearchEngine) {
        SearchEngines.shared.defaultEngine = engine
    }
        
}
