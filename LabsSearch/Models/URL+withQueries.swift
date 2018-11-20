//
//  URL+withQueries.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/04.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

extension URL {
    
    /// Adds query items to a given URL.
    ///
    /// - Parameter queries: Dictionary of keys and values to be added to the URL.
    /// - Returns: An optional URL with queries appended in the correct format.
    ///
    /// As this function uses `URLComponents`, there is some automatic percent encoding happening here. Be sure to test each case so that double encoding etc. does not occur.
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map {
            URLQueryItem(name: $0.0, value: $0.1)
        }
        return components?.url
    }
    
    
    /// Takes a base URL, a set of queries, and a search term string, and returns the URL with the queries appended. The search term string will appear in the queries in place of the value passed in as `replacing`; if this property is omitted, the string will replace any and all empty keys.
    ///
    /// - Parameters:
    ///   - terms: The search term string to be used in the URL query.
    ///   - queries: A key-value dictionary of queries.
    ///   - textToReplace: The value to replace with `terms`. This parameter is optional; omitting it will set the search term string as the value to any keys which lack one.
    /// - Returns: The synthesized URL, or `nil` if there are any issues.
    func withSearchTerms(_ terms: String, using queries: [String: String], replacing textToReplace: String = "") -> URL? {
        // Make queries mutable
        var queries = queries
        
        queries.replaceValue(textToReplace, with: terms)
        
        return self.withQueries(queries)
    }
    
}
