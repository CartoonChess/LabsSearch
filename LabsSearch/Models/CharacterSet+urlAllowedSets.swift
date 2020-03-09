//
//  CharacterSet+urlAllowedSets.swift
//  LabsSearch
//
//  Created by Xcode on ’19/06/23.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

extension CharacterSet {
    
    /// A collection of all defined URL-related `CharacterSet`s.
    ///
    /// These sets, along with the `#` (hash) symbol, are available in one set called [.urlAllowedCharacters](x-source-tag://CharacterSet.urlAllowedCharacters).
    private static var urlAllowedSets: [CharacterSet] {
        return [
            .urlUserAllowed,
            .urlPasswordAllowed,
            .urlHostAllowed,
            .urlPathAllowed,
            .urlQueryAllowed,
            .urlFragmentAllowed
        ]
    }
    
    /// Characters valid in at least one part of a URL.
    ///
    /// These characters are not allowed in *all* parts of a URL; each part has different requirements. This set is useful for checking for Unicode characters that need to be percent encoded before performing a validity check on individual URL components.
    ///
    /// ````
    /// let str = "http://www.example.com/~user/index.php?q=test%20query"
    /// CharacterSet.urlAllowedCharacters.isSuperset(of: CharacterSet(charactersIn: str))
    /// ````
    ///
    /// For a set which contains only characters safe in all parts of a URL, use [.urlSafeCharacters](x-source-tag://CharacterSet.urlSafeCharacters).
    ///
    /// - Tag: CharacterSet.urlAllowedCharacters
    static var urlAllowedCharacters: CharacterSet {
        // Start by including hash, which isn't in any URL set
        // Then include all URL-legal characters
        let set = CharacterSet(charactersIn: "#")
        return set.union(urlAllowedSets)
    }
    
    /// Characters valid in all parts of a URL.
    ///
    /// The characters in this set should not have to be percent encoded no matter which component of a URL in which they appear.
    ///
    /// For a set which contains all possible URL characters, without concern for component restrictions, use [.urlAllowedCharacters](x-source-tag://CharacterSet.urlAllowedCharacters).
    ///
    /// - Tag: CharacterSet.urlSafeCharacters
    static var urlSafeCharacters: CharacterSet {
//        return CharacterSet(intersectingCharactersIn: urlAllowedSets)
        var set = CharacterSet(intersectingCharactersIn: urlAllowedSets)
        // Remove ampersand, which is in all URL sets, apparently
//        return set.intersection(CharacterSet(charactersIn: "&"))
        set.remove(charactersIn: "&")
        return set
    }
    
//    /// Characters valid not in the entire query of a URL, but in each individual query item (key and value).
//    static var urlQueryItemAllowed: CharacterSet {
//        // FIXME: Shouldn't we be using .remove() instead?
//        return self.urlQueryAllowed.union(CharacterSet(charactersIn: "?&="))
//    }
    
    /// Character set including colon, forward slash, and other undesirables.
    static var invalidFileNameCharacters: CharacterSet {
        return CharacterSet(charactersIn: [
            CharacterSet(charactersIn: ":/\\"),
            .newlines, .controlCharacters, .illegalCharacters
            ])
    }
    
}
