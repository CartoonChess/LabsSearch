//
//  IntroViewController.swift
//  Chears
//
//  Created by Xcode on ’19/05/16.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

extension UIPageControl {
    
}

class IntroViewController: UIViewController, UIPageViewControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // The next button has to trigger the PageVC to whom we are the delegate, so basically delegate-delegate
//    var pageViewControllerDataSource: UIPageViewControllerDataSource?
    var introPageViewController: IntroPageViewController?
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNextButton()
    }
    
    /// Trigger the next page function of the PageViewController to which this view controller is delegate.
    @IBAction func nextButtonTapped() {
        guard let introPageViewController = introPageViewController else {
                print(.x, "PageVC couldn't be unwrapped in IntroVC.")
                return
        }
        
        // Get the currently showing page
        let currentPage = introPageViewController.pages[pageControl.currentPage]
        
//        // Get next page from data source
//        guard let nextPage = introPageViewController.dataSource?.pageViewController(introPageViewController, viewControllerAfter: currentPage) else {
//            print(.x, "Couldn't find next page from IntroVC.")
//            return
//        }
//
//        // Trigger transition in the PageVC
//        introPageViewController.setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
//
//        // Update page control (dots)
//        pageViewController(introPageViewController, didFinishAnimating: true, previousViewControllers: [currentPage], transitionCompleted: true)
        
        // If data source returns the next page, we want to show it
        if let nextPage = introPageViewController.dataSource?.pageViewController(introPageViewController, viewControllerAfter: currentPage) {
            // Trigger transition in the PageVC
            introPageViewController.setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
            // Update page control (dots)
            pageViewController(introPageViewController, didFinishAnimating: true, previousViewControllers: [currentPage], transitionCompleted: true)
        } else {
            // Otherwise, we must already be on the last page, so dismiss the IntroVC altogether
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// Change the text of the next button to one of advancement or dismissal.
    func updateNextButton() {
        let page = pageControl.currentPage
        let last = pageControl.numberOfPages - 1
        
        if page == last {
            nextButton.setTitle(NSLocalizedString("Intro.nextButton-Close", comment: ""), for: .normal)
        } else {
            nextButton.setTitle(NSLocalizedString("Intro.nextButton-Next", comment: ""), for: .normal)
        }
    }
    
    /// Detects when the user changes the highlighted dot in the PageControl by tapping on it, and adjusts the other views accordingly to change the page.
    @IBAction func pageControlValueChanged() {
        print(.d, "Page control value changed.")
        
        // Works, but with two caveats:
        //- 1. Slides in the wrong direction when reversing
        //- 2. Does nothing when trying to go to first page from second
        pageControl.currentPage -= 1
        nextButtonTapped()
        
        //pageControl.previousValue
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
