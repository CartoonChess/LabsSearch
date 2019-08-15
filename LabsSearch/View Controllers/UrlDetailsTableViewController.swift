//
//  UrlDetailsTableViewController.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/30.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit
import SafariServices

/// Allows the add/edit engine table view controller to receive details about the URL status.
protocol UrlDetailsTableViewControllerDelegate: class {
    var iconFetcher: IconFetcher { get }
    var searchEngineEditor: SearchEngineEditor { get set }
    /// After the user has modified the URL or magic word, decide whether to prepare to save the changes to the engine object. If the URL and magic word are valid, mark the URL as changed, so that it can be saved later. If either value is invalid, mark the URL as unchanged, so that it will revert back to its original value.
    ///
    /// - Parameters:
    ///   - baseUrl: The URL without queries.
    ///   - queries: A key-value dictionary of query items.
    func updateUrlDetails(baseUrl: URL?, queries: [String: String], updateView: Bool)
    func updateFields(for url: String)
    func updateIcon(for url: URL, host: String, completion: ((_ encodingChanged: Bool) -> Void)?)
    
    // Now we can tell AddEdit to reevaluate, i.e. check shortcut
    // in odd event engine was added via action extension inside Safari VC
    func willEnterForeground()
    
//    // This is just for debugging
//    var nameTextField: TableViewCellTextField! { get }
}

// Note: Code for UITextView is left here and in IB

//class UrlDetailsTableViewController: UITableViewController, UITextViewDelegate, SFSafariViewControllerDelegate {
class UrlDetailsTableViewController: UITableViewController, SFSafariViewControllerDelegate, XMLParserDelegate {

    // MARK: - Properties
    
    var engine: SearchEngine?
    
    /// The URL sent from the host app, if using the action extension and if the URL exists.
    ///
    /// This will be `nil` if the host app didn't send a URL or if the user has already set their own.
    var hostAppUrlString: String?
    
    // The URL sent from an unsuccessful OpenSearch attempt.
    var openSearchUrl: String?
    
    // Delegate-related properties
    weak var delegate: UrlDetailsTableViewControllerDelegate?
    var textFieldsDidChange: Bool = false
    
    // Table sections
    enum Section {
        static let instructions = 0
    }

    // Index paths for cells
    enum Cell {
        static let testButton: IndexPath = [2, 0]
    }
    
    // Used for validating URL and accessing .magicWord
    var urlController = UrlController()

    
    @IBOutlet weak var urlTextField: TableViewCellTextField!
//     // Reconnect the below in IB if using in the future
//    @IBOutlet weak var urlTextView: UITextView!
    
    @IBOutlet weak var magicWordCell: UITableViewCell!
    @IBOutlet weak var magicWordTextField: TableViewCellTextField!
    
    @IBOutlet weak var testButtonLabel: UILabel!
    
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Sets size for URL text view
//        tableView.estimatedRowHeight = 44
//        urlTextView.delegate = self
//        urlTextView.textContainerInset = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
        
        // Set up the URL and search term fields
        if let engine = engine {
            // Get the URL from the model, adding in the default search term
//            let url = engine.baseUrl.withSearchTerms(urlController.magicWord, using: engine.queries, replacing: SearchEngines.shared.termsPlaceholder)!
            let url = engine.baseUrl.withSearchTerms(urlController.magicWord, using: engine.queries, replacing: SearchEngines.shared.termsPlaceholder, encoding: delegate?.searchEngineEditor.characterEncoder?.encoding)!
            print(.i, "Using URL \(url).")
            
            // If we want to set magic world field placeholder text ...
            //magicWordTextField.placeholder = urlController.magicWord
            
            // Show the URL
            urlTextField.text = url.absoluteString
        } else if let openSearchUrl = openSearchUrl {
            // This happens when OpS was used but the URL wasn't valid
            // Note that even if OpS didn't find anything, if the URL contained the magic word, this view doesn't load, just assumes the URL is good
            urlTextField.text = openSearchUrl
        } else {
            // Engine is nil; this will do nothing if not using the action extension
            // Set URL to that which is provided by the host app if we haven't already made our own
            urlTextField.text = hostAppUrlString
        }
        
        // Determine if initial values are good enough to allow a test to be run
        updateView()
    }
    
    
    @IBAction func urlTextFieldChanged() {
        textFieldsDidChange = true
        
        // TODO: Add http(s?):// if the user didn't type in any protocol
        
        updateView()
    }
    
    // Delegate function; allows cell to resize with text view (in conjunction with tableView(heighForRowAt))
