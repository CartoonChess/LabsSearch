//
//  UIColor+adaptiveLabel.swift
//  LabsSearch
//
//  Created by Philip C. Partington on 2020-03-09.
//  Copyright © 2020 Distant Labs. All rights reserved.
//

import UIKit

extension UIColor {
    var adaptiveLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
}
