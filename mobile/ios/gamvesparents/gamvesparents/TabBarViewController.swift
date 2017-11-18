//
//  TabBarViewController.swift
//  audible
//
//  Created by Brian Voong on 10/3/16.
//  Copyright © 2016 Lets Build That App. All rights reserved.
//

import UIKit
import Parse

class TabBarViewController: UITabBarController {
    
    var tutorialController = TutorialController()
    
    var chatFeedViewController:ChatFeedViewController!

    var blurVisualEffectView:UIVisualEffectView?
    
    lazy var chatLauncher: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tabBarController?.tabBar.tintColor = UIColor.gamvesColor
    
        
        if let user = PFUser.current()
        {
            if !isLoggedIn()
            {
                perform(#selector(showTutorialController), with: nil, afterDelay: 0.01)
            }
            
        } else
        {
            perform(#selector(showTutorialController), with: nil, afterDelay: 0.01)
        }
        
        

        let homeViewController = HomeViewController()
        homeViewController.tabBarViewController = self
        
        let homeNavController = UINavigationController(rootViewController: homeViewController)
        homeNavController.tabBarItem.image = UIImage(named: "home")
        
        let layout = UICollectionViewFlowLayout()
        self.chatFeedViewController = ChatFeedViewController(collectionViewLayout: layout)
        self.chatFeedViewController.tabBarViewController = self
        
        let homeTitle = "Home"
        homeViewController.title = homeTitle
        
        let chatFeedNavController = UINavigationController(rootViewController: chatFeedViewController)
        self.chatFeedViewController.tabBarItem.image = UIImage(named: "community")
        let activiyTitle = "Activity"
        self.chatFeedViewController.title = activiyTitle
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarViewController = self
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        profileNavController.tabBarItem.image = UIImage(named: "profile")
        let profileTitle = "Profile"
        profileViewController.title = profileTitle

        
        viewControllers = [homeNavController, chatFeedNavController, profileNavController]

        let blurEffect = UIBlurEffect(style: .light)
        blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView?.frame = view.bounds
        self.view.addSubview(blurVisualEffectView!)

    }   
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if !isHasProfileInfo()
        {
            self.selectedIndex = 2
        }

        if isLoggedIn()
        {
            self.blurVisualEffectView?.removeFromSuperview()
        }        
    }
    
    private func createDummyNavControllerWithTitle(title: String, imageName: String) -> UINavigationController {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
    
    fileprivate func isLoggedIn() -> Bool {
        return UserDefaults.standard.isLoggedIn()
    }

    fileprivate func isHasProfileInfo() -> Bool {
        return UserDefaults.standard.isHasProfileInfo()
    }

    
    func showTutorialController() 
    {
        self.tutorialController.tabBarViewController = self
        present(self.tutorialController, animated: true, completion: {
            //perhaps we'll do something here later
        })
        
    }
    
    func showLoginController() {
        
        let loginController = LoginViewController()
        self.tutorialController.dismiss(animated: true)
        present(loginController, animated: true, completion: {
            //perhaps we'll do something here later
            self.blurVisualEffectView?.removeFromSuperview()
        })
        
    }
    
    func handleSignOut()
    {
        UserDefaults.standard.setIsLoggedIn(value: false)        
        let tutorialController = TutorialController()
        present(tutorialController, animated: true, completion: nil)
    }
    
    func openChat(room: String, chatId:Int64, users:[GamvesParseUser])
    {
        
        self.chatLauncher.chatId = chatId
        self.chatLauncher.gamvesUsers = users
        self.chatLauncher.room = room
        self.chatLauncher.isStandAlone = true
        self.chatLauncher.view.backgroundColor = UIColor.white
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = self.chatLauncher

        
        
    }
       

}


