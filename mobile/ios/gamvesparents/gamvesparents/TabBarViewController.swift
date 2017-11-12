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

    var blurVisualEffectView:UIVisualEffectView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        
        //navigationController?.navigationBar.topItem?.title = "Home"
        
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
        let homeTitle = "Home"
        homeNavController.tabBarItem.title = homeTitle
        homeNavController.tabBarItem.image = UIImage(named: "home")
        homeViewController.title = homeTitle
        
        let layout = UICollectionViewFlowLayout()
        let chatViewController = ChatFeedViewController(collectionViewLayout: layout)
        chatViewController.tabBarViewController = self
        let charNavController = UINavigationController(rootViewController: chatViewController)
        let activiyTitle = "Activity"
        charNavController.tabBarItem.title = activiyTitle
        charNavController.tabBarItem.image = UIImage(named: "activity")
        chatViewController.title = activiyTitle

        let profileViewController = ProfileViewController()
        profileViewController.tabBarViewController = self
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        let profileTitle = "Profile"
        profileNavController.tabBarItem.title = profileTitle
        profileNavController.tabBarItem.image = UIImage(named: "profile")
        profileViewController.title = profileTitle

        /*let settingsViewController = SettingsViewController()
        settingsViewController.tabBarViewController = self
        let settingsNavController = UINavigationController(rootViewController: settingsViewController)
        settingsNavController.tabBarItem.title = "Settings"
        settingsNavController.tabBarItem.image = UIImage(named: "settings")*/

        //viewControllers = [homeNavController, charNavController, profileNavController, settingsNavController]
        
        viewControllers = [homeNavController, charNavController, profileNavController]

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

}


