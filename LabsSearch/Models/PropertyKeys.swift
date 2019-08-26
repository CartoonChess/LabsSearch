//
//  PropertyKeys.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/20.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

/// Strings useful globally.
struct AppKeys {
//    static let appName = NSLocalizedString("LabsSearch.appName", comment: "")
    static let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "LabsSearch"
    static let appExtensionName = Bundle.init(path: Bundle.main.bundlePath + "/PlugIns/LabsSearchAddEngineAction.appex")?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Add Engine"
    static let appGroup = "group.com.distantlabs.LabsSearch"
}

/// Contains some useful URLs.
struct DirectoryKeys {
//    static let userEnginesUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("engines").appendingPathExtension("plist")
//    static let userImagesUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Icons", isDirectory: true)
    static let userEnginesUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppKeys.appGroup)?.appendingPathComponent("Documents").appendingPathComponent("engines").appendingPathExtension("plist")
    static let userImagesUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppKeys.appGroup)?.appendingPathComponent("Documents/Icons", isDirectory: true)
}

/// Contains unchanging key names for all in-app settings.
struct SettingsKeys {
    // Will trigger the intro scene when set to false
    static let introComplete = "IntroComplete"
    // App extensions will set this to true when they've modified save data
    static let extensionDidChangeData = "extensionDidChangeData"
    static let defaultEngineShortcut = "DefaultEngineShortcut"
    static let stayInApp = "StayInApp"
    static let developerSettings = "DeveloperSettings"
}

/// Contains unchanging key names for all cell identifiers.
struct CellKeys {
    static let engineTable = "EngineTableCell"
    static let defaultEngineTable = "DefaultEngineTableCell"
    static let allEnginesTable = "AllEnginesTableCell"
}

/// Contains unchanging key names for all segue identifiers.
struct SegueKeys {
    static let intro = "IntroSegue"
    static let settings = "SettingsSegue"
    static let about = "AboutSegue"
    static let defaultEngine = "DefaultEngineSegue"
    static let allEngines = "AllEnginesSegue"
    static let openSearch = "OpenSearchSegue"
    // TODO: Do these two need to be unique? We can probably just test for a selected cell
    static let addEngine = "AddEngineSegue" //
    static let editEngine = "EditEngineSegue" //
    static let urlDetails = "UrlDetailsSegue"
    
    // OpenSearch VC unwinds
    static let cancelOpenSearchUnwind = "CancelOpenSearchUnwindSegue"
    static let skipOpenSearchUnwind = "SkipOpenSearchUnwindSegue"
    static let attemptedOpenSearchUnwind = "AttemptedOpenSearchUnwindSegue"
    
    // AddEdit -> AllEngines unwinds
    static let addEditEngineUnwind = "AddEditEngineUnwindSegue"
    static let cancelAddEditEngineUnwind = "CancelAddEditEngineUnwindSegue"
    static let deleteEngineUnwind = "DeleteEngineUnwindSegue"
}

/// Contains various strings we need to reference.
// Note: Moved to UrlController
//struct CommonStrings {
//    static let magicWord = "123"
//}


/* Below is an overly complicated experiment in creating our own structs for UserDefaults.
 *
 * Issues:
 * - The `section` parameter was better left off defined in the view, not in the model.
 * - With `section` removed, the object does little more than act as a wrapper around `UserDefaults`.
 * - The generics (`Element`) aspect is untested.
 *
 * Why we may want to reinstate this object in the future:
 * - Additional parameters can be included with defaults (settings), if appropriate.
 * - One function can handle setting all types of defaults, if coded correctly.
 */

// // Load with:
// //- stayInAppSwitch.isOn = settings.stayInApp.value
// //- updateSectionFooter(settings.stayInApp.section!)
//
//struct Settings {
//    static var shared = Settings()
//
//    var stayInApp = Setting(name: "stayInApp", section: 0)
//}
//
//struct Setting {
//    let name: String
//    let section: Int?
//
//    var value: Bool {
//        get {
//            print(.n, "Fetching \(name) setting's value (\(UserDefaults.standard.bool(forKey: name))).")
//            return UserDefaults.standard.bool(forKey: name)
//        }
//        set (newValue) {
//            print(.n, "Setting \(name)'s value to \(newValue).")
//            UserDefaults.standard.set(newValue, forKey: name)
//            print(.n, "Newly set value: \(UserDefaults.standard.bool(forKey: name)).")
//        }
//    }
//}
//
//struct Setting_<Element> {
//    let name: String
//    let section: Int?
//
//    var value: Element {
//        get {
//            print(.n, "Fetching \(name) setting's value.")
//            return UserDefaults.standard.object(forKey: name) as! Element
//        }
//        set (newValue) {
//            print(.n, "Setting \(name)'s value to \(newValue).")
//            UserDefaults.standard.set(newValue, forKey: name)
//        }
//    }
//}
