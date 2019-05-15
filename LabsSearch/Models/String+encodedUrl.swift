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
    
    /// Converts a string to a percent-encoded URL, including Unicode characters.
    ///
    /// - Returns: An encoded URL if all steps succeed, otherwise nil.
    ///
    /// This method is not foolproof, mainly because it applies query character set rules to the entire URL. It also assumes the string is already a functioning URL, such as might be copied directly from a browser.
    func encodedUrl() -> URL? {
        // Remove preexisting encoding
        guard let decodedString = self.removingPercentEncoding,
            // Reencode, to revert decoding while encoding missed characters
            let percentEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                // Coding failed
                return nil
        }
        // Create URL from encoded string, or nil if failed
        return URL(string: percentEncodedString)
    }

}
