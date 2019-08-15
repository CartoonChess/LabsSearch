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
    /// - Parameters:
    ///   - queries: Dictionary of keys and values to be added to the URL.
    ///   - encoding: A `CharacterEncoding`. Optional.
    /// - Returns: A URL, if queries can be appended in the correct format, otherwise `nil`.
    ///
    /// As this function uses `URLComponents`, there is some automatic percent encoding happening here if the encoding is UTF-8 or not set. If a different encoding is provided, the function will expect manually percent-encoded queries. This has the potential to cause a fatal error, so care should be taken.
    func withQueries(_ queries: [String: String], characterEncoding encoding: CharacterEncoding? = nil) -> URL? {
        // Don't make any changes unless there are actually queries
        // This is done for backward compatibility reasons
        guard !queries.isEmpty else {
            return self
        }
        
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        
        // Determine the best way to handle the queries
        if encoding?.value == .utf8 || encoding?.value == nil {
            // Use the basic function for UTF
            components?.queryItems = queries.map {
                URLQueryItem(name: $0.0, value: $0.1)
            }
            
        } else if #available(iOS 11.0, *) {
            // Preserve percent encoding for non-UTF URLs
            print(.d, "percentEncodedQueryItems in withQueries")
            
            // Make sure the query is actually percent-encoded properly, or else the app will crash
            // Get all query keys and values into one string
            var testQuery = queries.keys.joined()
            testQuery += queries.values.joined()
            // Check for safety
            guard queryIsProperlyPercentEncoded(testQuery, encoding: encoding) else { return nil }
            
            // Safely (hopefully) assign manually percent encoded query items
            components?.percentEncodedQueryItems = queries.map {
                URLQueryItem(name: $0.0, value: $0.1)
            }
        } else {
            // Non-UTF but iOS too old
            
            // Make sure the query is actually percent-encoded properly, or else the app will crash
            // Get all query keys and values into one string
            let queryPairs = queries.map { "\($0.0)=\($0.1)" }
            let queryString = queryPairs.joined(separator: "&")
            // Check for safety
            guard queryIsProperlyPercentEncoded(queryString, encoding: encoding) else { return nil }
            
            // Safely (hopefully) assign manually constructed query
            components?.percentEncodedQuery = queryString
        }
    
        return components?.url
    }
    
    /// Checks that a query is properly percent encoded.
    ///
    /// - Parameters:
    ///   - query: A string representing the full query. This can be formatted to separate keys and values and those pairs with `=` and `&`, but for the purpose of testing, isn't strictly necessary.
    ///   - encoding: The `String.Encoding`, if available. Optional; only used for providing error details.
    /// - Returns: `true` if the string is a properly encoded query, otherwise `false`.
    ///
    /// Note that this function does not check whether percent-encoded characters are valid UTF-8 characters, nor does it compare against any encoding passed to it. This function only checks that the query will not cause a fatal error when assigned to `URLComponents.percentEncodedQuery` or similar.
    private func queryIsProperlyPercentEncoded(_ query: String, encoding: CharacterEncoding? = nil) -> Bool {
        // Create a testable URL
        let baseUrl = "https://www.example.com/?"
        // If all queries are percent encoded, this should pass
        if URLComponents(string: baseUrl + query) != nil {
            // Note: Query items could still contain query characters (?&=), but it doesn't crash
            print(.i, "Percent encoded query items can be used safely.")
            return true
        } else {
            print(.x, "URL.withQueries() expects properly percent-encoded query items when using \(encoding?.name ?? "nil") encoding. URL will be set to nil to avoid a fatal error, but calling URL.withQueries() this way is unintended and may result in unexpected behaviour.")
            return false
        }
    }
    
// Below is an earlier attempt at manually checking percent encoding, before the URLComponents method was discovered.
    
