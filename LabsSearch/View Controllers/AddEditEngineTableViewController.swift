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
    // Determines if a new, usable URL was passed back from the URL details VC
    var didReceiveUpdatedUrl: Bool = false
    
    // Index paths for cells
    enum Cell {
        static let deleteButton: IndexPath = [2, 0]
    }
    
    // To be assigned in viewDidLoad
    var saveButton: UIBarButtonItem!
    
    // MARK: IB properties
    
    @IBOutlet weak var engineIconView: EngineIconView!
    @IBOutlet weak var engineIconImage: EngineIconImageView!
    @IBOutlet weak var engineIconLabel: EngineIconLabel!
    
    @IBOutlet weak var nameTextField: TableViewCellTextField!
    @IBOutlet weak var shortcutTextField: TableViewCellTextField!
    
    @IBOutlet weak var urlDetailsChangedLabel: UILabel!
    
    @IBOutlet weak var deleteButtonCell: UITableViewCell!
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            // Hide the delete button
            deleteButtonCell.isHidden = true
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
            
            // Even if editing, only let corners be rounded once
            viewDidAppear = true
        }
    }
    
    // The icon can change in this view, so we must set its corners here
    override func viewWillAppear(_ animated: Bool) {
        print(.n, "view Will Appear")
        super.viewWillAppear(animated)
        if !viewDidAppear {
            updateIconCorners()
        }
    }
    
    
    // Transition immediately to URL details view if adding an engine
    // Note: This cannot be placed in viewDidLoad or visual rendering errors could creep up
    override func viewDidAppear(_ animated: Bool) {
        print(.n, "view Did Appear (parent)")
        super.viewDidAppear(animated)
        
        // Only segue automatically if adding and when first appearing
        if !viewDidAppear && engine == nil {
            viewDidAppear.toggle()
            performSegue(withIdentifier: SegueKeys.urlDetails, sender: nil)
        }
    }
    
    
    /// Update save button when name field is changed.
    @IBAction func nameChanged(_ sender: UITextField) {
        // TODO: Check that name does not conflict with other names
        updateSaveButton()
    }
    
    
//    /// Update the icon label when the shortcut changes if there's no image.
//    @IBAction func shortcutChanged(_ sender: UITextField) {
//        // FIXME: Don't let shortcuts contain characters that can't exist in filenames;
//        //- we have to use the shortcut to name and save icon images!
//
//        // TODO: When shortcut conflicts/has illegal characters, make this text red
//
//        if engine?.getImage() == nil {
//            engineIconLabel.setLetter(using: sender.text!)
//        }
//
//        updateSaveButton()
//    }
//
//
//    /// Enable the save button when all fields are filled out correctly.
//    func updateSaveButton() {
//
//        // Checking for nil engine will ensure URL has been set when adding engine
//        if engine != nil,
//            nameTextField.text != "",
//            let shortcut = shortcutTextField.text,
//            shortcut != "",
//            !(allOtherShortcuts?.contains(shortcut) ?? allShortcuts.contains(shortcut)) {
//            saveButton.isEnabled = true
//        } else {
//            saveButton.isEnabled = false
//        }
//
//    }
    
    /// Update the shortcut text field colour, and icon label when the shortcut changes if there's no image.
    @IBAction func shortcutChanged() {
        print(.n, "Parent: \"Shortcut changed.\"")
        // Set icon label to reflect shortcut, but only if there's no image already supplied
        if engine?.getImage() == nil {
            engineIconLabel.setLetter(using: shortcutTextField.text ?? "")
        }

        // Set text colour based on validity
        // Also, update the save button
        if shortcutIsValid() {
            print(.o, "Shortcut is valid.")
            shortcutTextField.textColor = .black
            updateSaveButton()
        } else {
            shortcutTextField.textColor = .red
            saveButton.isEnabled = false
        }
    }


    /// Checks that a shortcut can be used.
    ///
    /// - Returns: Returns `true` if the shortcut has at least one character, none of which are invalid for a filename, and that no other engine uses this shortcut.
    func shortcutIsValid() -> Bool {
        if let shortcut = shortcutTextField.text,
            !shortcut.isEmpty,
            shortcut.isValidFileName(),
            !(allOtherShortcuts?.contains(shortcut) ?? allShortcuts?.contains(shortcut) ?? false) {
            // The above line is a hack now, but basically it should never get to "false"
            return true
        } else {
            return false
        }
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
    
    
    // MARK: - Table view
    
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
            // Show alert
            present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueKeys.addEditEngineUnwind:
//            // baseUrl and queries should be included in `engine != nil` (SearchEngine can't have nil baseUrl/queries)
//            // TODO: Include changes for remaining parameters as we add them to the view
//            guard engine != nil,
//                let name = nameTextField.text,
//                let shortcut = shortcutTextField.text else {
//                print(.x, "Error detecting engine or reading user entered information.")
//                return
//            }
//
//            // Update the object to be updated in the model in the all engines table
//            engine?.name = name
//            engine?.shortcut = shortcut
            prepareForAddEditEngineUnwind()
        case SegueKeys.urlDetails:
            prepareForUrlDetailsSegue(segue)
        case SegueKeys.deleteEngineUnwind:
            // No action required here for delete
            print(.n, "Leaving add/edit view to delete engine \(engine?.name ?? "nil").")
            return
        default:
            // No action required for cancel
            print(.n, "Add/edit cancelled.")
            return
        }
    }
    
    /// Update the engine object to include data from all fields.
    ///
    /// In the main app, this function should be called during the `prepare(for:)` segue function. In the action extension, which doesn't unwind, call this directly.
    func prepareForAddEditEngineUnwind() {
        // baseUrl and queries should be included in `engine != nil` (SearchEngine can't have nil baseUrl/queries)
        // TODO: Include changes for remaining parameters as we add them to the view
        guard engine != nil,
            let name = nameTextField.text,
            let shortcut = shortcutTextField.text else {
                print(.x, "Error detecting engine or reading user entered information.")
                return
        }
        
        print(.o, "Updating saveable engine with name \"\(name)\" and shortcut \"\(shortcut)\".")
        
        // Update the object to be updated in the model in the all engines table
        engine?.name = name
        engine?.shortcut = shortcut
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
        destination.engine = engine
    }
    

}
