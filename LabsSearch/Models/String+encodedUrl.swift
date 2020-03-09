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
    /// - Parameter encoder: A `CharacterEncoder` object, if available.
    /// - Returns: An encoded URL if all steps succeed, otherwise nil.
    func encodedUrl(characterEncoder encoder: CharacterEncoder? = nil) -> URL? {
//        // Remove preexisting encoding
//        guard let decodedString = self.removingPercentEncoding,
//            // Reencode, to revert decoding while encoding missed characters
//            let percentEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//                // Coding failed
//                return nil
//        }
        
//        // Remove preexisting encoding,
//        guard let decodedString = self.removingPercentEncoding,
//            // encode any Unicode characters so URLComponents doesn't choke,
//            let unicodeEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters),
//            // break into components to use proper encoding for each part,
//            let components = URLComponents(string: unicodeEncodedString),
//            // and reencode, to revert decoding while encoding missed characters.
//            let percentEncodedUrl = components.url else {
//            // Encoding failed
//            print(.x, "String could not be encoded as URL.")
//            return nil
//        }
        
        // We will get the value differently depending on the encoding
        var partiallyEncodedString: String
        
        if encoder?.encoding.value != .utf8,
            // Custom encode the URL if using non-Unicode
            let characterEncodedString = encoder?.encode(self, fullUrl: true) {
//            print(.d, "Percent-encoding URL with non-UTF8 encoding.")
            //            guard let characterEncodedString = encoder?.encode(self, fullUrl: true) else {
            //                print(.x, "String could not be encoded as URL: failed to add percent encoding using specified character encoding.")
            //                return nil
            //            }
            //            partiallyEncodedString = characterEncodedString
            partiallyEncodedString = characterEncodedString
        } else {
            // Remove preexisting encoding,
            guard let decodedString = self.removingPercentEncoding else {
                print(.x, "String could not be encoded as URL: failed to remove preexisting percent encoding.")
                return nil
            }
            //        let decodedString = self //debug
            // encode any Unicode characters so URLComponents doesn't choke,
            guard let unicodeEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters) else {
                print(.x, "String could not be encoded as URL: failed to add percent encoding to non-ASCII characters.")
                return nil
            }
            //        let unicodeEncodedString = decodedString //debug
            partiallyEncodedString = unicodeEncodedString
        }
        
        // break into components to use proper encoding for each part,
        guard let components = URLComponents(string: partiallyEncodedString) else {
            print(.x, "String could not be encoded as URL: URL could not be broken into components.")
            return nil
        }
        // and reencode, to revert decoding while encoding missed characters.
        guard let percentEncodedUrl = components.url else {
                // Encoding failed
            print(.x, "String could not be encoded as URL: failed to add percent encoding to URL control characters.")
            return nil
        }
        
//        print(.d, "percentEncodedString: \(percentEncodedString)")
//        // Create URL from encoded string, or nil if failed
//        return URL(string: percentEncodedString)
//        print(.d, "String encoded as URL: \(percentEncodedUrl)")
//        print(.d, "Can open in Safari view: \(components.url?.schemeIsCompatibleWithSafariView ?? false)")
        return percentEncodedUrl
    }

}
