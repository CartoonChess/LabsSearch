//
//  AllEnginesTableViewController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/28.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

import UIKit

/// Shows a list of all search engines in detail for editing.
class AllEnginesTableViewController: EngineTableViewController, AddEditEngineTableViewControllerDelegate, OpenSearchTableViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    
    // This VC can receive the details of an OpenSearch from the OpenSearch VC
    //- It will then pass the object on to AddEdit via viewDidAppear
    var openSearch: OpenSearch?
    var searchEngineEditor: SearchEngineEditor?
    
    var selectedEngine: SearchEngine? {
        get {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let cell = tableView.cellForRow(at: indexPath) as? EngineTableViewCell,
                let engine = cell.engine else {
                return nil
            }
        
            return engine
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    // FIXME: This is no longer triggered when returning from OpS VC as of iOS 13
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        // In case we're coming back from OpS VC, kill the activity indicator
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//
//        // If an OpS engine is received, segue immediately to AddEdit VC
//        if openSearch != nil {
//            performSegue(withIdentifier: SegueKeys.addEngine, sender: nil)
//        }
//    }
    
    func openSearchViewControllerDidDisappear() {
//        // Set VC vars (this is legacy; may no longer be required)
//        self.openSearch = openSearch
//        self.searchEngineEditor = searchEngineEditor
        
        // In case we're coming back from OpS VC, kill the activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // If an OpS engine is received, segue immediately to AddEdit VC
        if openSearch != nil {
            performSegue(withIdentifier: SegueKeys.addEngine, sender: nil)
        }
    }
    
    override func willEnterForeground() {
        // Take note of the selected engine, if it exists
        let selectedEngine = self.selectedEngine
        var indexPath = tableView.indexPathForSelectedRow
        
        // Update table with engine added through action extention, if applicable
        super.willEnterForeground()
        
        // We can stop here if no row had been selected
        guard let previouslySelectedEngine = selectedEngine else { return }
        
        // Newly added engines are always enabled, so the index will be the same for disabled ones
        
        if previouslySelectedEngine.isEnabled {
            // Selected engine was enabled, so it may have been offset by the newly added engine
            let shortcut = previouslySelectedEngine.shortcut
            guard let row = enabledShortcuts.firstIndex(of: shortcut) else {
                print(.x, "Failed to find previously selected engine among enabled engines.")
                return
            }
            indexPath = [0, row]
        }
        
        // Reselect engine, so edit/delete still works
        print(.i, "Reselecting engine in AllEngines VC.")
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    
    
    // MARK: - Table view data source
    
    // Divide the table between enabled and disabled engines
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Only show the second section if there are disabled engines
//        if SearchEngines.shared.disabledShortcuts.count > 0 {
//            return 2
//        } else {
//            return 1
//        }
        // We should just be able to define two sections, and the second will disappear if empty
        return 2
    }
    
    // Literally the number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Enabled engines
            return enabledShortcuts.count
        case 1:
            // Disabled engines
            return disabledShortcuts.count
        default:
            print(.x, "Too many sections returned in AllEngines table.")
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellKeys.allEnginesTable, for: indexPath) as! AllEnginesTableViewCell
        
        // Perform all setup necessary before displaying row
        prepareCell(cell, at: indexPath)
        
        return cell
    }
    
    /// Deselect the selected row when returning to the view. From iOS 13, this is necessary when returning via AddEdit VC's cancel bar button.
    func deselectRow() {
        guard let selectedRow = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedRow, animated: false)
    }
    
    
    // MARK: - Table data update functions
    
    // TODO: We might merge these functions with an `action` parameter, and/or move .shared/defaults logic into SearchEngines
    //- We could do this just by testing for nil on the two parameters, but that would be less semantically clear...
    
    // TODO: We also reuse a lot of code from functions like getImage(), so consider refactoring
    
    // TODO: Ask SOf how to improve this dumpster fire
    //- https://codereview.stackexchange.com/
    
    func addEngine(_ engine: SearchEngine) {
        // Note: Model updates are all performed before the segue in AddEdit VC
        // TODO: Maybe that's dumb?
        
        print(.i, "Adding engine \(engine.name).")
        
        // Add to table view
        engines[engine.shortcut] = engine
        // TODO: Can we take out this first line now?
        shortcuts = SearchEngines.shared.allShortcuts // preserves alpha-order
        enabledShortcuts = SearchEngines.shared.enabledShortcuts
        disabledShortcuts = SearchEngines.shared.disabledShortcuts
        tableView.reloadData()
    }
    
