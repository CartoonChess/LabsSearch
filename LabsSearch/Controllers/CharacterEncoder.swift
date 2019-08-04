//
//  CharacterEncoder.swift
//  Chears
//
//  Created by Xcode on ’19/06/19.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

///// Essentially the same as `String.Encoding`, but with a human-readable `name` as well.
//struct CharacterEncoding: CustomStringConvertible, Equatable, Codable {
//    // A readable name. Mainly used for display
//    let name: String
//    // The raw value. Used for encoding
////    let value: String.Encoding
//    let value: UInt
//
//    var description: String { return name }
//}

/// Essentially the same as `String.Encoding`, but with a human-readable `name` as well.
struct CharacterEncoding: CustomStringConvertible, Equatable, Codable {
    // A readable name. Mainly used for display
    let name: String
    // The raw value. Do not access directly; use `value` instead
    private var rawValue: UInt
    
    // The actual encoding. This computed property allows the struct to be codable
    // This keeps SearchEngine struct codable
    var value: String.Encoding {
        get { return String.Encoding(rawValue: rawValue) }
        set { rawValue = newValue.rawValue }
    }
    
    var description: String { return name }
    
    // Necessary due to Codable
    init(name: String, value: String.Encoding) {
        self.name = name
        self.rawValue = value.rawValue
    }
}


/// Percent-encodes a UTF-8 string into another character encoding.
///
/// A valid character encoding, either as a string or `Encoding`, must be provided, or else HTML represented by a string which has its character encoding set. If the encoding cannot be determined, this struct will be `nil`.
struct CharacterEncoder {
    
    // MARK: - Properties
    
    // If this value cannot be set during the init, the CharacterEncoder struct will be nil
//    let encoding: String.Encoding
    let encoding: CharacterEncoding
    
    
    // MARK: - Initializers
    
    // These are basically ordered as would be ideal to use them.
    
    /// Initializes with a `CharacterEncoding`.
    ///
    /// - Parameter encoding: A `CharacterEncoding`.
    init(encoding: CharacterEncoding) {
        self.encoding = CharacterEncoding(name: encoding.name, value: encoding.value)
    }
    
    /// Initializes with a string representing a common name of the encoding.
    ///
    /// - Parameter encoding: A string whose alphanumeric characters correspond with a `String.Encoding` alias.
    ///
    /// If no matching encoding can be found, the `CharacterEncoder` will not be initialized and the property to which it is assigned will be `nil`.
    init?(encoding name: String) {
        guard let encoding = CharacterEncoder.getEncodingValue(name: name) else { return nil }
        self.encoding = CharacterEncoding(name: name, value: encoding)
    }
    
    // TODO: Are we going to use this?
//    /// Initializes with HTML, represented as a string, that contains a character encoding attribute.
//    ///
//    /// - Parameter html: Properly formatted HTML string containing a valid character encoding attribute.
//    ///
//    /// If the HTML cannot be parsed or no matching encoding can be found, the `CharacterEncoder` will not be initialized and the property to which it is assigned will be `nil`.
//    init?(html: String) {
//        guard let encoding = CharacterEncoder.getCharacterEncoding(html: html) else { return nil }
////        guard let encoding = String.Encoding.alias(htmlEncoding) else { return nil }
////        self.encoding = encoding
//        self.init(encoding: encoding)
//    }
    
    /// Initializes with a `String.Encoding`.
    ///
    /// - Parameter encoding: A `String.Encoding` or an alias for a `CFStringEncodings`.
    init(encoding: String.Encoding) {
//        // With no encoding name provided, we'll show the int value for reference
//        let name = String(encoding.rawValue)
        // Attempt to derive the encoding name, otherwise call it "unknown"
        let rawEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
        let name = CFStringConvertEncodingToIANACharSetName(rawEncoding) as String? ?? "unknown"
        
        self.encoding = CharacterEncoding(name: name, value: encoding)
    }
    
    /// Initializes with a `CFStringEncodings`.
    ///
    /// - Parameter encoding: A `CFStringEncodings` which will be converted to `String.Encoding`.
    init(encoding: CFStringEncodings) {
//        let encoding = encoding.toStringEncoding()
//        self.init(encoding: encoding)
        let stringEncoding = encoding.toStringEncoding()
        // Attempt to derive the encoding name, otherwise call it "unknown"
        let name = CFStringConvertEncodingToIANACharSetName(CFStringEncoding(stringEncoding.rawValue)) as String? ?? "unknown"

        self.encoding = CharacterEncoding(name: name, value: stringEncoding)
    }
    
    
    // MARK: - Methods
    