//    func textViewDidChange(_ textView: UITextView) {
//        UIView.setAnimationsEnabled(false)
//        textView.sizeToFit()
//        tableView.beginUpdates()
//        tableView.endUpdates()
//        UIView.setAnimationsEnabled(true)
//    }
//
//    // This helps with textViewDidChange to resize cell with textview's size as contents change
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//            return UITableView.automaticDimension
//    }
    
    
    @IBAction func magicWordTextFieldChanged() {
        textFieldsDidChange = true
        updateView()
    }
    
    /// Change the return key on the URL text field depending on its contents.
    func updateUrlTextFieldReturnKey() {
        if urlController.engineIsTestable {
            urlTextField.returnKeyType = .go
        } else if !magicWordCell.isHidden {
            urlTextField.returnKeyType = .next
        } else {
            urlTextField.returnKeyType = .default
        }
        
        // TODO: This may only work for iOS 10+
        //- (same for magic word text field return key)
        //- However, we don't support below iOS 10 at the moment.
        urlTextField.reloadInputViews()
    }
    
    /// Change the return key on the magic word text field depending on its contents.
    func updateMagicWorldTextFieldReturnKey() {
        if urlController.engineIsTestable {
            magicWordTextField.returnKeyType = .go
        } else {
            magicWordTextField.returnKeyType = .default
        }
        
        magicWordTextField.reloadInputViews()
    }
    
    /// Decide what to do when pressing the return key in the URL field.
    @IBAction func urlTextFieldReturnKeyPressed() {
        if urlController.engineIsTestable {
            // If the engine is already testable, run the test
            openUrl()
        } else if !magicWordCell.isHidden {
            // If it's not testable and the magic word field is showing, move the cursor there
            magicWordTextField.becomeFirstResponder()
            
        } else {
            // If the URL is just invalid, hide the keyboard
            urlTextField.endEditing(true)
        }
    }
    
    /// Decide what to do when pressing the return key in the magic word field.
    @IBAction func magicWordTextFieldReturnKeyPressed() {
        if urlController.engineIsTestable {
            // If the engine is testable, run the test
            openUrl()
        } else {
            // If not, just hide the keyboard
            magicWordTextField.endEditing(true)
        }
    }
    
    
    /// Make changes to the view depending on whether the URL is valid and the magic word is found.
    func updateEngineTestableStatus() {
        // TODO: See if we can combine some logic:
        //- Consolodate detectMagicWord and updateMagicWord
        //- Note: engineIsTestable = url.isValid + detectMagicWord ... right?
        //- Plus: magicWord's `hide` is always true when the URL is valid and contains the default magicWord
        //- (Put another way: If looking for a custom word (whether present or not), this is false
        
        
//        // First, check that URL itself is valid
//        guard let url = urlController.validUrl(from: urlTextField.text, characterEncoder: delegate?.searchEngineEditor.characterEncoder, schemeIsValid: { schemeIsValid(url: $0) }) else {
//            // URL field is empty or otherwise invalid
//            urlController.urlIsValid = false
//            return
//        }
        
        
//        // First, check that URL itself is valid
//        var url = urlController.validUrl(from: urlTextField.text, characterEncoder: delegate?.searchEngineEditor.characterEncoder, schemeIsValid: { schemeIsValid(url: $0) })
//
//        // If the URL isn't valid, try changing the encoding to "invalid utf-8" and try again
//        if url == nil {
//            let invalidEncoding = CharacterEncoding(name: "invalid utf-8", value: .invalid)
//            let invalidEncoder = CharacterEncoder(encoding: invalidEncoding)
//            guard let encodedUrl = urlController.validUrl(from: urlTextField.text, characterEncoder: invalidEncoder, schemeIsValid: { schemeIsValid(url: $0) }) else {
//                // URL field is empty or otherwise invalid
//                urlController.urlIsValid = false
//                return
//            }
//            // If the encoding was the problem, change it, and keep going
//            delegate?.searchEngineEditor.updateCharacterEncoding(encoder: invalidEncoder, urlString: encodedUrl.absoluteString, completion: nil)
//            url = encodedUrl
//        }
        
        
        
        // Quit if URL field is empty
        guard let urlString = urlTextField.text,
            !urlString.isEmpty else {
            urlController.urlIsValid = false
            return
        }
        
        var possibleUrl: URL?
        // Check if URL is valid, and if it contains differently-encoded characters
        //- If using UTF-8, non-UTF URL will set "invalid utf-8"
        delegate?.searchEngineEditor.updateCharacterEncoding(encoder: delegate?.searchEngineEditor.characterEncoder, urlString: urlString, allowNilEncoder: true)
        
        // If encoding was changed or was unnecessary, this will work, otherwise we will fail with invalid URL
        possibleUrl = urlController.validUrl(from: urlString, characterEncoder: delegate?.searchEngineEditor.characterEncoder, schemeIsValid: { self.schemeIsValid(url: $0) })
        
        // Quit if URL field is not a valid URL
        guard let url = possibleUrl else {
            urlController.urlIsValid = false
            return
        }
        
        // If the default magic word is there, the engine is already testable
        if urlController.detectMagicWord(in: url) {
            urlController.engineIsTestable = true
            urlController.customMagicWordIsInUrl = false
            return
        }
        
        // URL is valid but default magic word isn't found, so check if the user has entered a custom word
        if let customMagicWord = magicWordTextField.text,
            !customMagicWord.isEmpty,
            urlController.detectMagicWord(in: url, magicWord: customMagicWord) {
            urlController.customMagicWordIsInUrl = true
        } else {
            // If we make it here, there's no custom word, or it isn't in the URL
            urlController.urlIsValid = true
            urlController.engineIsTestable = false
        }
        
    }
    
    
    /// Check if the current URL is testable and with what magic word, then reflect this in the view
    func updateView() {
        updateEngineTestableStatus()
        
        updateUrlTextField()
        updateMagicWordCell()
        updateTestButton()
        
        updateIcon()
    }
    
    
    /// Updates the URL text field based on the validity of the URL entered.
    ///
    /// - Parameter urlIsValid: Boolean.
    func updateUrlTextField() {
        // Change the URL text colour based on validity
        if urlController.urlIsValid {
            print(.o, "URL is valid.")
            urlTextField.textColor = UIColor.darkText
        } else {
            print(.n, "URL is invalid.")
            urlTextField.textColor = .red
        }
        
        updateUrlTextFieldReturnKey()
    }
    
    /// Format the magic word cell based on the current URL state
    func updateMagicWordCell() {
        let valid = urlController.urlIsValid
        let testable = urlController.engineIsTestable
        let custom = urlController.customMagicWordIsInUrl
        
        switch (valid, testable, custom) {
        case (_, _, true):
            magicWordCell.isHidden = false
            magicWordTextField.textColor = .black
        case (true, false, _):
            magicWordCell.isHidden = false
            magicWordTextField.textColor = .red
        default:
            magicWordCell.isHidden = true
        }
        
        updateMagicWorldTextFieldReturnKey()
    }
    
    /// Imitate enabled/disabled state in test button
    func updateTestButton() {
        if urlController.engineIsTestable {
            testButtonLabel.textColor = view.tintColor
        } else {
            testButtonLabel.textColor = .gray
        }
    }
    
    /// Tell the AddEditEngine VC to update its icon
    func updateIcon() {
        if urlController.engineIsTestable {
            // Load the page in the background to look for engine name, shortcut, and icon
            
            guard let urlString = urlTextField.text,
                let (url, host) = delegate?.iconFetcher.getUrlComponents(urlString, characterEncoder: delegate?.searchEngineEditor.characterEncoder) else {
                return
            }
            
            // Tell AddEditEngine VC to use the IconFetcher and update its view after fetching icon from server
            delegate?.updateIcon(for: url, host: host) { encodingDidChange in
                if encodingDidChange {
                    print(.d, "UrlDetails completion handler: encoding has changed!")
                    // Double check URL now that encoding has changed
//                    self.urlTextField.text = encodedUrl
                    // TODO: Is this even necessary?
                    self.urlTextFieldChanged()
                    // TODO: This, and the whole completion handler... are they even necessary?
                } else {
                    // Nothing changed
                    print(.d, "UrlDetails completion handler: encoding hasn't changed!")
                }
            }
            
            // TODO: Look in urlTextFieldChanged() for adding http://
        }
    }
    
    
    /// Shows the URL in the Safari view, unless the view is unable to display it, in which case an external app will handle it, if desired.
    func openUrl() {
        if urlController.engineIsTestable {
            // TODO: First and second round of tests: first with only the magicWord query,
            //- second uses the original full URL if first fails (based on user feedback)
            //- Note: We may be able to use the completion handler to change test buttons; see extension file
            //- Perhaps set completion to default nil so we can use this elsewhere without specifying explicitly
            if let url = urlTextField.text?.encodedUrl(characterEncoder: delegate?.searchEngineEditor.characterEncoder) {
                
                // Simultaneously load the same page with URLSession to look for the character encoding
                updateCharacterEncoding(from: url)
                
                // Safari view will crash if not using http
                if url.schemeIsCompatibleWithSafariView {
                    // http or https
                    showSafariViewController(for: url)
                } else {
                    // URL is not http(s)
                    urlRequiresExternalApp(url: url)
                }
            } else {
                print(.x, "Failed to open URL for testing.")
            }
        }
    }
    
    /// Use the testing URL in the background to look for the character encoding.
    ///
    /// - Parameter url: The `URL` whose header might contain character encoding information. The scheme will automatically be changed to `https`.
    func updateCharacterEncoding(from url: URL) {
        // Change scheme to https
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.scheme = "https"
        
        guard let httpsUrl = components?.url else {
            print(.x, "Could not create https URL.")
            return
        }
        
        print(.i, "Checking for character encoding at URL \"\(httpsUrl)\".")
        URLSession.shared.dataTask(with: httpsUrl) { (_, response, error) in
            //                if let engine = self.engine,
            //                    let urlString = engine.baseUrl.withQueries(engine.queries, characterEncoding: self.searchEngineEditor.characterEncoder?.encoding)?.absoluteString {
            //                    // Attempt to update encoding
            //                    let encodingChanged = self.searchEngineEditor.updateCharacterEncoding(encoder: self.iconFetcher.characterEncoder, urlString: urlString)
            //                    // Let the caller (should be UrlDetails) know if the encoding has changed
            //                    if let completion = completion { completion(encodingChanged) }
            //                } else {
            //                    print(.x, "No engine found, or urlString failed.")
            //                }
            if let encodingName = response?.textEncodingName {
                // Encoding header was found
                let encoder = CharacterEncoder(encoding: encodingName)
                // Have to call this async because AddEdit's URL "changed/saved" label may change
                DispatchQueue.main.async {
                    // Attempt to update encoding
                    // FIXME: Will this cause double percent encoding?
                    self.delegate?.searchEngineEditor.updateCharacterEncoding(encoder: encoder, urlString: httpsUrl.absoluteString, completion: nil)
                    
                    // FIXME: If we leave this out, will e.g.UTF+emoji -> EUC cause errors?
                    //- Will everything update and save okay?
                    //- We also removed the Changed() call from when queries are totally removed
//                        // Double check URL now that encoding has changed
//                        self.urlTextField.text = encodedUrl
//                        // This should allow newly encoded queries to be passed back, validate/colour URL, etc.
//                        self.urlTextFieldChanged()
                }
            } else if let error = error {
                print(.n, "Background fetch for HTML headers failed with the following error: \(error)")
            } else {
                print(.i, "No character encoding found.")
            }
        }.resume()
        
    }
    
