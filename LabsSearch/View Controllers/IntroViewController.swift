//
//  IntroViewController.swift
//  Chears
//
//  Created by Xcode on ’19/05/16.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

//extension UIPageControl {
//    var currentPage: Int {
////        willSet {
////            print("derp")
////        }
////        return 1
////        let zero = 0
//        didSet {
//            print(.d, "oldValue: \(oldValue)")
//            print(.d, "newValue: \(self.currentPage)")
//        }
//        return self.currentPage
//    }
//
//    var previousPage: Int?
//
//    override var currentPage: Int {
//        willSet(newValue) {
//            print(.d, "newValue: \(newValue)")
//        }
//        didSet {
//            print(.d, "oldValue: \(oldValue)")
//            previousPage = oldValue
//        }
//    }
//}

/// Adds `previouslyDisplayedPage` and `lastPage` properties to the default `UIPageControl` implementation.
///
/// The overridden `currentPage` property automatically passes its previous value to this subclass' `previouslyDisplayedPage` property whenever it is changed. This can be used to identify whether the user tapped on the left or the right side of the control to change the page. However, `previouslyDisplayedPage` will not be updated when the `currentPage` value is changed via Interface Builder. Therefore, an additional function which copies the value of `currentPage` to `previouslyDisplayedPage` whenever the control is touched is advised.
class IntroPageControl: UIPageControl {
    var previouslyDisplayedPage: Int?
    
    override var currentPage: Int {
        didSet {
            previouslyDisplayedPage = oldValue
        }
    }
    
    var lastPage: Int {
        return numberOfPages - 1
    }
}


/// The controller for the view which contains the container which contains the controller for the view that holds the view controller pages.
class IntroViewController: UIViewController, UIPageViewControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nextButton: UIButton!
//    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControl: IntroPageControl!
    
    // The next button has to trigger the PageVC to whom we are the delegate, so basically delegate-delegate
//    var pageViewControllerDataSource: UIPageViewControllerDataSource?
    var introPageViewController: IntroPageViewController?
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNextButton()
    }
    
    /// Determine whether to advance to the next page or to dismiss the intro altogether.
    @IBAction func nextButtonTapped() {
        if pageControl.currentPage != pageControl.lastPage {
            // As long as we aren't on the last page, advance to the next one
            changePage()
        } else {
            // Otherwise, we must already be on the last page, so dismiss the IntroVC altogether
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// Change the text of the next button to one of advancement or dismissal.
    func updateNextButton() {
        if pageControl.currentPage != pageControl.lastPage {
            nextButton.setTitle(NSLocalizedString("Intro.nextButton-Next", comment: ""), for: .normal)
        } else {
            nextButton.setTitle(NSLocalizedString("Intro.nextButton-Close", comment: ""), for: .normal)
        }
    }
    
    /// Interface Builder does not use the custom `IntroPageControl` override of `currentPage`, so we have to make sure `previouslyDisplayedPage` is up-to-date before the control's value is changed.
    @IBAction func pageControlValueTouched() {
        pageControl.previouslyDisplayedPage = pageControl.currentPage
    }
    
    /// Detects when the user changes the highlighted dot in the PageControl by tapping on it, and adjusts the other views accordingly to change the page.
    @IBAction func pageControlValueChanged() {
        if let previousPage = pageControl.previouslyDisplayedPage,
            pageControl.currentPage > previousPage {
            // The counter has to be returned to its previous state before this call, otherwise it advances twice
            //- Plus the other functions rely on knowing what the index was before the value change
            pageControl.currentPage -= 1
            changePage()
        } else {
            // If the user tapped on the left side, go backwards
            pageControl.currentPage += 1
            changePage(direction: .reverse)
        }
    }
    
    // Called when transition after swipe has finished (used to update page control [dots])
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let introPageViewController = pageViewController as? IntroPageViewController else {
            print(.x, "PageViewController isn't of Intro type!")
            return
        }
        
        //        // This function can be triggered even if the user aborts the transition, so we must check
        //        // (not sure this is strictly necessary, though)
        //        guard completed else {
        //            print(.d, "Page transition aborted.")
        //            return
        //        }
        
        // PageVC indicates pages as viewControllers array
        guard let page = introPageViewController.viewControllers?.first,
            let pageIndex = introPageViewController.pages.firstIndex(of: page) else {
                print(.x, "Page is not in intro pages array.")
                return
        }
        
        didUpdatePageIndex(to: pageIndex)
    }
    
    // This is called by the PageVC itself on load, not by us.
    //- Overrides the stub function of the delegate protocol extension.
    func didUpdatePageCount(to count: Int) {
        pageControl.numberOfPages = count
    }
    
    /// Update the page control (dots) to reflect the currently visible page in the PageVC.
    ///
    /// - Parameter pageIndex: The new page index.
    func didUpdatePageIndex(to index: Int) {
        pageControl.currentPage = index
        updateNextButton()
    }
    
    /// Transition to the next or previous page, if it exists.
    ///
    /// - Parameter direction: Whether to go `forward` or in `reverse`. Defaults to `forward`.
    func changePage(direction: UIPageViewController.NavigationDirection = .forward) {
        guard let introPageViewController = introPageViewController else {
            print(.x, "PageVC couldn't be unwrapped in IntroVC.")
            return
        }
        
        // Get the currently showing page
        let currentPage = introPageViewController.pages[pageControl.currentPage]
        // And prepare for the page we're transitioning to
        let pageToDisplay: UIViewController
        
        switch direction {
        case .forward:
            // If data source returns the next page, we want to show it
            if let nextPage = introPageViewController.dataSource?.pageViewController(introPageViewController, viewControllerAfter: currentPage) {
                pageToDisplay = nextPage
            } else {
                print(.n, "No next page found.")
                return
            }
        case .reverse:
            if let previousPage = introPageViewController.dataSource?.pageViewController(introPageViewController, viewControllerBefore: currentPage) {
                pageToDisplay = previousPage
            } else {
                print(.n, "No previous page found.")
                return
            }
        @unknown default:
            print(.x, "Attempted to change pages in a weird direction!")
            return
        }
        
        // Trigger transition in the PageVC
        introPageViewController.setViewControllers([pageToDisplay], direction: direction, animated: true, completion: nil)
        // Update page control (dots)
        pageViewController(introPageViewController, didFinishAnimating: true, previousViewControllers: [currentPage], transitionCompleted: true)
        
    }
    

    // MARK: - Navigation

    // Displaying the container with the PageVC apparently counts as a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // First, don't bother with any of the below if we're just pressing the skip button
        if let _ = sender as? UIButton { return }
        
        // Otherwise, the segue should really be showing the pages inside the container
        guard let destination = segue.destination as? IntroPageViewController else {
            print(.x, "Attempted to show wrong VC in container.")
            return
        }
        
        // Set oursevles as the delegate so we can control the page control (dots)
        destination.delegate = self
        // And make a reference to the PageVC so we can trigger its "next page" func with our next button
        introPageViewController = destination
    }

}
