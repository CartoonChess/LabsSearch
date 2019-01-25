//
//  SearchEngine.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/18.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

/// Defines a single search engine and its parameters.
struct SearchEngine: Equatable, Codable {
    
    var name: String
    var shortcut: String
    var baseUrl: URL
    // For backward compatibility reasons, queries is not optional
    // URLs which do not contain queries should be defined as an empty dictionary (`[:]`)
    var queries: [String: String]
//    var image: UIImage? = nil
//    var image: Data? = nil
    var isEnabled: Bool = true // TODO: Enable/disable from preferences view
    
    func getImage() -> UIImage? {
        // Make sure the image actually exists; otherwise give up
        // NOTE: .absoluteString returns false here
        guard let imageUrl = DirectoryKeys.userImagesUrl?.appendingPathComponent(shortcut),
            FileManager.default.fileExists(atPath: imageUrl.path) else {
            print(.n, "Could not find image for shortcut \"\(shortcut)\".")
            return nil
        }
        
        do {
            // Fetch image
            let data = try Data(contentsOf: imageUrl)
            // Will return nil if it fails
            return UIImage(data: data)
            // TODO: Internet recommended the following change for retina devices
            // return UIImage(data: data, scale: UIScreen.main.scale)
        } catch {
            print(.x, "Found but failed to fetch image at \(imageUrl.absoluteString).")
            return nil
        }
    }
    
}

/// Holds a copy of all search engines and handles saving/loading functions.
///
/// Access via the `.shared` property rather than creating a new instance.
struct SearchEngines {
    
    // TODO: Seriously we should dispell with the dictionary index and allShortcuts,
    //- and just access and sort on the shortcuts property of SearchEngine objects in an allEngines array
    
    // Access this object using .shared rather than creating a new instance
    static var shared = SearchEngines()
    
    // For example, ["g": SearchEngine(name: "Google", shortcut: "g" ... ]
    var allEngines = [String: SearchEngine]()
    var defaultEngine: SearchEngine? {
        get {
            // This value always reflects the user default setting
//            if let shortcut = UserDefaults.standard.value(forKey: SettingsKeys.defaultEngineShortcut) as? String {
            if let shortcut = UserDefaults(suiteName: AppKeys.appGroup)?.value(forKey: SettingsKeys.defaultEngineShortcut) as? String {
                return allEngines[shortcut]
            } else {
                print(.x, "Could not find a value for default engine.")
                return nil
            }
        }
        set(engine) {
            // Setting this value is equivalent to setting in user defaults
            print(.o, "Setting default engine to \(engine?.name ?? "nil").")
//            UserDefaults.standard.set(engine?.shortcut, forKey: SettingsKeys.defaultEngineShortcut)
            UserDefaults(suiteName: AppKeys.appGroup)?.set(engine?.shortcut, forKey: SettingsKeys.defaultEngineShortcut)
        }
    }
    
    // An array of all engine shortcuts in alphabetical order
    // TODO: This might be an expensive way to do this; should we refactor?
    var allShortcuts: [String] {
        get {
            let array = allEngines.keys.map { $0 }
            return array.sorted()
        }
    }
    
    // This unlikely string will be the placeholder for the user's search terms
//    let termsPlaceholder: String = "F@r=z&L;e/h?Q:M p\"T`O<P]w[s>I#p%z}z{T\\|^a~"
    let termsPlaceholder = "5C5WRbhx88ax8e7Xb7cOVXSjAFJgtKHs09DKd7E4IvemJRKEIwdqglpAvhvksgo9GjPI5cW8uWcOelAVwzt2ErQFijKUap5UdIjy"
    
    // MARK: - Saving and loading properties and methods
    
//    static let fileManager = FileManager.default
//    static let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//    static let archiveUrl = documentsDirectory.appendingPathComponent("engines").appendingPathExtension("plist")
    
    /// Overwrites the saved engines list with the current contents of allEngines, or creates a new file if no save data exists.
    ///
    /// This function only updates the app's documents directory. We currently deal with the current working copy of allEngines separately.
    func saveEngines() {
        // TODO: We should wrap updating shared.allEngines into this function
        // TODO: Can we modify this (or in AllEngines) to append/modify, rather than rewrite the entire file?
        let propertyListEncoder = PropertyListEncoder()
        
        do {
            let encodedEngines = try propertyListEncoder.encode(allEngines)
//            try encodedEngines.write(to: SearchEngines.archiveUrl, options: .noFileProtection)
            guard let userEnginesUrl = DirectoryKeys.userEnginesUrl else {
                throw NSError(domain: "", code: 0, userInfo: ["User Engines URL Failure": "The engines plist URL could not be loaded."])
            }
            try encodedEngines.write(to: userEnginesUrl, options: .noFileProtection)
            print(.o, "Saved engines to disk archive.")
        } catch {
            print(.x, "Failed to encode or write engines to disk archive; error: \(error)")
        }
    }
    