//    /// Use the testing URL in the background to look for the character encoding.
//    ///
//    /// - Parameter url: The `URL` whose header might contain character encoding information. The scheme will automatically be changed to `https`.
//    func updateCharacterEncoding(from url: URL) {
//        // Change scheme to https
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
//        components?.scheme = "https"
//
//        if let httpsUrl = components?.url {
//            print(.i, "Checking for character encoding at URL \"\(httpsUrl)\".")
//            URLSession.shared.dataTask(with: httpsUrl) { (_, response, error) in
////                if let engine = self.engine,
////                    let urlString = engine.baseUrl.withQueries(engine.queries, characterEncoding: self.searchEngineEditor.characterEncoder?.encoding)?.absoluteString {
////                    // Attempt to update encoding
////                    let encodingChanged = self.searchEngineEditor.updateCharacterEncoding(encoder: self.iconFetcher.characterEncoder, urlString: urlString)
////                    // Let the caller (should be UrlDetails) know if the encoding has changed
////                    if let completion = completion { completion(encodingChanged) }
////                } else {
////                    print(.x, "No engine found, or urlString failed.")
////                }
//                if let encodingName = response?.textEncodingName {
//                    // Encoding header was found
//                    let encoder = CharacterEncoder(encoding: encodingName)
//                    DispatchQueue.main.async {
//                        // Attempt to update encoding
//                        // FIXME: Will this cause double percent encoding?
//                        let encodingDidChange = self.delegate?.searchEngineEditor.updateCharacterEncoding(encoder: encoder, urlString: httpsUrl.absoluteString)
//
//
////                        // Set encoding
////                        self.delegate?.searchEngineEditor.characterEncoder = encoder
////                        print(.o, "Detected and set encoding to \(encoder.encoding). Checking if URL is still valid.")
////                        // Check that the URL still validates in this new encoding
////                        // Copying from AddEdit...
////                        if let urlString = self.urlTextField.text {
////                            print(.d, "url: \(urlString)")
////                            var encodedUrl = encoder.encode(urlString, fullUrl: true)
////                            print(.d, "encodedUrl: \(encodedUrl)")
////                            // This next one (always?) passes when changing utf/nonU->nonU,
////                            //- as well as nonU with no encoding specific characters -> utf
////                            //- It only fails when changing nonU w/ encoding-specific chars -> utf
////                            if let url = self.urlController.validUrl(from: encodedUrl, characterEncoder: encoder, schemeIsValid: {_ in true}) {
////                                print(.d, "validUrl (using \(encoder.encoding)): \(url.absoluteString)")
////                                encodedUrl = url.absoluteString
//
//                                // Double check URL now that encoding has changed
//                                // TODO: Is it right to change this?
//                        // FIXME: If we leave this out, will e.g.UTF+emoji -> EUC cause errors?
//                        //- Will everything update and save okay?
////                                self.urlTextField.text = encodedUrl
////                                // This should allow newly encoded queries to be passed back, validate/colour URL, etc.
////                                self.urlTextFieldChanged()
//                            } else {
//                                // If the URL is no longer valid, red the text field and remove engine's queries
//                                print(.x, "validUrl failed; removing queries from AddEdit's engine object.")
//                                self.delegate?.searchEngineEditor.delegate?.removeQueries()
//                                // FIXME: Can we still call this safely??
//                                self.urlTextFieldChanged()
//                            }
//                        } else {
//                            print(.x, "urlString failed.")
//                        }
//                    }
//
//                } else if let error = error {
//                    print(.n, "Background fetch for HTML headers failed with the following error: \(error)")
//                } else {
//                    print(.i, "No character encoding found.")
//                }
//            }.resume()
//        } else {
//            print(.x, "Could not create https URL.")
//        }
//    }
    
    @objc override func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print(.n, "Safari view dismissed.")
        
        if let extensionDidChangeData = UserDefaults(suiteName: AppKeys.appGroup)?.bool(forKey: SettingsKeys.extensionDidChangeData),
            extensionDidChangeData {
            print(.i, "Engine added via action extension nested inside Safari view; reevaluating AddEdit VC.")
            // Refresh data
            SearchEngines.shared.loadEngines()
            // Tell AddEdit to reevaluate
            delegate?.willEnterForeground()
//            // Toggle setting back to false
//            UserDefaults(suiteName: AppKeys.appGroup)?.set(false, forKey: SettingsKeys.extensionDidChangeData)
            // Toggling the preference back to false will be handled elsewhere
            // Table updates in AddEdit must consider both main and ext engines simultaneously in this case
        }
    }
    
    
    // Note that this is also called when testing, but that's not really a problem
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        let nameText = delegate?.nameTextField.text
//        print(.d, "AddEdit name field: \(nameText)")
        
