//
//  String+isValidFileName.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/12.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

extension CharacterSet {
    
    /// Character set including colon, forward slash, and other undesirables.
    static var invalidFileNameCharacters: CharacterSet {
        var characters = CharacterSet(charactersIn: ":/\\")
        characters.formUnion(.newlines)
        characters.formUnion(.controlCharacters)
        characters.formUnion(.illegalCharacters)
        return characters
    }
    
    /// Characters valid in at least one part of a URL.
    ///
    /// These characters are not allowed in ALL parts of a URL; each part has different requirements. This set is useful for checking for Unicode characters that need to be percent encoded before performing a validity check on individual URL components.
    static var urlAllowedCharacters: CharacterSet {
        // Start by including hash, which isn't in any set
        var characters = CharacterSet(charactersIn: "#")
        // All URL-legal characters
        characters.formUnion(.urlUserAllowed)
        characters.formUnion(.urlPasswordAllowed)
        characters.formUnion(.urlHostAllowed)
        characters.formUnion(.urlPathAllowed)
        characters.formUnion(.urlQueryAllowed)
        characters.formUnion(.urlFragmentAllowed)
        
        return characters
    }
}


extension String {
    
//    // Create character set including colon, forward slash, and other undesirables
//    static var invalidFileNameCharacters: CharacterSet {
//        var characters = CharacterSet(charactersIn: ":/")
//        characters.formUnion(.newlines)
//        characters.formUnion(.controlCharacters)
//        characters.formUnion(.illegalCharacters)
//        return characters
//    }
    
    /// Determine if a string is free of characters inappropriate for a file name.
    ///
    /// - Returns: `true` if the string is a good candidate for use as a file name, or `false` if it contains shady characters.
    func isValidFileName() -> Bool {
        // Return false if/when first illegal character is found
        if self.rangeOfCharacter(from: .invalidFileNameCharacters) == nil {
            return true
        } else {
            return false
        }
    }
    
    /// Creates a new string with characters unsuited for filenames replaced by an underscore.
    ///
    /// - Returns: A valid filename.
    func asValidFileName() -> String {
        return self.components(separatedBy: .invalidFileNameCharacters).joined(separator: "_")
    }
    
    /// Substitutes an underscore in place of any characters in the string unuited for filenames.
    mutating func becomeValidFileName() {
        self = self.asValidFileName()
    }
    
}
