//
//  EngineTableViewController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/25.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

/*
 * BIG CRAZY NOTE
 *
 * Current Swift practices tell us we should do this as a protocol, not a super class.
 * However, for the sake of practice (heh), we're going to subclass this.
 *
 */

import UIKit

/// Shows a list of all search engines.
///
/// As of the current implementation, this view should not be used directly, but rather, subclassed.
class EngineTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    // TODO: Is this... bad form?
    var engines = SearchEngines.shared.allEngines
    var shortcuts = SearchEngines.shared.allShortcuts
    var enabledShortcuts = SearchEngines.shared.enabledShortcuts
    var disabledShortcuts = SearchEngines.shared.disabledShortcuts

    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(.d, "shortcuts: \(shortcuts)")
//        print(.d, "enabledShortcuts: \(enabledShortcuts)")
//        print(.d, "disabledShortcuts: \(disabledShortcuts)")
        
        // FIXME: This is supposed to allow custom cells to shrink on iPad, but it's not working
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // If action extension added an engine, we need to reload the table
        // This watches for every time the main app enters the foreground on an engine table VC
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    /// Check for updated data when returning from another app, and reload the table if necessary.
    @objc func willEnterForeground() {
        print(.d, "(EngineTable) VC will enter foreground!")
        if let extensionDidChangeData = UserDefaults(suiteName: AppKeys.appGroup)?.bool(forKey: SettingsKeys.extensionDidChangeData),
            extensionDidChangeData {
            
            print(.i, "Reloading table to reflect changes made by the action extension.")
            // This is hacky, but it updates the VC's copy of the engines list to match the global copy
            engines = SearchEngines.shared.allEngines
            shortcuts = SearchEngines.shared.allShortcuts
            enabledShortcuts = SearchEngines.shared.enabledShortcuts
            disabledShortcuts = SearchEngines.shared.disabledShortcuts
            
            tableView.reloadData()
        }
        print(.d, "(EngineTable) VC will enter foreground - with \(SearchEngines.shared.allShortcuts)!")
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return engines.count
    }
    
    /// Creates a table row. This function should be fully overridden without calling to its super.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellKeys.engineTable, for: indexPath) as! EngineTableViewCell
        
        print(.i, "Setting up cell from available shortcuts: \(shortcuts)")
        
        // Perform all setup necessary before displaying row
        prepareCell(cell, at: indexPath)
        
        return cell
    }
    
    func prepareCell(_ cell: EngineTableViewCell, at indexPath: IndexPath) {
        var shortcuts = self.shortcuts
        
        // List all engines or just enabled ones, depending on the view controller
        switch self {
        case is DefaultEngineTableViewController:
            shortcuts = enabledShortcuts
        case is AllEnginesTableViewController:
            // Check if we're in enabled or disabled section
            switch indexPath[0] {
            case 0:
                // Enabled engines
                shortcuts = enabledShortcuts
                break
            case 1:
                // Disabled engines
                shortcuts = disabledShortcuts
                break
            default:
                print(.x, "Attempting to load cells for a nonexistant section.")
                return
            }
        default:
//            let engine = engines[shortcuts[indexPath.row]]
            print(.x, "Attempted to load EngineTableViewCell in unsupported view controller.")
            break
        }
        
        // Get engine info from engines object
//        guard let engine = engines[shortcuts[indexPath.row]] else {
//            print(.x, "Failed to unwrap engine for cell.")
//            return
//        }
        let engine = engines[shortcuts[indexPath.row]]
        
        
        // Configure the cell
        // Cell class's engine property uses didSet to configure after setting engine here
        cell.engine = engine
    }
    
}
