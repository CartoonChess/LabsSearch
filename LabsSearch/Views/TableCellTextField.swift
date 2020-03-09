//
//  TableViewCellTextField.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/28.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

/// Text fields which adopt this subclass will fit in nicely in a tableview cell.
///
/// Usage: To use, make sure the text field is set in Interface Builder to have no border, and set its constraints to fill the cell.
class TableViewCellTextField: UITextField {
    
    func getPadding(plusExtraFor clearButtonMode: ViewMode) -> UIEdgeInsets {
//        // Eliminate side padding if using readable width guidelines
//        var foo: CGFloat = 16
//        let sidePadding: CGFloat = foo >= 16 ? foo : 0
//        print(.d, "\(self.readableContentGuide)")
        
        // Define basic (without clear button) padding
        var padding = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        
        // Add additional padding on the right side when showing the clear button
        if self.clearButtonMode == .always || self.clearButtonMode == clearButtonMode {
//            padding.right = 28
            padding.right += 12
        }
        
        return padding
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = getPadding(plusExtraFor: .unlessEditing)
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = getPadding(plusExtraFor: .unlessEditing)
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = getPadding(plusExtraFor: .whileEditing)
        return bounds.inset(by: padding)
    }

}
