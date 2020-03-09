//
//  IntroAddEngineViewController.swift
//  Chears
//
//  Created by Xcode on ’19/08/26.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class IntroAddEngineViewController: UIViewController {

    @IBOutlet weak var appExtensionNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appExtensionNameLabel.text = AppKeys.appExtensionName
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
