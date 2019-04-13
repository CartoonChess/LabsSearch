//
//  AddEditEngineTableViewController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/28.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

class AddEditEngineTableViewController: UITableViewController, EngineIconViewController, UrlDetailsTableViewControllerDelegate {
    
    // MARK: - Properties
    
    // Set this to true when the view has appeared for the first time
    var viewDidAppear: Bool = false
    
    // For checking that the shortcut isn't already in use
    // This must be instantiated in viewDidLoad so that the app extension has a chance to use it
//    let allShortcuts = SearchEngines.shared.allShortcuts
    var allShortcuts: [String]?
    // This will be the same as above, but minus the current engine's shortcut, if editing
    //- This allows us to check that our shortcut doesn't conflict with existing shortcuts,
    //- but says that it's okay if we're keeping this engine's shortcut the same
    var allOtherShortcuts: [String]?
    
    // When adding, this value will be nil on load
    var engine: SearchEngine?
    // When adding, an OpenSearch object may have been passed in
    var openSearch: OpenSearch?
    // Determines if a new, usable URL was passed back from the URL details VC
    var didReceiveUpdatedUrl: Bool = false
    
    // Object manipulated by UrlDetails to find an icon from the user's URL
    let iconFetcher = IconFetcher()
    // Keeps track of what website the current icon came from so that it isn't fetched again unnecessarily
    var mostRecentHost: String?
    
    // Index paths for cells
    enum Cell {
        static let engineName: IndexPath = [0, 0]
        static let shortcut: IndexPath = [0, 1]
        static let deleteButton: IndexPath = [2, 0]
    }
    
    // To be assigned in viewDidLoad
    var saveButton: UIBarButtonItem!
    
    
    // MARK: App extension properties
    
    // These details will be provided by the host app
    var hostAppEngineName: String?
    var hostAppUrlString: String?
    var hostAppHtml: String?
    
    let urlController = UrlController()
    
    
    // MARK: IB properties
    
    @IBOutlet weak var engineIconView: EngineIconView!
    @IBOutlet weak var engineIconImage: EngineIconImageView!
    @IBOutlet weak var engineIconLabel: EngineIconLabel!
    
    @IBOutlet weak var nameTextField: TableViewCellTextField!
    @IBOutlet weak var enabledToggle: UISwitch!
    @IBOutlet weak var shortcutTextField: TableViewCellTextField!
    
    @IBOutlet weak var urlDetailsChangedLabel: UILabel!
    
    @IBOutlet weak var deleteButtonCell: UITableViewCell!
    
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Increase the size of the view containing the icon view when using larger icon on iPad
        // Note that there seems to be a conflict with IB's vary for traits,
        // so iPhone reports iconHeight as 120 (big) if this is calculated in viewDidLoad().
        // For this reason, we detect iPads (regular width + regular height) and adjust to new size
        // (detection code from SOf)
        
        // Also note tableHeaderView is the (usually nil) view atop the table sections!
        // We messed with this in IB (somehow) but Apple actually put it there
        
//        let iconHeight = engineIconView.frame.size.height
//        let additionalIconHeight = iconHeight - 60 // 60 is default/smallest height (iPhone)
//        let additionalPadding = (additionalIconHeight / 30) * 8 // 8 is also default for top/bottom
//        let additionalViewHeight = additionalIconHeight + (additionalPadding * 2)
////        engineIconContainerView.frame.size.height += additionalViewHeight
//        tableView.tableHeaderView?.frame.size.height += additionalViewHeight
//
//        print(.d, "iconHeight: \(iconHeight)")
//        print(.d, "additionalIconHeight: \(additionalIconHeight)")
//        print(.d, "additionalPadding: \(additionalPadding)")
//        print(.d, "additionalViewHeight: \(additionalViewHeight)")
        
        let sizeTraitsClass:(UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) = (UIScreen.main.traitCollection.horizontalSizeClass, UIScreen.main.traitCollection.verticalSizeClass)
        
        switch sizeTraitsClass {
        case (UIUserInterfaceSizeClass.regular, UIUserInterfaceSizeClass.regular):
            //iPad - width: regular; height: regular
            tableView.tableHeaderView?.frame.size.height += 92
        default:
            break
        }
        
