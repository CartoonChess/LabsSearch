//
//  SearchController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/18.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

/// Objects which conform to this protocol receive cues to update their views to reflect the currently selected search engine and the user's search terms.
///
/// Note that, as per internet advice, this delegate protocol and the others in this app which are strictly adopted by view controllers are given the class keyword, and the delegate vars are later `weak`ly retained. Apparently this will help to control memory leaks.
protocol SearchControllerDelegate: class {
    /// Receive updates about the current search to provide feedback to the user about the current engine.
    ///
    /// - Parameters:
    ///   - detectedEngine: The detected search engine, if any.
    ///   - didSetEngine: Whether the engine has been set.
    ///
    /// The delegate should adopt this function by setting `didSetEngine` to default to `false`, as it will never be `true` when `detectedEngine` is `nil`. Therefore, be sure to always set `didSetEngine` to `true` when supplying any non-`nil` value to `detectedEngine`.
    func didUpdateSearch(detectedEngine: SearchEngine?, didSetEngine: Bool)
}

// This extension allows protocol functions to adopt default values
// TODO: Should this have :class as well?
extension SearchControllerDelegate {
    // Call the function as usual, but default `didSetEngine` to false
    func didUpdateSearch(detectedEngine: SearchEngine?, didSetEngine: Bool = false) {
        didUpdateSearch(detectedEngine: detectedEngine, didSetEngine: didSetEngine)
    }
}

/// Performs all functions related to determining the engine and query and performing the search.
struct SearchController {
    // The delegate will update the view (image, search field)
    weak var delegate: SearchControllerDelegate?
    // Variable updates whenever user's text matches a search shortcut
    var currentSearchEngine: SearchEngine? = nil
    
    // TODO: Might need to account for %20 vs. + sign
    // TODO: If we ever feel like refactoring this again, we might use switch cases with advanced matching
    //- Reference: https://www.hackingwithswift.com/files/pro-swift-sample.pdf
    
