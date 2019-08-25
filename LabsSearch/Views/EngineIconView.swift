//
//  EngineIconView.swift
//  LabsSearch
//
//  Created by Xcode on ’18/10/25.
//  Copyright © 2018 Distant Labs. All rights reserved.
//

/*
 * Alright look, this is a weird implementation but obviously we're amateurs.
 *
 * Ideally, I suppose, these would all be methods on the EngineIconView class itself.
 */

// TODO: Apparently we should be using "observers" to do this automatically... :(
//- https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_key-value_observing_in_swift
// Subclassing UIView to be smart:
//- UIView subclass frame init/layout: https://stackoverflow.com/a/39810191/
//- Subclassing UIView: https://stackoverflow.com/a/41928756/
//- Init UIView subclass object: https://stackoverflow.com/a/7126874/
//-
//- More: https://medium.com/@marcosantadev/calayer-and-auto-layout-with-swift-21b2d2b8b9d1

import UIKit

protocol EngineIconViewController {
    // All three views MUST be set when conforming to this protocol; IBOutlet is fine.
    // TODO: Are those exclamation marks necessary?
    var engineIconView: EngineIconView! { get }
    var engineIconImage: EngineIconImageView! { get }
    var engineIconLabel: EngineIconLabel! { get }
    
    // This must also be set; see updateIconEngine for notes on how to handle
    var engine: SearchEngine? { get set }
}

extension EngineIconViewController {
    
    /// Set up the icon for display.
    ///
    /// Views which will change the icon based on user input should use `updateIconEngine()` to avoid recalculating the corners and border every time.
    func setIcon() {
        updateIconLayout()
        if engine != nil {
            updateIconEngine()
        }
    }
    
    
    /// Sets up the initial layout of the view--basically everything but the engine's specific icon.
    ///
    /// Call during `viewWillAppear` in views beneath the settings view to make sure this is always udpated. Note that clip to bounds must be set in Interface Builder to see any effect.
    func updateIconLayout() {
        updateIconCorners()
        drawBorder()
    }
    
    
    /// Sets corner roundness of the engine icon based on the user's `stayInApp` preference.
    func updateIconCorners() {
        // 16.0 imitates Safari bookmarks; 4.0 imitates home screen icons
        let engineIconCornerRadiusFactor: CGFloat
//        if UserDefaults.standard.bool(forKey: SettingsKeys.stayInApp) {
        if let stayInApp = UserDefaults(suiteName: AppKeys.appGroup)?.bool(forKey: SettingsKeys.stayInApp),
            stayInApp {
            // true
            engineIconCornerRadiusFactor = 16.0
        } else {
            // false or nil
            engineIconCornerRadiusFactor = 4.0
        }
        
        // FIXME: Corners are wrong due to iPhone vs. iPad traits.
        //- (mainly in add/edit?)
        // engineIconView.frame.width reports based on IB preview rather than actual device
        //- iPad IB, iPad device: Main 120, AddEdit 120
        //- iPad IB, iPhone device: Main 120 (60 when returning from Settings), AddEdit 120
        //- iPhone IB, iPad device: Main 120, AddEdit 60
        //- iPhone IB, iPhone device: Main 60, AddEdit 60
        
        let engineIconCornerRadius = engineIconView.frame.width / engineIconCornerRadiusFactor
        engineIconView.layer.cornerRadius = engineIconCornerRadius

        // Note on icon size: 60 imitates iPhone home screen/bookmark sizes
        // 144 looks nice but most icons appear to be aliased
    }
    
    
    /// Creates a slight border around the icon view for aesthetic purposes (especially useful on white backgrounds).
    func drawBorder() {
        let layer = engineIconView.layer

//        layer.borderColor = UIColor(white: 0, alpha: 0.4).cgColor
//        layer.borderWidth = 0.1
        // This seems to be closest to as it appears in iOS Settings app.
        layer.borderColor = UIColor(white: 0, alpha: 0.8).cgColor
        layer.borderWidth = 0.05
    }
    
    
    /// Updates the icon to use the appropriate image or label.
    ///
    /// This method should not be called directly. For typical views which set the icon only once, initialize the icon through the `setIcon` method in the `engine didSet`. For views that have to change the icon beyond its initial state, provide `didSet` on the `engine` property of the view which calls this function.
    func updateIconEngine() {
        guard let engine = engine else {
            print(.x, "Cannot update icon because no engine is set.")
            return
        }
        
        // Get the expected background colour from IB
        // This should only be called once
        if engineIconView.defaultBackgroundColor == nil {
            engineIconView.defaultBackgroundColor = engineIconView.backgroundColor
        }
        
        // Hide both image and label, then later show only the one we use
        // Image doesn't react well to isHidden, so we use alpha
        engineIconImage.alpha = 0
        engineIconLabel.isHidden = true
        
        // Check if the detected engine has an image
        if let image = engine.getImage() {
            print(.i, "\(engine.name) has an image; using for icon.")
            engineIconImage.image = image
            engineIconImage.alpha = 1
            // Change background colour to white, in case image has transparencies
            engineIconView.backgroundColor = .white
        } else {
            // No image for engine, so use first letter of name as label
            print(.n, "\(engine.name) has no image; setting label for icon.")
//            engineIconLabel.setLetter(using: engine.shortcut)
            // This is more useful than shortcut in non-Latin alphabets
            engineIconLabel.setLetter(using: engine.name)
            engineIconLabel.isHidden = false
            // Change background colour back to grey, in case image was previously shown
            engineIconView.backgroundColor = engineIconView.defaultBackgroundColor
        }
    }
    
}


/// The main view of an engine icon, which will choose between an image or a label, in that order.
class EngineIconView: UIView {
    // This will be set by the control to read from IB
    var defaultBackgroundColor: UIColor?
    
    // Prevent background colour from being changed by table cell when selected
    override var backgroundColor: UIColor? {
        didSet {
//            if backgroundColor != nil && backgroundColor!.cgColor.alpha == 0 {
//                backgroundColor = oldValue
//            }
            
            if let color = backgroundColor,
                color.cgColor.alpha == 0 {
                backgroundColor = oldValue
            }
        }
    }
}

/// The label view of an engine icon, which shows when no image is available.
class EngineIconLabel: UILabel {
    /// Set the label to the first letter of the search engine name.
    ///
    /// - Parameter shortcut: The `SearchEngine` name.
    func setLetter(using name: String) {
        text = String(name.uppercased().first ?? "🔍")
    }
}

// We don't really need this class, but it makes it easier to identify stuff.
// Also note that IB complains about unknown classes if typealias is used... :(
//typealias EngineIconImageView = UIImageView

/// The image view of an engine icon, which shows so long as an image is available.
class EngineIconImageView: UIImageView {}
