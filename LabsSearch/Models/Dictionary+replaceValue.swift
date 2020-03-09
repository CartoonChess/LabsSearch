//
//  Dictionary+replaceValue.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/03.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

extension Dictionary where Value == String {
    
    // TODO: Would be nice to genericize this
    
    mutating func replaceValue(_ valueToReplace: String, with newValue: String) {
        for (key, value) in self {
            if value == valueToReplace {
                self[key] = newValue
            }
        }
    }
    
    func withValueReplaced(_ valueToReplace: String, replaceWith newValue: String) -> Dictionary {
        var dictionary = self
        for (key, value) in dictionary {
            if value == valueToReplace {
                dictionary[key] = newValue
            }
        }
        return dictionary
    }
    
}
