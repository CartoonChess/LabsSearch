//
//  UrlController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/11.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

/// Provides functions related to URL validation when adding and editing search engines.
struct UrlController {
    
    // MARK: - Properties
    
    /// The default value used to detect the search term key in URL queries.
    let magicWord = "123"
    
    // State of the current URL/magic word combo:
    // False cascades down to details (magic word), true bubbles up to basics (URL)
    
    // If the URL is invalid, all other state values are also false
    var urlIsValid = false {
        willSet {
            if !newValue {
                engineIsTestable = false
                customMagicWordIsInUrl = false
            }
        }
    }
    // If the engine is testable, the URL is also valid; if not, the custom word is also not there
    var engineIsTestable = false {
        willSet {
            if newValue {
                urlIsValid = true
            } else {
                customMagicWordIsInUrl = false
            }
        }
    }
    // If a custom magic word is in the URL, all other state values are also true
    var customMagicWordIsInUrl = false {
        willSet {
            if newValue {
                urlIsValid = true
                engineIsTestable = true
            }
        }
    }
    
    
    // MARK: - Methods
    
    
    /// Deterines if a supplied string represents a URL that is valid for both the OS and the app context in which it is presented.
    ///
    /// - Parameters:
    ///   - string: The string representing a URL. If empty or `nil`, this function will also return `nil`.
    ///   - encoder: A `CharacterEncoder` object, if available.
    ///   - schemeIsValid: A closure which receives a URL object, and which expects a boolean value based on whether the scheme is compatible within the current app content. Optional; defaults to `true`.
    ///   - url: The URL object to be passed to the enclosure.
    /// - Returns: A URL object if all checks are passed, otherwise `nil`.
    ///
    /// This function will check that the string is not nil and that it conforms to URL expectations. It will then pass a percentage encoded URL to the completion handler, where it expects the calling view to return a boolean value based on whether the app can open the URL based on its scheme (http, etc.).
//    func validUrl(from string: String?, characterEncoder encoder: CharacterEncoder? = nil, schemeIsValid: (_ url: URL) -> Bool) -> URL? {
    func validUrl(from string: String?, characterEncoder encoder: CharacterEncoder? = nil, schemeIsValid: ((_ url: URL) -> Bool)? = nil) -> URL? {
        if let urlText = string,
            let url = urlText.encodedUrl(characterEncoder: encoder),
            schemeIsValid?(url) ?? true {
            return url
        } else {
            // Return nil if any conditions are not met
            return nil
        }
    }
    
    
    /// Tries to find the magic word in the URL.
    ///
    /// - Parameters:
    ///   - url: Full URL.
    ///   - magicWord: The default magic word if not supplied, otherwise a custom string.
    /// - Returns: `true` or `false`, depending on whether the magic word is found.
    func detectMagicWord(in url: URL, magicWord customMagicWord: String? = nil) -> Bool {
        // Get queries as dictionary
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                print(.x, "Failed to split URL into components.")
                return false
        }
        let queries = components.queryDictionary()

        // Use the default magic word, unless a custom one was provided
        let magicWord = customMagicWord ?? self.magicWord

        // If no query items are detected, let this run once and then silently fail
        for (_, value) in queries {
            if value == magicWord {
                return true
            }
        }

        // If we make it through the loop without returning, check for magic word in base URL
        
//        if url.absoluteString.contains(magicWord) {
        guard let baseUrl = components.withoutQueries() else {
            print(.x, "Failed to remove queries from base URL.")
            return false
        }
        
