//
//  SettingsTableViewController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/19.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, DefaultEngineTableViewControllerDelegate {
    
//    let defaults = UserDefaults.standard
    let defaults = UserDefaults(suiteName: AppKeys.appGroup)
    let fileManager = FileManager.default
    
    // Tell the view in which section of the table each setting is displayed
    // TODO: Replace this with enum a la other tables
    let sections = [
        SettingsKeys.stayInApp: 0
    ]
    
    enum Section {
        static let stayInApp = 0
        static let developerSettings = 2
    }
    
    enum Cell {
        static let exportEngines: IndexPath = [Section.developerSettings, 0]
        static let resetApp: IndexPath = [Section.developerSettings, 1]
    }
    
    @IBOutlet weak var stayInAppSwitch: UISwitch!
    @IBOutlet weak var defaultEngineNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the navigation bar in the settings view
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Show default engine. We call this whenever the view appears in case add/edit changed this
        // Note: Where is the "gray" option in IB? This label was set to greyscale 50%...
        defaultEngineNameLabel.text = SearchEngines.shared.defaultEngine?.name ?? NSLocalizedString("Settings.defaultEngineNameLabel-Choose", comment: "")
    }
    
    
    /// Load user's settings to the view
    func loadSettings() {
        // This check returns false whether set by the user or simply nonexistent
//        stayInAppSwitch.isOn = defaults.bool(forKey: SettingsKeys.stayInApp)
        stayInAppSwitch.isOn = defaults?.bool(forKey: SettingsKeys.stayInApp) ?? false
        updateSectionFooter(Section.stayInApp)
    }
    
    
    @IBAction func stayInAppSwitchToggled(_ sender: UISwitch) {
        updateSectionFooter(sections[SettingsKeys.stayInApp]!)
//        defaults.set(sender.isOn, forKey: SettingsKeys.stayInApp)
        UserDefaults(suiteName: AppKeys.appGroup)?.set(sender.isOn, forKey: SettingsKeys.stayInApp)
        print(.o, "Stay in app preference udpated to \(sender.isOn).")
        
    }
    
    
    // Delegate function; update the default engine when received from selection table view
    func didSelectDefaultEngine(_ engine: SearchEngine) {
        SearchEngines.shared.defaultEngine = engine
        defaultEngineNameLabel.text = engine.name
        
        // Recalculate row height in case newly selected default engine's name is longer/shorter than previous
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    
    /// Intermediate function to update section footers by disabling animation.
    ///
    /// - Parameter section: The section to update.
    func updateSectionFooter(_ section: Int) {
        // The old method involved disabling all animations, but this meant the table "jumps" when changing number of lines in label
        //UIView.setAnimationsEnabled(false)
        
        // TODO: Setting the label text directly (tableView.footerView(forSection: section)?.textLabel?.text)
        // won't account for changes in text length,
        // but overrriding the tableView(_:titleForFooterInSection) method means it is called
        // with every pixel scroll! Is this expected behaviour or a major performance hit??
        
        // The old and new footers briefly coexist, so hide the old one before updating
        tableView.footerView(forSection: section)?.isHidden = true
        tableView.reloadSections([section], with: .none)
        // Note that having animation will hide the cell:
        //- https://stackoverflow.com/a/20491576/
        
        // Renable animations - no longer in use (see above)
        //UIView.setAnimationsEnabled(true)
    }
    
    
    // MARK: - Debug features
    
    // TODO: These features, like so many other things now, are bloating up our VCs
    //- We should move various functions into pure controllers perhaps
    
    
    /// Opens the system share sheet to export the engines plist.
    ///
    /// - Parameter sender: The table cell the user touched to initiate this function. Useful for iPad layouts.
    ///
    /// This is intended for debug mode only.
    func exportEngines(sender: UITableViewCell) {
        // We have to make a copy of allEngines with the terms placeholder obscured
        // However, we can't put in a URL-illegal string, but we also don't want something reproducable
        // Therefore, each export will generate its own random string to replace the placeholder
        // A dummy engine will be added to the array (using the illegal shortcut " ")
        // It will contain the randomized placeholder, so that this can be checked for importing later
        
        // Create the random placeholder
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let censoredPlaceholder = String((0...20).map{_ in characters.randomElement()!})
        
        // Create a copy of allEngines with the placeholder changed
        var censoredEngines = [String: SearchEngine]()
        
        for (_, engine) in SearchEngines.shared.allEngines {
            // Censor placeholder in base URL
            let censoredBaseUrl = engine.baseUrl.absoluteString.replacingOccurrences(of: SearchEngines.shared.termsPlaceholder, with: censoredPlaceholder)
            
            // If for some reason we can't replace the placeholder, just skip the engine
            //- Sorry, engine.
            guard let baseUrl = URL(string: censoredBaseUrl) else {
                print(.x, "Problem removing terms placeholder in engine \"\(engine.name)\".")
                continue
            }
            
            // Recreate engine with URL and queries censored
            let censoredEngine = SearchEngine(
                name: engine.name,
                shortcut: engine.shortcut,
                baseUrl: baseUrl,
                queries: engine.queries.withValueReplaced(SearchEngines.shared.termsPlaceholder, replaceWith: censoredPlaceholder),
                isEnabled: engine.isEnabled)
            censoredEngines[censoredEngine.shortcut] = censoredEngine
        }
        
        // Add a dummy engine that contains the randomized placeholder as the name
        censoredEngines[" "] = SearchEngine(name: censoredPlaceholder, shortcut: " ", baseUrl: URL(string: "http://example.com")!, queries: [:], isEnabled: false)
        
        // Create plist data from allEngines with the terms placeholder obscured
        // TODO: When/if an import function is written, this obfuscation will have to be reversed
        
        let propertyListEncoder = PropertyListEncoder()
        do {
            let encodedEngines = try propertyListEncoder.encode(censoredEngines)
            print(.i, "Engines successfully encoded.")
            
            // Create temporary plist file
            let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let temporaryFile = temporaryDirectory.appendingPathComponent("engines").appendingPathExtension("plist")
            try encodedEngines.write(to: temporaryFile, options: .noFileProtection)
            print(.i, "Saved censored engines to temporary file.")
        
            // Create the activity controller with the archive data to pass
            let activityController = UIActivityViewController(activityItems: [temporaryFile], applicationActivities: nil)
            
            // iPad only: Eminate from button (fatal error if omitted)
            activityController.popoverPresentationController?.sourceView = sender
            // And make it come from the center of the button
            activityController.popoverPresentationController?.sourceRect = sender.bounds

            present(activityController, animated: true, completion: nil)
        } catch {
            print(.x, "Failed to encode engines to plist format; error: \(error)")
        }
    }
    
    
    /// This is only intended for debug mode. It will reset all preferences and load the default engines.
    func resetApp() {
        // Remove all preferences
//        if let appDomain = Bundle.main.bundleIdentifier {
//            defaults.removePersistentDomain(forName: appDomain)
//        } else {
//            print(.x, "Failed to delete preferences file.")
//        }
        defaults?.removePersistentDomain(forName: AppKeys.appGroup)
        
        // Set up some standard preferences
//        defaults.set(false, forKey: SettingsKeys.stayInApp)
        defaults?.set(false, forKey: SettingsKeys.stayInApp)
        
        // Delete Icons folder
//        if fileManager.fileExists(atPath: DirectoryKeys.userImagesUrl.path) {
        if let userImagesUrl = DirectoryKeys.userImagesUrl,
//            fileManager.fileExists(atPath: DirectoryKeys.userImagesUrl.path) {
            fileManager.fileExists(atPath: userImagesUrl.path) {
            do {
//                try fileManager.removeItem(at: DirectoryKeys.userImagesUrl)
                try fileManager.removeItem(at: userImagesUrl)
                print(.o, "Icons folder deleted.")
            } catch {
                print(.x, "Icons folder could not be deleted; error: \(error)")
            }
        } else {
            print(.x, "Icons folder could not be deleted because it was not found in the user directory.")
        }
        
        // Delete user's engine archive
//        if fileManager.fileExists(atPath: DirectoryKeys.userEnginesUrl.path) {
        if let userEnginesUrl = DirectoryKeys.userEnginesUrl,
            fileManager.fileExists(atPath: userEnginesUrl.path) {
            do {
//                try fileManager.removeItem(at: DirectoryKeys.userEnginesUrl)
                try fileManager.removeItem(at: userEnginesUrl)
                print(.o, "Engines archive deleted.")
            } catch {
                print(.x, "Engines archive could not be deleted; error: \(error)")
            }
        } else {
            print(.x, "Engines archive could not be deleted because it was not found in the user directory.")
        }
        
        // Replace all engines, icons, and default engine with app defaults
        SearchEngines.shared.loadEngines()
    }
    
    
    // MARK: - Table view methods
    
    // Show or hide the developer row
    //- Do we want to allow beta testers to use this?
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Set the default to be safe
        var numberOfSections = 2
        
        #if DEBUG || TEST
            numberOfSections = 3
        #endif
        
        return numberOfSections
    }
    
    // Update the footer (explanatory subtitle) for specified sections
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case Section.stayInApp:
            if stayInAppSwitch.isOn {
                return NSLocalizedString("Settings.stayInAppFooter-On", comment: "")
            } else {
                return NSLocalizedString("Settings.stayInAppFooter-Off", comment: "")
            }
        default:
            // We have to let this fail silently because it's called every time the view scrolls...
            return nil
        }
    }
    
    
    // Don't highlight rows when they're tapped
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        
        // Some cells shouldn't show highlighting; default is to show
        switch (section, row) {
        case (Section.stayInApp, _):
            return false
        default:
            return true
        }
    }
    
    
    // Simulate button tap for developer buttons
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case Cell.exportEngines:
            guard let cell = tableView.cellForRow(at: indexPath) else {
                print(.x, "Failed to unwrap export engines cell.")
                return
            }
            
            exportEngines(sender: cell)
            tableView.deselectRow(at: indexPath, animated: true)
            
        case Cell.resetApp:
            // Set alert
            let alert = UIAlertController(title: NSLocalizedString("Settings.resetAppAlert-Title", comment: ""), message: NSLocalizedString("Settings.resetAppAlert-Message", comment: ""), preferredStyle: .alert)
            // Add actions
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings.resetAppAlert-Reset", comment: ""), style: .destructive) { alert in
                // This throws a small error is we don't force it onto the main thread
                DispatchQueue.main.async {
                    self.resetApp()
                    self.navigationController?.popViewController(animated: true)
                }
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings.resetAppAlert-Cancel", comment: ""), style: .cancel) { alert in
                // If the user chooses cancel, just deselect the row
                tableView.deselectRow(at: indexPath, animated: true)
            })
            // Show alert
            present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueKeys.defaultEngine {
            // Get the new view controller using segue.destination
            let destination = segue.destination as! DefaultEngineTableViewController
            // Pass necessary objects to the new view controller
            destination.delegate = self
        }
    }

}
