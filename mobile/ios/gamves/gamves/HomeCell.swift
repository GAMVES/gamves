    //
//  HomeCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/19/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Floaty

class HomeCell: BaseCell, UIPageViewControllerDataSource, UIPageViewControllerDelegate, CellDelegate {
    
    var homeController: HomeController?
    
    var pages = [UIViewController]()
    
    var pageController : UIPageViewController?
    
    var categoryHomePage:CategoryHomePage!
    var categoryPage:CategoryPage!
    var fanpagePage:FanpagePage!
    
    var index = Int()      
    
    override func setupViews() 
    {
        super.setupViews()   

        //self.backgroundColor = UIColor.green

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

        self.pages.append(self.categoryHomePage)
        self.pages.append(self.categoryPage)
        self.pages.append(self.fanpagePage)      
        
        self.pageController?.setViewControllers([self.pages[initialPage]], direction: .forward, animated: true, completion: nil)
        
        self.pageController!.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);    

        self.addSubview((self.pageController?.view)!)

        removeSwipeGesture()
        
        let floaty = Floaty()
        
        floaty.addItem(title: "New Fanpage", handler: { item in
            
            if self.homeController != nil
            {
                self.homeController?.addNewFanpage(edit:false)
            }
            
        })
        
        floaty.addItem(title: "New Video", handler: { item in
            
            if self.homeController != nil
            {
                self.homeController?.addNewVideo()
            }
            
        })
        
        self.addSubview(floaty)

        NotificationCenter.default.addObserver(self, selector: #selector(setLastFanpage), name: NSNotification.Name(rawValue: Global.notificationKeyReloadPageFanpage), object: nil)
        
        Global.pagesPageView = self.pages
        
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
                             
                if data != nil 
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
                        
                        var fanpagePage = viewController as! FanpagePage
                        
                        var fanpage = data as! FanpageGamves
                        
                        //print(fanpage.fanpageObj?.objectId)
                        
                        fanpagePage.setFanpageGamvesData(data: fanpage)
                        
                        fanpagePage.setFanpageData()                        

                    }
                }
        })
        
    }
    
    

    func setLastFanpage() {       
        
        self.pageController?.setViewControllers([self.pages[0]], direction: .forward, animated: true, completion: nil)
    }

    
    func setCurrentPage(current: Int, direction: UIPageViewControllerNavigationDirection, data: AnyObject?)
    {
        //let fanpage = data as! FanpageGamves
        
        //print(fanpage.fanpageObj?.objectId)
        
        scrollToViewController(viewController: pages[current], direction: direction, data: data)
        
        self.pageController?.setViewControllers([self.pages[current]], direction: .forward, animated: true, completion: nil)
    }


    
    
}