        // For app extension:
        // In order to access allShortcuts, we must load up the engines plist
        // In the main app, this is already taken care of in MainViewController
        #if EXTENSION
            print(.n, "Loading engines for app extension.")
            SearchEngines.shared.loadEngines()
        
            // Get the current web page's URL and title from the host app
            loadUrl()
        #endif
        
        // Note: Be sure to load up engines BEFORE calling this super in app extension
        allShortcuts = SearchEngines.shared.allShortcuts
        
        // Set upper right save button
        saveButton = navigationItem.rightBarButtonItem
        
        // Perform setup differently depending on whether we're adding (engine == nil) or editing
        if engine == nil {
            // Adding
            
            // Set title
            navigationItem.title = NSLocalizedString("AddEditEngine.navigationItemTitle-Add", comment: "")
            
            // Indicate that the URL is not set
            urlDetailsChangedLabel.isHidden = false
            // Hide the enabled toggle and delete button
            enabledToggle.isHidden = true
            deleteButtonCell.isHidden = true
            
            // Check if an OpS object has been passed in and if so use the URL and name
            if let openSearch = openSearch {
                print(.o, "Using OpenSearch engine named \"\(openSearch.name)\".")
                updateUsingOpenSearch(openSearch)
            } else {
                print(.n, "No OpenSearch object found; proceeding for manual engine creation.")
            }
        } else {
            // Editing
            guard let engine = engine else {
                print(.x, "Error unwrapping engine while setting up view.")
                return
            }
            
            // Set title
            navigationItem.title = NSLocalizedString("AddEditEngine.navigationItemTitle-Edit", comment: "")
            
            // Set array of engine shortcuts which excludes the current
            allOtherShortcuts = allShortcuts?.filter { $0 != engine.shortcut }
            
            // Populate fields
            setIcon()
            nameTextField.text = engine.name
            shortcutTextField.text = engine.shortcut
            
            // Disable toggle entirely if engine is default, otherwise set according to isEnabled property
            if engine == SearchEngines.shared.defaultEngine {
                enabledToggle.isEnabled = false
                // Hide the delete button, too
                deleteButtonCell.isHidden = true
            } else {
                enabledToggle.isOn = engine.isEnabled
                enabledToggleChanged()
            }
            
            // Even if editing, only let corners be rounded once
            viewDidAppear = true
        }
        
        // If switching apps, we need to recheck shortcut validity
        // Note: UIApplication works in app ext, just not .shared, so this is okay
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    /// Check for updated data when returning from another app, and recheck the shortcut validity.
    @objc func willEnterForeground() {
        print(.d, "(AddEdit) VC will enter foreground!")
        
        // If switching back to the main app, we only need to recheck if the ext has added an engine
        #if !EXTENSION
            guard let extensionDidChangeData = UserDefaults(suiteName: AppKeys.appGroup)?.bool(forKey: SettingsKeys.extensionDidChangeData),
                extensionDidChangeData else {
                print(.i, "Returned to app but extension did not add an engine, so no need to retest shortcut.")
                return
            }
            print(.i, "Testing shortcut validity because extension has added an engine.")
        #else
            print(.i, "Testing shortcut validity because extension returned to foreground.")
        #endif
        
        SearchEngines.shared.loadEngines()
        allShortcuts = SearchEngines.shared.allShortcuts
        // allOtherShortcuts is only for edit mode, which can only happen in main app
        #if !EXTENSION
            allOtherShortcuts = allShortcuts?.filter { $0 != engine?.shortcut }
        #endif
        
        // Check shortcut validity and update save button
        shortcutChanged()
        
        print(.d, "(AddEdit) VC will enter foreground - with \(SearchEngines.shared.allShortcuts)!")
    }
    
    
    func updateUsingOpenSearch(_ openSearch: OpenSearch) {
        updateView()
        
        let urlString = openSearch.url?.absoluteString
        prepareToUpdateIcon(for: urlString)
    }
    
