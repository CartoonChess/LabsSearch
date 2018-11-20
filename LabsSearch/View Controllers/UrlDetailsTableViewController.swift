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
    /// After the user has modified the URL or magic word, decide whether to prepare to save the changes to the engine object. If the URL and magic word are valid, mark the URL as changed, so that it can be saved later. If either value is invalid, mark the URL as unchanged, so that it will revert back to its original value.
    ///
    /// - Parameters:
    ///   - baseUrl: The URL without queries.
    ///   - queries: A key-value dictionary of query items.
    func updateUrlDetails(baseUrl: URL?, queries: [String: String])
}

class UrlDetailsTableViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    // MARK: - Properties
    
    var engine: SearchEngine?
    
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

    // Set to true when URL+magic word are all good
//    var engineIsTestable: Bool = false {
//        willSet {
//            // Imitate enabled/disabled state in test button
//            if newValue {
//                testButtonLabel.textColor = view.tintColor
//            } else {
//                testButtonLabel.textColor = .gray
//            }
//        }
//    }
    
    @IBOutlet weak var urlTextField: TableViewCellTextField!
    
    @IBOutlet weak var magicWordCell: UITableViewCell!
    @IBOutlet weak var magicWordTextField: TableViewCellTextField!
    
    @IBOutlet weak var testButtonLabel: UILabel!
    
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the URL and search term fields
        if let engine = engine {
            // Get the URL from the model, adding in the default search term
            let url = engine.baseUrl.withSearchTerms(urlController.magicWord, using: engine.queries)!
            print(.o, "Using URL \(url).")
            
            // If we want to set magic world field placeholder text ...
            //magicWordTextField.placeholder = urlController.magicWord
            
            // Show the URL
            urlTextField.text = url.absoluteString
        }
        
        // Determine if initial values are good enough to allow a test to be run
        updateView()
    }
    
    
    @IBAction func urlTextFieldChanged() {
        textFieldsDidChange = true
        updateView()
    }
    
    @IBAction func magicWordTextFieldChanged() {
        textFieldsDidChange = true
        updateView()
    }
    
    
    /// Make changes to the view depending on whether the URL is valid and the magic word is found.
    func updateEngineTestableStatus() {
        // TODO: See if we can combine some logic:
        //- Consolodate detectMagicWord and updateMagicWord
        //- Note: engineIsTestable = url.isValid + detectMagicWord ... right?
        //- Plus: magicWord's `hide` is always true when the URL is valid and contains the default magicWord
        //- (Put another way: If looking for a custom word (whether present or not), this is false
        
        
        // First, check that URL itself is valid
        guard let url = urlController.validUrl(from: urlTextField.text, schemeIsValid: { schemeIsValid(url: $0) }) else {
            // URL field is empty or otherwise invalid
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
    }
    
//    /// Make changes to the view depending on whether the URL is valid and the magic word is found.
//    func updateEngineTestableStatus() {
//        // TODO: See if we can combine some logic:
//        //- Consolodate detectMagicWord and updateMagicWord
//        //- Note: engineIsTestable = url.isValid + detectMagicWord ... right?
//        //- Plus: magicWord's `hide` is always true when the URL is valid and contains the default magicWord
//        //- (Put another way: If looking for a custom word (whether present or not), this is false
//
//
//        // First, check that URL itself is valid
//        guard let url = urlController.validUrl(from: urlTextField.text, schemeIsValid: { schemeIsValid(url: $0) }) else {
//            // URL field is empty or otherwise invalid
//            urlController.urlIsValid = false
//            urlController.engineIsTestable = false
//            urlController.customMagicWordIsInUrl = false
//            return
//        }
//
//        // URL is valid; first, update URL text field to reflect this
//        urlController.urlIsValid = true
//
//        // If the default magic word is there, the engine is already testable
//        if urlController.detectMagicWord(in: url) {
//            urlController.engineIsTestable = true
//            urlController.customMagicWordIsInUrl = false
//            return
//        }
//
//        // URL is valid but default magic word isn't found, so check if the user has entered a custom word
//        if let customMagicWord = magicWordTextField.text,
//            !customMagicWord.isEmpty,
//            urlController.detectMagicWord(in: url, magicWord: customMagicWord) {
//            urlController.engineIsTestable = true
//            urlController.customMagicWordIsInUrl = true
//        } else {
//            // If we make it here, there's no custom word, or it isn't in the URL
//            urlController.engineIsTestable = false
//            urlController.customMagicWordIsInUrl = false
//        }
//
//    }
    
    
//    /// Make changes to the view depending on whether the URL is valid and the magic word is found.
//    func updateEngineTestableStatus() {
//        // TODO: See if we can combine some logic:
//        //- Consolodate detectMagicWord and updateMagicWord
//        //- Note: engineIsTestable = url.isValid + detectMagicWord ... right?
//        //- Plus: magicWord's `hide` is always true when the URL is valid and contains the default magicWord
//        //- (Put another way: If looking for a custom word (whether present or not), this is false
//
//        // Begin ridiculous logic chain to determine if URL is valid and if magic word matches (= engine is testible)
//
////        let urlController = UrlController()
//
//        // First, check that URL itself is valid
//        if let url = urlController.validUrl(from: urlTextField.text, schemeIsValid: { schemeIsValid(url: $0) }) {
//
//            // URL is valid; first, update URL text field to reflect this
//            updateUrlTextField(urlIsValid: true)
//
//            // Next, see if the magic word is in the URL queries, starting with the default magic word
//
//            // If the default magic word is there, the engine is already testable
//            engineIsTestable = urlController.detectMagicWord(in: url)
//
//            if engineIsTestable {
//                // Default magic word found in URL
//                updateMagicWordCell(hide: true)
//
//            // If the default magic word isn't found, check if the user has entered a custom word
//            } else if let customMagicWord = magicWordTextField.text,
//                !customMagicWord.isEmpty {
//
//                // There's a custom word, socheck for that in the URL
//                // Engine testability depends on finding that word
//                engineIsTestable = urlController.detectMagicWord(in: url, magicWord: customMagicWord)
//                updateMagicWordCell(hide: false)
//
//            // Here, the default magic word wasn't found, but neither has the user entered a custom word
//            } else {
//                updateMagicWordCell(hide: false)
//            }
//
//        // If we reach here, the URL field is empty or otherwise invalid
//        } else {
//            updateUrlTextField(urlIsValid: false)
//            engineIsTestable = false
//            updateMagicWordCell(hide: true)
//        }
//
//    }
    
    /// Determines whether the URL can be tested from within the current view.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: A boolean value based on whether the view will be able to load the URL.
    ///
    /// By default, this will only be true when the scheme is `http(s)`. While this is the only option for app extensions, the full app can and should override this method to return the value of `url.schemeIsValid` instead.
    func schemeIsValid(url: URL) -> Bool {
        return url.schemeIsCompatibleWithSafariView
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
    }
    
    /// Imitate enabled/disabled state in test button
    func updateTestButton() {
        if urlController.engineIsTestable {
            testButtonLabel.textColor = view.tintColor
        } else {
            testButtonLabel.textColor = .gray
        }
    }
    
    
    /// Shows the URL in the Safari view, unless the view is unable to display it, in which case an external app will handle it, if desired.
    func openUrl() {
        if urlController.engineIsTestable {
            // TODO: First and second round of tests: first with only the magicWord query,
            //- second uses the original full URL if first fails (based on user feedback)
            //- Note: We may be able to use the completion handler to change test buttons; see extension file
            //- Perhaps set completion to default nil so we can use this elsewhere without specifying explicitly
            if let url = urlTextField.text?.encodedUrl() {
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
    
    /// Provide the option for subclasses to open the URL in an external app, if available.
    ///
    /// App extensions cannot launch external apps, and so should not implement this method. Use `updateEngineTestibleStatus()` to check that URLs use the `http` or `https` schemes and update engineIsTestible accordingly. This method should never have to be called in app extensions.
    func urlRequiresExternalApp(url: URL) {
        print(.x, "Attempted to open URL but view controller provides no means to open URLs with scheme \(url.scheme ?? "nil").")
    }
    
    
    // Note that this is also called when testing, but that's not really a problem
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        var baseUrl: URL?
//        var queries = [String: String]()
        
        // No need to call delegate function unless something has been updated
        if textFieldsDidChange {
            // Pass new URL if everything is working, otherwise we'll pass nil
            if urlController.engineIsTestable {
                urlController.willUpdateUrlDetails(url: urlTextField.text, magicWord: magicWordTextField.text) { (baseUrl, queries) in
                    delegate?.updateUrlDetails(baseUrl: baseUrl, queries: queries)
                }
            }
            
//            delegate?.updateUrlDetails(baseUrl: baseUrl, queries: queries)
        }
    }
    
    
    // MARK: - Table view
    
    // Update the footer (explanatory subtitle) for specified sections
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case Section.instructions:
            return String(format: NSLocalizedString("UrlDetails.firstSection-Instructions", comment: ""), urlController.magicWord)
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
