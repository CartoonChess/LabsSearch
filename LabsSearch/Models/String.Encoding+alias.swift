//
//  String.Encoding+alias.swift
//  LabsSearch
//
//  Created by Xcode on ’19/07/29.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

extension CFStringEncodings {
    /// Makes a `CFStringEncodings` more immediately usable by translating it into a `String` encoding.
    ///
    /// - Returns: `String.Encoding` object.
    func toStringEncoding() -> String.Encoding {
        //        let rawEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(self.rawValue))
        //        return String.Encoding(rawValue: rawEncoding)
        let rawEncoding = CFStringEncoding(self.rawValue)
        return rawEncoding.toStringEncoding()
    }
}

extension CFStringEncoding {
    /// Makes a `CFStringEncoding` more immediately usable by translating it into a `String` encoding.
    ///
    /// - Returns: `String.Encoding` object.
    func toStringEncoding() -> String.Encoding {
        let rawEncoding = CFStringConvertEncodingToNSStringEncoding(self)
        return String.Encoding(rawValue: rawEncoding)
    }
}

extension String.Encoding {
    
    // Some of these are combined with related DOS/similar encodings, following WHATWG
    static let big5 = CFStringEncodings.big5.toStringEncoding()
    static let big5_E = CFStringEncodings.big5_E.toStringEncoding()
    static let big5_HKSCS_1999 = CFStringEncodings.big5_HKSCS_1999.toStringEncoding()
    static let ISO_2022_CN = CFStringEncodings.ISO_2022_CN.toStringEncoding()
    static let ISO_2022_CN_EXT = CFStringEncodings.ISO_2022_CN_EXT.toStringEncoding()
    static let ISO_2022_KR = CFStringEncodings.ISO_2022_KR.toStringEncoding()
    static let dosRussian = CFStringEncodings.dosRussian.toStringEncoding()
    static let EUC_CN = CFStringEncodings.EUC_CN.toStringEncoding()
    static let EUC_KR = CFStringEncodings.EUC_KR.toStringEncoding()
    static let GB_18030_2000 = CFStringEncodings.GB_18030_2000.toStringEncoding()
    static let HZ_GB_2312 = CFStringEncodings.HZ_GB_2312.toStringEncoding()
    static let isoLatin3 = CFStringEncodings.isoLatin3.toStringEncoding()
    static let isoLatin4 = CFStringEncodings.isoLatin4.toStringEncoding()
    static let isoLatin6 = CFStringEncodings.isoLatin6.toStringEncoding()
    static let isoLatin7 = CFStringEncodings.isoLatin7.toStringEncoding()
    static let isoLatin8 = CFStringEncodings.isoLatin8.toStringEncoding()
    static let isoLatin9 = CFStringEncodings.isoLatin9.toStringEncoding()
    static let isoLatin10 = CFStringEncodings.isoLatin10.toStringEncoding()
    static let isoLatinArabic = CFStringEncodings.isoLatinArabic.toStringEncoding()
    static let isoLatinCyrillic = CFStringEncodings.isoLatinCyrillic.toStringEncoding()
    static let isoLatinGreek = CFStringEncodings.isoLatinGreek.toStringEncoding()
    static let isoLatinHebrew = CFStringEncodings.isoLatinHebrew.toStringEncoding()
    static let isoLatinThai = CFStringEncodings.isoLatinThai.toStringEncoding()
    static let KOI8R = CFStringEncodings.KOI8_R.toStringEncoding()
    static let KOI8U = CFStringEncodings.KOI8_U.toStringEncoding()
    static let macCyrillic = CFStringEncodings.macCyrillic.toStringEncoding()
    static let macUkrainian = CFStringEncodings.macUkrainian.toStringEncoding()
    static let windowsArabic = CFStringEncodings.windowsArabic.toStringEncoding()
    static let windowsBalticRim = CFStringEncodings.windowsBalticRim.toStringEncoding()
    static let windowsVietnamese = CFStringEncodings.windowsVietnamese.toStringEncoding()
    static let windowsHebrew = CFStringEncodings.windowsHebrew.toStringEncoding()
    
    // This is specifically for when an encoding is invalid
    static let invalid = kCFStringEncodingInvalidId.toStringEncoding()
    