    func updateView() {
        // Create an engine object with the URL, if it's testable
        // This will prevent pushing to the URL details view
        // FIXME: This can still probably fail and cause the URL details view to push when the JSON is slow
        
        // Set up variables and set them based on OpS or app ext
        let urlString: String?
        
        if let openSearch = openSearch {
            print(.i, "URL loaded from OpenSearch; checking validity.")
            urlString = openSearch.url?.absoluteString
        } else {
            print(.i, "URL loaded from host app; checking validity.")
            urlString = hostAppUrlString
        }
        
        // First, see if the URL is valid and that it contains the default magic word
        if let url = urlController.validUrl(from: urlString, schemeIsValid: { (url) -> Bool in
            // TODO: Have this check compatibility differently if using OpS
            return url.schemeIsCompatibleWithSafariView
        }),
            urlController.detectMagicWord(in: url) {
            
            print(.o, "URL and default magic word detected; creating engine object.")
            // Create engine object with URL, awaiting further details
            urlController.willUpdateUrlDetails(url: url.absoluteString) { (baseUrl, queries) in
                updateUrlDetails(baseUrl: baseUrl, queries: queries)
            }
            
        }
        
        // Update text fields
        
        // Set the name field
        if let openSearch = openSearch,
            !openSearch.name.isEmpty {
            // If using the main app (OpS object will always exist), check for OpS name
            print(.i, "Setting name via OpenSearch name \"\(openSearch.name)\".")
            nameTextField.text = openSearch.name
        } else if let openSearch = openSearch,
            let url = openSearch.url,
            let name = makeEngineName(from: url.absoluteString) {
            // If OpS didn't specify a name, construct it from the URL
            print(.i, "Setting name via OpenSearch URL.")
            nameTextField.text = name
        } else if let url = hostAppUrlString,
            let name = makeEngineName(from: url) {
            // If using the app ext, construct name from URL
            print(.i, "Setting name via host app URL.")
            nameTextField.text = name
        } else {
            print(.x, "Failed to get host from OpenSearch object or host app URL; setting name field to page title or nil.")
            // If host app's URL can't be detected, use page title (will set a blank name if main app reaches here)
            nameTextField.text = hostAppEngineName
        }
        shortcutTextField.text = makeEngineShortcut()
        
        // Must call this after to make sure the shortcut field is validated properly
        shortcutChanged()
        updateSaveButton()
    }
    
    /// Checks that the URL is valid, then calls `IconFetcher`.
    ///
    /// - Parameter url: The URL as a string. This parameter will accept a `nil` value, but this will cause the function to fail silently.
    ///
    /// This function is used when adding via OpenSearch as well as via the action extension.
    func prepareToUpdateIcon(for url: String?) {
        // Pass URL to the icon fetcher
        guard let urlString = url,
            let (fetchableUrl, host) = iconFetcher.getUrlComponents(urlString) else {
                return
        }
        
        // Tell AddEditEngine VC to use the IconFetcher and update its view after fetching icon from server
        updateIcon(for: fetchableUrl, host: host)
    }
    
    
    // For app extension:
    // JSON appears to finish during viewDidLoad, viewWillAppear, or viewDidAppear.
    // We are adding view population code here twice because it goes out of sync otherwise
    //- It's redundant but hopefully it gives us a chance to populate before the viewer sees if quick
    