//        var baseUrl: URL?
//        var queries = [String: String]()
        
        // No need to call delegate function unless something has been updated
        if textFieldsDidChange {
            // Pass new URL if everything is working, otherwise we'll pass nil
            if urlController.engineIsTestable,
                let url = urlTextField.text {
                urlController.willUpdateUrlDetails(url: url, magicWord: magicWordTextField.text, characterEncoder: delegate?.searchEngineEditor.characterEncoder) { (baseUrl, queries) in
                    delegate?.updateUrlDetails(baseUrl: baseUrl, queries: queries, updateView: true)
                    delegate?.updateFields(for: url)
                }
            }
        }
    }
    
    
    // MARK: - Table view
    
    // Update the footer (explanatory subtitle) for specified sections
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case Section.instructions:
            var instructions = String(format: NSLocalizedString("UrlDetails.firstSection-InstructionsStart", comment: ""), urlController.magicWord)
            // Explain about copying URL if we're in the main app
            #if !EXTENSION
                instructions += " " + NSLocalizedString("UrlDetails.firstSection-InstructionsExtraForMainApp", comment: "")
            #endif
            return instructions
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
            return urlController.engineIsTestable
        default:
            // Other cells never need to be highlighted
            return false
        }
    }
    
    
    // Handle tapping certain rows as though they are buttons.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case Cell.testButton:
            openUrl()
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
    }
    */

}