//    func safeQueryItem(from item: String) -> String? {
//        // We will allow the % sign for now, and check for proper encoding later on
//        let allowedCharacters = CharacterSet.urlQueryItemAllowed.union(CharacterSet(charactersIn: "%"))
//
//        // First check that there are no illegal characters (other than % sign)
//        if !allowedCharacters.isSuperset(of: CharacterSet(charactersIn: item)) {
//            // If the item contains illegal characters, attempt to percent encode it (though this will be UTF-8)
//            guard let safeItem = item.addingPercentEncoding(withAllowedCharacters: .urlQueryItemAllowed) else {
//                // If the item cannot be encoded, we have to give up altogether
//                print(.x, "Cannot percent encode query item \"\(item)\".")
//                //            properlyPercentEncoded = false
//                return nil
//            }
//            //        safeQueries.removeValue(forKey: key)
//            //        safeQueries[safeKey] = value
//            return safeItem
//        } else {
//            // If the item was safe to begin with, return unmodified string
//            return item
//        }
//    }
//
//
//    func queryItemIsProperlyPercentEncoded(_ item: String) -> Bool {
//        //    // If the item begins with a percent sign, note for later
//        //    var beginsWithPercentSign = false
//        //    if item.first == "%" { beginsWithPercentSign = true }
//
//        // Then, split the string into pieces using percent sign as a delimiter
//        let components = item.split(separator: "%", maxSplits: Int.max, omittingEmptySubsequences: false)
//        //    let foo = item.components(separatedBy: "%")
//        //    // If there wasn't a leading percent sign in the original string, delete the first component
//        //    if beginsWithPercentSign { components.dropFirst() }
//        let testableComponents = components.dropFirst()
//
//        // Check that all values after percent signs are valid percent encoding (%XX), where X is hex
//        for component in testableComponents {
//            // First check that the component is at least two characters long
//            //        let length = component.count
//            let prefix = component.prefix(2)
//            //        print(.i, "Length of \"\(component)\" is \(length).")
//            //        guard length >= 2 else {
//            guard prefix.count == 2 else {
//                print(.x, "Percent sign is followed by fewer than two characters (\"\(component)\").")
//                return false
//            }
//            //        // Cut off all characters after the first two in every component
//            //        component.dropLast(length - 2)
//            //        let testableComponent = component.range
//            // Test that no component returns nil using Int(component, radix: 16)
//            //        let hex = Int(component, radix: 16)
//            guard Int(prefix, radix: 16) != nil else {
//                print(.x, "Percent-encoded character \"%\(prefix)\" is not proper hexadecimal.")
//                return false
//            }
//        }
//
//        // If no problematic encoding was found, this string is safe
//        return true
//    }
//
//    // ... withQueries ... //
//    // Make a copy of queries so we can percent encode them if necessary
//    var safeQueries = queries
//
//    // Make sure the query is actually percent-encoded properly, or else the app will crash
//    var properlyPercentEncoded = true
//    //// We will allow the % sign for now, and check for proper encoding later on
//    //let allowedCharacters = CharacterSet.urlQueryItemAllowed.union(CharacterSet(charactersIn: "%"))
//
//    //// Get all query keys and values into one array to check them all
//    //var queryItems: [String] = queries.keys.map { $0 }
//    //queryItems.append(contentsOf: queries.values.map { $0 })
//
//    for (key, value) in safeQueries {
//        // Check that key doesn't contain any illegal characters
//        guard let safeKey = safeQueryItem(from: key) else {
//            // If the key cannot be encoded, we have to give up altogether
//            properlyPercentEncoded = false
//            break
//        }
//        // Update the queries if the key was reencoded
//        if safeKey != key {
//            safeQueries.removeValue(forKey: key)
//            safeQueries[safeKey] = value
//        }
//
//        // Value next
//        guard let safeValue = safeQueryItem(from: value) else {
//            properlyPercentEncoded = false
//            break
//        }
//        if safeValue != value {
//            safeQueries[safeKey] = safeValue
//        }
//    }
//
//    // If there are no illegal characters, check that any % signs represent properly encoded characters
//    if properlyPercentEncoded {
//        for (key, value) in safeQueries {
//            // If string ends with a percent sign, fail
//            guard key.last != "%" && value.last != "%" else {
//                print(.x, "Key or value ends with a percent sign, which is illegal.")
//                properlyPercentEncoded = false
//                break
//            }
//
//            // Check if there are any percent signs, and simply move on if there aren't
//            if key.contains("%") {
//                // Check that any encoded characters are encoded correctly
//                print(.i, "Key \"\(key)\" contains a percent sign; verifying encoding.")
//                guard queryItemIsProperlyPercentEncoded(key) else {
//                    properlyPercentEncoded = false
//                    break
//                }
//            }
//            if value.contains("%") {
//                print(.i, "Value \"\(value)\" contains a percent sign; verifying encoding.")
//                guard queryItemIsProperlyPercentEncoded(value) else {
//                    properlyPercentEncoded = false
//                    break
//                }
//            }
//        }
//    }
//    // Finally, we can safely assign the query items if they are properly percent encoded
//    if properlyPercentEncoded {
//        // existing code in main app
//        print(.o, "All queries are properly percent encoded; proceeding to affix to URL.")
//    } else {
//        print(.x, "Queries could not be assigned.")
//    }
    
    
    
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
