//
//  String+UITextField+textWithAttributes.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/24.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

extension String {
    
    /// Return a copy of the string with the specified portion decorated.
    ///
    /// - Parameters:
    ///   - attributes: A dictionary of attribute keys and their values.
    ///   - portionToBeModified: The text to look for and modify in the full string.
    /// - Returns: Decorated string if `portionToBeModified` is found, otherwise the original string as an attributed string with no other changes.
    func withAttributes(_ attributes: [NSAttributedString.Key: Any], on portionToBeModified: String) -> NSMutableAttributedString? {
        // Make a rich text copy of the text
        let attributedText = NSMutableAttributedString(string: self)
        
        // Check that the string to be modified exists in the whole string
        // If so, set the range of characters to be changed to that portion's position
        guard let modifiableRange = attributedText.string.range(of: portionToBeModified) else {
            print(.x, "Could not find text to change in copied string.")
            return attributedText
        }
        
        // Add attributes to the rich text copy of the string
        attributedText.addAttributes(attributes, range: NSRange(modifiableRange, in: attributedText.string))
        
        // Return the decorated version of the full string
        return attributedText
    }
    
}

extension UITextField {
    
    /// Apply text decoration to the text property while optionally maintaining the cursor position.
    ///
    /// - Parameters:
    ///   - attributes: An array of attributes used to colour or otherwise modify the text.
    ///   - maintainCursorPosition: Determines whether to keep the cursor in the position the user placed it. Defaults to `true`.
    func decorateText(using attributes: [NSAttributedString.Key: Any], on portionToBeModified: String, maintainCursorPosition: Bool = true) {
        // When we set the text field to show the attributed text, the cursor will jump to the end;
        // So, first get the current cursor position (even if we don't end up using it)
        // (We assume this function is called after editing text, and so therefore the "range" is one position)
        let cursorPosition = selectedTextRange?.start
        
        // Assign the attributed text property to the text field (doing so also updates the text property)
        attributedText = text?.withAttributes(attributes, on: portionToBeModified)
        // TODO: We once saw the whole string turn grey when returning from Safari web view; is this the cause?:
        /* Assigning a new value to this property also replaces the value of the text property with the same string data, albeit without any formatting information. In addition, assigning a new value updates the values in the font, textColor, and other style-related properties so that they reflect the style information starting at location 0 in the attributed string. */
        
        // Return the cursor to its proper position (behaviour expected by user)
        if maintainCursorPosition,
            let cursorPosition = cursorPosition {
            selectedTextRange = textRange(from: cursorPosition, to: cursorPosition)
        }
    }
}