//    func updateEngine(_ engineBeforeUpdates: SearchEngine, to engineAfterUpdates: SearchEngine, at indexPath: IndexPath) {
    func updateEngine(to engineAfterUpdates: SearchEngine) {
        guard let engineBeforeUpdates = selectedEngine else {
                print(.x, "Failed to detect engine at selected cell or unwrap engine for deletion.")
                return
        }
        
        print(.i, "Updating engine \(engineAfterUpdates.name).")
        
        // Update in shared object
        let oldShortcut = engineBeforeUpdates.shortcut
        SearchEngines.shared.allEngines.removeValue(forKey: oldShortcut)
        SearchEngines.shared.allEngines[engineAfterUpdates.shortcut] = engineAfterUpdates
        
        // Update in table view
        shortcuts = SearchEngines.shared.allShortcuts // preserves alpha-order
        enabledShortcuts = SearchEngines.shared.enabledShortcuts
        disabledShortcuts = SearchEngines.shared.disabledShortcuts
        engines.removeValue(forKey: oldShortcut)
        engines[engineAfterUpdates.shortcut] = engineAfterUpdates
        tableView.reloadData()
        
        // Update save data
        SearchEngines.shared.saveEngines()
        
        // Update image, if necessary
        
        let oldImageUrl = DirectoryKeys.userImagesUrl?.appendingPathComponent(engineBeforeUpdates.shortcut)
        //        let newImageUrl = DirectoryKeys.userImagesUrl?.appendingPathComponent(engineAfterUpdates.shortcut)
        
        // New/updated images are saved in AddEdit; here, we only remove an image if the shortcut has changed
        if engineBeforeUpdates.shortcut != engineAfterUpdates.shortcut,
            let oldImageUrl = oldImageUrl,
            //            let newImageUrl = newImageUrl,
            FileManager.default.fileExists(atPath: oldImageUrl.path) {
            do {
                //                try FileManager.default.moveItem(at: oldImageUrl, to: newImageUrl)
                try FileManager.default.removeItem(at: oldImageUrl)
                //                print(.o, "Renamed icon image from \"\(engineBeforeUpdates.shortcut)\" to \"\(engineAfterUpdates.shortcut)\".")
                print(.o, "Deleted old icon image \"\(engineBeforeUpdates.shortcut)\".")
            } catch {
                print(.x, "Icon image could not be deleted; error: \(error)")
            }
        } else {
            print(.i, "No old icon image was found, so we are not trying to delete one.")
        }
        
        
        // If this is the default engine, reflect our shared object (updates preferences automatically)
        if UserDefaults(suiteName: AppKeys.appGroup)?.string(forKey: SettingsKeys.defaultEngineShortcut) == engineBeforeUpdates.shortcut
            && engineBeforeUpdates.shortcut != engineAfterUpdates.shortcut {
            print(.i, "Changed default engine shortcut; updating default engine settings.")
            SearchEngines.shared.defaultEngine = engineAfterUpdates
        }
    }
    
    func deleteEngine() {
        // We're going to delete the engine in the currently selected row
        guard let indexPath = tableView.indexPathForSelectedRow,
            let engine = selectedEngine else {
            print(.x, "Failed to detect engine at selected cell or unwrap engine for deletion.")
            return
        }
        
        print(.n, "Deleting engine \(engine.name).")
        // TODO: Error messages?
        
        let shortcut = engine.shortcut
        
        // Remove from shared object
        SearchEngines.shared.allEngines.removeValue(forKey: shortcut)
        
        // Remove from table view
        engines.removeValue(forKey: shortcut)
        guard let index = shortcuts.firstIndex(of: shortcut) else {
            print(.x, "Could not find shortcut in shortcuts array.")
            return
        }
        shortcuts.remove(at: index)
        enabledShortcuts.removeAll { $0 == shortcut }
        disabledShortcuts.removeAll { $0 == shortcut }
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        // Update save data
        SearchEngines.shared.saveEngines()
        
        // Delete icon, if it exists
        let imageUrl = DirectoryKeys.userImagesUrl?.appendingPathComponent(shortcut)
        
        if let imageUrl = imageUrl,
            FileManager.default.fileExists(atPath: imageUrl.path) {
            do {
                try FileManager.default.removeItem(at: imageUrl)
                print(.n, "Deleted icon image for engine \(engine.name).")
            } catch {
                print(.x, "Icon image could not be deleted; error: \(error)")
            }
        } else {
            print(.n, "No matching image was found, so we are not trying to delete one.")
        }
        
        // Note: Default engine is no longer allowed to be disabled or deleted.
    }
    
    
     // MARK:- Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Maybe we should have one segue and look for a selected cell instead
        // Actually, with no data to pass, AddEngineSegue is all handled through the storyboard
        
        guard let destinationNavigationController = segue.destination as? UINavigationController else {
            print(.x, "Attempted to segue from AllEngines VC to wrong view.")
            return
        }
        
        if let openSearchViewController = destinationNavigationController.topViewController as? OpenSearchTableViewController {
            // Assign ourselves as our own presentation delegate to know when OpS VC is dismissed by dragging
            // We will also be the delegate to receive viewDidDisappear notifications
            // This is new for iOS 13 since the new view is now presented as a popover
            destinationNavigationController.presentationController?.delegate = self
            openSearchViewController.delegate = self
        } else if let destination = destinationNavigationController.topViewController as? AddEditEngineTableViewController {
            
            switch segue.identifier {
            case SegueKeys.editEngine:
                // Detect the engine the user tapped
                guard let indexPath = tableView.indexPathForSelectedRow,
                    let cell = tableView.cellForRow(at: indexPath) as? AllEnginesTableViewCell,
                    let engine = cell.engine else {
                        print(.x, "Could not determine selected row, row's cell, or cell's engine.")
                        return
                }
                
                // Pass the selected object to the new view controller
                destination.engine = engine
                // And also make ourselves the delegate
                destination.delegate = self
            case SegueKeys.addEngine:
                print(.o, "Segueing to AddEdit view using OpenSearch engine named \"\(openSearch?.name ?? "nil")\".")
                destination.openSearch = openSearch
                if let searchEngineEditor = searchEngineEditor {
                    destination.searchEngineEditor = searchEngineEditor
                }
                // Set AllEngine view's copy to nil so that it doesn't loop when AddEdit is dismissed
                openSearch = nil
                searchEngineEditor = nil
            default:
                print(.x, "Attempted to perform segue with no identifier.")
            }
            
        } else {
                print(.x, "OpenSearch or AddEdit view controller could not be loaded.")
                return
        }
        
    }
    
    // Calls when OpS is dismissed via dragging down (new for iOS 13)
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print(.i, "Presented view controller dismissed (iOS 13+).")
        openSearch = nil
        searchEngineEditor = nil
    }
    
    
    @IBAction func unwindToAllEnginesTable(segue: UIStoryboardSegue) {
        print(.i, "Unwinding to AllEngines view.")
        
        // First, copy over the OpS engine object if coming back from the VC and the object exists
        if let source = segue.source as? OpenSearchTableViewController {
            switch segue.identifier {
            case SegueKeys.cancelOpenSearchUnwind:
                print(.i, "Cancelled adding via OpenSearch.")
                // Set OpS vars to nil, just in case the user somehow cancelled after they were created
                openSearch = nil
                searchEngineEditor = nil
            case SegueKeys.skipOpenSearchUnwind:
                // If user tapped skip button, segue to AddEdit VC with entered URL, if available
                openSearch = OpenSearch(name: "", url: source.url)
                searchEngineEditor = source.searchEngineEditor
            default:
                // An OpS search was attempted, so pass the OpS object to AddEdit
                openSearch = source.openSearch
                searchEngineEditor = source.searchEngineEditor
            }
            // Don't execute AddEdit segues below
            return
        }
        
        // If we aren't coming back from OpS VC, make sure it's AddEdit
        guard let source = segue.source as? AddEditEngineTableViewController else {
            print(.x, "Error returning from add/edit engine view.")
            return
        }
        
        switch segue.identifier {
        case SegueKeys.addEditEngineUnwind:
            // This could be an edit or adding a new engine
            // Get the engine
            if let engineAfterUpdates = source.engine {
                // If a row was selected in the all engines table, this is an edit
                if tableView.indexPathForSelectedRow != nil {
                    // Save name for comparison
                    
                    updateEngine(to: engineAfterUpdates)
                    
                    // TODO: When updating/adding/deleting, if that shortcut is still in the main screen search field, that doesn't make any sense
                    //- Clear search field automatically when returning from settings view aka viewWillAppear?
                    //- Clear when allEngines has been updated?
                    //- Be really intense and compare the search field string to any changes which would have impacted it?
                } else {
                    // Adding a new engine
                    addEngine(engineAfterUpdates)
                }
            } else {
                print(.x, "Failed to unwrap engine passed from add/edit view.")
            }
        case SegueKeys.deleteEngineUnwind:
            // We're going to delete the engine in the currently selected row
            deleteEngine()
            
        default:
            // Unwind with no further action if cancel is tapped
            // Note: This never appears to actually be triggered
            print(.i, "Cancel button was tapped.")
        }
        
    }
    
}
