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
    var isEnabled: Bool
    
    // Optional properties
    // Note that these cannot be set when initializing and must be set separately
    // TODO: We can remove the initializer if we provide default values, starting with Swift 5.1 (Xcode 11)
    var encoding: CharacterEncoding?
//    var characterEncoding: String = "UTF-8"
    
    init(name: String, shortcut: String, baseUrl: URL, queries: [String: String], isEnabled: Bool, encoding: CharacterEncoding? = nil) {
        self.name = name
        self.shortcut = shortcut
        self.baseUrl = baseUrl
        self.queries = queries
        self.isEnabled = isEnabled
        self.encoding = encoding
    }
    
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

// MARK: -

/// Holds a copy of all search engines and handles saving/loading functions.
///
/// Access via the `.shared` property rather than creating a new instance.
struct SearchEngines {
    
    // TODO: Seriously we should dispell with the dictionary index and allShortcuts,
    //- and just access and sort on the shortcuts property of SearchEngine objects in an allEngines array
    
    // MARK: - Properties
    
    // Access this object using .shared rather than creating a new instance
    static var shared = SearchEngines()
    
    // For example, ["g": SearchEngine(name: "Google", shortcut: "g" ... ]
    var allEngines = [String: SearchEngine]()
    
    /// Created when first starting the app, so that the user can choose their preferred default engine
    var commonShortcuts: [String]?
    
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
    // The old way sorted by shortcut, but now we sort them by engine name
    // TODO: This might be an expensive way to do this; should we refactor?
//    var allShortcuts: [String] {
//        get {
//            let array = allEngines.keys.map { $0 }
//            return array.sorted()
//        }
//    }
    
    
    // TODO: Why not make an enum or array like SearchEngines.shared.allShortcuts.enabled, so we can update one value in VCs instead of all three?
    /// Shortcuts for all engines, including disabled ones, alphabetically by engine name.
    var allShortcuts: [String] {
        get {
//            // Make an array of arrays of every engine [[shortcut, name]]
//            var shortcutsAndNames = allEngines.values.map { [$0.shortcut, $0.name] }
//            // Sort these alphabetically using the engine name
//            shortcutsAndNames = shortcutsAndNames.sorted { $1[1] > $0[1] }
//            // Return a simple array of [shortcuts], but this is still sorted by alphabetical names
//            return shortcutsAndNames.map { $0[0] }
            return getShortcuts()
        }
    }
    
    /// Shortcuts for enabled engines, alphabetically by engine name.
    var enabledShortcuts: [String] {
        get {
//            // Make an array of arrays of every enabled engine [[shortcut, name]]
//            var shortcutsAndNames = allEngines.values.filter({$0.isEnabled}).map { [$0.shortcut, $0.name] }
//            // Sort these alphabetically using the engine name
//            shortcutsAndNames = shortcutsAndNames.sorted { $1[1] > $0[1] }
//            // Return a simple array of [shortcuts], but this is still sorted by alphabetical names
//            return shortcutsAndNames.map { $0[0] }
            return getShortcuts(includeDisabledEngines: false)
        }
    }
    
    var disabledShortcuts: [String] {
        get {
//            let allShortcuts = Set(self.allShortcuts)
//            let enabledShortcuts = Set(self.enabledShortcuts)
//            // FIXME : Does this maintain alphabetical order?
////            return Array(allShortcuts.symmetricDifference(enabledShortcuts))
//            var disabledShortcuts = Array(allShortcuts.symmetricDifference(enabledShortcuts))
            return getShortcuts(includeEnabledEngines: false)
        }
    }
    
    /// This unlikely string will be the placeholder for the user's search terms.
    let termsPlaceholder = "5C5WRbhx88ax8e7Xb7cOVXSjAFJgtKHs09DKd7E4IvemJRKEIwdqglpAvhvksgo9GjPI5cW8uWcOelAVwzt2ErQFijKUap5UdIjy"
    //    let termsPlaceholder: String = "F@r=z&L;e/h?Q:M p\"T`O<P]w[s>I#p%z}z{T\\|^a~"
    
    
    // MARK: - Methods
    
