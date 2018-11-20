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
        
        // TODO: Link IBOutlets, then enable these lines
        //- Also need to deal with engine optional (declared in protocol via parent,
        //- but also unwrapped in super function...)
        engineShortcutLabel.text = engine?.shortcut
//        engineIsEnabled.isOn = engine.isEnabled
    }
    
}
