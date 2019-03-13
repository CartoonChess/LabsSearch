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
class AllEnginesTableViewController: EngineTableViewController {
    
    // This VC can receive the details of an OpenSearch from the OpenSearch VC
    //- It will then pass the object on to AddEdit via viewDidAppear
    var openSearch: OpenSearch? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // In case we're coming back from OpS VC, kill the activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // If an OpS engine is received, segue immediately to AddEdit VC
        if openSearch != nil {
            performSegue(withIdentifier: SegueKeys.addEngine, sender: nil)
        }
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellKeys.allEnginesTable, for: indexPath) as! AllEnginesTableViewCell
        
        // Perform all setup necessary before displaying row
        prepareCell(cell, at: indexPath)
        
        return cell
    }
    
    
    // MARK: - Table data update functions
    
    // TODO: We might merge these functions with an `action` parameter, and/or move .shared/defaults logic into SearchEngines
    //- We could do this just by testing for nil on the two parameters, but that would be less semantically clear...
    
    // TODO: We also reuse a lot of code from functions like getImage(), so consider refactoring
    
    // TODO: Ask SOf how to improve this dumpster fire
    //- https://codereview.stackexchange.com/
    
    func addEngine(_ engine: SearchEngine) {
        // Model updates are all performed before the segue in AddEdit VC
        
        // Add to table view
        engines[engine.shortcut] = engine
        shortcuts = SearchEngines.shared.allShortcuts // preserves alpha-order
        tableView.reloadData()
    }
    
    func updateEngine(_ engineBeforeUpdates: SearchEngine, to engineAfterUpdates: SearchEngine, at indexPath: IndexPath) {
        print(.o, "Updating engine \(engineAfterUpdates.name).")

        // Update in shared object
        let oldShortcut = engineBeforeUpdates.shortcut
        SearchEngines.shared.allEngines.removeValue(forKey: oldShortcut)
        SearchEngines.shared.allEngines[engineAfterUpdates.shortcut] = engineAfterUpdates
        
        // Update in table view
        shortcuts = SearchEngines.shared.allShortcuts // preserves alpha-order
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
            print(.n, "Changed default engine shortcut; updating default engine settings.")
            SearchEngines.shared.defaultEngine = engineAfterUpdates
        }
    }
    
    func deleteEngine(_ engine: SearchEngine, at indexPath: IndexPath) {
        print(.o, "Deleting engine \(engine.name).")
        // TODO: Error messages?
        
        // Remove from shared object
        SearchEngines.shared.allEngines.removeValue(forKey: engine.shortcut)
        
        // Remove from table view
        engines.removeValue(forKey: engine.shortcut)
        guard let index = shortcuts.index(of: engine.shortcut) else {
            print(.x, "Could not find shortcut in shortcuts array.")
            return
        }
        shortcuts.remove(at: index)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        // Update save data
        SearchEngines.shared.saveEngines()
        
        // Delete icon, if it exists
        let imageUrl = DirectoryKeys.userImagesUrl?.appendingPathComponent(engine.shortcut)
        
        if let imageUrl = imageUrl,
            FileManager.default.fileExists(atPath: imageUrl.path) {
            do {
                try FileManager.default.removeItem(at: imageUrl)
                print(.o, "Deleted icon image for engine \(engine.name).")
            } catch {
                print(.x, "Icon image could not be deleted; error: \(error)")
            }
        } else {
            print(.n, "No matching image was found, so we are not trying to delete one.")
        }
        
        // Handle cases where the user deletes the last engine or the default engine
        
        let allEngines = SearchEngines.shared.allEngines
        
        // If we've deleted the last engine, load the defaults
        if allEngines.count == 0 {
            // TODO: This doesn't refresh the view until we go out and return to it;
            //- Anyway, we should have a more elegant approach to having no engines
            //- (plus, we will likely make the default engines only hideable, not deleteable)
            print(.n, "Deleted last engine; loading defaults.")
            SearchEngines.shared.loadEngines()
            tableView.reloadData()
//        } else if UserDefaults.standard.string(forKey: SettingsKeys.defaultEngineShortcut) == engine.shortcut {
        } else if UserDefaults(suiteName: AppKeys.appGroup)?.string(forKey: SettingsKeys.defaultEngineShortcut) == engine.shortcut {
            // If this is the default engine, reflect our shared object (updates preferences automatically)
            // TODO: We should handle default engine logic elsewhere; this is temporary
            print(.n, "Deleted default engine; setting next available engine as new default.")
            SearchEngines.shared.defaultEngine = allEngines.first?.value
        }
    }
    
    
     // MARK:- Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Maybe we should have one segue and look for a selected cell instead
        // Actually, with no data to pass, AddEngineSegue is all handled through the storyboard
        
        guard let destinationNavigationController = segue.destination as? UINavigationController else {
            print(.x, "Attempted to segue from AllEngines VC to wrong view.")
            return
        }
        
        if let _ = destinationNavigationController.topViewController as? OpenSearchTableViewController {
            // No special prep required
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
            case SegueKeys.addEngine:
                print(.o, "Segueing to AddEdit view using OpenSearch engine named \"\(openSearch?.name ?? "nil")\".")
                destination.openSearch = openSearch
                // Set AllEngine view's copy to nil so that it doesn't loop when AddEdit is dismissed
                openSearch = nil
            default:
                print(.x, "Attempted to perform segue with no identifier.")
            }
            
        } else {
                print(.x, "OpenSearch or AddEdit view controller could not be loaded.")
                return
        }
        
    }
    
    
    @IBAction func unwindToAllEnginesTable(segue: UIStoryboardSegue) {
        print(.n, "Unwinding to AllEngines view.")
        
//        // First, copy over the OpS engine object if coming back from the VC and the object exists
//        if let source = segue.source as? OpenSearchTableViewController {
//            openSearch = source.openSearch
//            return
//        }
        
        // First, copy over the OpS engine object if coming back from the VC and the object exists
        if let source = segue.source as? OpenSearchTableViewController {
            switch segue.identifier {
            case SegueKeys.cancelOpenSearchUnwind:
                print(.i, "Cancelled adding via OpenSearch.")
            case SegueKeys.skipOpenSearchUnwind:
                // If user tapped skip button, segue to AddEdit VC with dummy object
                openSearch = OpenSearch(name: "", url: nil)
            default:
                // An OpS search was attempted, so pass the OpS object to AddEdit
                openSearch = source.openSearch
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
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    // Save name for comparison
                    guard let engineBeforeUpdates = engines[shortcuts[selectedIndexPath.row]]  else {
                        print(.x, "Could not get engine at selected row for updates.")
                        return
                    }
                    
                    print(.n, "Applying updates to \(engineBeforeUpdates.name).")
                    updateEngine(engineBeforeUpdates, to: engineAfterUpdates, at: selectedIndexPath)
                    
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
            guard let selectedIndexPath = tableView.indexPathForSelectedRow,
                let engine = engines[shortcuts[selectedIndexPath.row]] else {
                print(.x, "Failed to detect engine at cell or unwrap engine for deletion.")
                return
            }
            
            print(.n, "Deleting engine \(engine.name).")
            deleteEngine(engine, at: selectedIndexPath)
            
        default:
            // Unwind with no further action if cancel is tapped
            print(.i, "Cancel button was tapped.")
        }
        
    }
    
}
