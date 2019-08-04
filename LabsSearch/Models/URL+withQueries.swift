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
    func withQueries(_ queries: [String: String], characterEncoding encoding: CharacterEncoding? = nil) -> URL? {
        // Don't make any changes unless there are actually queries
        // This is done for backward compatibility reasons
        guard !queries.isEmpty else {
            return self
        }
        
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
//        components?.queryItems = queries.map {
//            URLQueryItem(name: $0.0, value: $0.1)
//        }
        
        // Determine the best way to handle the queries
        if encoding?.value == .utf8 || encoding?.value == nil {
            // Use the basic function for UTF
            components?.queryItems = queries.map {
                URLQueryItem(name: $0.0, value: $0.1)
            }
        } else if #available(iOS 11.0, *) {
            // Preserve percent encoding for non-UTF URLs
            print(.d, "percentEncodedQueryItems in withQueries")
            components?.percentEncodedQueryItems = queries.map {
                URLQueryItem(name: $0.0, value: $0.1)
            }
        } else {
            // Non-UTF but iOS too old
            var queryString = ""
            for query in queries {
                let query = "\(query.key)=\(query.value)"
                if !queryString.isEmpty { queryString += "&" }
                queryString += query
            }
            components?.percentEncodedQuery = queryString
        }
    
        return components?.url
    }
    
    
