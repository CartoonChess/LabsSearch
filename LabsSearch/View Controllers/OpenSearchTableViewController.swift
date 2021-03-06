//
//  OpenSearchTableViewController.swift
//  Chears
//
//  Created by Xcode on ’19/02/15.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

protocol OpenSearchTableViewControllerDelegate {
    func openSearchViewControllerDidDisappear()
}

class OpenSearchTableViewController: UITableViewController {
    
    // MARK: - Parameters
    
    // If OpS is found, an engine object will be created and set back to AllEngines to be passed to AddEdit VC
    var openSearch: OpenSearch?
    var searchEngineEditor = SearchEngineEditor()
    let urlController = UrlController()
    
    var delegate: OpenSearchTableViewControllerDelegate?
    
    // A properly formatted URL, in case the user entered a slightly malformed one
    // When set to nil, test button should be disabled
    var url: URL? = nil {
        didSet {
            if url == nil {
                toggleTestButton(enable: false)
            } else {
                toggleTestButton(enable: true)
            }
        }
    }
    
    // Note: Sections/cells enums copied from UrlDetails
    
    // Table sections
    enum Section {
        static let instructions = 0
        static let noteAboutAppExtension = 3
    }
    
    // Index paths for cells
    enum Cell {
        static let testButton: IndexPath = [2, 0]
    }
    
    // IB outlets
    @IBOutlet weak var urlTextField: TableViewCellTextField!
    @IBOutlet weak var testButtonLabel: UILabel!
    @IBOutlet weak var testButtonActivityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Test button is disabled until text is entered
        toggleTestButton(enable: false)
        
