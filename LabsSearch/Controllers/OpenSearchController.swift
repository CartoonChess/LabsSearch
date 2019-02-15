//
//  OpenSearch.swift
//  LabsSearch
//
//  Created by Xcode on ’19/01/27.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

struct OpenSearchController {
    
    // Assuming we're adding (not editing) an engine, try OpS first:
    
    // a. If using app ext, poll host URL for OpS (AddEdit).
    // b. If using main app, use user-entered URL (UrlDetails).
    // ---- UrlDetails will handle adding http(s) for us.
    
    // Double-check URL validity; return nil if fail.
    
    // Poll typical places for OpS. Try to check obvious URLs while parsing HTML simultaneously.
    // https://github.com/dewitt/opensearch/blob/master/opensearch-1-1-draft-6.md#autodiscovery
    // ---- We can get HTML header from IconFetcher. (Problem if this is using mobile UserAgent?)
    // ---- Perhaps break the HTML parser out of IconFetcher; but what about the parser delegate?
    
    // Once found, convert JSON to OpS object.
    // https://github.com/dewitt/opensearch/blob/master/opensearch-1-1-draft-6.md#opensearch-url-template-syntax
    
    // Parse for URL and name (anything else? icon?).
    
    // Pass SearchEngine object, or variables.
    // ---- Add termsPlaceholder?
    
    // If OpS fails, fall back to old method.
    
    
    // TODO: Search suggestions (MainVC):
    // http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.0
    
    // TODO: Detect mobile? (Are we already doing this with IconFetcher?)
    // http://www.opensearch.org/Community/Proposal/Specifications/OpenSearch/Extensions/Mobile/1.0/Draft_1
    
}
