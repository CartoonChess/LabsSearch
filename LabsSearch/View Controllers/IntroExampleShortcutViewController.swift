//
//  IntroExampleShortcutViewController.swift
//  Chears
//
//  Created by Xcode on ’19/05/18.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class IntroExampleShortcutViewController: UIViewController, EngineIconViewController {
    
    // EngineIconVC stub vars
    @IBOutlet weak var engineIconView: EngineIconView!
    @IBOutlet weak var engineIconImage: EngineIconImageView!
    @IBOutlet weak var engineIconLabel: EngineIconLabel!
    var engine: SearchEngine? {
        didSet {
            // Main VC uses updateIconEngine() here and layout else; we won't change so do all at once
            setIcon()
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var shortcut = NSLocalizedString("SearchEngine.defaultEngines-YouTubeShortcut", comment: "")
        
        if !SearchEngines.shared.enabledShortcuts.contains(shortcut) {
            // No YouTube in this language; just use first engine in list
            shortcut = SearchEngines.shared.enabledShortcuts.first ?? "gif"
        }
        
        // Set sample engine to YouTube for icon
        engine = SearchEngine(
            name: "",
            shortcut: shortcut,
            baseUrl: URL(string: "http://example.com")!,
            queries: [:],
            isEnabled: true
        )
        
        searchTextField.text = shortcut + " " + NSLocalizedString("Intro.searchTextField-example", comment: "")
        highlightSearchShortcut(shortcut, in: searchTextField)
    }
    
    // Highlight the search shortcut in a given text field.
    func highlightSearchShortcut(_ shortcut: String, in textField: UITextField) {
        // Set up special attributes for shortcut text
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray
        ]
        
        // Replace text field text with coloured copy
        textField.decorateText(using: attributes, on: shortcut, maintainCursorPosition: false)
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
