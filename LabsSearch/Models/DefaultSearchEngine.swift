//
//  DefaultSearchEngine.swift
//  Chears
//
//  Created by Xcode on ’19/08/24.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

/// Contains all default engines for when the app is first installed.
///
/// The `localizableName` is supplied if the engine is used in more than one language. This allows for icons to be copied from the icons bunndle to the correct shortcut.
struct DefaultSearchEngine {
    
    // MARK: - Private properties
    
    let localizableName: String?
    var engine: SearchEngine
    
    private static let termsPlaceholder = SearchEngines.shared.termsPlaceholder
    
    
    // MARK: - Methods
    
    // Don't allow the creation of default engines outside of this struct itself
    private init(localizableName: String? = nil, engine: SearchEngine) {
        self.localizableName = localizableName
        self.engine = engine
    }
    
    /// Properties of `SearchEngine` which can be localized.
    private enum LocalizableComponent: String {
        case name = "Name", shortcut = "Shortcut", url = "URL", query = "Query"
    }
    
    /// Returns a localized `SearchEngine` property.
    ///
    /// - Parameters:
    ///   - component: The `LocalizableComponent` to localize.
    ///   - query: The query key to localize. Optional.
    ///   - name: The localizable engine name.
    /// - Returns: The localized string.
    ///
    /// - Warning:
    /// A `.query` component must be matched with a `query` string. Including only one and not the other will cause this function to return an empty string.
    private static func localized(_ component: LocalizableComponent, query: String? = nil, from name: String) -> String {
        guard (component == .query && query != nil)
            || (component != .query && query == nil) else {
                print(.x, "localied() must be called with both .query component and query string together, or neither at all.")
                return ""
        }
        var queryKey = ""
        if let query = query {
            queryKey = ".\(query)"
        }
        
        return NSLocalizedString("SearchEngine.defaultEngines-\(name)\(component.rawValue)\(queryKey)", comment: "")
    }
    
    
    // MARK: - Engines
    
    
    // MARK: Localized engines (US)
    