    /// Returns a list of engine shortcuts ordered alphabetically by engine name.
    ///
    /// - Parameters:
    ///   - includeEnabledEngines: Whether to include enabled engines. Optional; defaults to `true`.
    ///   - includeDisabledEngines: Whether to include disabled engines. Optional; defaults to `true`.
    /// - Returns: An array of engine shortcuts.
    ///
    /// If both parameters are set to `false`, this function returns an empty array.
    private func getShortcuts(includeEnabledEngines: Bool = true, includeDisabledEngines: Bool = true) -> [String] {
        // Save some cycles by immediately returning an empty array when someone is dumb enough to ask for nothing
        if !includeEnabledEngines && !includeDisabledEngines { return [] }
        
        var engines = allEngines
        
        // Remove disabled engines, if desired
        if !includeDisabledEngines {
            engines = engines.filter({$0.value.isEnabled})
        }
        
        // Removes enabled engines
        if !includeEnabledEngines {
            engines = engines.filter({!$0.value.isEnabled})
        }
        
        // Make an array of arrays of every engine [[shortcut, name]]
        var shortcutsAndNames = engines.values.map { [$0.shortcut, $0.name] }
        
        // Sort these alphabetically using the engine name
//        shortcutsAndNames = shortcutsAndNames.sorted { $1[1] > $0[1] }
        shortcutsAndNames = shortcutsAndNames.sorted {
            // Sort by name ([1]), but,
            //- if names are the same, sort by shortcut ([0])
            // (we compare the name lowercased, otherwise eg "eBay" falls after "Z--"
            $1[1].lowercased() > $0[1].lowercased() || ($1[1] == $0[1] && $1[0] > $0[0])
        }
        // Return a simple array of [shortcuts], but this is still sorted by alphabetical names
        return shortcutsAndNames.map { $0[0] }
    }
    
    
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
            let defaultShortcut = NSLocalizedString("SearchEngine.loadEngines-DefaultEngineShortcut", comment: "")
            defaultEngine = allEngines[defaultShortcut] ?? allEngines[allShortcuts.first!]
            // Copy default engine images to user directory
            copyDefaultImages()
        }
    }
    
    
    /// Populates a default list of common engines if nothing found on the device or in the cloud.
    ///
    /// - Returns: A dictionary of shortcuts and their corresponding engines.
    ///
    /// This function does not set a default engine. The default engine must be set separately after calling this function.
    private mutating func loadDefaultEngines() -> [String: SearchEngine] {
        // TODO: Maybe we should be using a plist or core data...
        //- Also considered making this an array and searching on the objects, but would it be too slow?
        //- https://stackoverflow.com/questions/28727845/find-an-object-in-array
        
//        let engines = [
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-GoogleName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-GoogleShortcut", comment: ""),
//                baseUrl: URL(string: "https://www.google.com/search")!,
//                queries: ["q": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-AppleMapsName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-AppleMapsShortcut", comment: ""),
//                baseUrl: URL(string: "https://maps.apple.com/")!,
//                queries: ["q": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-NamuWikiName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-NamuWikiShortcut", comment: ""),
//                baseUrl: URL(string: "https://namu.wiki/go/\(termsPlaceholder)")!,
//                queries: [:],
//                isEnabled: false),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-NaverName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-NaverShortcut", comment: ""),
//                baseUrl: URL(string: "https://search.naver.com/search.naver")!,
//                queries: ["query": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-NaverKoEnDictionaryName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-NaverKoEnDictionaryShortcut", comment: ""),
//                baseUrl: URL(string: "https://endic.naver.com/search.nhn")!,
//                queries: ["query": termsPlaceholder],
//                isEnabled: false),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-QDWikiName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-QDWikiShortcut", comment: ""),
//                baseUrl: URL(string: "http://www.qetuodesigns.com/wiki/")!,
//                queries: [
//                    "pagename": "Site.Search",
//                    "q": termsPlaceholder],
//                isEnabled: false),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-WikipediaName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-WikipediaShortcut", comment: ""),
//                baseUrl: URL(string: NSLocalizedString("SearchEngine.defaultEngines-WikipediaURL", comment: ""))!,
//                queries: ["search": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-YouTubeName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-YouTubeShortcut", comment: ""),
//                baseUrl: URL(string: "https://www.youtube.com/results")!,
//                queries: ["search_query": termsPlaceholder],
//                isEnabled: true)
//        ]
        
        
//        // This was an old test method, kept here in case we ever want to change localizaitons on the fly again.
//        let englishBundlePath = Bundle.main.path(forResource: "en", ofType: "lproj")!
//        let englishBundle = Bundle(path: englishBundlePath)!
//        let localizedString = NSLocalizedString("SearchEngine.defaultEngines-GoogleShortcut", bundle: englishBundle, comment: "")
//
//        let english = localizedString
//        let current = NSLocalizedString("SearchEngine.defaultEngines-GoogleShortcut", comment: "")
//        print("english: \(english)")
//        print("current: \(current)")
        
        // Determine the user's language and region
        let locale = Locale.current
        let language = locale.languageCode
        let region = locale.regionCode
        print(.i, "Setting up default engines for language \(language ?? "nil") and region \(region ?? "nil").")
        
        // Choose which engines to use and how to enable/disable them
        var engines = [SearchEngine]()
        // TODO: Don't repeat lists
        switch (language, region) {
        case ("ko", "KR"):
            // All Korea (KR) engines
            let enabledEngines = [aliExpress, bing, daum, facebook, google, hanaTour, interpark, knowledgeIn, kyoboBooks, linkedIn, namuwiki, nate, naver, naverCafe, naverDictionary, naverImages, naverMap, naverNews, naverShopping, netflix, theCall, twitch, twitter, watcha, wikipedia, youTube, zum]
            let disabledEngines = changeIsEnabled(afreecaTv, airbnb, aladin, albamon, amazon, appleMaps, auction, bugs, clien, coupang, dailymotion, danawa, daumCafe, daumDictionary, dcInside, egloos, elevenStreet, enuri, everytime, gmail, gmarket, googleDrive, googleImages, googleMaps, hotTracks, hotelsDotCom, inven, jobKorea, kakaoMap, melon, natePann, naverAcademic, naverBlog, naverRealEstate, naverStocks, papago, ppomPpu, realEstate114, ridiBooks, roblox, ruliweb, saramin, ssg, tistory, tmon, todayHumor, tripAdvisor, yes24, isEnabled: false)
            engines = enabledEngines + disabledEngines
            commonShortcuts = [bing, daum, google, nate, naver, zum].map { $0.shortcut }
        case ("ko", _):
            // Most Korea (KR) engines, plus Korean(ko)-capable international engines
            // First, copy from ko-KR
            var enabledEngines = [aliExpress, bing, daum, facebook, google, hanaTour, interpark, knowledgeIn, kyoboBooks, linkedIn, namuwiki, nate, naver, naverCafe, naverDictionary, naverImages, naverMap, naverNews, naverShopping, netflix, theCall, twitch, twitter, watcha, wikipedia, youTube, zum]
            var disabledEngines = changeIsEnabled(afreecaTv, airbnb, aladin, albamon, amazon, appleMaps, auction, bugs, clien, coupang, dailymotion, danawa, daumCafe, daumDictionary, dcInside, egloos, elevenStreet, enuri, everytime, gmail, gmarket, googleDrive, googleImages, googleMaps, hotTracks, hotelsDotCom, inven, jobKorea, kakaoMap, melon, natePann, naverAcademic, naverBlog, naverRealEstate, naverStocks, papago, ppomPpu, realEstate114, ridiBooks, roblox, ruliweb, saramin, ssg, tistory, tmon, todayHumor, tripAdvisor, yes24, isEnabled: false)
            // Next, make some adjustments
            // Change these engines to enabled
            let enginesToEnable = [airbnb, amazon, appleMaps, googleMaps, hotelsDotCom]
            enabledEngines.append(contentsOf: enginesToEnable)
            disabledEngines.removeAll { enginesToEnable.map{$0.shortcut}.contains($0.shortcut) }
            // Add these engines as disabled
            disabledEngines += changeIsEnabled(googleTranslate, parcels, reddit, spotify, weatherNetwork, yelp, isEnabled: false)
            // Create final engine list
            engines = enabledEngines + disabledEngines
            commonShortcuts = [bing, daum, google, nate, naver, zum].map { $0.shortcut }
        case (_, "KR"):
            // Most international engines, plus English(en)-capable Korea (KR) engines
            // First, copy from default case (nominally en-US)
            var enabledEngines = [airbnb, amazon, appleMaps, bing, duckDuckGo, eBay, facebook, giphy, gmail, google, googleImages, googleMaps, googleNews, googleTranslate, hotelsDotCom, imdb, linkedIn, netflix, oxfordDictionary, parcels, pinterest, reddit, rottenTomatoes, spotify, weatherNetwork, twitch, twitter, wikipedia, yahoo, yelp, youTube]
            var disabledEngines = changeIsEnabled(aliExpress, amazonMusic, costco, dailymotion, downForEveryone, espn, etsy, expedia, fileInfo, genius, github, googleDrive, googlePhotos, googleScholar, googleImFeelingLucky, indeed, internetArchive, jstor, marketWatch, mayoClinic, medium, metacritic, oneDrive, openStreetMap, oxfordThesaurus, pandora, quora, googleReverseImage, roblox, stackOverflow, steam, target, tumblr, urbanDictionary, vimeo, walmart, webMd, wikivoyage, wolframAlpha, wordPress, yahooAnswers, yahooNews, zillow, isEnabled: false)
            // Next, make some adjustments
            // Add these engines as enabled
            enabledEngines.append(contentsOf: [naver, naverEnglishDictionary, naverMap])
            // Change these engines to disabled
            let enginesToDisable = [amazon, appleMaps, eBay, parcels]
            enabledEngines.removeAll { enginesToDisable.map{$0.shortcut}.contains($0.shortcut) }
            disabledEngines += changeIsEnabled(enginesToDisable, isEnabled: false)
            // Add these engines as disabled
            disabledEngines += changeIsEnabled(theCall, watcha, kakaoMap, papago, isEnabled: false)
            // Remove these disabled engines
            let disabledEnginesToRemove = [target, walmart]
            disabledEngines.removeAll { disabledEnginesToRemove.map{$0.shortcut}.contains($0.shortcut) }
            // Create final engine list
            engines = enabledEngines + disabledEngines
            commonShortcuts = [bing, duckDuckGo, google, naver, yahoo].map { $0.shortcut }
        default:
            // All international engines
            let enabledEngines = [airbnb, amazon, appleMaps, bing, duckDuckGo, eBay, facebook, giphy, gmail, google, googleImages, googleMaps, googleNews, googleTranslate, hotelsDotCom, imdb, linkedIn, netflix, oxfordDictionary, parcels, pinterest, reddit, rottenTomatoes, spotify, weatherNetwork, twitch, twitter, wikipedia, yahoo, yelp, youTube]
            let disabledEngines = changeIsEnabled(aliExpress, amazonMusic, costco, dailymotion, downForEveryone, espn, etsy, expedia, fileInfo, genius, github, googleDrive, googlePhotos, googleScholar, googleImFeelingLucky, indeed, internetArchive, jstor, marketWatch, mayoClinic, medium, metacritic, oneDrive, openStreetMap, oxfordThesaurus, pandora, quora, googleReverseImage, roblox, stackOverflow, steam, target, tumblr, urbanDictionary, vimeo, walmart, webMd, wikivoyage, wolframAlpha, wordPress, yahooAnswers, yahooNews, zillow, isEnabled: false)
            engines = enabledEngines + disabledEngines
            commonShortcuts = [bing, duckDuckGo, google, yahoo].map { $0.shortcut }
        }
        
//        // English (this is the one we've been using)
//        let engines: [SearchEngine] = [
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-GoogleName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-GoogleShortcut", comment: ""),
//                baseUrl: URL(string: "https://www.google.com/search")!,
//                queries: ["q": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-AppleMapsName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-AppleMapsShortcut", comment: ""),
//                baseUrl: URL(string: "https://maps.apple.com/")!,
//                queries: ["q": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-WikipediaName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-WikipediaShortcut", comment: ""),
//                baseUrl: URL(string: NSLocalizedString("SearchEngine.defaultEngines-WikipediaURL", comment: ""))!,
//                queries: ["search": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-YouTubeName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-YouTubeShortcut", comment: ""),
//                baseUrl: URL(string: "https://www.youtube.com/results")!,
//                queries: ["search_query": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: "ShiftJS Test",
//                shortcut: "js",
//                baseUrl: URL(string: "https://kakaku.com/search_results/\(termsPlaceholder)/")!,
//                queries: [:],
//                isEnabled: true,
//                encoding: CharacterEncoding(name: "shift-js", value: .shiftJIS)),
//            SearchEngine(
//                name: "EUC-KR Test",
//                shortcut: "kr",
//                baseUrl: URL(string: "http://search.gmarket.co.kr/search.aspx")!,
//                queries: ["keyword": termsPlaceholder],
//                isEnabled: true,
//                encoding: CharacterEncoding(name: "euc-kr", value: .EUC_KR))
//        ]
        
//        // Korean
//        let _ = [
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-GoogleName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-GoogleShortcut", comment: ""),
//                baseUrl: URL(string: "https://www.google.com/search")!,
//                queries: ["q": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-NaverName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-NaverShortcut", comment: ""),
//                baseUrl: URL(string: "https://search.naver.com/search.naver")!,
//                queries: ["query": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-NaverKoEnDictionaryName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-NaverKoEnDictionaryShortcut", comment: ""),
//                baseUrl: URL(string: "https://endic.naver.com/search.nhn")!,
//                queries: ["query": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-NamuWikiName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-NamuWikiShortcut", comment: ""),
//                baseUrl: URL(string: "https://namu.wiki/go/\(termsPlaceholder)")!,
//                queries: [:],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-WikipediaName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-WikipediaShortcut", comment: ""),
//                baseUrl: URL(string: NSLocalizedString("SearchEngine.defaultEngines-WikipediaURL", comment: ""))!,
//                queries: ["search": termsPlaceholder],
//                isEnabled: true),
//            SearchEngine(
//                name: NSLocalizedString("SearchEngine.defaultEngines-YouTubeName", comment: ""),
//                shortcut: NSLocalizedString("SearchEngine.defaultEngines-YouTubeShortcut", comment: ""),
//                baseUrl: URL(string: "https://www.youtube.com/results")!,
//                queries: ["search_query": termsPlaceholder],
//                isEnabled: true)
//        ]
        
        var enginesWithShortcutsAndImages = [String: SearchEngine]()
        
        for engine in engines {
//            let image = UIImage(named: "\(engine.shortcut)Icon") // nil if unavailable; desired behaviour
            let newEngine = SearchEngine(
                name: engine.name,
                shortcut: engine.shortcut,
                baseUrl: engine.baseUrl,
                queries: engine.queries,
//                image: image,
                isEnabled: engine.isEnabled,
                encoding: engine.encoding)
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
        
        // Check that the "Icons" folder in user directory exists, otherwise create it
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
        
        // Path to the default icons bundle
        let mainBundlePath = Bundle.main.resourcePath
        let iconBundlePath = mainBundlePath! + "/Icons.bundle"
        
        // We will collect the names of the icons (named after engines)
        var engineNames = [String]()
        
        do {
            engineNames = try FileManager.default.contentsOfDirectory(atPath: iconBundlePath)
        } catch {
            print(.x, "Attempted to fetch icon names from path \(iconBundlePath) but encountered the following error: \(error)")
        }
        
        for oldIconName in engineNames {
            
            // newIconName will be set to "!" if localization doesn't exist for some reason
            // This suggests that search engine isn't in use in that language
            let newIconName = NSLocalizedString("SearchEngine.defaultEngines-\(oldIconName)Shortcut", value: "!", comment: "")
            
            // If this localization doesn't use that engine, skip it
            // FIXME: This skips the icon, but leaves a broken engine!
            //- loadDefaultEngines() must be configured on a per-localization basis.
            guard newIconName != "!" else {
                print(.n, "Skipped \(oldIconName) because this localization does not use it.")
                continue
            }
            
            // Paths for default icon from bundle and where to copy it to user folder
            let sourcePath = "\(iconBundlePath)/\(oldIconName)"
            let destinationPath = userImagesUrl.appendingPathComponent(newIconName)
            
            // Convert data file to image, then to image data
            guard let sourceImage = UIImage(named: sourcePath),
                let data = sourceImage.pngData() else {
                    print(.x, "Failed to fetch or convert default image to PNG data.")
                    continue
            }
            
            print(.i, "Default image for \"\(oldIconName)\" found; proceeding to copy to user directory.")
            
            // Try to write data to user directory
            do {
                try data.write(to: destinationPath)
                print(.o, "Copied image \"\(newIconName)\".")
            } catch {
                print(.x, "Failed to write image data to user directory; error: \(error)")
            }
            
        }
        
    }
    
}



