//
//  CharacterSet+union.swift
//  LabsSearch
//
//  Created by Xcode on ’19/06/23.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

// Create character sets from arrays, either through unions or intersection.

extension CharacterSet {
    
    /// Initialize with sets in an array.
    ///
    /// - Parameter array: An array of `CharacterSet`s. An empty array will result in an empty `CharacterSet`.
    public init(charactersIn array: [CharacterSet]) {
        self = CharacterSet()
        self.formUnion(array)
    }
    
    
    /// Initialize with an array, but keep only the characters present in every set.
    ///
    /// - Parameter array: An array of `CharacterSet`s. An empty array will result in an empty `CharacterSet`.
    public init(intersectingCharactersIn array: [CharacterSet]) {
        switch array.count {
        case 0:
            // Empty array creates empty object
            self = CharacterSet()
        case 1:
            self = array.first!
        default:
            // For a proper (>1) array:
            // Copy array
            var sets = array
            // Remove first set and assign to self
            self = sets.removeFirst()
            // Intersect with remaining set(s)
            self.formIntersection(sets)
        }
    }
    
    
    /// Adds the elements of the given sets to the set.
    ///
    /// - Parameter array: An array of `CharacterSet`s. An empty array will result in no change.
    mutating func formUnion(_ array: [CharacterSet]) {
        guard !array.isEmpty else { return }
        
        for set in array {
            self.formUnion(set)
        }
    }
    
    
    /// Returns a new set with the elements of both this and the given sets.
    ///
    /// - Parameter array: An array of `CharacterSet`s. An empty array will result in no change.
    /// - Returns: A new set with the unique elements of this set and the others.
    func union(_ array: [CharacterSet]) -> CharacterSet {
        guard !array.isEmpty else { return self }
        
        var newSet = self
        newSet.formUnion(array)
        
        return newSet
    }
    
    /// Removes the elements of this set that aren’t also in the given sets.
    ///
    /// - Parameter array: An array of `CharacterSet`s. An empty array will result in no change.
    mutating func formIntersection(_ array: [CharacterSet]) {
        guard !array.isEmpty else { return }
        
        for set in array {
            self.formIntersection(set)
        }
    }
    
    
    /// Returns a new set with the elements that are common to both this set and the given set.
    ///
    /// - Parameter array: An array of `CharacterSet`s. An empty array will result in an empty `CharacterSet`.
    /// - Returns: A new set with only elements common to all sets.
    func intersection(_ array: [CharacterSet]) -> CharacterSet {
        guard !array.isEmpty else { return self }
        
        var newSet = self
        newSet.formIntersection(array)
        
        return newSet
    }
    
}
