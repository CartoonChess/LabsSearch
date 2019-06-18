//
//  String+encodedUrl.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/07.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

extension String {
    
    // TODO: Do we need an option to skip `.removingPercentEncoding` for when user searches literal stuff?
    //- Seems to be working as expected so far...
    
    // TODO: Account for weird (and maybe wrong) URLs that have two hashes in them, by percent-encoding subsequent hashes after the first.
    
    /// Converts a string to a percent-encoded URL, including Unicode characters.
    ///
    /// - Returns: An encoded URL if all steps succeed, otherwise nil.
    func encodedUrl() -> URL? {
//        // Remove preexisting encoding
//        guard let decodedString = self.removingPercentEncoding,
//            // Reencode, to revert decoding while encoding missed characters
//            let percentEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//                // Coding failed
//                return nil
//        }
        
        // Remove preexisting encoding,
        guard let decodedString = self.removingPercentEncoding,
            // encode any Unicode characters so URLComponents doesn't choke,
            let unicodeEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters),
            // break into components to use proper encoding for each part,
            let components = URLComponents(string: unicodeEncodedString),
            // and reencode, to revert decoding while encoding missed characters.
            let percentEncodedUrl = components.url else {
            // Encoding failed
            return nil
        }
        
//        print(.d, "percentEncodedString: \(percentEncodedString)")
//        // Create URL from encoded string, or nil if failed
//        return URL(string: percentEncodedString)
        return percentEncodedUrl
    }

}
