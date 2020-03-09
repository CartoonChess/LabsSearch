//
//  URL+schemeIsValid.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/02.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

extension URL {
    
    /// Indicates whether the scheme, such as `http` or `sms`, can be opened on the device.
    ///
    /// This funciton cannot be used within app extensions.
    var schemeIsValid: Bool {
        get {
            return UIApplication.shared.canOpenURL(self)
        }
    }
    
}
