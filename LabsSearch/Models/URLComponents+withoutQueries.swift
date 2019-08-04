//
//  URLComponents+withoutQueries.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/03.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

extension URLComponents {
    
    /// Returns a URL without queries.
    ///
    /// - Returns: URL object without queries, or `nil` if the URL can't be formed.
    func withoutQueries() -> URL? {
        var urlComponents = self
        urlComponents.query = nil
        return urlComponents.url
    }
    
    
    /// Converts the `URLQueryItem` object array into a `[String: String]` dictionary.
    ///
    /// - Returns: The query, divided as `[key: value]`.
    func queryDictionary(keepPercentEncoding: Bool = false) -> [String: String] {
        var queries = [String: String]()
        var possibleQueryItems: [URLQueryItem]?
        
        if keepPercentEncoding,
            #available(iOS 11.0, *) {
            // We use this case when we have to preserve non-UTF encoding
            print(.d, "percentEncodedQueryItems in withoutQueries")
            possibleQueryItems = self.percentEncodedQueryItems
        } else {
            // If the URL components don't include a query, return empty dictionary (for legacy reasons)
            possibleQueryItems = self.queryItems
        }
        
        // If the URL components don't include a query, return empty dictionary (for legacy reasons)
//        guard let queryItems = self.queryItems else { return queries }
        guard let queryItems = possibleQueryItems else { return queries }
        
        for queryItem in queryItems {
            //URLQueryItem(name, value)
            queries[queryItem.name] = queryItem.value
        }
        
        return queries
    }
    
}
