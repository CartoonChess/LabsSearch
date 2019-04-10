//
//  Print+Level.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/17.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

/// A set of synonyms at three levels for console reporting: `error`, `note`, and `ok`.
///
/// The shortest notation is `x`, `n`, `o`, `i`, `d`.
enum PrintLevel {
    case error, x, bad, warning, fail, red
    case notice, n, issue, yellow
    case ok, o, okay, good, np, pass, success, green
    case comment, i, info, information, note, white
    case debug, d, blue
}

/// Extends the basic `print` function to add an emoji in front for readability in console logs.
///
/// - Parameters:
///   - level: Four levels available with various synonyms, shortest being `x` (error), `n` (note), `o` (okay), and `i` (comment).
///   - message: The string to be output to the console.
///
/// Messages printed with this function will only output in debug mode.
func print(_ level: PrintLevel, _ message: String) {
    #if DEBUG
        let symbol: String
    
        switch level {
        case .error, .x, .bad, .warning, .fail, .red:
            symbol = "🛑"
        case .notice, .n, .issue, .yellow:
            symbol = "⚠️"
        case .ok, .o, .okay, .good, .np, .pass, .success, .green:
            symbol = "✅"
        case .comment, .i, .info, .information, .note, .white:
            symbol = "💬"
        case .debug, .d, .blue:
            symbol = "🙅‍♂️🦋🙅‍♂️"
        }
        
        print(symbol + " " + message)
    #endif
}
