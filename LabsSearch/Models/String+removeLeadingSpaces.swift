//
//  String+removeLeadingSpaces.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/23.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

extension String {
    
    /// Returns a new string with all leading spaces removed.
    ///
    /// - Returns: String without leading spaces.
    func leadingSpacesRemoved() -> String {
        return String(self.drop { $0 == " " })
    }
    
    /// Mutates the string to remove all leading spaces.
    mutating func removeLeadingSpaces() {
        self = self.leadingSpacesRemoved()
    }
    
}
