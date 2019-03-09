//
//  Dimmable.swift
//  LabsSearch
//
//  Created by Xcode on ’19/03/05.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

/// Visually dims a text field when disabled.
class DimmableTableViewCellTextField: TableViewCellTextField {
    
    override var isEnabled: Bool {
        willSet {
            switch newValue {
            case true:
                textColor = .darkText
                backgroundColor = .clear
            case false:
                textColor = .gray
//                backgroundColor = .groupTableViewBackground
                backgroundColor = UIColor(white: 0, alpha: 0.1)
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
