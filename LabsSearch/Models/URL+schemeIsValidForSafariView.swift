//
//  URL+schemeIsCompatibleWithSafariView.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/09.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

extension URL {
    
    /// Indicates whether the scheme is `http` or `https`, and can therefore be opened in Safari view.
    var schemeIsCompatibleWithSafariView: Bool {
        get {
            if self.scheme == "http" || self.scheme == "https" {
                return true
            } else {
                return false
            }
        }
    }
    
}
