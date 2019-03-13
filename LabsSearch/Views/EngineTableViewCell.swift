//
//  EngineTableViewCell.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/25.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

import UIKit

/// A basic cell showing a search engine's icon and name.
class EngineTableViewCell: UITableViewCell, EngineIconViewController {
    
    // This is used for displaying and changing the icon via the protocol
    var engine: SearchEngine? {
        didSet {
            setIcon()
            updateCell()
        }
    }
    
    @IBOutlet weak var engineIconView: EngineIconView!
    @IBOutlet weak var engineIconImage: EngineIconImageView!
    @IBOutlet weak var engineIconLabel: EngineIconLabel!
    
    @IBOutlet weak var engineNameLabel: UILabel!
    
    
    // Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    /// Set cell parameters after cell is created.
    ///
    /// - Parameter engine: The search engine whose details will fill the cell.
    func updateCell() {
        guard let engine = engine else {
            print(.x, "Failed to unwrap engine for table cell.")
            return
        }

        engineNameLabel.text = engine.name
        
        // Dim the cell if the engine is disabled
        // TODO: We should probably split enabled/disabled engines between two sections
        if !engine.isEnabled {
            engineIconView.alpha = 0.5
            engineNameLabel.alpha = 0.5
        }
    }
    
    
    /// Bug fix? This helps tables adjust cell heights on load if the labels are too long
    override func didMoveToSuperview() {
        layoutIfNeeded()
    }


    // This was in the boilerplate but we're not using it
    /*
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
     */

}


/// A detailed cell showing most properties of a search engine.
class AllEnginesTableViewCell: EngineTableViewCell {
    
    // TODO: Do we need to override/make any super calls, such as awakeFromNib()?
    
    @IBOutlet weak var engineShortcutLabel: UILabel!
    
    override func updateCell() {
        super.updateCell()
        
        guard let engine = engine else {
            print(.x, "Failed to unwrap engine for use in table cell.")
            return
        }
        
        engineShortcutLabel.text = engine.shortcut
        if !engine.isEnabled {
            engineShortcutLabel.alpha = 0.5
        }
        // TODO: Link IBOutlets, then enable this line
//        engineIsEnabled.isOn = engine.isEnabled
    }
    
}
