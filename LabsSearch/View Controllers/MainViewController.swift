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
    
    // MARK: - Parameters

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
    
    // This is used in conjunction with observers/notifications to scroll in case the keyboard covers the text field
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var engineIconView: EngineIconView!
    @IBOutlet weak var engineIconImage: EngineIconImageView!
    @IBOutlet weak var engineIconLabel: EngineIconLabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    // MARK: - Methods
    
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
        
        // Allow the VC to listen to keyboard notifications so we can scroll the view if the keyboard hides the text field
        registerForKeyboardNotifications()
        
        // Hide engine icon on startup
        engineIconView.alpha = 0
        
        // Set text size in search field programatically to keep iOS<11 happy
        if #available(iOS 11.0, *) {
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
        // Refresh icon corners, in case stayInApp has changed
        updateIconLayout()
        // Check the text field again, in case the user has en(/dis)abled entered engine or changed shortcut
        // Note: If we ever have issues with this in the future, consider setting self.engine = nil
        searchController.currentSearchEngine = nil
        searchTextFieldChanged(searchTextField)
        
//        // Suppress autolayout errors related to iPad keyboard's autocorrect bar
//        // This works on first load, but fails on returning to the view
//        // We tried this in viewDidLoad as well...
//        // We'll just accept this as a bug for now:
//        //- https://openradar.appspot.com/36578167
//        //- https://stackoverflow.com/questions/46566188/uibuttonbarstackview-breaking-constraint-when-becomefirstresponder-sent
//        searchTextField.inputAssistantItem.leadingBarButtonGroups = []
//        searchTextField.inputAssistantItem.trailingBarButtonGroups = []
    }
    
    
    /// Check contents of the search field whenever it is changed by the user.
    ///
    /// - Parameter sender: The search text field.
    @IBAction func searchTextFieldChanged(_ sender: UITextField) {
//        sender.text = sender.text?.leadingSpacesRemoved()
//        sender.attributedText = NSAttributedString(sender.attributedText?.string.leadingSpacesRemoved())
        
        let unsplitText = sender.text
//        print(.i, "Search field changed to \"\(unsplitText ?? "nil")\".")
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
//            .foregroundColor: UIColor.white,
//            .backgroundColor: UIColor.lightGray,
//            .kern: 100
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
    
    
    // MARK: - TextField vs. keyboard scroll functions
    // Note: These are all taken from Apple's "App Development with Swift" ebook
    
    // Set observers for keyboard show/hide notifications
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Basically, extend the length of the scroll view by the height of the keyboard, effectively scrolling it
    @objc func keyboardWasShown(_ notification: NSNotification) {
        // Not sure about this error
        guard let info = notification.userInfo,
            let keyboardFrameValue = info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else {
            print(.x, "Error receiving keyboard showing notification.")
            return
        }
        
        // Get keyboard size
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        // Add inset to bottom of scroll view
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        // Adjust the scrollbar respectively
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // Revert the scroll view to the way it was before the keyboard was shown
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // TODO: Search button (for if user prefers this over return key); below?

}
