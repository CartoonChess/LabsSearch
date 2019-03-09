//
//  OpenSearchController.swift
//  LabsSearch
//
//  Created by Xcode on ’19/01/27.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

struct OpenSearch {
    var name = String()
    var url = URL(string: "")
}


class OpenSearchController: NSObject, XMLParserDelegate {
    
    // FIXME: We need a status bar network loading indicator!
    
    // URL the user has specified; we must declare this at the class level for the parser's sake
    var url: URL? = nil
    var openSearch = OpenSearch()
    
    // Determine if we're parsing HTML or OpS XML, which allows the parser to look for the correct elements
    var parsingHtml = true
    
    // OpS XML file URL
    var openSearchDescriptionUrl: URL? = nil
    
    // The XML element currently being parsed
    var xmlElement = String()
    
    // Bring in UrlController so we know the magic word
    //- Using termsPlaceholder instead means the AddEdit VC will think the URL isn't fully valid
    let urlController = UrlController()
    
    func detectOpenSearch(at url: URL, completion: @escaping () -> Void) {
        // Assuming we're adding (not editing) an engine, try OpS first:
        //        // ---- Calling VC will check for valid URL on each keystroke, and call this func when host (incl subdomain) is valid and changed
        //        // ---- Should this be run async? This way it can keep looking even after going back to AddEdit VC?
        
        // a. If using app ext, poll host URL for OpS (AddEdit).
        //        // b. If using main app, use user-entered URL (UrlDetails).
        // ---- OpenSearch VC must handle adding http(s) and making sure the URL is valid.
        
        
        // Double-check URL validity; return nil if fail.
        // Actually, maybe it's not necessary to isolate the host; just grab from whatever URL they send
        // TODO: Maybe use this as a fallback, if the full URL doesn't return OpS?
        //        let allComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        //        var hostComponents = URLComponents()
        //        hostComponents.scheme = allComponents?.scheme
        //        hostComponents.host = allComponents?.host
        //        print(hostComponents.url?.absoluteString)
        
        
        // TODO: Poll typical places for OpS. Try to check obvious URLs while parsing HTML simultaneously.
        // https://github.com/dewitt/opensearch/blob/master/opensearch-1-1-draft-6.md#autodiscovery
        // ---- We can get HTML header from IconFetcher. (Problem if this is using mobile UserAgent?)
        // ---- Perhaps break the HTML parser out of IconFetcher; but what about the parser delegate?
        ////        let openSearchDescriptionUrl = URL(string: "https://en.wikipedia.org/w/opensearch_desc.php")!
        ////        let openSearchDescriptionUrl = URL(string: "https://www.google.com/searchdomaincheck?format=opensearch")!
        //        let longRootUrl = URL(string: "\(host)/opensearch.xml")
        //        let shortRootUrl = URL(string: "\(host)/search.xml")
        
        // Copy the user-supplied URL to the class (for use with parser)
        self.url = url
        
        // Unlike IconFetcher, we won't use UserAgent to look for the mobile page, as it often doesn't include OpS declaration :(
        let htmlTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let html = String(data: data, encoding: .utf8) {
                
                // Clear previously found URL, if it exists
                self.openSearchDescriptionUrl = nil
                
                // First, look for OpS <link> tag in HTML
                // As the XML parser can choke on HTML, we use a custom function to isolate the tag first
                guard let openSearchTag = self.findOpenSearchHtmlTag(in: html),
                    let htmlData = openSearchTag.data(using: .utf8) else {
                        print(.x, "Could not find OpenSearch tag in HTML, or could not convert it to data format.")
                        completion()
                        return
                }
                
                // Then, parse tag for URL to OpS XML file
                self.parsingHtml = true
                self.parseXml(data: htmlData)
                
                
                // If we've found the OpS XML file, begin parsing that
                if let openSearchDescriptionUrl = self.openSearchDescriptionUrl {
                    
                    let xmlTask = URLSession.shared.dataTask(with: openSearchDescriptionUrl, completionHandler: { (data, response, error) in
                        if let data = data {
                            // Inform the parser that we're now looking at the XML file itself
                            self.parsingHtml = false
                            self.parseXml(data: data)
                            
                            // If the parse was successful, an OpenSearch object will be passed back; otherwise nil
                            completion()
                        } else {
                            print(.x, "Failed to download XML data because the following error occurred: \(error ?? "(nil)" as! Error)")
                            completion()
                        }
                    })
                    
                    xmlTask.resume()
                    
                } else {
                    // If the XML file was never found, run the completion handler anyway to provide caller with nil
                    completion()
                }
            } else if let error = error {
                print(.x, "Failed to download HTML source because the following error occurred: \(error)")
                completion()
            } else {
                print(.x, "Failed to download HTML because an unknown error occurred.")
                completion()
            }
        }
        
        htmlTask.resume()
        
        // Once found, create OpS object.
        // https://github.com/dewitt/opensearch/blob/master/opensearch-1-1-draft-6.md#opensearch-url-template-syntax
        //        let openSearch = OpenSearch()
        
