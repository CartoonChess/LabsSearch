//
//  AboutTableViewController.swift
//  Chears
//
//  Created by Xcode on ’19/05/25.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

protocol AboutTableViewControllerDelegate {
    func didUpdateDeveloperSettings()
}

class AboutTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    // We'll make the Settings VC a delegate so it can refresh its section in case we change the dev setting here
    var delegate: AboutTableViewControllerDelegate?
    
    @IBOutlet weak var developerSettingsSwitch: UISwitch!
    
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set developer settings toggle
        developerSettingsSwitch.isOn = UserDefaults(suiteName: AppKeys.appGroup)?.bool(forKey: SettingsKeys.developerSettings) ?? false
    }
    
    @IBAction func developerSettingsSwitchToggled(_ sender: UISwitch) {
        print(.o, "Exerimental features preference udpated to \(sender.isOn).")
        UserDefaults(suiteName: AppKeys.appGroup)?.set(sender.isOn, forKey: SettingsKeys.developerSettings)
        
        delegate?.didUpdateDeveloperSettings()
    }
    
    
    // MARK: - Table view methods
    
    // Update the footer (explanatory subtitle) for specified sections
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return String(format: NSLocalizedString("Settings.about-Footer", comment: "Paragraph breaks (two slash-n's) should be left in, with no spaces around them."), AppKeys.appName)
        default:
            // We have to let this fail silently because it's called every time the view scrolls...
            return nil
        }
    }
    
    
    // Don't highlight rows when they're tapped
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