    // The icon can change in this view, so we must set its corners here
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !viewDidAppear {
            updateIconLayout()
            
            // In app extension: Update the URL and text fields with the fetched info
            #if EXTENSION
                updateView()
            #endif
        }
    }
    
    
    // Transition immediately to URL details view if adding an engine
    // Note: This cannot be placed in viewDidLoad or visual rendering errors could creep up
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // For app extension (note this used to be called AFTER the segue; trying earlier for now):
        // Since we're calling this twice, don't execute if it worked the first time
        #if EXTENSION
        if hostAppEngineName != nil {
            print(.n, "Already attempted on time to create engine object in viewWillAppear.")
        } else if !viewDidAppear {
            // This won't be tried again if it's not the first time the view appeared
            updateView()
        }
        #endif
        
        // Only segue automatically if adding and when first appearing
        if !viewDidAppear && engine == nil {
            viewDidAppear.toggle()
            performSegue(withIdentifier: SegueKeys.urlDetails, sender: nil)
        }
    }
    
    
    /// Generates an engine name based on the domain name.
    ///
    /// - Parameter url: The URL, as a string.
    /// - Returns: A string, if the URL can be parsed correctly, otherwise `nil`.
    func makeEngineName(from url: String) -> String? {
        // Get the host from the URL string, otherwise return nil
        guard let components = URLComponents(string: url),
            let host = components.host else {
            print(.x, "Failed to get host from URL.")
            return nil
        }
        
        // Split the host into an array by periods AND hyphens
        var array = host.components(separatedBy: CharacterSet(charactersIn: ".-"))
        
        if array.isEmpty {
            return nil
        } else if array.count == 1 {
            // In the unlikely case of no period (like "localhost"), just capitalize that
            return array.first!.capitalized
        } else {
            // So long as there is more than one piece, delete the last item in the array (e.g. "com")
            array.removeLast()
            // If there is still more than one piece AND the first is www (e.g. wasn't "www.com"), delete the first item
            if array.count > 1 && array.first == "www" {
                array.removeFirst()
            }
            // Remove "m" (mobile)
            if array.count > 1 {
                array.removeAll { $0 == "m" }
            }
            // Set name as array items Capitalized and concatenated by spaces
            return array.joined(separator: " ").capitalized
        }
    }
    
    /// Generates a shortcut based on the first character(s) of the engine name.
    ///
    /// - Returns: A string of lowercase letter(s), if possible, otherwise `nil`.
    func makeEngineShortcut() -> String? {
        // Create an array from the (lowercase) name field
//        guard let name = nameTextField.text?.lowercased() else {
        guard let name = nameTextField.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
            print(.x, "Could not generate shortcut because name could not be read.")
            return nil
        }
        let nameCharacters = Array(name)
        
        var shortcut = ""
        
        // Add characters from the name one by one
        for character in nameCharacters {
            // Skip over spaces
            if character == " " { continue }
            
            shortcut += String(character)
            
            // Once the shortcut is unique, stop adding characters
            if shortcutIsValid(shortcut) { break }
        }
        
        // TODO: Add incremental number until unique

        print(.o, "Automatically set shortcut to \"\(shortcut)\".")
        