        // Pass SearchEngine object, or variables.
        // ---- Add termsPlaceholder?
        // ---- If OpS is found, we should light up the "Test" button in UrlDetails or similar
        
        
        // If OpS fails, fall back to old method.
        //        return nil
    }
    
    
    func findOpenSearchHtmlTag(in html: String) -> String? {
        let elementStart = "<link "
        let elementMiddle = "application/opensearchdescription+xml"
        // Should end with " />" but we're playing it safe
        let elementEnd = ">"
        
        // Look for the OpS string identifier and try to split there
        let components = html.components(separatedBy: elementMiddle)
        
        // Make sure the OpS string was found at least once
        guard components.count >= 2 else {
            return nil
        }
        
        // Look backward from the OpS string to find the start of the <link> tag
        // Note: This force unwrap SHOULD be okay, given we guarded the array
        let start = components.first!.components(separatedBy: elementStart)
        
        // Make sure the start string was found at least once
        guard start.count >= 2 else {
            return nil
        }
        
        // Look beyond the Ops string to find the end of the <link> tag
        let end = components[1].components(separatedBy: elementEnd)
        
        guard end.count >= 2 else {
            return nil
        }
        
        // At this point, we should have the <link> tag isolated and can assemble it
        return elementStart + start.last! + elementMiddle + end.first! + elementEnd
    }
    
    
    // Parse for URL and name (anything else? icon?).
    // TODO: May be able to get name from <link rel="opensearch.." title="Wikipedia (en)">
    func parseXml(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: - Parser delegte functions
    
    // Identify the element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //        /* *** DEBUG *** */
        //        print("***** ELEMENT NAME: \(elementName)")
        //        print("***** ATTRIBUTES: \(attributeDict)")
        
        // Switch to parsing OpS XML if we've found its opening tag
        if parsingHtml && elementName == "OpenSearchDescription" {
            print(.n, "Begin parsing OpenSearch XML.")
            parsingHtml = false
        }
        
        if parsingHtml {
            // We're only concerned with <link> tags
            if elementName == "link" {
                // We only want those with "search" rel and OpS type attributes
                guard let rel = attributeDict["rel"],
                    rel == "search",
                    let type = attributeDict["type"],
                    type == "application/opensearchdescription+xml" else {
                        return
                }
                
                // Note: Multiple of the above link+rel+type combination can exist, but we'll just have to hope the first is right...
                
                // Make sure this is an absolute URL and using httpS
                guard let unformattedHref = attributeDict["href"],
                    let absoluteUrl = URL(string: unformattedHref, relativeTo: url)?.absoluteString,
                    var components = URLComponents(string: absoluteUrl) else {
                        print(.x, "Failed to format <link> href into absolute URL.")
                        return
                }
                components.scheme = "https"
                guard let href = components.url else {
                    print(.x, "Failed to format <link> href into https URL.")
                    return
                }
                
                // If we've found a usable URL for the XML file, set it for the next network request
                print(.o, "Located OpenSearch XML document at \(href).")
                openSearchDescriptionUrl = href
                parser.abortParsing()
            }
        } else {
            // OpS XML parsing
            switch elementName {
            case "Url":
                guard var urlTemplate = attributeDict["template"] else {
                    print(.x, "URL attribute in XML file does not include template attribute.")
                    break
                }
                
                // For now, we only want the URL used for results (default), and using HTML
                //- Break out of this element if any of that isn't true
                if (attributeDict["rel"] != nil && attributeDict["rel"] != "results")
                    || attributeDict["type"] != "text/html" {
                    xmlElement = ""
                    break
                }
                
                // If we've made it this far, we believe this URL is the correct one
                print(.o, "Found OpenSearch URL; template before parameter substitution: \(urlTemplate).")
                
                // Replace {searchTerms} with the magicWord
//                urlTemplate = urlTemplate.replacingOccurrences(of: "{searchTerms}", with: SearchEngines.shared.termsPlaceholder)
                urlTemplate = urlTemplate.replacingOccurrences(of: "{searchTerms}", with: urlController.magicWord)
                
                // Eliminate all other {template parameters}; we'll just have to hope this works since we can't predict them
                while let start = urlTemplate.firstIndex(of: "{"),
                    let end = urlTemplate.firstIndex(of: "}") {
                        urlTemplate.removeSubrange(start...end)
                }
                
                print(.o, "Setting OpenSearch URL to \(urlTemplate).")
                openSearch.url = URL(string: urlTemplate)
            default:
                // Other elements are passed on to the parser for further inspection (foundCharacters func)
                xmlElement = elementName
            }
        }
        
    }
    
    // Convert XML element value to object parameter
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !parsingHtml {
            switch xmlElement {
            case "ShortName":
                // Some XML documents assign this twice, the second being "\n  ", so we only accept the first one
                if openSearch.name.isEmpty {
                    openSearch.name = string
                }
            default:
                break
            }
        }
    }
    
    // Stop looking for XML link once we leave the <head> tag
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if parsingHtml && elementName == "head" {
            print(.i, "Aborting search for XML URL because closing head tag was reached.")
            parser.abortParsing()
        }
    }
    
    // Pass new OpenSearch object once XML parsing is complete
    func parserDidEndDocument(_ parser: XMLParser) {
        print(.o, "Reached end of XML file without any errors.")
    }
    
    // Parser error
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // When we abort on purpose, error 512 will be reported, but we don't mind that
//        if parseError.localizedDescription.contains("512") {
        if (parseError as NSError).code == 512 {
            print(.i, "Desired data was found, so parsing was aborted.")
        } else {
            print(.x, "OpenSearch \(parsingHtml ? "HTML" : "XML") parsing failed because the following error occurred: \(parseError.localizedDescription)")
        }
    }
    
    // TODO: Search suggestions (MainVC):
    // http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.0
    
    // TODO: Detect mobile? (Are we already doing this with IconFetcher?)
    // http://www.opensearch.org/Community/Proposal/Specifications/OpenSearch/Extensions/Mobile/1.0/Draft_1
    
}
