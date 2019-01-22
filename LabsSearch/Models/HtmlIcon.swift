//
//  HtmlIcon.swift
//  LabsSearch
//
//  Created by Xcode on ’18/12/13.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import Foundation

/// A <link> element and its attributes, including its image data, if available.
struct HtmlIcon {
    let href: String
    let rel: String
    let size: Int
    var data: Data?
}
