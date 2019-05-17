//
//  IntroViewController.swift
//  Chears
//
//  Created by Xcode on ’19/05/16.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIPageViewControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    // MARK: - Methods
    
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
    func didUpdatePageCount(to count: Int) {
        pageControl.numberOfPages = count
    }
    
    /// Update the page control (dots) to reflect the currently visible page in the PageVC.
    ///
    /// - Parameter pageIndex: The new page index.
    func didUpdatePageIndex(to index: Int) {
        pageControl.currentPage = index
    }
    

    // MARK: - Navigation

    // Displaying the container with the PageVC apparently counts as a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? IntroPageViewController else {
            print(.x, "Attempted to show wrong VC in container.")
            return
        }
        
        // Set oursevles as the delegate so we can control the page control (dots)
        destination.delegate = self
    }

}