//    /// Takes a base URL, a set of queries, and a search term string, and returns the URL with the queries appended. The search term string will appear anywhere in the URL in place of the value passed in as `replacing`; if this property is omitted, the string will replace any and all empty query keys.
//    ///
//    /// - Parameters:
//    ///   - terms: The search term string to be used in the URL.
//    ///   - queries: A key-value dictionary of queries.
//    ///   - textToReplace: The value to replace with `terms`. This parameter is optional; omitting it will set the search term string as the value to any passed query keys which lack one.
//    ///   - encoding: The text encoding to use, if the URL doesn't support UTF-8. Optional.
//    /// - Returns: The synthesized URL, or `nil` if there are any issues.
//    func withSearchTerms(_ terms: String, using queries: [String: String], replacing textToReplace: String = "", encoding: CharacterEncoding? = nil) -> URL? {
//        // Create a mutable copy of terms
//        var terms = terms
//
//        // If the encoding for the engine is not UTF-8, encode the terms
//        if let encoding = encoding {
//            // Encode terms in new character encoding
//            let encoder = CharacterEncoder(encoding: encoding)
//            terms = encoder.encode(terms)
//
//            // Encode plus sign
//            terms = terms.replacingOccurrences(of: "+", with: "%2B")
//
//            // Append queries to URL
//            guard let url = self.withQueries(queries) else {
//                print(.x, "Could not append queries to base URL.")
//                return nil
//            }
//
//            // Get URL string with terms
//            let urlString = url.absoluteString.replacingOccurrences(of: SearchEngines.shared.termsPlaceholder, with: terms)
//
//            // Return URL and ignore rest of function
//            return URL(string: urlString)
//        }
//
//        // Replace any "+" in user's terms with unlikely string
//        //- We will replace this with the proper "%2B" encoding at the end of this function
//        let plusPlaceholder = String(SearchEngines.shared.termsPlaceholder.reversed())
//        terms = terms.replacingOccurrences(of: "+", with: plusPlaceholder)
//
////        let hashPlaceholder = "1234567890"
////        terms = terms.replacingOccurrences(of: "#", with: hashPlaceholder)
//
//        let queries = queries.withValueReplaced(textToReplace, replaceWith: terms)
//
//        // First, check for placeholder in queries (most typical case)
//        guard let url = self.withQueries(queries) else {
//            print(.x, "Could not append queries to base URL.")
//            return nil
//        }
//
//        // Then, check for terms placeholder in base URL (less typical cases)
////        guard let encodedTerms = terms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//        guard let encodedTerms = terms.addingPercentEncoding(withAllowedCharacters: .urlSafeCharacters) else {
//            print(.x, "Could not percent encode terms.")
//            return url
//        }
//        // TODO: Should this be `.path` instead?
//        var urlString = url.absoluteString.replacingOccurrences(of: SearchEngines.shared.termsPlaceholder, with: encodedTerms)
//
//        // Replace "+" with "%2B", as URLComponents and addingPercentEncoding will miss this
//        //- This finishes the process started at the beginning of this function
//        // TODO: Provide option in UrlDetails to toggle this on a per-engine basis
//        urlString = urlString.replacingOccurrences(of: plusPlaceholder, with: "%2B")
////        urlString = urlString.replacingOccurrences(of: hashPlaceholder, with: "#")
//
//        return URL(string: urlString)
//    }
    
    /// Takes a base URL, a set of queries, and a search term string, and returns the URL with the queries appended. The search term string will appear anywhere in the URL in place of the value passed in as `replacing`; if this property is omitted, the string will replace any and all empty query keys.
    ///
    /// - Parameters:
    ///   - terms: The search term string to be used in the URL.
    ///   - queries: A key-value dictionary of queries.
    ///   - textToReplace: The value to replace with `terms`. This parameter is optional; omitting it will set the search term string as the value to any passed query keys which lack one.
    ///   - encoding: The text encoding to use, if the URL doesn't support UTF-8. Optional.
    /// - Returns: The synthesized URL, or `nil` if there are any issues.
    func withSearchTerms(_ terms: String, using queries: [String: String], replacing textToReplace: String = "", encoding: CharacterEncoding? = nil) -> URL? {
        // Create mutable copies
        var encodedTerms = terms
        var queries = queries
        // Keep track of whether we're really using a different encoding or not, since it might fall back to utf-8
        var usingUnicode = true
        
        // If the encoding for the engine is not UTF-8, encode the terms
        if let encoding = encoding {
            // Encode terms in new character encoding
            let encoder = CharacterEncoder(encoding: encoding)
            encodedTerms = encoder.encode(terms)
            
            // If the terms have changed, we must preserve the new encoding
            if encodedTerms != terms {
                usingUnicode = false
            }
        }
        
        // Replace any "+" in user's terms with unlikely string
        //- We will replace this with the proper "%2B" encoding at the end of this function
        let plusPlaceholder = String(SearchEngines.shared.termsPlaceholder.reversed())
        encodedTerms = encodedTerms.replacingOccurrences(of: "+", with: plusPlaceholder)
        
        //        let hashPlaceholder = "1234567890"
        //        terms = terms.replacingOccurrences(of: "#", with: hashPlaceholder)
    
        if usingUnicode {
            queries = queries.withValueReplaced(textToReplace, replaceWith: encodedTerms)
        }
        
        // First, check for placeholder in queries (most typical case)
        guard let url = self.withQueries(queries, characterEncoding: encoding) else {
            print(.x, "Could not append queries to base URL.")
            return nil
        }
        
        // Then, check for terms placeholder in base URL (less typical cases)
        //        guard let encodedTerms = terms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        if usingUnicode {
            guard let percentEncodedTerms = encodedTerms.addingPercentEncoding(withAllowedCharacters: .urlSafeCharacters) else {
                print(.x, "Could not percent encode terms.")
                return url
            }
            encodedTerms = percentEncodedTerms
        }
        // TODO: Should this be `.path` instead?
        var urlString = url.absoluteString.replacingOccurrences(of: SearchEngines.shared.termsPlaceholder, with: encodedTerms)
        
        // Replace "+" with "%2B", as URLComponents and addingPercentEncoding will miss this
        //- This finishes the process started at the beginning of this function
        // TODO: Provide option in UrlDetails to toggle this on a per-engine basis
        urlString = urlString.replacingOccurrences(of: plusPlaceholder, with: "%2B")
        //        urlString = urlString.replacingOccurrences(of: hashPlaceholder, with: "#")
        
        return URL(string: urlString)
    }
    
}