    private static func getEncodingValue(name: String) -> String.Encoding? {
        // First, try the CFString method
        let encoding = CFStringConvertIANACharSetNameToEncoding(name as CFString)
        // Unknown names will all produce the same InvalidId
        if encoding != kCFStringEncodingInvalidId {
            print(.o, "Matched \(name) encoding to corresponding value \(encoding).")
            return encoding.toStringEncoding()
        } else {
            // If CFString can't find the name, use our custom method
            // This will return nil if nothing is found
            return String.Encoding.alias(name)
        }
    }
    
    // TODO: Are we going to use this?
//    private static func getCharacterEncoding(html: String) -> String? {
//        // - Get HTML from SearchEngineEditor (future versions can use URLSession as backup)
//        // - Parse HTML for <meta...charset> tag (may need to check for deprecated one as well)
//        // - Pass HTML encoding to SearchEngineEditor (which will assign it to a SearchEngine object; AddEdit will read from there to update its view when developer features are enabled)
//        let encoding = html
//        return encoding
//    }
    
    
    /// Encodes a string according to `CharacterEncoder`'s assigned `encoding`. Non-URL safe characters will be percent encoded.
    ///
    /// - Parameters:
    ///   - string: The string to be encoded.
    ///   - fullUrl: Whether the string is a representation of a full URL. Defaults to `false` if not provided. See **Warning** for how this impacts the return value.
    /// - Returns: The string, with non-URL safe characters percent encoded, or the original string if encoding fails or if UTF-8 is used.
    ///
    /// This function will only return a modified string if a valid encoding other than UTF-8 is specified, the encoding process is successful, and one or more characters are outside the URL safe character set. Failing to meet all of these conditions will simply return the original string.
    ///
    /// - Warning:
    /// If `fullUrl` is set to `true`, the function behaves differently: instead of the default behaviour of percent-encoding all characters that are not URL-safe (essentially anything non-alphanumeric), only those characters which are not URL-allowed will be encoded. This means the string will **not** immediately translate to a valid URL, as any invalidly placed reserved characters will first have to be percent encoded. As `String.addingPercentEncoding` will produce double encoding issues, it is necessary to use `URLComponents` instead.
    func encode(_ string: String, fullUrl: Bool = false) -> String {
        
        // Don't bother with any of this if the encoding is already UTF-8
        guard encoding.value != .utf8 else {
            print(.n, "No character encoding required for UTF-8.")
            return string
        }
        
//        //Create a byte sequece representing the string using the new encoding
//        guard let encodedData = string.data(using: encoding.value) else {
//            print(.x, "Failed to encode characters using \"\(encoding)\". Falling back to UTF-8.")
//            return string
//        }
        
        //Create a byte sequece representing the string using the new encoding
        var encodedData = string.data(using: encoding.value)
        // However, encoding can fail if user enters characters outside the encoding table
        // We must continue to encode with UTF-8 so that URLComponents won't crash when looking for percent encoding
        if encodedData == nil {
            guard let utfData = string.data(using: .utf8) else {
                print(.x, "Failed to encode characters using \"\(encoding)\" and UTF-8. Returning original string without percent encoding, but this may cause a fatal error.")
                return string
            }
            encodedData = utfData
            print(.n, "Failed to encode characters using \"\(encoding)\". Falling back to UTF-8.")
        } else {
            print(.i, "Encoding using \(encoding).")
        }
        
        // Analyze string byte by byte, encode URL-unsafe characters, then reassemble
        let encodedString = encodedData!.map { byte -> String in
            // Choose which characters will not be encoded
            var legalCharacters = CharacterSet()
            if fullUrl {
                // If a full URL, do not escape control characters
                legalCharacters = CharacterSet.urlAllowedCharacters.union(CharacterSet(charactersIn: "%"))
            } else {
                // Encode URL control characters if this is a query
                legalCharacters = CharacterSet.urlSafeCharacters
            }
            
            // Check for ASCII printable characters:
            //- UInt->Int casting makes sure it isn't a wild Unicode character
            //- urlSafeCharacters will make sure it's both ASCII and safe for URLs
            //- Bytes 0~127 are basic ASCII, and 32~126 are printable ASCII, if we need to be more specific
            if let character = UnicodeScalar(Int(byte)),
                legalCharacters.contains(character) {
                // Return normal ASCII character, so long as byte has no problems converting and is URL safe
                return String(Character(character))
            } else {
                // For anything not URL safe (includes non-Unicode characters), percent encode the byte directly
                // %% = escaped %, %02X = two digits (w/ leading 0 for single)
                return String(format: "%%%02X", byte)
            }
            }.joined()
        
        print(.o, "String \"\(string)\" encoded in \(encoding) to produce \"\(encodedString)\".")
        
        return encodedString
        
    }
    
}