    static var airbnb: DefaultSearchEngine {
        let name = "Airbnb"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.airbnb.com/s/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var aliExpress: DefaultSearchEngine {
        let name = "AliExpress"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://m.aliexpress.com/wholesale/\(termsPlaceholder).html")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var amazon: DefaultSearchEngine {
        let name = "Amazon"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.amazon.com/s")!,
        queries: ["k": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var appleMaps: DefaultSearchEngine {
        let name = "AppleMaps"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://maps.apple.com/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var bing: DefaultSearchEngine {
        let name = "Bing"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.bing.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var dailymotion: DefaultSearchEngine {
        let name = "Dailymotion"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.dailymotion.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var facebook: DefaultSearchEngine {
        let name = "Facebook"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.facebook.com/search/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var gmail: DefaultSearchEngine {
        let name = "Gmail"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://mail.google.com/mail/mu/#tl/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var google: DefaultSearchEngine {
        let name = "Google"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.google.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var googleDrive: DefaultSearchEngine {
        let name = "GoogleDrive"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://drive.google.com/drive/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var googleImages: DefaultSearchEngine {
        let name = "GoogleImages"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.google.com/search")!,
        queries: ["tbm": "isch", "q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var googleMaps: DefaultSearchEngine {
        let name = "GoogleMaps"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.google.com/maps/search/\(termsPlaceholder)/")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var googleTranslate: DefaultSearchEngine {
        let name = "GoogleTranslate"
        let query = "hl"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: String(format: localized(.url, from: name), termsPlaceholder))!,
        queries: [query: localized(.query, query: query, from: name)],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var hotelsDotCom: DefaultSearchEngine {
        let name = "HotelsDotCom"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.hotels.com/search.do")!,
        queries: ["q-destination": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var linkedIn: DefaultSearchEngine {
        let name = "LinkedIn"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.linkedin.com/search/results/index/")!,
        queries: ["keywords": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var netflix: DefaultSearchEngine {
        let name = "Netflix"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.netflix.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var roblox: DefaultSearchEngine {
        let name = "Roblox"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.roblox.com/games/")!,
        queries: ["Keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var twitch: DefaultSearchEngine {
        let name = "Twitch"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://twitch.tv/search")!,
        queries: ["term": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var twitter: DefaultSearchEngine {
        let name = "Twitter"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.twitter.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var wikipedia: DefaultSearchEngine {
        let name = "Wikipedia"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: localized(.url, from: name))!,
        queries: ["search": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var youTube: DefaultSearchEngine {
        let name = "YouTube"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.youtube.com/results")!,
        queries: ["search_query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    // MARK: Localized engines (KR)
    
    static var kakaoMap: DefaultSearchEngine {
        let name = "KakaoMap"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://m.map.kakao.com/actions/searchView")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naver: DefaultSearchEngine {
        let name = "Naver"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://search.naver.com/search.naver")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naverMap: DefaultSearchEngine {
        let name = "NaverMap"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://m.map.naver.com/search2/search.nhn")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var papago: DefaultSearchEngine {
        let name = "Papago"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://papago.naver.com/")!,
        queries: ["st": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var theCall: DefaultSearchEngine {
        let name = "TheCall"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: "https://www.thecall.co.kr/bbs/board.php")!,
        queries: ["stx": termsPlaceholder, "bo_table": "phone"],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var watcha: DefaultSearchEngine {
        let name = "Watcha"
        return DefaultSearchEngine(localizableName: name, engine: SearchEngine(
        name: localized(.name, from: name),
        shortcut: localized(.shortcut, from: name),
        baseUrl: URL(string: localized(.url, from: name))!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    
    // MARK: English engines
    
    static var naverEnglishDictionary: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Naver Dictionary",
        shortcut: "nd",
        baseUrl: URL(string: "https://korean.dict.naver.com/english/search.nhn")!,
        queries: ["sLn": "kr", "query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var rottenTomatoes: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Rotten Tomatoes",
        shortcut: "rt",
        baseUrl: URL(string: "https://www.rottentomatoes.com/search/")!,
        queries: ["search": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var googleImFeelingLucky: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "I'm Feeling Lucky",
        shortcut: "lu",
        baseUrl: URL(string: "https://www.google.com/search")!,
        queries: ["bntI": "1", "q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var yahooNews: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Yahoo News",
        shortcut: "yn",
        baseUrl: URL(string: "https://news.search.yahoo.com/search")!,
        queries: ["p": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var walmart: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Walmart",
        shortcut: "wal",
        baseUrl: URL(string: "https://www.walmart.com/search/")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var medium: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Medium",
        shortcut: "me",
        baseUrl: URL(string: "https://medium.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var wikivoyage: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Wikivoyage",
        shortcut: "wv",
        baseUrl: URL(string: "https://en.wikivoyage.org/wiki/Special:Search")!,
        queries: ["search": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var googleScholar: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Google Scholar",
        shortcut: "sc",
        baseUrl: URL(string: "https://scholar.google.com/scholar")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var weatherNetwork: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "The Weather Network",
        shortcut: "we",
        baseUrl: URL(string: "https://www.theweathernetwork.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var tumblr: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Tumblr",
        shortcut: "tu",
        baseUrl: URL(string: "https://www.tumblr.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var openStreetMap: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "OpenStreetMap",
        shortcut: "osm",
        baseUrl: URL(string: "https://www.openstreetmap.org/search")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var wordPress: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "WordPress",
        shortcut: "wp",
        baseUrl: URL(string: "https://en.search.wordpress.com/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var fileInfo: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "FileInfo",
        shortcut: "fi",
        baseUrl: URL(string: "https://fileinfo.com/extension/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var expedia: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Expedia",
        shortcut: "ex",
        baseUrl: URL(string: "https://www.expedia.com/Hotel-Search")!,
        queries: ["destination": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var eBay: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "eBay",
        shortcut: "e",
        baseUrl: URL(string: "https://www.ebay.com/sch/i.html")!,
        queries: ["_nkw": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var jstor: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "JSTOR",
        shortcut: "j",
        baseUrl: URL(string: "https://www.jstor.org/action/doBasicSearch")!,
        queries: ["Query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var etsy: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Etsy",
        shortcut: "et",
        baseUrl: URL(string: "https://www.etsy.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var wolframAlpha: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Wolfram|Alpha",
        shortcut: "wa",
        baseUrl: URL(string: "https://m.wolframalpha.com/input/")!,
        queries: ["i": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var steam: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Steam",
        shortcut: "s",
        baseUrl: URL(string: "https://store.steampowered.com/search/")!,
        queries: ["term": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var duckDuckGo: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "DuckDuckGo",
        shortcut: "d",
        baseUrl: URL(string: "https://www.duckduckgo.com/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var giphy: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Giphy",
        shortcut: "gif",
        baseUrl: URL(string: "https://giphy.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
//    static var oxfordDictionary: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
//        name: "Oxford Dictionary",
//        shortcut: "di",
//        baseUrl: URL(string: "https://en.oxforddictionaries.com/search")!,
//        queries: ["filter": "dictionary", "query": termsPlaceholder],
//        isEnabled: true,
//        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var dictionaryDotCom: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Dictionary.com",
        shortcut: "di",
        baseUrl: URL(string: "https://www.dictionary.com/browse/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var target: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Target",
        shortcut: "ta",
        baseUrl: URL(string: "https://www.target.com/s")!,
        queries: ["searchTerm": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var reddit: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Reddit",
        shortcut: "r",
        baseUrl: URL(string: "https://www.reddit.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var yahooAnswers: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Yahoo Answers",
        shortcut: "an",
        baseUrl: URL(string: "https://answers.search.yahoo.com/search")!,
        queries: ["p": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var pinterest: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Pinterest",
        shortcut: "p",
        baseUrl: URL(string: "https://www.pinterest.com/search/pins/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var webMd: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "WebMD",
        shortcut: "wmd",
        baseUrl: URL(string: "https://www.webmd.com/search/search_results/default.aspx")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var yelp: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Yelp",
        shortcut: "ye",
        baseUrl: URL(string: "https://yelp.com/search")!,
        queries: ["find_desc": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var oneDrive: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "OneDrive",
        shortcut: "od",
        baseUrl: URL(string: "https://onedrive.live.com/")!,
        queries: ["qt": "search", "q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var parcels: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Parcels",
        shortcut: "pa",
        baseUrl: URL(string: "http://parcelsapp.com/en/tracking/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var pandora: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Pandora",
        shortcut: "pan",
        baseUrl: URL(string: "https://www.pandora.com/search/\(termsPlaceholder)/all")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var imdb: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "IMDb",
        shortcut: "imdb",
        baseUrl: URL(string: "https://m.imdb.com/find")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var metacritic: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Metacritic",
        shortcut: "mc",
        baseUrl: URL(string: "https://www.metacritic.com/search/all/\(termsPlaceholder)/results")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var github: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Github",
        shortcut: "gh",
        baseUrl: URL(string: "https://github.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var genius: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Genius",
        shortcut: "ge",
        baseUrl: URL(string: "https://genius.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var spotify: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Spotify",
        shortcut: "sp",
        baseUrl: URL(string: "https://open.spotify.com/search/results/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var marketWatch: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "MarketWatch",
        shortcut: "mw",
        baseUrl: URL(string: "https://www.marketwatch.com/investing/stock/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var urbanDictionary: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Urban Dictionary",
        shortcut: "ud",
        baseUrl: URL(string: "https://www.urbandictionary.com/define.php")!,
        queries: ["term": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var downForEveryone: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Down For Everyone Or Just Me",
        shortcut: "down",
        baseUrl: URL(string: "https://downforeveryoneorjustme.com/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var yahoo: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Yahoo",
        shortcut: "ya",
        baseUrl: URL(string: "https://search.yahoo.com/search")!,
        queries: ["p": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var indeed: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Indeed",
        shortcut: "in",
        baseUrl: URL(string: "https://indeed.com/jobs")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var vimeo: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Vimeo",
        shortcut: "v",
        baseUrl: URL(string: "https://vimeo.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var quora: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Quora",
        shortcut: "qu",
        baseUrl: URL(string: "https://www.quora.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var costco: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Costco",
        shortcut: "c",
        baseUrl: URL(string: "https://www.costco.com/CatalogSearch")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
//    static var oxfordThesaurus: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
//        name: "Oxford Thesaurus",
//        shortcut: "th",
//        baseUrl: URL(string: "https://en.oxforddictionaries.com/search")!,
//        queries: ["query": termsPlaceholder, "filter": "thesaurus"],
//        isEnabled: true,
//        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var thesaurusDotCom: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Thesaurus.com",
        shortcut: "th",
        baseUrl: URL(string: "https://www.thesaurus.com/browse/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var internetArchive: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Internet Archive",
        shortcut: "ia",
        baseUrl: URL(string: "https://web.archive.org/web/*/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var mayoClinic: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Mayo Clinic",
        shortcut: "mayo",
        baseUrl: URL(string: "https://www.mayoclinic.org/search/search-results")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var zillow: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Zillow",
        shortcut: "z",
        baseUrl: URL(string: "https://www.zillow.com/homes/for_sale/\(termsPlaceholder)_rb/")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var googlePhotos: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Google Photos",
        shortcut: "ph",
        baseUrl: URL(string: "https://photos.google.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var amazonMusic: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Amazon Music",
        shortcut: "am",
        baseUrl: URL(string: "https://music.amazon.com/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var stackOverflow: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Stack Overflow",
        shortcut: "so",
        baseUrl: URL(string: "https://stackoverflow.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var googleNews: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Google News",
        shortcut: "gn",
        baseUrl: URL(string: "https://news.google.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var googleReverseImage: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "Reverse Image",
        shortcut: "ri",
        baseUrl: URL(string: "https://www.google.com/searchbyimage")!,
        queries: ["image_url": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var espn: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "ESPN",
        shortcut: "es",
        baseUrl: URL(string: "https://www.espn.com/search/results")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    
    // MARK: Korean engines
    
    static var ridiBooks: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "리디북스",
        shortcut: "ㄹㄷ",
        baseUrl: URL(string: "https://ridibooks.com/search/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naverAcademic: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이버 학술정보",
        shortcut: "ㅎㅅ",
        baseUrl: URL(string: "https://academic.naver.com/search.naver")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naverNews: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이버 뉴스",
        shortcut: "ㄴㅅ",
        baseUrl: URL(string: "https://search.naver.com/search.naver")!,
        queries: ["query": termsPlaceholder, "where": "news"],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var coupang: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "쿠팡",
        shortcut: "ㅋ",
        baseUrl: URL(string: "https://coupang.com/np/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var realEstate114: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "부동산114",
        shortcut: "ㅂㄷㅅㅇ",
        baseUrl: URL(string: "https://m.r114.com/Search/m5/m520.asp")!,
        queries: ["dqSearchTerm": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var everytime: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "에브리타임",
        shortcut: "ㅇㅂㄹ",
        baseUrl: URL(string: "https://everytime.kr/search/all/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var daum: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "다음",
        shortcut: "ㄷ",
        baseUrl: URL(string: "https://search.daum.net/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var inven: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "인벤",
        shortcut: "ㅇㅂ",
        baseUrl: URL(string: "http://inven.co.kr/search/webzine/top/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var zum: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "줌",
        shortcut: "줌",
        baseUrl: URL(string: "http://search.zum.com/search.zum")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var ssg: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "쓱닷컴",
        shortcut: "ㅆ",
        baseUrl: URL(string: "http://www.ssg.com/search.ssg")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var hotTracks: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "핫트랙스",
        shortcut: "ㅎㅌ",
        baseUrl: URL(string: "http://m.hottracks.co.kr/m/search/searchMain")!,
        queries: ["searchTerm": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var afreecaTv: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "아프리카TV",
        shortcut: "ㅇㅍ",
        baseUrl: URL(string: "http://afreecatv.com/#/search/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var dcInside: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "디시인사이드",
        shortcut: "ㄷㅅ",
        baseUrl: URL(string: "https://m.dcinside.com/search")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var knowledgeIn: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "지식iN",
        shortcut: "ㅈㅅ",
        baseUrl: URL(string: "https://m.kin.naver.com/mobile/search/searchList.nhn")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var enuri: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "에누리",
        shortcut: "ㅇㄴㄹ",
        baseUrl: URL(string: "http://enuri.com/search.jsp")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var yes24: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "예스24",
        shortcut: "예스",
        baseUrl: URL(string: "http://m.yes24.com/search/search")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var tripAdvisor: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "트립어드바이저",
        shortcut: "ㅌㄹ",
        baseUrl: URL(string: "https://www.tripadvisor.co.kr/Search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var interpark: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "인터파크",
        shortcut: "ㅇㅌㅍ",
        baseUrl: URL(string: "http://m.shop.interpark.com/search_all/")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naverDictionary: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이버 사전",
        shortcut: "ㅅㅈ",
        baseUrl: URL(string: "https://ko.dict.naver.com/#/search?query=\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var saramin: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "사람인",
        shortcut: "ㅅㄹ",
        baseUrl: URL(string: "https://saramin.co.kr/zf_user/search")!,
        queries: ["searchword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naverBlog: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이버 블로그",
        shortcut: "ㅂㄹㄱ",
        baseUrl: URL(string: "http://m.blog.naver.com/SectionPostSearch.nhn")!,
        queries: ["searchValue": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var egloos: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "이글루스",
        shortcut: "ㅇㄱ",
        baseUrl: URL(string: "http://valley.egloos.com/m/search")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var melon: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "멜론",
        shortcut: "ㅁㄹ",
        baseUrl: URL(string: "https://m.app.melon.com/search/searchMcom.htm")!,
        queries: ["s": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naverCafe: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이버 카페",
        shortcut: "ㅋㅍ",
        baseUrl: URL(string: "https://m.cafe.naver.com/SectionArticleSearch.nhn")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var bugs: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "벅스",
        shortcut: "ㅂ",
        baseUrl: URL(string: "https://m.bugs.co.kr/search/track")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var aladin: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "알라딘",
        shortcut: "ㅇㄹ",
        baseUrl: URL(string: "https://www.aladin.co.kr/search/wsearchresult.aspx")!,
        queries: ["SearchWord": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var tistory: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "티스토리",
        shortcut: "ㅌㅅ",
        baseUrl: URL(string: "https://tistory.com/m/search/")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var ppomPpu: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "뽐뿌",
        shortcut: "ㅃ",
        baseUrl: URL(string: "https://m.ppomppu.co.kr/new/search_result.php")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "euc-kr", value: .EUC_KR)))}
    
    static var tmon: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "티몬",
        shortcut: "ㅌㅁ",
        baseUrl: URL(string: "http://search.tmon.co.kr/search")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var nate: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이트",
        shortcut: "ㄴㅇㅌ",
        baseUrl: URL(string: "https://search.daum.net/nate")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naverRealEstate: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이버 부동산",
        shortcut: "ㅂㄷㅅ",
        baseUrl: URL(string: "https://m.land.naver.com/search/result/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var daumDictionary: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "다음 사전",
        shortcut: "ㄷㅇㅅ",
        baseUrl: URL(string: "https://dic.daum.net/search.do")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var namuwiki: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "나무위키",
        shortcut: "ㄴㅁㅇ",
        baseUrl: URL(string: "https://namu.wiki/go/\(termsPlaceholder)")!,
        queries: [:],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var albamon: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "알바몬",
        shortcut: "ㅇㅂㅁ",
        baseUrl: URL(string: "http://m.albamon.com/Search")!,
        queries: ["kwd": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naverStocks: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이버 증권",
        shortcut: "ㅈㄱ",
        baseUrl: URL(string: "https://m.stock.naver.com/searchItem.nhn")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var gmarket: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "지마켓",
        shortcut: "ㅈㅁ",
        baseUrl: URL(string: "http://search.gmarket.co.kr/search.aspx")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "euc-kr", value: .EUC_KR)))}
    
    static var kyoboBooks: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "교보문고",
        shortcut: "ㄱㅂ",
        baseUrl: URL(string: "https://search.kyobobook.co.kr/mobile/search")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var hanaTour: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "하나투어",
        shortcut: "ㅎㄴ",
        baseUrl: URL(string: "http://m.hanatour.com/search/search.hnt")!,
        queries: ["searchQuery": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var natePann: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이트판",
        shortcut: "ㄴㅇㅌㅍ",
        baseUrl: URL(string: "https://m.pann.nate.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var elevenStreet: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "11번가",
        shortcut: "1",
        baseUrl: URL(string: "http://m.11st.co.kr/MW/Search/searchProduct.tmall")!,
        queries: ["searchKeyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "euc-kr", value: .EUC_KR)))}
    
    static var auction: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "옥션",
        shortcut: "ㅇㅅ",
        baseUrl: URL(string: "http://browse.auction.co.kr/search")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var naverImages: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이버 이미지",
        shortcut: "ㅇ",
        baseUrl: URL(string: "https://search.naver.com/search.naver")!,
        queries: ["query": termsPlaceholder, "where": "image"],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var daumCafe: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "다음 카페",
        shortcut: "ㄷㅇㅋ",
        baseUrl: URL(string: "http://m.cafe.daum.net/_search")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var ruliweb: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "루리웹",
        shortcut: "ㄹㄹ",
        baseUrl: URL(string: "https://m.ruliweb.com/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var todayHumor: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "오늘의유머",
        shortcut: "ㅇㄴ",
        baseUrl: URL(string: "http://m.todayhumor.co.kr/list.php")!,
        queries: ["kind": "search", "keyword": termsPlaceholder, "keyfield": "subject"],
        isEnabled: true,
        encoding: CharacterEncoding(name: "iso-8859-1", value: .isoLatin1)))}
    
    static var naverShopping: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "네이버 쇼핑",
        shortcut: "ㅅㅍ",
        baseUrl: URL(string: "https://msearch.shopping.naver.com/search/all")!,
        queries: ["query": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var jobKorea: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "잡코리아",
        shortcut: "ㅈㅋ",
        baseUrl: URL(string: "https://www.jobkorea.co.kr/Search/")!,
        queries: ["stext": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var danawa: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "다나와",
        shortcut: "ㄷㄴ",
        baseUrl: URL(string: "https://search.danawa.com/dsearch.php")!,
        queries: ["keyword": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    static var clien: DefaultSearchEngine { return DefaultSearchEngine(engine: SearchEngine(
        name: "클리앙",
        shortcut: "ㅋㄹ",
        baseUrl: URL(string: "https://clien.net/service/search")!,
        queries: ["q": termsPlaceholder],
        isEnabled: true,
        encoding: CharacterEncoding(name: "utf-8", value: .utf8)))}
    
    
//    private static func localized(name: String) -> String {
//        return NSLocalizedString("SearchEngine.defaultEngines-\(name)Name", comment: "")
//    }
//
//    private static func localized(shortcutFrom name: String) -> String {
//        return NSLocalizedString("SearchEngine.defaultEngines-\(name)Shortcut", comment: "")
//    }
//
//    private static func localized(urlFrom name: String) -> String {
//        return NSLocalizedString("SearchEngine.defaultEngines-\(name)URL", comment: "")
//    }
    
}