    /// Provides the relevant `Encoding` based on commonly used aliases.
    ///
    /// - Parameter encoding: Encoding name containing only lowercase letters and/or numbers. Other characters will be stripped out, but accented characters like `é` will cause this function to return `nil`.
    /// - Returns: `String.Encoding` if the alias exists, otherwise `nil`.
    static func alias(_ encoding: String) -> String.Encoding? {
        // Overwrite the encoding variable to make it a lowercase string
        var encoding = encoding.lowercased()
        // Remove any hyphens or underscores etc. (technically allows characters like "é" but why would they be in charset?)
        let allowedCharacters = CharacterSet.lowercaseLetters.union(.decimalDigits)
        encoding = encoding.components(separatedBy: allowedCharacters.inverted).joined()
        
        // The following list is adapted from WHATWG:
        //- https://encoding.spec.whatwg.org/#names-and-labels
        
        switch encoding {
        // UTF-8
        case "unicode11utf8", "utf8":
            return .utf8
        // Legacy singlebyte encodings
        case "866", "cp866", "csibm866", "ibm866":
            return .dosRussian
        case "csisolatin2", "iso88592", "isoir101", "iso885921987", "l2", "latin2":
            return .isoLatin2
        case "csisolatin3", "iso88593", "isoir109", "iso88593:1988", "l3", "latin3":
            return .isoLatin3
        case "csisolatin4", "iso88594", "isoir110", "iso88594:1988", "l4", "latin4":
            return .isoLatin4
        case "csisolatincyrillic", "cyrillic", "iso88595", "isoir144", "iso885951988":
            return .isoLatinCyrillic
        case "arabic", "asmo708", "csiso88596e", "csiso88596i", "csisolatinarabic", "ecma114", "iso88596", "iso88596e", "iso88596i", "isoir127", "iso885961987":
            return .isoLatinArabic
        case "csisolatingreek", "ecma118", "elot928", "greek", "greek8", "iso88597", "isoir126", "iso885971987", "suneugreek":
            return .isoLatinGreek
        case "csiso88598e", "csisolatinhebrew", "hebrew", "iso88598", "iso88598e", "isoir138", "iso885981988", "visual", "csiso88598i", "iso88598i", "logical": // "i"/"logical" have no matching Encoding?
            return .isoLatinHebrew
        case "csisolatin6", "iso885910", "isoir157", "l6", "latin6":
            return .isoLatin6
        case "iso885913":
            return .isoLatin7
        case "iso885914":
            return .isoLatin8
        case "csisolatin9", "iso885915", "l9":
            return .isoLatin9
        case "iso885916":
            return .isoLatin10
        case "cskoi8r", "koi", "koi8", "koi8r":
            return .KOI8R
        case "koi8ru", "koi8u":
            return .KOI8U
        case "csmacintosh", "mac", "macintosh", "xmacroman":
            return .macOSRoman
        case "dos874", "iso885911", "tis620", "windows874":
            return .isoLatinThai
        case "cp1250", "windows1250", "xcp1250":
            return .windowsCP1250
        case "cp1251", "windows1251", "xcp1251":
            return .windowsCP1251
        case "cp1253", "windows1253", "xcp1253":
            return .windowsCP1253
        case "cp1254", "csisolatin5", "iso88599", "isoir148", "iso885991989", "l5", "latin5", "windows1254", "xcp1254":
            return .windowsCP1254
        case "cp1255", "windows1255", "xcp1255":
            return .windowsHebrew
        case "cp1256", "windows1256", "xcp1256":
            return .windowsArabic
        case "cp1257", "windows1257", "xcp1257":
            return .windowsBalticRim
        case "cp1258", "windows1258", "xcp1258":
            return .windowsVietnamese
        case "xmaccyrillic":
            return .macCyrillic // Cryillic and Ukrainian broke up from WHATWG
        case "xmacukrainian":
            return .macUkrainian
        // ASCII/Latin and variants (WHATWG combines these to CP1252)
        case "cp1252", "windows1252", "xcp1252":
            return .windowsCP1252
        case "ansix341968", "ascii", "usacii":
            return .ascii
        case "cp819", "csisolatin1", "ibm819", "iso88591", "iso885911987", "isoir100", "isolatin1", "l1", "latin1":
            return .isoLatin1
        // Legacy multibyte Chinese (simplified) encodings
        case "chinese", "csgb2312", "csiso58gb231280", "gb2312", "gb231280", "gbk", "isoir58", "xgbk":
            return .EUC_CN
        case "gb18030":
            return .GB_18030_2000
        // Legacy multibyte Chinese (traditional) encodings
        case "big5", "cnbig5", "csbig5", "xxbig5":
            return .big5
        case "big5hkscs", "big5hkscs1999":
            // Hong Kong
            return .big5_HKSCS_1999
        case "big5e":
            // Taiwan
            return .big5_E
        // Legacy multibyte Japanese encodings
        case "cseucpkdfmtjapanese", "eucjp", "xeucjp":
            return .japaneseEUC
        case "csiso2022jp", "iso2022jp":
            return .iso2022JP
        case "csshiftjis", "ms932", "mskanji", "shiftjis", "sjis", "windows31j", "xsjis":
            return .shiftJIS
        // Legacy multibyte Korean encodings
        case "cseuckr", "csksc56011987", "euckr", "isoir149", "korean", "ksc56011987", "ksc56011989", "ksc5601", "windows949":
            return .EUC_KR
        // Legacy miscellaneous encodings
        case "utf16":
            return .utf16
        case "utf16be":
            return .utf16BigEndian
        case "utf16le":
            return .utf16LittleEndian
        // "Replacement" encodings (but "replacement" encoding removed)
        case "csiso2022kr", "iso2022kr":
            return .ISO_2022_KR
        case "iso2022cn":
            return .ISO_2022_CN
        case "iso2022cnext":
            return .ISO_2022_CN_EXT
        case "hzgb2312":
            return .HZ_GB_2312
        // Additional String.Encoding not defined by WHATWG
        case "nextstep":
            // Exactly what it sounds like
            return .nextstep
        case "nonlossyascii":
            // TextEdit ASCII which gives Unicode hex encoding to non-ASCII characters
            return .nonLossyASCII
        case "symbol":
            // Adobe's 1990s printed mathematical set
            return .symbol
        case "iec10646", "iso10646", "ucs", "unicode":
            // "Bare" Unicode, I guess; more spec than use
            return .unicode
        case "utf32":
            return .utf32
        case "utf32be":
            return .utf32BigEndian
        case "utf32le":
            return .utf32LittleEndian
        // Invalid case
        case "invalid", "invalidutf8":
            return .invalid
        default:
            return nil
        }
        
        // "x-user-defined" removed because it's for unusual purposes and there's no matching Encoding
    }
    
}
