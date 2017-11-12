    //
//  HomeCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/19/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
    


class HomeCell: BaseCell, UIPageViewControllerDataSource, UIPageViewControllerDelegate, CellDelegate {
        
    var pages = [UIViewController]()
    //let pageControl = UIPageControl()
    var pageController : UIPageViewController?
    
    var categoryHomePage:CategoryHomePage!
    var categoryPage:CategoryPage!
    var fanpagePage:FanpagePage!
    
    var index = Int()    
    
    override func setupViews() 
    {
        super.setupViews()

        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController!.dataSource = self       
        self.pageController!.delegate = self
        
        self.categoryHomePage = CategoryHomePage()
        self.categoryHomePage.delegate = self
        
        self.categoryPage = CategoryPage()
        self.categoryPage.delegate = self
        
        self.fanpagePage = FanpagePage()
        self.fanpagePage.delegate = self
        
        let initialPage = 0
        
        // add the individual viewControllers to the pageController
        self.pages.append(self.categoryHomePage)
        self.pages.append(categoryPage)
        self.pages.append(fanpagePage)
        //self.pages.append(videoPage)
        
        //self.pageControl.numberOfPages = 4
        
        self.pageController?.setViewControllers([self.pages[initialPage]], direction: .forward, animated: true, completion: nil)
        
        self.pageController!.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);

        // pageControl
        //self.pageControl.frame = CGRect()
        //self.pageControl.currentPageIndicatorTintColor = UIColor.black
        //self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        //self.pageControl.numberOfPages = self.pages.count
        //self.pageControl.currentPage = initialPage
        //self.pageControl.pageIndicatorTintColor = UIColor.black

        self.addSubview((self.pageController?.view)!)

        removeSwipeGesture()
        
    }
    
   

    func removeSwipeGesture()
    {
        for view in self.pageController!.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
    
  
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex == 0 {
                // wrap to last page in array
                return self.pages.last
            } else {
                // go to previous page in array
                return self.pages[viewControllerIndex - 1]
            }
        }
        return nil
    }
            
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex < self.pages.count - 1 {
                // go to next page in array
                return self.pages[viewControllerIndex + 1]
            } else {
                // wrap to first page in array
                return self.pages.first
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    
    }

    func scrollToViewController(viewController: UIViewController,
                                direction: UIPageViewControllerNavigationDirection, data: AnyObject?)
    {
        
        pageController?.setViewControllers([viewController],
            direction: direction,
            animated: true,
            completion: { (finished) -> Void in
                
                // Setting the view controller programmatically does not fire
                // any delegate methods, so we have to manually notify the
                // 'tutorialDelegate' of the new index.
                //self.notifyTutorialDelegateOfNewIndex()
                
                if data != nil //.isKind(of: String() as! AnyClass)
                {
                    if (data?.isKind(of: CategoryGamves.self))!
                    {
                            print("category")
                        
                            let category = viewController as! CategoryPage
                        
                            category.categoryGamves = data as! CategoryGamves
                        
                            category.setCategoryData()
                        
                    } else if (data?.isKind(of: FanpageGamves.self))!
                    {
                        print("fanpage")
                        
                        let fanpagePage = viewController as! FanpagePage
                        
                        let fanpage = data as! FanpageGamves
                        
                        //print(fanpage.fanpageObj?.objectId)
                        
                        fanpagePage.setFanpageGamvesData(data: fanpage)
                        
                        fanpagePage.setFanpageData()
                    }
                }
        })
        
    }
    
    
    func setCurrentPage(current: Int, direction: UIPageViewControllerNavigationDirection, data: AnyObject?)
    {           
        print(current)
        
        scrollToViewController(viewController: pages[current], direction: direction, data: data)
    }


    
    
}


