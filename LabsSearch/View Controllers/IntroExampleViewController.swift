//
//  IntroExampleViewController.swift
//  Chears
//
//  Created by Xcode on ’19/08/23.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class IntroExampleViewController: UIViewController {
    
    @IBOutlet weak var defaultSearchExplanationLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.text = NSLocalizedString("Intro.searchTextField-example", comment: "")
        
        guard let defaultEngineName = SearchEngines.shared.defaultEngine?.name else {
            print(.x, "No default engine was set.")
            return
        }
        
        defaultSearchExplanationLabel.text = String(format: NSLocalizedString("IntroExample.defaultSearch-explanation", comment: "Leave '%@' to represent the default search engine name."), defaultEngineName)
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
