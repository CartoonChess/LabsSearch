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
        // Don't make any changes unless there are actually queries
        // This is done for backward compatibility reasons
        if queries.isEmpty {
            return self
        } else {
            var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
            components?.queryItems = queries.map {
                URLQueryItem(name: $0.0, value: $0.1)
            }
            return components?.url
        }
    }
    
    
    /// Takes a base URL, a set of queries, and a search term string, and returns the URL with the queries appended. The search term string will appear anywhere in the URL in place of the value passed in as `replacing`; if this property is omitted, the string will replace any and all empty query keys.
    ///
    /// - Parameters:
    ///   - terms: The search term string to be used in the URL.
    ///   - queries: A key-value dictionary of queries.
    ///   - textToReplace: The value to replace with `terms`. This parameter is optional; omitting it will set the search term string as the value to any passed query keys which lack one.
    /// - Returns: The synthesized URL, or `nil` if there are any issues.
    func withSearchTerms(_ terms: String, using queries: [String: String], replacing textToReplace: String = "") -> URL? {
        // Make queries mutable
        var queries = queries
        
        queries.replaceValue(textToReplace, with: terms)
        
//        return self.withQueries(queries)
        // First, check for placeholder in queries (most typical case)
        guard let url = self.withQueries(queries) else {
            print(.x, "Could not append queries to base URL.")
            return nil
        }
        
        // Then, check for terms placeholder in base URL (less typical cases)
        guard let encodedTerms = terms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print(.x, "Could not percent encode terms.")
            return url
        }
        // TODO: Should this be `.path` instead?
        let urlString = url.absoluteString.replacingOccurrences(of: SearchEngines.shared.termsPlaceholder, with: encodedTerms)
        return URL(string: urlString)
    }
    
}
