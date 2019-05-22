//
//  IntroPageViewController.swift
//  Chears
//
//  Created by Xcode on ’19/05/15.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit


extension UIPageViewControllerDelegate {
    /// Called by the UIPageViewController whenever the current number of pages is set or changed.
    ///
    /// - Parameter pageCount: The new page count.
    func didUpdatePageCount(to count: Int) {}
}


class IntroPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    
    // MARK:- Properties
    
    // Array of all "pages" (view controllers)
    let pages: [UIViewController] = {
        let viewControllerIDs = ["Intro4", "Intro1", "Intro2", "Intro3"]
        return viewControllerIDs.map {
            return UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: $0)
        }
    }()
    
    
    // MARK:- Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set data source (pages) to scroll through
        dataSource = self
        guard let firstPage = pages.first else {
            print(.x, "Failed to unwrap first page.")
            return
        }
        setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        
        // Pass page count to delegate to set page control (dots)
        delegate?.didUpdatePageCount(to: pages.count)
    }
    
    
    // MARK:- Data source methods
    
    // Define previous page when swiping (PageVCDataSource protocol required method)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pages.firstIndex(of: viewController) else {
            print(.x, "Page is not in intro pages array.")
            return nil
        }
        
        let previousPageIndex = pageIndex - 1
        
        // Show the previous page, unless we're already on the first page
        if previousPageIndex >= 0 {
            return pages[previousPageIndex]
        } else {
            return nil
        }
    }
    
    // Define next page when swiping (PageVCDataSource protocol required method)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pages.firstIndex(of: viewController) else {
            print(.x, "Page is not in intro pages array.")
            return nil
        }
        
        let nextPageIndex = pageIndex + 1
        
        // Show the next page, unless we're already on the last page
        if nextPageIndex < pages.count {
            return pages[nextPageIndex]
        } else {
            return nil
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
