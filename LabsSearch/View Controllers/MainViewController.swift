//
//  MainViewController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/18.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit
import SafariServices

class MainViewController: UIViewController, SearchControllerDelegate, SFSafariViewControllerDelegate, EngineIconViewController {

    // TODO: Make SearchController a class? .shared? Fix currentEngine?
    //- Had to make this a var to keep everyone happy...
    var searchController = SearchController()
//    let defaults = UserDefaults.standard
    let defaults = UserDefaults(suiteName: AppKeys.appGroup)
    
    // This is used for displaying and changing the icon via the protocol
    var engine: SearchEngine? {
        didSet {
            updateIconEngine()
        }
    }
    
    @IBOutlet weak var engineIconView: EngineIconView!
    @IBOutlet weak var engineIconImage: EngineIconImageView!
    @IBOutlet weak var engineIconLabel: EngineIconLabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make main view controller the delegate in order to update engine image and search field visuals
        searchController.delegate = self
        
        // Populate list of engines, using saves or defaults
        // TODO: Should this be done in AppDelegate?
        SearchEngines.shared.loadEngines()
        
        // Set stayInApp preference if it doesn't exist
        // TODO: Should this be done in AppDelegate?
//        if UserDefaults.standard.value(forKey: SettingsKeys.stayInApp) == nil {
//            UserDefaults.standard.set(false, forKey: SettingsKeys.stayInApp)
        if UserDefaults(suiteName: AppKeys.appGroup)?.value(forKey: SettingsKeys.stayInApp) == nil {
            UserDefaults(suiteName: AppKeys.appGroup)?.set(false, forKey: SettingsKeys.stayInApp)
        }
        
        // Show keyboard automatically
        searchTextField.becomeFirstResponder()
        
        // Hide engine icon on startup
        engineIconView.alpha = 0
        
        // Set text size in search field programatically to keep iOS<11 happy
        if #available(iOS 11.0, *) {
            print(.o, "Using iOS 11+; using large title font for search field.")
            searchTextField.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        } else {
            // Earlier versions use storyboard default ("Title 1" style)
            print(.n, "Using iOS<11; setting fixed font size for search field.")
        }
    }
    
    
    /// Hide the navigation bar on the main view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateIconCorners()
    }
    
    
    /// Check contents of the search field whenever it is changed by the user.
    ///
    /// - Parameter sender: The search text field.
    @IBAction func searchTextFieldChanged(_ sender: UITextField) {
        let unsplitText = sender.text
        print(.o, "Search field changed to \"\(unsplitText ?? "nil")\".")
        searchController.detectEngine(in: unsplitText)
    }
    
    // TODO: Now that we've got `engine` as part of the icon protocol, ...
    //- can we just set delegate?.engine in the SearchController,
    //- and eliminate the detectedEngine parameter?...
    //- It means we could also eliminate the need to pass the `shortcut` to `highlightSearchShortcut`.
    
    // Delegate function; update search field highlighting and icon based on engine selection status
    func didUpdateSearch(detectedEngine: SearchEngine?, didSetEngine: Bool) {
        
        // Use two-tone coloration on string if engine is set, otherwise entire string is black
        if didSetEngine {
            engine = detectedEngine
            engineIconView.alpha = 1
            
            // Highlight search shortcut
            if let shortcut = detectedEngine?.shortcut {
                highlightSearchShortcut(shortcut, in: searchTextField)
            } else {
                print(.x, "Could not determine current search engine shortcut.")
            }
        } else if detectedEngine != nil {
            engine = detectedEngine
            engineIconView.alpha = 0.5
            searchTextField.textColor = .black
        } else {
            engineIconView.alpha = 0
            searchTextField.textColor = .black
        }
    }
    
    
    /// Highlight the search shortcut in a given text field.
    ///
    /// - Parameter textField: The text field which should contain the search shortcut.
    func highlightSearchShortcut(_ shortcut: String, in textField: UITextField) {
        // Set up special attributes for shortcut text
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray
        ]
        
        // Replace text field text with coloured copy
        textField.decorateText(using: attributes, on: shortcut)
    }
    
    
    /// Perform the main action from the search field.
    ///
    /// - Parameter sender: The search text field.
    @IBAction func searchTextFieldReturnKeyPressed(_ sender: UITextField) {
        guard let searchTerms = sender.text else { return }
        searchController.search(searchTerms) { (url) in
            // Display in Safari view controller if preference is set
//            if let url = url {
//                print(.o, "Opening URL in Safari web view: \(url)")
//                showSafariViewController(for: url)
//            }
            
//            if defaults.bool(forKey: SettingsKeys.stayInApp)
//                && url.schemeIsCompatibleWithSafariView {
            if let stayInApp = defaults?.bool(forKey: SettingsKeys.stayInApp),
                stayInApp,
                url.schemeIsCompatibleWithSafariView {
                // Safari view must be handled by subclass of UIViewController
                print(.o, "Opening URL in Safari web view: \(url)")
                showSafariViewController(for: url)
            } else {
                // Extenal launches handled by SearchController extension (API cannot be called in app extensions)
                print(.o, "Opening external app to show url: \(url)")
                searchController.showSearchInExternalApp(for: url)
            }
        }
    }
    
    
    // TODO: Keyboard shouldn't cover search field (do we need a scroll view?)
    // TODO: Search button (for if user prefers this over return key); below?
    
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