//        // Update icon label
//        shortcutChanged()
        
        return shortcut
    }
    
    
    /// Update save button when name field is changed.
    @IBAction func nameChanged(_ sender: UITextField) {
        // TODO: Check that name does not conflict with other names
        updateSaveButton()
    }

    
    /// Update the shortcut text field colour, and icon label when the shortcut changes if there's no image.
    @IBAction func shortcutChanged() {
        // Make sure any user-entered shortcut never contains spaces
        shortcutTextField.text = shortcutTextField.text?.components(separatedBy: .whitespacesAndNewlines).joined()
        
//        print(.n, "Parent: \"Shortcut changed.\"")
        // Set icon label to reflect shortcut, but only if there's no image already supplied
        if engineIconImage.image == nil,
            let shortcut = shortcutTextField.text {
            engineIconLabel.setLetter(using: shortcut)
        }

        // Set text colour based on validity
        // Also, update the save button
        if shortcutIsValid() {
            print(.o, "Shortcut is valid.")
            shortcutTextField.textColor = .black
            updateSaveButton()
        } else {
            print(.n, "Shortcut is invalid.")
            shortcutTextField.textColor = .red
            saveButton.isEnabled = false
        }
    }


    /// Checks that a shortcut can be used.
    ///
    /// - Returns: Returns `true` if the shortcut has at least one character, none of which are invalid for a filename, and that no other engine uses this shortcut.
    func shortcutIsValid(_ shortcut: String? = nil) -> Bool {
        var shortcutToCheck = shortcut
        
        // Check against the shortcut text field if no argument is passed
        if shortcutToCheck == nil {
            shortcutToCheck = shortcutTextField.text
        }
        
        if let shortcut = shortcutToCheck,
            !shortcut.isEmpty,
            shortcut.isValidFileName(),
            !(allOtherShortcuts?.contains(shortcut) ?? allShortcuts?.contains(shortcut) ?? false) {
            // The above line is a hack now, but basically it should never get to "false"
            return true
        } else {
            return false
        }
    }
    
    // This can also be done with delegation and tags:
    //- https://stackoverflow.com/questions/31766896/switching-between-text-fields-on-pressing-return-key-in-swift
    
    /// Moves focus to the shortcut field when return is pressed.
    @IBAction func nameTextFieldReturnKeyPressed() {
        shortcutTextField.becomeFirstResponder()
    }
    
    /// Hide the keyboard when pressing the return key.
    @IBAction func shortcutTextFieldReturnKeyPressed() {
//        shortcutTextField.resignFirstResponder()
        shortcutTextField.endEditing(true)
    }
    
    
    /// Dim the engine icon when the engine is disabled.
    ///
    /// - Parameter sender: The UISwitch which triggered this function. This parameter is optional and defaults to `nil`, so programatic calls can omit it. Note that providing a sender updates the save button, while omitting the parameter does not trigger an update.
    @IBAction func enabledToggleChanged(_ sender: UISwitch? = nil) {
        if enabledToggle.isOn {
            engineIconView.alpha = 1
        } else {
            engineIconView.alpha = 0.5
        }
        
        if sender != nil { updateSaveButton() }
    }
    

    /// Enable the save button when all fields are filled out correctly.
    func updateSaveButton() {
        // Checking for nil engine will ensure URL has been set when adding engine
        if engine != nil,
            nameTextField.text != "",
            shortcutIsValid() {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    
    // MARK: - Delegate functions
    
    // Determine if the URL should really be changed, based on whether or not it is valid
    func updateUrlDetails(baseUrl: URL?, queries: [String: String]) {
        print(.n, "Called updateUrlDetails with baseUrl \"\(baseUrl?.absoluteString ?? "nil")\" and queries \"\(queries)\" while updatedUrlReceived is \(didReceiveUpdatedUrl).")
        
        // Set up the two possibilities for the label
        let changedText: String
        
        // Use slightly different wording when adding or editing engine
        if engine == nil {
            changedText = NSLocalizedString("AddEditEngine.urlDetails-Saved", comment: "URL added for new engine.")
        } else {
            changedText = NSLocalizedString("AddEditEngine.urlDetails-Changed", comment: "URL of existing engine changed.")
        }
        
        // If url isn't nil, note that URL has been changed (i.e. can be saved)
        if let baseUrl = baseUrl {
            print(.o, "baseUrl found; updating engine for later saving.")
            didReceiveUpdatedUrl = true
            
            // Update URL details cell right label
            urlDetailsChangedLabel.text = changedText
//            urlDetailsChangedLabel.isHidden = false
            
            // If we're adding a new engine, we need to make a fake one whose properties we can change
            if engine == nil {
                print(.o, "Creating engine object with URL and queries.")
                engine = SearchEngine(
                    name: "",
                    shortcut: "",
                    baseUrl: baseUrl,
                    queries: queries,
                    isEnabled: true)
            } else {
                // If editing, update the URL of the VC's existing engine (NOT SearchEngines/Defaults)
                engine?.baseUrl = baseUrl
                engine?.queries = queries
            }
            
            // TODO: Update save/cancel buttons to show alerts (we've drawn details on paper)
            
        } else if baseUrl == nil && !didReceiveUpdatedUrl {
            // FIXME: Does this ever actually execute?
            // Engine was modified for the first time, but it wasn't usable (i.e. can't be saved)
            print(.n, "Invalid URL entered; notifying user.")
            // Update URL details cell right label
//            urlDetailsChangedLabel.text = String(format: NSLocalizedString("AddEditEngine.urlDetails-NotUpdated", comment: "Negative form of Saved or Changed."), changedText)
            urlDetailsChangedLabel.text = NSLocalizedString("AddEditEngine.urlDetails-NotUpdated", comment: "Negative form of Saved or Changed.")
//            urlDetailsChangedLabel.isHidden = false
        }
        
        // This function is called whenever text fields change, so we'll always want to show some status
        urlDetailsChangedLabel.isHidden = false
        updateSaveButton()
        
        // If no URL was passed in but we already changed it at least once, do nothing
    }
    
    
    func updateFields(for url: String) {
        if let name = nameTextField.text,
            name.isEmpty {
            nameTextField.text = makeEngineName(from: url)
        }
        
        if let shortcut = shortcutTextField.text,
            shortcut.isEmpty {
            shortcutTextField.text = makeEngineShortcut()
            shortcutChanged()
        }
        
        updateSaveButton()
    }
    
    
    func updateIcon(for url: URL, host: String) {
        // Only look for an icon if icons from this host haven't already been scraped
        if host != mostRecentHost {
            mostRecentHost = host
            
            // Show network activity indicator
            #if !EXTENSION
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            #endif
            
            iconFetcher.fetchIcon(for: url) { (icon) in
                DispatchQueue.main.async {
                    // FIXME: We're now overriding EngineIcon functions and checks
                    //- But as they require an engine object and a saved image, what else can we do?
                    // FIXME: Mutliple calls stack up; need to cancel existing if this happens
                    // TODO: Animate this?
                    self.engineIconImage.image = icon
                    self.engineIconImage.alpha = 1
                    self.engineIconLabel.isHidden = true
                    
                    #if !EXTENSION
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    #endif
                }
                // TODO: Still need to get name and shortcut from URL!
            }
            
        }
    }
    
    
    // MARK: - Table view
    
    // Don't let the name row highlight if user taps around the isEnabled toggle
    // Set this for shortcut now as well so left/right iPad padding doesn't trigger highlight
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath {
        case Cell.engineName, Cell.shortcut:
            return false
        default:
            // Other cells should be highlighted
            return true
        }
    }
    
    // MARK: Simulate button tap for delete button
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case Cell.deleteButton:
            // Set alert
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            // Add actions
            alert.addAction(UIAlertAction(title: NSLocalizedString("AddEditEngine.deleteEngine-Remove", comment: ""), style: .destructive) { alert in
                // Perform an unwinding segue which removes the engine from the table, working copy, and saved copy
                self.performSegue(withIdentifier: SegueKeys.deleteEngineUnwind, sender: nil)
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("AddEditEngine.deleteEngine-Cancel", comment: ""), style: .cancel) { alert in
                // If the user chooses cancel, just deselect the delete row
                tableView.deselectRow(at: indexPath, animated: true)
            })
            
            // iPad only: Eminate from button
            guard let cell = tableView.cellForRow(at: indexPath) else {
                print(.x, "Failed to unwrap delete button cell.")
                return
            }
            // Assures us this is an iPad, basically
            if let popover = alert.popoverPresentationController {
                // iPad action sheet doesn't show cancel button, so add a message so it doesn't look weird
                alert.message = "This cannot be undone."
//                alert.popoverPresentationController?.sourceView = cell
//                alert.popoverPresentationController?.sourceRect = cell.bounds
                // Set centre of cell
                popover.sourceView = cell
                popover.sourceRect = cell.bounds
            }
            
            // Note: There is a constraint issue here with a width of -16 that the layout engine handles by itself in iOS 12.2. Currently this is filed as a bug:
            //- https://stackoverflow.com/questions/55372093/uialertcontrollers-actionsheet-gives-constraint-error-on-ios-12-2
            
            // Show alert
            present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    
    // MARK: - Navigation
    
    /// Dismiss the view controller when cancelling the main app. For the app extension, return to the host app.
    @IBAction func cancelButtonTapped() {
        #if EXTENSION
            returnToHostApp()
        #else
            dismiss(animated: true, completion: nil)
        #endif
    }
    
    
    /// Save the newly added engine and dismiss the view controller.
    ///
    /// In the app extension, this will return to the host app. In the main app, this will pop to the AllEngines VC and update the table view.
    @IBAction func saveButtonTapped() {
        // Check all fields and ready the final engine object
        prepareForAddEditEngineUnwind()
        
        // We should never be attempting a save with a nil engine
        guard let engine = engine else {
            print(.x, "Mistakenly allowed save button to be tapped when engine is nil.")
            return
        }
        
        print(.i, "Updating save file with engine named \(engine.name).")
        let shortcut = engine.shortcut
        
        // Add to shared object
        SearchEngines.shared.allEngines[shortcut] = engine
        
        // Update save data
        SearchEngines.shared.saveEngines()
        
        // Save icon, if found
        if let icon = engineIconImage.image {
            saveIcon(icon)
        }
        
        #if EXTENSION
            // Tell main app it needs to refresh data when returned to foreground
            UserDefaults(suiteName: AppKeys.appGroup)?.set(true, forKey: SettingsKeys.extensionDidChangeData)
        
            returnToHostApp()
        #else
            // Main app must pass engine object via unwind in order to update AllEngines table
            performSegue(withIdentifier: SegueKeys.addEditEngineUnwind, sender: self)
        #endif
    }
    
    // TODO: This is copied from SearchEngine copyDefaultImages(); refactor
    func saveIcon(_ icon: UIImage) {
        // We will save icon images to the folder "Icons" in the user directory
        guard let userImagesUrl = DirectoryKeys.userImagesUrl else {
            print(.x, "Failed to unwrap user images URL.")
            return
        }
        
        if FileManager.default.fileExists(atPath: userImagesUrl.path) {
            print(.i, "Found user images directory at \(userImagesUrl).")
        } else {
            // Try to create the directory
            do {
                try FileManager.default.createDirectory(at: userImagesUrl, withIntermediateDirectories: true, attributes: nil)
                print(.o, "Created user images directory at \(userImagesUrl).")
            } catch {
                print(.x, "Could not locate user images directory at \(userImagesUrl) and subsequently failed to create it; error: \(error)")
            }
        }
        
        // All images are named after the search shortcut
        guard let imageName = engine?.shortcut else {
            print(.x, "Could not save icon image because engine doesn't appear to have a shortcut.")
            return
        }
        
        let destinationPath = userImagesUrl.appendingPathComponent(imageName)
        
        // Convert PNG to raw data
        // TODO: Will this take care of .ico?
        if let data = icon.pngData() {
            // Try to write data to user directory
            do {
                try data.write(to: destinationPath)
                print(.o, "Saved image to \(destinationPath).")
            } catch {
                print(.x, "Failed to write image data to user directory; error: \(error)")
            }
        } else {
            print(.x, "Failed to convert image to PNG data.")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(.n, "Preparing for segue.")

        if segue.identifier == SegueKeys.urlDetails {
            prepareForUrlDetailsSegue(segue)
        }
        
    }
    
    
    /// Update the engine object to include data from all fields.
    ///
    /// In the main app, this function should be called during the `prepare(for:)` segue function. In the action extension, which doesn't unwind, call this directly.
    func prepareForAddEditEngineUnwind() {
        // baseUrl and queries should be included in `engine != nil` (SearchEngine can't have nil baseUrl/queries)
        guard engine != nil,
            let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let shortcut = shortcutTextField.text else {
                print(.x, "Error detecting engine or reading user entered information.")
                return
        }
        
        print(.o, "Updating saveable engine with name \"\(name)\" and shortcut \"\(shortcut)\".")
        
        // Update the object to be updated in the model in the all engines table
        engine?.name = name
        engine?.shortcut = shortcut
        engine?.isEnabled = enabledToggle.isOn
        
        
        // TODO: If we aren't going to continue looking for icons after this is dismissed, kill icon fetcher
        // URLSession.shared.invalidateAndCancel()
    }
    
    
    /// Pass additional data from the host app when executing inside an app extension.
    ///
    /// - Parameter segue: The segue about to be performed.
    func prepareForUrlDetailsSegue(_ segue: UIStoryboardSegue) {
        // Send engine to next view for editing the URL
        guard let destination = segue.destination as? UrlDetailsTableViewController else {
            print(.x, "Attempted to perform UrlDetailsSegue to wrong view.")
            return
        }
        destination.delegate = self
        
        // If we're using details from an incomplete OpenSearch attempt, use that URL.
        // In the case of the app extension, this will pass the URL scraped from the host, if available.
        // If the engine already exists (main or extension), engine's URL will be passed.
        if let openSearch = openSearch,
            let openSearchUrl = openSearch.url,
            engine == nil {
            destination.openSearchUrl = openSearchUrl.absoluteString
        } else if engine == nil {
            destination.hostAppUrlString = hostAppUrlString
        } else {
            destination.engine = engine
        }
    }
    

}