    mutating func loadEngines() {
        // Load saved engines from disk, if they exist; otherwise, load defaults
        let propertyListDecoder = PropertyListDecoder()
        
        do {
            // First, try to grab engines from user directory
//            let decodedEngines = try Data(contentsOf: SearchEngines.archiveUrl)
            guard let userEnginesUrl = DirectoryKeys.userEnginesUrl else {
                throw NSError(domain: "", code: 0, userInfo: ["User Engines URL Failure": "The engines plist could not be loaded."])
            }
            let decodedEngines = try Data(contentsOf: userEnginesUrl)
            try allEngines = propertyListDecoder.decode(Dictionary<String, SearchEngine>.self, from: decodedEngines)
            
            // This is ugly, but it prevents the app from crashing with an existing but empty engines plist
            if allEngines.count == 0 {
                let error = NSError(domain: "", code: 0, userInfo: ["Empty archive": "The engines plist exists, but contains no engines."])
                throw error
            }
            
            // Default engine should come from preferences, but set it to the first engine if none is set
            if defaultEngine == nil {
                defaultEngine = allEngines[allShortcuts[0]]
                print(.n, "Default engine not found; setting to \(defaultEngine?.name ?? "nil").")
            }
            print(.o, "Successfully loaded engines from disk archive.")
        } catch {
            // If we can't get custom engines, load the defaults
            print(.x, "Failed to read or decode engines from disk archive; error: \(error)")
            print(.o, "Loading default engines instead.")
            
            // TODO: Will these always execute when there's no save, and only when there's no save?
            allEngines = loadDefaultEngines()
            // Overwrite old engines save list, if it exists
            saveEngines()
            // Set the default to Google; if that's missing, set it to the first available engine
            defaultEngine = allEngines["g"] ?? allEngines[allShortcuts.first!]
            // Copy default engine images to user directory
            copyDefaultImages()
        }
        
    }
    
    
    /// Populates a default list of common engines if nothing found on the device or in the cloud.
    ///
    /// - Returns: A dictionary of shortcuts and their corresponding engines.
    ///
    /// This function does not set a default engine. The default engine must be set separately after calling this function.
    func loadDefaultEngines() -> [String: SearchEngine] {
        // TODO: Maybe we should be using a plist or core data...
        //- Also considered making this an array and searching on the objects, but would it be too slow?
        //- https://stackoverflow.com/questions/28727845/find-an-object-in-array
        
        let engines = [
            SearchEngine(
                name: NSLocalizedString("SearchEngine.defaultEngines-Google", comment: ""),
                shortcut: "g",
                baseUrl: URL(string: "https://www.google.com/search")!,
                queries: ["q": termsPlaceholder],
                isEnabled: true),
            SearchEngine(
                name: NSLocalizedString("SearchEngine.defaultEngines-AppleMaps", comment: ""),
                shortcut: "m",
                baseUrl: URL(string: "https://maps.apple.com/")!,
                queries: ["q": termsPlaceholder],
                isEnabled: true),
            SearchEngine(
                name: NSLocalizedString("SearchEngine.defaultEngines-NamuWiki", comment: ""),
                shortcut: "nw",
                baseUrl: URL(string: "https://namu.wiki/go/\(termsPlaceholder)")!,
                queries: [:],
                isEnabled: true),
            SearchEngine(
                name: NSLocalizedString("SearchEngine.defaultEngines-Naver", comment: ""),
                shortcut: "n",
                baseUrl: URL(string: "https://search.naver.com/search.naver")!,
                queries: ["query": termsPlaceholder],
                isEnabled: true),
            SearchEngine(
                name: NSLocalizedString("SearchEngine.defaultEngines-NaverKoEnDictionary", comment: ""),
                shortcut: "nd",
                baseUrl: URL(string: "https://endic.naver.com/search.nhn")!,
                queries: ["query": termsPlaceholder],
                isEnabled: true),
            SearchEngine(
                name: NSLocalizedString("SearchEngine.defaultEngines-QDWiki", comment: ""),
                shortcut: "q",
                baseUrl: URL(string: "http://www.qetuodesigns.com/wiki/")!,
                queries: [
                    "pagename": "Site.Search",
                    "q": termsPlaceholder],
                isEnabled: true),
            SearchEngine(
                name: NSLocalizedString("SearchEngine.defaultEngines-Wikipedia", comment: ""),
                shortcut: "w",
                baseUrl: URL(string: NSLocalizedString("SearchEngine.defaultEngines-WikipediaURL", comment: ""))!,
                queries: ["search": termsPlaceholder],
                isEnabled: true),
            SearchEngine(
                name: NSLocalizedString("SearchEngine.defaultEngines-YouTube", comment: ""),
                shortcut: "y",
                baseUrl: URL(string: "https://www.youtube.com/results")!,
                queries: ["search_query": termsPlaceholder],
                isEnabled: true)
        ]
        
        var enginesWithShortcutsAndImages = [String: SearchEngine]()
        
        for engine in engines {
//            let image = UIImage(named: "\(engine.shortcut)Icon") // nil if unavailable; desired behaviour
            let newEngine = SearchEngine(
                name: engine.name,
                shortcut: engine.shortcut,
                baseUrl: engine.baseUrl,
                queries: engine.queries,
//                image: image,
                isEnabled: true)
            enginesWithShortcutsAndImages[newEngine.shortcut] = newEngine
        }
        
        return enginesWithShortcutsAndImages
    }
    
    
    // TODO: We might end up deleting this function and incorporating its logic elsewhere
    func copyDefaultImages() {
        
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
        
        for shortcut in allShortcuts {
            // All images are named after the search shortcut
            let imageName = shortcut
            
            // Copying images from app assets
            if let sourceImage = UIImage(named: "Icons/\(shortcut)") {
                print(.o, "Default image for engine with shortcut \"\(shortcut)\" found; proceeding to copy to user directory.")
                
                // TODO: PNGs don't need a file extension?
                let destinationPath = userImagesUrl.appendingPathComponent(imageName)
                
                // Convert PNG to raw data
                if let data = sourceImage.pngData() {
                    // Try to write data to user directory
                    do {
                        try data.write(to: destinationPath)
                        print(.o, "Copied image to \(destinationPath).")
                    } catch {
                        print(.x, "Failed to write image data to user directory; error: \(error)")
                    }
                } else {
                    print(.x, "Failed to convert default image to PNG data.")
                }
            } else {
                // No need to continue this engine if there is no default image for it
                print(.n, "No default icon included for engine with shortcut \"\(shortcut)\".")
            }
            
        }
        
    }
    
}
