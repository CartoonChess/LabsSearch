//
//  DefaultEngineTableViewController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/25.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

/// Delegates that adopt this protocol will receive a `SearchEngine` object intended to be sent to `UserDefaults` as the default engine.
protocol DefaultEngineTableViewControllerDelegate: class {
    /// Assign the passed engine to the default engine in `UserDefaults`.
    ///
    /// - Parameter engine: The search engine the user selected to be the default.
    func didSelectDefaultEngine(_ engine: SearchEngine)
}

/// Shows a simple list of all engines so that the user can select the default engine.
class DefaultEngineTableViewController: EngineTableViewController {
    
    var selectedEngine: SearchEngine? = SearchEngines.shared.defaultEngine
    var selectedEngineCell: UITableViewCell?
    weak var delegate: DefaultEngineTableViewControllerDelegate?


    // MARK: - Table view data source
    
    // We have to override the EngineTableViewController so we can exclude disabled engines
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return engines.count
        return enabledShortcuts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellKeys.defaultEngineTable, for: indexPath) as! EngineTableViewCell
        
        // Perform all setup necessary before displaying row
        prepareCell(cell, at: indexPath)
        
        // Show the checkmark if this is the default
        if let defaultEngine = selectedEngine,
//            engines[shortcuts[indexPath.row]]?.shortcut == defaultEngine.shortcut {
            enabledShortcuts[indexPath.row] == defaultEngine.shortcut {
            print(.o, "Showing checkmark in default engine cell.")
            cell.accessoryType = .checkmark
            selectedEngineCell = cell
        } else {
            // This prevents "phantom" checkmarks from showing in reused cells while scrolling
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
    // MARK:- Table view display
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform deselect row animation
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Hide checkmark from previously selected row
        if let oldDefaultEngineCell = selectedEngineCell {
            print(.o, "Removing checkmark from previous selection.")
            oldDefaultEngineCell.accessoryType = .none
        }
        
        // Show checkmark accessory for newly selected row
        selectedEngineCell = tableView.cellForRow(at: indexPath)
        selectedEngineCell?.accessoryType = .checkmark
        
        // Update default engine in local view with var and defaults using delegate
        if let engine = engines[enabledShortcuts[indexPath.row]] {
            selectedEngine = engine
            delegate?.didSelectDefaultEngine(engine) //*
            // Note: We hit a critical error trying to unwrap an optional here
            //- It occurred when touching a define engine cell after increasing system font size
            //- Note that the settings table labels disappear before this
            //- However, we've been unable to reproduce this.
        }
    }

}
