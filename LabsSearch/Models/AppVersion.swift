//
//  AppVersion.swift
//  Chears
//
//  Created by Xcode on ’19/08/26.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

/// Get the version number of the app.
struct AppVersion {
    
    /// Returns the compile date in GMT.
    static var compileDate: Date {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date {
            return infoDate
        }
        
        return Date()
    }
    
    /// A formatted version of the compile date, in the current time zone.
    static var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: compileDate)
    }
    
    /// A formatted version of the compile time.
    static var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: compileDate)
    }
    
    /// The app's version number, or a "?" if anything has gone wrong.
    static var number: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }
    
    /// The app's build number, or a "?" if anything has gone wrong.
    static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }
    
}