        if baseUrl.absoluteString.contains(magicWord) {
            return true
        } else {
            return false
        }
    }
    
    
    /// Prepare a URL and its queries for insertion into an engine object.
    ///
    /// - Parameters:
    ///   - urlString: The URL, with queries, as a string. If `nil`, this function will fail silently.
    ///   - customMagicWord: The custom magic word found in a query value. If you do not supply this value, the default magic word will be used instead.
    ///   - completion: Sends the `baseUrl` and `queries` for use with `updateUrlDetails()`.
    ///   - baseUrl: The URL string converted to a URL object, minus queries.
    ///   - queries: A dictionary of the URL's key-value queries.
    func willUpdateUrlDetails(url urlString: String?, magicWord customMagicWord: String? = nil, characterEncoder encoder: CharacterEncoder? = nil, completion: (_ baseUrl: URL?, _ queries: [String: String]) -> Void) {
        print(.o, "Getting updated URL to pass back to AddEdit VC.")
        
        guard let urlString = urlString,
            let urlWithMagicWord = urlString.encodedUrl(characterEncoder: encoder) else {
                print(.x, "Could not return to Add/Edit VC because text fields failed to unwrap or could not be converted to URL.")
                return
        }
        
        let magicWord: String
        
        // Use default magic word if found in URL, otherwise use custom
        // This check is a little bit weird given that we now have customMagicWordIsInUrl,
        //- but it double checks for sanity and it deals with the arguments optional.
        // Note: This will have to be changed if we ever see a URL which coincidentally contains the magic word
        if detectMagicWord(in: urlWithMagicWord) {
            magicWord = self.magicWord
        } else if let customMagicWord = customMagicWord {
            magicWord = customMagicWord
        } else {
            // TODO: Will the action extension choke here if the default magic word is missing?
            //- It shouldn't, because we should never get here if the engine isn't testable
            print(.x, "Could not update URL details because no magic word was found in queries.")
            return
        }
        
        // Split text field into URL components and get queries
//        guard let urlComponents = URLComponents(url: urlWithMagicWord, resolvingAgainstBaseURL: true),
//            let queryDictionary = urlComponents.queryDictionary() else {
//                print(.x, "Could not get URL components, or failed to extract queries.")
//                return
//        }
        
        guard let urlComponents = URLComponents(url: urlWithMagicWord, resolvingAgainstBaseURL: true) else {
                print(.x, "Could not get URL components.")
                return
        }
        
        // Determine the best way to handle the queries
        var queryDictionary: [String: String]
        if encoder?.encoding.value == .utf8 || encoder == nil {
            // Use the basic function for UTF
            // This function no longer returns a nil value; it should return an empty dictionary when no queries present
            queryDictionary = urlComponents.queryDictionary()
        } else if #available(iOS 11.0, *) {
            // Preserve percent encoding for non-UTF URLs
            // Query items can be get with percent encoding only in later versions of iOS
            queryDictionary = urlComponents.queryDictionary(keepPercentEncoding: true)
        } else {
            // Non-UTF but iOS too old; custom code ahead
            // Queries are non-UTF percent encoded, but these cannot be fetched before iOS 11
            let queryItems = urlComponents.percentEncodedQuery?.components(separatedBy: "&") ?? []
            queryDictionary = [:]
            
            for item in queryItems {
                let side = item.components(separatedBy: "=")
                queryDictionary[side[0]] = side[1]
            }
        }
        
        // Replace the magic word in query (if present) with the terms placeholder before passing it back
        let queries = queryDictionary.withValueReplaced(magicWord, replaceWith: SearchEngines.shared.termsPlaceholder)
//        print(.d, "queries: \(queries)")
        
        // Get URL without queries and replace magic word (if present)
        // TODO: This seems likely to break things. Perhaps it should be done earlier?
        guard let baseUrl = urlComponents.withoutQueries() else {
            print(.x, "Failed to remove queries from base URL.")
            return
        }
        let baseUrlString = baseUrl.absoluteString.replacingOccurrences(of: magicWord, with: SearchEngines.shared.termsPlaceholder)
        guard let baseUrlWithTermsPlaceholder = URL(string: baseUrlString) else {
            print("Failed to create URL with terms placeholder.")
            return
        }
        
        // Call completion handler, which should call updateUrlDetails()
        completion(baseUrlWithTermsPlaceholder, queries)
    }
    
    
}