    mutating func detectEngine(in unsplitText: String?) {
        
        if let unsplitText = unsplitText, !unsplitText.isEmpty {
            
            // Leading whitespace throws off the logic, and trimming it changes the cursor position in the view
            // Therefore, don't bother to detect anything when there's leading whitespace; just nil everything
            guard unsplitText == unsplitText.leadingSpacesRemoved() else {
                print(.n, "Search field contains leading whitespace; setting engine to nil.")
                currentSearchEngine = nil
                delegate?.didUpdateSearch(detectedEngine: nil)
                return
            }
            
            
            print(.o, "Search field contains text; attempting to split.")
            let components = splitShortcutAndTerms(in: unsplitText)
            let possibleShortcut: String
            
            if let components = components {
                // Successful split
                possibleShortcut = components[0]
            } else {
                // Could not split; remove trailing space if it exists
                possibleShortcut = unsplitText.trimmingCharacters(in: .whitespaces)
            }
            
            // We now have a possibleShortcut; we may optionally have additionalTerms
            
            if let currentSearchEngine = currentSearchEngine {
                print(.o, "Search engine already set; proceeding to check for changes to shortcut.")
                if possibleShortcut == currentSearchEngine.shortcut {
                    print(.o, "Current shortcut \"\(possibleShortcut)\" matches current engine \(currentSearchEngine.name); checking for space or additional terms.")
                    if unsplitText != currentSearchEngine.shortcut {
                        print(.o, "Search field contains at least a space after shortcut \(currentSearchEngine.shortcut); no change needed.")
                        // TODO: Do we need to call the delegate, or is there really no change?
                        return
                    } else {
                        print(.n, "Engine \(currentSearchEngine.name) matches shortcut \"\(unsplitText)\" but no space or additional terms were entered; desetting engine.")
                        delegate?.didUpdateSearch(detectedEngine: currentSearchEngine)
                        self.currentSearchEngine = nil
                        return
                    }
                } else {
                    // TODO: We may need to check for current engine and changed engine simultaneously
                    print(.n, "Engine set to \(currentSearchEngine.name) but shortcut changed to \"\(possibleShortcut)\"; desetting engine and rechecking text.")
                    self.currentSearchEngine = nil
                }
            }
            
            // If execution continues beyond this point, text was entered, but engine was not set
            // Based on the above logic, this if should always be entered with currentSearchEngine set to nil
            
//            if let detectedEngine = SearchEngines.shared.allEngines[possibleShortcut] {
            if SearchEngines.shared.enabledShortcuts.contains(possibleShortcut),
                let detectedEngine = SearchEngines.shared.allEngines[possibleShortcut] {
                print(.o, "Detected engine \(detectedEngine.name) from shortcut \"\(possibleShortcut)\".")
                if unsplitText != detectedEngine.shortcut {
                    print(.o, "Space or additional text were entered after the shortcut; saving engine.")
                    currentSearchEngine = detectedEngine
                    delegate?.didUpdateSearch(detectedEngine: detectedEngine, didSetEngine: true)
                } else {
                    print(.n, "Engine detected, but will not save until space or additional text is entered.")
                    delegate?.didUpdateSearch(detectedEngine: detectedEngine)
                }
            } else {
                print(.n, "Shortcut \"\(possibleShortcut)\" doesn't match any enabled engine.")
                delegate?.didUpdateSearch(detectedEngine: nil)
            }
            
        } else {
            print(.n, "Search field is empty; setting engine to nil.")
            currentSearchEngine = nil
            delegate?.didUpdateSearch(detectedEngine: nil)
        }
    }
    
    
    /// Perform a search for a string of terms using a given search engine.
    ///
    /// - Parameters:
    ///   - unsplitText: The full string provided by the user, including engine shortcut and search terms.
    ///   - completion: The completion handler which will handle displaying the URL.
    ///   - url: The URL sent to the completion enclosure. The view controller which called this function must handle displaying the URL in a Safari view or external app.
    func search(_ unsplitText: String, completion: (_ url: URL) -> Void) {
        var shortcut: String? = nil
        var terms = unsplitText
        let searchEngine: SearchEngine

        // Return the shortcut and the terms, otherwise nil (no shortcut provided because only one word entered)
        let components = splitShortcutAndTerms(in: unsplitText)
        
        if let components = components {
            shortcut = components[0]
            terms = components[1]
        }
        
        // FIXME: Need to disable search text field when there's no search engines available
        //- Update UI to instruct user to allow default engines to be loaded
        
        // TODO: Can we simplify this by asking for the currentSearchEngine?
        //- Maybe falling back to this method if set to nil? Or should we trust that and avoid checking the shortcut altogether?..
        //- Alternately, we may be able to call detectEngine at the beginning of this function;
        //- But that could be an issue with the delegate, not to mention the crazy if/else web...
        if let shortcut = shortcut,
            SearchEngines.shared.enabledShortcuts.contains(shortcut),
            let unwrappedEngine = SearchEngines.shared.allEngines[shortcut] {
            print(.o, "Found engine \(unwrappedEngine.name); preparing for search.")
            searchEngine = unwrappedEngine
        } else {
            guard let defaultEngine = SearchEngines.shared.defaultEngine else {
                // TODO: This is another place we should be calling a generic no-default fallback function
                print(.x, "No default search engine specified.")
                return
            }
            // TODO: Currently, searching for a shortcut without terms just searches that shortcut in the default engine;
            //- Is this desired behaviour? (Maybe? e.g. user wants to literally search for the word "images")
            print(.n, "Search shortcut not recognized or only one word entered; default engine will be used.")
            // If no shortcut was detected in the first word, make sure we search using the whole text
            terms = unsplitText
            searchEngine = defaultEngine
        }
        
//        // This is sorta hacky, but basically it replaces any empty query with the search terms
//        let queries = searchEngine.queries
//        let url = searchEngine.baseUrl.withSearchTerms(terms, using: queries)!
        
        // Check for placeholder in queries and base URL
        guard let url = searchEngine.baseUrl.withSearchTerms(terms, using: searchEngine.queries, replacing: SearchEngines.shared.termsPlaceholder) else {
            print(.x, "Failed to inject search terms into URL.")
            return
        }
        
        // Safari view must be handled by subclass of UIViewController
        completion(url)
        
    }
    
    
    // We had move showSearchInExternalApp to a struct extension because action extensions can't access UIApplication.shared.
    //- However, our main app had trouble accessing the struct extension, so we changed the following setting instead:
    //- [Project] > Targets > [Action Extension] > Build Settings > Build Options >>
    //- >> Require Only App-Extension-Safe API -> changed to NO
    //- Of course, we must be careful never to access showSearchInExternalApp in the action extension,
    //- or everything will blow up, presumably.
    
    
    /// Isolate the search shortcut from the user's search terms.
    ///
    /// - Parameter unsplitText: The full string as entered by the user.
    /// - Returns: An array of two strings—the `shortcut` and `terms`—or else `nil` if there was only one word.
    func splitShortcutAndTerms(in unsplitText: String) -> [String]? {
        let components = unsplitText.split(separator: " ", maxSplits: 1)
        
        if components.count > 1 {
            let shortcut = String(components[0])
            let terms = String(components[1])
            print(.o, "Text split into \"\(shortcut)\" and \"\(terms)\".")
            return [shortcut, terms]
        } else {
            // There was only one word, so no shortcut was present
            print(.n, "Text could not be split because only one word was entered.")
            return nil
        }
    }
    
}