        // Show keyboard automatically
        urlTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.openSearchViewControllerDidDisappear()
        
    }
    
    @IBAction func urlTextFieldChanged() {
        // Disable the test button if the URL field is empty
        guard let urlString = urlTextField.text,
            !urlString.isEmpty else {
                print(.i, "URL text field is empty.")
                self.url = nil
                return
        }

        // If the user's text is a proper URL, make sure it's https and enable test button
        // Note that the URL validates even for single words, so this isn't very robust

        // TODO: Maybe we can just look for "://" ...
        //- Split into components using ://
        //- Replace scheme or add https...
        // OR MAYBE put this in the schemeIsValid area??? As a separate toHttps() function...
        // [old: schemeIsValid(url: $0)]


        var possibleUrl: URL?
        // Check if URL is valid, and if it contains non-UTF characters
        //- Non-UTF URL will set "invalid utf-8"
        self.searchEngineEditor.updateCharacterEncoding(encoder: CharacterEncoder(encoding: ""), urlString: urlString, allowNilEncoder: true)
        
        // If encoding was changed or was unnecessary, this will work, otherwise we will fail with invalid URL
        possibleUrl = self.urlController.validUrl(from: urlString, characterEncoder: self.searchEngineEditor.characterEncoder)
        
        guard let url = possibleUrl else {
            // URL field is not a valid URL
            self.url = nil
            return
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print(.n, "Failed to break URL into components.")
            self.url = nil
            return
        }



        // Network requests tend to fail unless protocol is followed by "://",
        //- but URLComponents usually only inserts ":". We try to fix this.
        components.scheme = "https"

        guard var urlWithSlashes = components.string else {
            print(.x, "Could not test for leading slashes.")
            self.url = nil
            return
        }

        // Test for two slashes following scheme, otherwise add them
        if urlWithSlashes.count >= 8 {
            var prefix = urlWithSlashes.prefix(8) // "https:**"
            urlWithSlashes.removeFirst(8)

            if prefix.dropLast() != "https:/" {
                // "https:ex"
                prefix = "https://" + prefix.suffix(2)
            } else if prefix != "https://" {
                // "https:/e"
                prefix = "https://" + prefix.suffix(1)
            }

            urlWithSlashes = prefix + urlWithSlashes
        }

        guard let httpsUrl = URL(string: urlWithSlashes) else {
            print(.x, "Could not change scheme to https.")
            self.url = nil
            return
        }

        print(.i, "Setting URL to \(httpsUrl).")
        self.url = httpsUrl
    }
    
    
    /// Visually updates the test button to show whether it is enabled or not.
    ///
    /// - Parameter enable: `true` if enabled, `false` if disabled.
    ///
    /// Setting the `url` to `nil` automatically calls this function, which does not actually disable any button; the row is made untappable when the `url` is invalid.
    func toggleTestButton(enable: Bool) {
        switch enable {
        case true:
            testButtonLabel.textColor = view.tintColor
        case false:
            testButtonLabel.textColor = .gray
        }
    }
    
    
    @IBAction func testButtonTapped() {
        guard let url = url else {
            print(.x, "Test button was somehow tapped while URL was invalid.")
            return
        }
        
        // Show network loading indicator; this is turned off in the unwind segue (AllEngines VC)
        // TODO: Or maybe in the cancel/found/skip segues?
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // While testing, Disable URL text field and replace button text with activity spinner
        urlTextField.isEnabled = false
        testButtonLabel.isHidden = true
        testButtonActivityIndicator.startAnimating()
        // Note: This apparently makes the cell untappable, but why?
        
        let openSearchController = OpenSearchController()
        openSearchController.detectOpenSearch(at: url) {
            // Save HTML so other controllers can use it
            self.searchEngineEditor.html = openSearchController.html
            // And the character encoder, in case we found an encoding
            // But don't use UTF-8 if the URL isn't valid UTF!
            
            if let remoteEncoder = openSearchController.characterEncoder {
                let textFieldEncoder = self.searchEngineEditor.characterEncoder
                switch (remoteEncoder.encoding.value, textFieldEncoder?.encoding.value) {
                case (.utf8, String.Encoding.invalid):
                    // Keep invalid utf-8
                    break
                default:
                    // Any encoding should be fine
                    self.searchEngineEditor.characterEncoder = remoteEncoder
                }
            }
            
            let name = openSearchController.openSearch.name
            
            if let openSearchUrl = openSearchController.openSearch.url {
                print(.o, "Found OpenSearch named \"\(name)\" with URL \(openSearchUrl).")
                self.openSearch = openSearchController.openSearch
            } else {
                print(.n, "Failed to fetch an OpenSearch URL.")
                // Pass user's preferred (but non-OpS) URL along to AllEngines->AddEdit
                self.openSearch = OpenSearch(name: name, url: url)
            }
            
            // Make sure the segue occurs on the main thread
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: SegueKeys.attemptedOpenSearchUnwind, sender: nil)
            }
        }
    }
    
    
//    /// Just dismiss this VC when tapping the cancel button (no unwind segue).
//    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
//        dismiss(animated: true, completion: nil)
//    }
    
    
    // MARK: - Table view
    // Note: This is almost directly copied from UrlDetails :(
    
    // Update the footer (explanatory subtitle) for specified sections
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case Section.instructions:
            return NSLocalizedString("OpenSearch.firstSection-Instructions", comment: "")
        case Section.noteAboutAppExtension:
            return NSLocalizedString("OpenSearch.lastSection-NoteAboutAppExtension", comment: "")
        default:
            // We have to let this fail silently because it's called every time the view scrolls...
            return nil
        }
    }
    
    // Highlight on tap
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath {
        case Cell.testButton:
            // When test button is enabled, show highlight on tap
            return (url != nil && !testButtonActivityIndicator.isAnimating)
        default:
            // Other cells never need to be highlighted
            return false
        }
    }
    
    
    // Handle tapping certain rows as though they are buttons.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case Cell.testButton:
            testButtonTapped()
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print(segue.identifier)
        guard #available(iOS 13.0, *),
            let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
        presentationController.delegate?.presentationControllerDidDismiss!(presentationController)
    }
    */
    
//    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        super.dismiss(animated: flag, completion: completion)
//
//        guard #available(iOS 13.0, *),
//            let presentationController = presentationController else { return }
//        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
//    }

}