// We've made this an extension so that the main struct declaration is less cluttered
//- This has resulted in the need for computed properties however,
//- though this comes with two benefits:
//- 1. Should only have to load these on a fresh install
//- 2. `termsPlaceholder` can be used
extension SearchEngines {
    //struct DefaultSearchEngines {
    
    // MARK: - Properties
    
    //    private var termsPlaceholder: String {
    //        return SearchEngines.shared.termsPlaceholder
    //    }
    
    //    private static let termsPlaceholder = SearchEngines.shared.termsPlaceholder
    
    // MARK: Universal engines
    
    // TODO: With Swift 5.1 (Xcode 11), we can make this return implicit
    private var airbnb: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-AirbnbName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-AirbnbShortcut", comment: ""),
        baseUrl: URL(string: "https://www.airbnb.com/s/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var aliExpress: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-AliExpressName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-AliExpressShortcut", comment: ""),
        baseUrl: URL(string: "https://m.aliexpress.com/wholesale/\(termsPlaceholder).html")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var amazon: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-AmazonName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-AmazonShortcut", comment: ""),
        baseUrl: URL(string: "https://www.amazon.com/s")!,
        queries: ["k": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var appleMaps: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-AppleMapsName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-AppleMapsShortcut", comment: ""),
        baseUrl: URL(string: "https://maps.apple.com/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var bing: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-BingName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-BingShortcut", comment: ""),
        baseUrl: URL(string: "https://www.bing.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var dailymotion: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-DailymotionName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-DailymotionShortcut", comment: ""),
        baseUrl: URL(string: "https://www.dailymotion.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var facebook: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-FacebookName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-FacebookShortcut", comment: ""),
        baseUrl: URL(string: "https://www.facebook.com/search/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var gmail: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-GmailName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-GmailShortcut", comment: ""),
        baseUrl: URL(string: "https://mail.google.com/mail/mu/#tl/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var google: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-GoogleName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-GoogleShortcut", comment: ""),
        baseUrl: URL(string: "https://www.google.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var googleDrive: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-GoogleDriveName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-GoogleDriveShortcut", comment: ""),
        baseUrl: URL(string: "https://drive.google.com/drive/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var googleImages: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-GoogleImagesName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-GoogleImagesShortcut", comment: ""),
        baseUrl: URL(string: "https://www.google.com/search")!,
        queries: ["tbm": "isch", "q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var googleMaps: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-GoogleMapsName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-GoogleMapsShortcut", comment: ""),
        baseUrl: URL(string: "https://www.google.com/maps/search/\(termsPlaceholder)/")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var googleTranslate: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-GoogleTranslateName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-GoogleTranslateShortcut", comment: ""),
        baseUrl: URL(string: String(format: NSLocalizedString("SearchEngine.defaultEngines-GoogleTranslateURL", comment: ""), termsPlaceholder))!,
        queries: ["hl": NSLocalizedString("SearchEngine.defaultEngines-GoogleTranslateQuery.hl", comment: "")],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var hotelsDotCom: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-HotelsDotComName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-HotelsDotComShortcut", comment: ""),
        baseUrl: URL(string: "https://www.hotels.com/search.do")!,
        queries: ["q-destination": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var linkedIn: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-LinkedInName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-LinkedInShortcut", comment: ""),
        baseUrl: URL(string: "https://www.linkedin.com/search/results/index/")!,
        queries: ["keywords": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var netflix: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-NetflixName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-NetflixShortcut", comment: ""),
        baseUrl: URL(string: "https://www.netflix.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var roblox: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-RobloxName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-RobloxShortcut", comment: ""),
        baseUrl: URL(string: "https://www.roblox.com/games/")!,
        queries: ["Keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var twitch: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-TwitchName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-TwitchShortcut", comment: ""),
        baseUrl: URL(string: "https://twitch.tv/search")!,
        queries: ["term": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var twitter: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-TwitterName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-TwitterShortcut", comment: ""),
        baseUrl: URL(string: "https://www.twitter.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var wikipedia: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-WikipediaName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-WikipediaShortcut", comment: ""),
        baseUrl: URL(string: NSLocalizedString("SearchEngine.defaultEngines-WikipediaURL", comment: ""))!,
        queries: ["search": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var youTube: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-YouTubeName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-YouTubeShortcut", comment: ""),
        baseUrl: URL(string: "https://www.youtube.com/results")!,
        queries: ["search_query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    
    // MARK: English engines
    
    private var naverEnglishDictionary: SearchEngine { return SearchEngine(
        name: "Naver Dictionary",
        shortcut: "nd",
        baseUrl: URL(string: "https://korean.dict.naver.com/english/search.nhn")!,
        queries: ["sLn": "kr", "query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var rottenTomatoes: SearchEngine { return SearchEngine(
        name: "Rotten Tomatoes",
        shortcut: "rt",
        baseUrl: URL(string: "https://www.rottentomatoes.com/search/")!,
        queries: ["search": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var googleImFeelingLucky: SearchEngine { return SearchEngine(
        name: "I'm Feeling Lucky",
        shortcut: "lu",
        baseUrl: URL(string: "https://www.google.com/search")!,
        queries: ["bntI": "1", "q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var yahooNews: SearchEngine { return SearchEngine(
        name: "Yahoo News",
        shortcut: "yn",
        baseUrl: URL(string: "https://news.search.yahoo.com/search")!,
        queries: ["p": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var walmart: SearchEngine { return SearchEngine(
        name: "Walmart",
        shortcut: "wal",
        baseUrl: URL(string: "https://www.walmart.com/search/")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var medium: SearchEngine { return SearchEngine(
        name: "Medium",
        shortcut: "me",
        baseUrl: URL(string: "https://medium.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var wikivoyage: SearchEngine { return SearchEngine(
        name: "Wikivoyage",
        shortcut: "wv",
        baseUrl: URL(string: "https://en.wikivoyage.org/wiki/Special:Search")!,
        queries: ["search": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var googleScholar: SearchEngine { return SearchEngine(
        name: "Google Scholar",
        shortcut: "sc",
        baseUrl: URL(string: "https://scholar.google.com/scholar")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var weatherNetwork: SearchEngine { return SearchEngine(
        name: "The Weather Network",
        shortcut: "we",
        baseUrl: URL(string: "https://www.theweathernetwork.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var tumblr: SearchEngine { return SearchEngine(
        name: "Tumblr",
        shortcut: "tu",
        baseUrl: URL(string: "https://www.tumblr.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var openStreetMap: SearchEngine { return SearchEngine(
        name: "OpenStreetMap",
        shortcut: "osm",
        baseUrl: URL(string: "https://www.openstreetmap.org/search")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var wordPress: SearchEngine { return SearchEngine(
        name: "WordPress",
        shortcut: "wp",
        baseUrl: URL(string: "https://en.search.wordpress.com/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var fileInfo: SearchEngine { return SearchEngine(
        name: "FileInfo",
        shortcut: "fi",
        baseUrl: URL(string: "https://fileinfo.com/extension/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var expedia: SearchEngine { return SearchEngine(
        name: "Expedia",
        shortcut: "ex",
        baseUrl: URL(string: "https://www.expedia.com/Hotel-Search")!,
        queries: ["destination": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var eBay: SearchEngine { return SearchEngine(
        name: "eBay",
        shortcut: "e",
        baseUrl: URL(string: "https://www.ebay.com/sch/i.html")!,
        queries: ["_nkw": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var jstor: SearchEngine { return SearchEngine(
        name: "JSTOR",
        shortcut: "j",
        baseUrl: URL(string: "https://www.jstor.org/action/doBasicSearch")!,
        queries: ["Query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var etsy: SearchEngine { return SearchEngine(
        name: "Etsy",
        shortcut: "et",
        baseUrl: URL(string: "https://www.etsy.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var wolframAlpha: SearchEngine { return SearchEngine(
        name: "Wolfram|Alpha",
        shortcut: "wa",
        baseUrl: URL(string: "https://m.wolframalpha.com/input/")!,
        queries: ["i": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var steam: SearchEngine { return SearchEngine(
        name: "Steam",
        shortcut: "s",
        baseUrl: URL(string: "https://store.steampowered.com/search/")!,
        queries: ["term": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var duckDuckGo: SearchEngine { return SearchEngine(
        name: "DuckDuckGo",
        shortcut: "d",
        baseUrl: URL(string: "https://www.duckduckgo.com/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var giphy: SearchEngine { return SearchEngine(
        name: "Giphy",
        shortcut: "gif",
        baseUrl: URL(string: "https://giphy.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var oxfordDictionary: SearchEngine { return SearchEngine(
        name: "Oxford Dictionary",
        shortcut: "di",
        baseUrl: URL(string: "https://en.oxforddictionaries.com/search")!,
        queries: ["filter": "dictionary", "query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var target: SearchEngine { return SearchEngine(
        name: "Target",
        shortcut: "ta",
        baseUrl: URL(string: "https://www.target.com/s")!,
        queries: ["searchTerm": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var reddit: SearchEngine { return SearchEngine(
        name: "Reddit",
        shortcut: "r",
        baseUrl: URL(string: "https://www.reddit.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var yahooAnswers: SearchEngine { return SearchEngine(
        name: "Yahoo Answers",
        shortcut: "an",
        baseUrl: URL(string: "https://answers.search.yahoo.com/search")!,
        queries: ["p": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var pinterest: SearchEngine { return SearchEngine(
        name: "Pinterest",
        shortcut: "p",
        baseUrl: URL(string: "https://www.pinterest.com/search/pins/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var webMd: SearchEngine { return SearchEngine(
        name: "WebMD",
        shortcut: "wmd",
        baseUrl: URL(string: "https://www.webmd.com/search/search_results/default.aspx")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var yelp: SearchEngine { return SearchEngine(
        name: "Yelp",
        shortcut: "ye",
        baseUrl: URL(string: "https://yelp.com/search")!,
        queries: ["find_desc": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var oneDrive: SearchEngine { return SearchEngine(
        name: "OneDrive",
        shortcut: "od",
        baseUrl: URL(string: "https://onedrive.live.com/")!,
        queries: ["qt": "search", "q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var parcels: SearchEngine { return SearchEngine(
        name: "Parcels",
        shortcut: "pa",
        baseUrl: URL(string: "http://parcelsapp.com/en/tracking/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var pandora: SearchEngine { return SearchEngine(
        name: "Pandora",
        shortcut: "pan",
        baseUrl: URL(string: "https://www.pandora.com/search/\(termsPlaceholder)/all")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var imdb: SearchEngine { return SearchEngine(
        name: "IMDb",
        shortcut: "imdb",
        baseUrl: URL(string: "https://m.imdb.com/find")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var metacritic: SearchEngine { return SearchEngine(
        name: "Metacritic",
        shortcut: "mc",
        baseUrl: URL(string: "https://www.metacritic.com/search/all/\(termsPlaceholder)/results")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var github: SearchEngine { return SearchEngine(
        name: "Github",
        shortcut: "gh",
        baseUrl: URL(string: "https://github.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var genius: SearchEngine { return SearchEngine(
        name: "Genius",
        shortcut: "ge",
        baseUrl: URL(string: "https://genius.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var spotify: SearchEngine { return SearchEngine(
        name: "Spotify",
        shortcut: "sp",
        baseUrl: URL(string: "https://open.spotify.com/search/results/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var marketWatch: SearchEngine { return SearchEngine(
        name: "MarketWatch",
        shortcut: "mw",
        baseUrl: URL(string: "https://www.marketwatch.com/investing/stock/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var urbanDictionary: SearchEngine { return SearchEngine(
        name: "Urban Dictionary",
        shortcut: "ud",
        baseUrl: URL(string: "https://www.urbandictionary.com/define.php")!,
        queries: ["term": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var downForEveryone: SearchEngine { return SearchEngine(
        name: "Down For Everyone Or Just Me",
        shortcut: "down",
        baseUrl: URL(string: "https://downforeveryoneorjustme.com/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var yahoo: SearchEngine { return SearchEngine(
        name: "Yahoo",
        shortcut: "ya",
        baseUrl: URL(string: "https://search.yahoo.com/search")!,
        queries: ["p": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var indeed: SearchEngine { return SearchEngine(
        name: "Indeed",
        shortcut: "in",
        baseUrl: URL(string: "https://indeed.com/jobs")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var vimeo: SearchEngine { return SearchEngine(
        name: "Vimeo",
        shortcut: "v",
        baseUrl: URL(string: "https://vimeo.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var quora: SearchEngine { return SearchEngine(
        name: "Quora",
        shortcut: "qu",
        baseUrl: URL(string: "https://www.quora.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var costco: SearchEngine { return SearchEngine(
        name: "Costco",
        shortcut: "c",
        baseUrl: URL(string: "https://www.costco.com/CatalogSearch")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var oxfordThesaurus: SearchEngine { return SearchEngine(
        name: "Oxford Thesaurus",
        shortcut: "th",
        baseUrl: URL(string: "https://en.oxforddictionaries.com/search")!,
        queries: ["query": termsPlaceholder, "filter": "thesaurus"],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var internetArchive: SearchEngine { return SearchEngine(
        name: "Internet Archive",
        shortcut: "ia",
        baseUrl: URL(string: "https://web.archive.org/web/*/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var mayoClinic: SearchEngine { return SearchEngine(
        name: "Mayo Clinic",
        shortcut: "mayo",
        baseUrl: URL(string: "https://www.mayoclinic.org/search/search-results")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var zillow: SearchEngine { return SearchEngine(
        name: "Zillow",
        shortcut: "z",
        baseUrl: URL(string: "https://www.zillow.com/homes/for_sale/\(termsPlaceholder)_rb/")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var googlePhotos: SearchEngine { return SearchEngine(
        name: "Google Photos",
        shortcut: "ph",
        baseUrl: URL(string: "https://photos.google.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var amazonMusic: SearchEngine { return SearchEngine(
        name: "Amazon Music",
        shortcut: "am",
        baseUrl: URL(string: "https://music.amazon.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var stackOverflow: SearchEngine { return SearchEngine(
        name: "Stack Overflow",
        shortcut: "so",
        baseUrl: URL(string: "https://stackoverflow.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var googleNews: SearchEngine { return SearchEngine(
        name: "Google News",
        shortcut: "gn",
        baseUrl: URL(string: "https://news.google.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var googleReverseImage: SearchEngine { return SearchEngine(
        name: "Reverse Image",
        shortcut: "ri",
        baseUrl: URL(string: "https://www.google.com/searchbyimage")!,
        queries: ["image_url": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var espn: SearchEngine { return SearchEngine(
        name: "ESPN",
        shortcut: "es",
        baseUrl: URL(string: "https://www.espn.com/search/results")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    
    // MARK: Korean engines
    
    private var ridiBooks: SearchEngine { return SearchEngine(
        name: "리디북스",
        shortcut: "ㄹㄷ",
        baseUrl: URL(string: "https://ridibooks.com/search/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naverAcademic: SearchEngine { return SearchEngine(
        name: "네이버 학술정보",
        shortcut: "ㅎㅅ",
        baseUrl: URL(string: "https://academic.naver.com/search.naver")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naverNews: SearchEngine { return SearchEngine(
        name: "네이버 뉴스",
        shortcut: "ㄴㅅ",
        baseUrl: URL(string: "https://search.naver.com/search.naver")!,
        queries: ["query": termsPlaceholder, "where": "news"],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var watcha: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-WatchaName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-WatchaShortcut", comment: ""),
        baseUrl: URL(string: NSLocalizedString("SearchEngine.defaultEngines-WatchaURL", comment: ""))!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var coupang: SearchEngine { return SearchEngine(
        name: "쿠팡",
        shortcut: "ㅋ",
        baseUrl: URL(string: "https://coupang.com/np/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var realEstate114: SearchEngine { return SearchEngine(
        name: "부동산114",
        shortcut: "ㅂㄷㅅㅇ",
        baseUrl: URL(string: "https://m.r114.com/Search/m5/m520.asp")!,
        queries: ["dqSearchTerm": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var papago: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-PapagoName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-PapagoShortcut", comment: ""),
        baseUrl: URL(string: "https://papago.naver.com/")!,
        queries: ["st": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var everytime: SearchEngine { return SearchEngine(
        name: "에브리타임",
        shortcut: "ㅇㅂㄹ",
        baseUrl: URL(string: "https://everytime.kr/search/all/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var daum: SearchEngine { return SearchEngine(
        name: "다음",
        shortcut: "ㄷ",
        baseUrl: URL(string: "https://search.daum.net/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var inven: SearchEngine { return SearchEngine(
        name: "인벤",
        shortcut: "ㅇㅂ",
        baseUrl: URL(string: "http://inven.co.kr/search/webzine/top/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var zum: SearchEngine { return SearchEngine(
        name: "줌",
        shortcut: "줌",
        baseUrl: URL(string: "http://search.zum.com/search.zum")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var ssg: SearchEngine { return SearchEngine(
        name: "쓱닷컴",
        shortcut: "ㅆ",
        baseUrl: URL(string: "http://www.ssg.com/search.ssg")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var hotTracks: SearchEngine { return SearchEngine(
        name: "핫트랙스",
        shortcut: "ㅎㅌ",
        baseUrl: URL(string: "http://m.hottracks.co.kr/m/search/searchMain")!,
        queries: ["searchTerm": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var afreecaTv: SearchEngine { return SearchEngine(
        name: "아프리카TV",
        shortcut: "ㅇㅍ",
        baseUrl: URL(string: "http://afreecatv.com/#/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var dcInside: SearchEngine { return SearchEngine(
        name: "디시인사이드",
        shortcut: "ㄷㅅ",
        baseUrl: URL(string: "https://m.dcinside.com/search")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var knowledgeIn: SearchEngine { return SearchEngine(
        name: "지식iN",
        shortcut: "ㅈㅅ",
        baseUrl: URL(string: "https://m.kin.naver.com/mobile/search/searchList.nhn")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var enuri: SearchEngine { return SearchEngine(
        name: "에누리",
        shortcut: "ㅇㄴㄹ",
        baseUrl: URL(string: "http://enuri.com/search.jsp")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var yes24: SearchEngine { return SearchEngine(
        name: "예스24",
        shortcut: "예스",
        baseUrl: URL(string: "http://m.yes24.com/search/search")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var tripAdvisor: SearchEngine { return SearchEngine(
        name: "트립어드바이저",
        shortcut: "ㅌㄹ",
        baseUrl: URL(string: "https://www.tripadvisor.co.kr/Search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var interpark: SearchEngine { return SearchEngine(
        name: "인터파크",
        shortcut: "ㅇㅌㅍ",
        baseUrl: URL(string: "http://m.shop.interpark.com/search_all/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naverDictionary: SearchEngine { return SearchEngine(
        name: "네이버 사전",
        shortcut: "ㅅㅈ",
        baseUrl: URL(string: "https://ko.dict.naver.com/#/search?query=\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var saramin: SearchEngine { return SearchEngine(
        name: "사람인",
        shortcut: "ㅅㄹ",
        baseUrl: URL(string: "https://saramin.co.kr/zf_user/search")!,
        queries: ["searchword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var kakaoMap: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-KakaoMapName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-KakaoMapShortcut", comment: ""),
        baseUrl: URL(string: "https://m.map.kakao.com/actions/searchView")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naverBlog: SearchEngine { return SearchEngine(
        name: "네이버 블로그",
        shortcut: "ㅂㄹㄱ",
        baseUrl: URL(string: "http://m.blog.naver.com/SectionPostSearch.nhn")!,
        queries: ["searchValue": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var egloos: SearchEngine { return SearchEngine(
        name: "이글루스",
        shortcut: "ㅇㄱ",
        baseUrl: URL(string: "http://valley.egloos.com/m/search")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var melon: SearchEngine { return SearchEngine(
        name: "멜론",
        shortcut: "ㅁㄹ",
        baseUrl: URL(string: "https://m.app.melon.com/search/searchMcom.htm")!,
        queries: ["s": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naverCafe: SearchEngine { return SearchEngine(
        name: "네이버 카페",
        shortcut: "ㅋㅍ",
        baseUrl: URL(string: "https://m.cafe.naver.com/SectionArticleSearch.nhn")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var bugs: SearchEngine { return SearchEngine(
        name: "벅스",
        shortcut: "ㅂ",
        baseUrl: URL(string: "https://m.bugs.co.kr/search/track")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var aladin: SearchEngine { return SearchEngine(
        name: "알라딘",
        shortcut: "ㅇㄹ",
        baseUrl: URL(string: "https://www.aladin.co.kr/search/wsearchresult.aspx")!,
        queries: ["SearchWord": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var tistory: SearchEngine { return SearchEngine(
        name: "티스토리",
        shortcut: "ㅌㅅ",
        baseUrl: URL(string: "https://tistory.com/m/search/")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var ppomPpu: SearchEngine { return SearchEngine(
        name: "뽐뿌",
        shortcut: "ㅃ",
        baseUrl: URL(string: "https://m.ppomppu.co.kr/new/search_result.php")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "euc-kr", value: .EUC_KR))}
    
    private var tmon: SearchEngine { return SearchEngine(
        name: "티몬",
        shortcut: "ㅌㅁ",
        baseUrl: URL(string: "http://search.tmon.co.kr/search")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var nate: SearchEngine { return SearchEngine(
        name: "네이트",
        shortcut: "ㄴㅇㅌ",
        baseUrl: URL(string: "https://search.daum.net/nate")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naverRealEstate: SearchEngine { return SearchEngine(
        name: "네이버 부동산",
        shortcut: "ㅂㄷㅅ",
        baseUrl: URL(string: "https://m.land.naver.com/search/result/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var daumDictionary: SearchEngine { return SearchEngine(
        name: "다음 사전",
        shortcut: "ㄷㅇㅅ",
        baseUrl: URL(string: "https://dic.daum.net/search.do")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var namuwiki: SearchEngine { return SearchEngine(
        name: "나무위키",
        shortcut: "ㄴㅁㅇ",
        baseUrl: URL(string: "https://namu.wiki/go/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var albamon: SearchEngine { return SearchEngine(
        name: "알바몬",
        shortcut: "ㅇㅂㅁ",
        baseUrl: URL(string: "http://m.albamon.com/Search")!,
        queries: ["kwd": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naverStocks: SearchEngine { return SearchEngine(
        name: "네이버 증권",
        shortcut: "ㅈㄱ",
        baseUrl: URL(string: "https://m.stock.naver.com/searchItem.nhn")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var gmarket: SearchEngine { return SearchEngine(
        name: "지마켓",
        shortcut: "ㅈㅁ",
        baseUrl: URL(string: "http://search.gmarket.co.kr/search.aspx")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "euc-kr", value: .EUC_KR))}
    
    private var theCall: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-TheCallName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-TheCallShortcut", comment: ""),
        baseUrl: URL(string: "https://www.thecall.co.kr/bbs/board.php")!,
        queries: ["stx": termsPlaceholder, "bo_table": "phone"],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naverMap: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-NaverMapName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-NaverMapShortcut", comment: ""),
        baseUrl: URL(string: "https://m.map.naver.com/search2/search.nhn")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var kyoboBooks: SearchEngine { return SearchEngine(
        name: "교보문고",
        shortcut: "ㄱㅂ",
        baseUrl: URL(string: "https://search.kyobobook.co.kr/mobile/search")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var hanaTour: SearchEngine { return SearchEngine(
        name: "하나투어",
        shortcut: "ㅎㄴ",
        baseUrl: URL(string: "http://m.hanatour.com/search/search.hnt")!,
        queries: ["searchQuery": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var natePann: SearchEngine { return SearchEngine(
        name: "네이트판",
        shortcut: "ㄴㅇㅌㅍ",
        baseUrl: URL(string: "https://m.pann.nate.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var elevenStreet: SearchEngine { return SearchEngine(
        name: "11번가",
        shortcut: "1",
        baseUrl: URL(string: "http://m.11st.co.kr/MW/Search/searchProduct.tmall")!,
        queries: ["searchKeyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "euc-kr", value: .EUC_KR))}
    
    private var auction: SearchEngine { return SearchEngine(
        name: "옥션",
        shortcut: "ㅇㅅ",
        baseUrl: URL(string: "http://browse.auction.co.kr/search")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naver: SearchEngine { return SearchEngine(
        name: NSLocalizedString("SearchEngine.defaultEngines-NaverName", comment: ""),
        shortcut: NSLocalizedString("SearchEngine.defaultEngines-NaverShortcut", comment: ""),
        baseUrl: URL(string: "https://search.naver.com/search.naver")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var naverImages: SearchEngine { return SearchEngine(
        name: "네이버 이미지",
        shortcut: "ㅇ",
        baseUrl: URL(string: "https://search.naver.com/search.naver")!,
        queries: ["query": termsPlaceholder, "where": "image"],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var daumCafe: SearchEngine { return SearchEngine(
        name: "다음 카페",
        shortcut: "ㄷㅇㅋ",
        baseUrl: URL(string: "http://m.cafe.daum.net/_search")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var ruliweb: SearchEngine { return SearchEngine(
        name: "루리웹",
        shortcut: "ㄹㄹ",
        baseUrl: URL(string: "https://m.ruliweb.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var todayHumor: SearchEngine { return SearchEngine(
        name: "오늘의유머",
        shortcut: "ㅇㄴ",
        baseUrl: URL(string: "http://m.todayhumor.co.kr/list.php")!,
        queries: ["kind": "search", "keyword": termsPlaceholder, "keyfield": "subject"],
        isEnabled: true,
        encoding: CharacterEncoding(name: "iso-8859-1", value: .isoLatin1))}
    
    private var naverShopping: SearchEngine { return SearchEngine(
        name: "네이버 쇼핑",
        shortcut: "ㅅㅍ",
        baseUrl: URL(string: "https://msearch.shopping.naver.com/search/all")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var jobKorea: SearchEngine { return SearchEngine(
        name: "잡코리아",
        shortcut: "ㅈㅋ",
        baseUrl: URL(string: "https://www.jobkorea.co.kr/Search/")!,
        queries: ["stext": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var danawa: SearchEngine { return SearchEngine(
        name: "다나와",
        shortcut: "ㄷㄴ",
        baseUrl: URL(string: "https://search.danawa.com/dsearch.php")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    private var clien: SearchEngine { return SearchEngine(
        name: "클리앙",
        shortcut: "ㅋㄹ",
        baseUrl: URL(string: "https://clien.net/service/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8))}
    
    //    enum foo {
    //        case koreanEngines, englishEngines
    //
    //        static let Google = SearchEngine(
    //            name: NSLocalizedString("SearchEngine.defaultEngines-GoogleName", comment: ""),
    //            shortcut: NSLocalizedString("SearchEngine.defaultEngines-GoogleShortcut", comment: ""),
    //            baseUrl: URL(string: "https://www.google.com/search")!,
    //            queries: ["q": SearchEngines.shared.termsPlaceholder],
    //            isEnabled: true,
    //            encoding: CharacterEncoding(name: "utf-8", value: .utf8)
    //            )
    //    }
    
    
    // MARK: - Methods
    
    //    private func changeIsEnabled(_ engines: SearchEngine..., isEnabled: Bool? = nil) -> [SearchEngine] {
    //        var updatedEngines = [SearchEngine]()
    //
    //        for engine in engines {
    //            var engine = engine
    //            if
    //            engine.isEnabled.toggle()
    //            updatedEngines.append(engine)
    //        }
    //
    //        return updatedEngines
    //    }
    
    private func changeIsEnabled(_ engines: [SearchEngine], isEnabled: Bool? = nil) -> [SearchEngine] {
        // This should probably never happen, but just being safe
        guard !engines.isEmpty else { return engines }
        
        // Create mutable copy of engines array
        var engines = engines
        
        // Change each engine's isEnabled property as requested or simply toggle it
        for index in 0 ... engines.count - 1 {
            if let isEnabled = isEnabled {
                engines[index].isEnabled = isEnabled
            } else {
                engines[index].isEnabled.toggle()
            }
        }
        
        return engines
    }
    
    private func changeIsEnabled(_ engines: SearchEngine..., isEnabled: Bool? = nil) -> [SearchEngine] {
        // This should probably never happen, but just being safe
        guard !engines.isEmpty else { return engines }
        // Call main function
        return changeIsEnabled(engines, isEnabled: isEnabled)
    }
    
}

