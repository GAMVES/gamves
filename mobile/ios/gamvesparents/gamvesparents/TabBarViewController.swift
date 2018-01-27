//
//  TabBarViewController.swift
//  audible
//
//  Created by Brian Voong on 10/3/16.
//  Copyright © 2016 Lets Build That App. All rights reserved.
//

import UIKit
import Parse

class TabBarViewController: UITabBarController, CLLocationManagerDelegate {
    
    var tutorialController = TutorialController()
    
    var chatFeedViewController:ChatFeedViewController!

    var blurVisualEffectView:UIVisualEffectView?
    
    var locationManager : CLLocationManager = CLLocationManager()
        
    var didFindLocation = Bool()
    
    //var profileViewController : ProfileViewController!
    //var isRegistered = Bool()
    
    lazy var homeViewController: HomeViewController = {
        let launcher = HomeViewController()
        launcher.tabBarViewController = self
        return launcher
    }()
    
    lazy var chatLauncher: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()
    
    lazy var accountViewController: AccountViewController = {
        let launcher = AccountViewController()
        launcher.tabBarViewController = self
        return launcher
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tabBarController?.tabBar.tintColor = UIColor.gamvesColor
    
        locationManager.delegate = self
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
            didFindLocation = false
        }
        
        if let user = PFUser.current() {
            if !isLoggedIn() {
                perform(#selector(showTutorialController), with: nil, afterDelay: 0.01)
            }
        } else {
            perform(#selector(showTutorialController), with: nil, afterDelay: 0.01)
        }
        
        let homeNavController = UINavigationController(rootViewController: homeViewController)
        homeNavController.tabBarItem.image = UIImage(named: "home")
        
        let layout = UICollectionViewFlowLayout()
        self.chatFeedViewController = ChatFeedViewController(collectionViewLayout: layout)
        self.chatFeedViewController.tabBarViewController = self
        
        let homeTitle = "Home"
        self.homeViewController.title = homeTitle
        
        let chatFeedNavController = UINavigationController(rootViewController: chatFeedViewController)
        self.chatFeedViewController.tabBarItem.image = UIImage(named: "community")
        let activiyTitle = "Activity"
        self.chatFeedViewController.title = activiyTitle
        
        let accountNavController = UINavigationController(rootViewController: accountViewController)
        self.accountViewController.tabBarItem.image = UIImage(named: "profile")
        let accountTitle = "Account"
        self.accountViewController.title = accountTitle
        
        viewControllers = [homeNavController, chatFeedNavController, accountNavController]

        let blurEffect = UIBlurEffect(style: .light)
        blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView?.frame = view.bounds
        self.view.addSubview(blurVisualEffectView!)
        
    }
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        
        if !isHasProfileInfo() && !isHasRegistered()
        {
            self.selectedIndex = 2
        } else
        {
            self.selectedIndex = 0
            
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

    fileprivate func isHasRegistered() -> Bool {
        return UserDefaults.standard.isRegistered()
    }
    
    @objc func showTutorialController() 
    {
        self.tutorialController.tabBarViewController = self
        present(self.tutorialController, animated: true, completion: {
            //perhaps we'll do something here later
        })
        
    }
    
    func showLoginController(registered: Bool) {
        
        UserDefaults.standard.setIsRegistered(value: registered)
        
        let loginController = LoginViewController()
        
        loginController.isRegistered = registered
        loginController.tabBarViewController = self
        self.tutorialController.dismiss(animated: true)        
        
        present(loginController, animated: true, completion: {
            //perhaps we'll do something here later
            self.blurVisualEffectView?.removeFromSuperview()
        })
        
    }
    
    func handleSignOut(registered: Bool)
    {
        UserDefaults.standard.setIsLoggedIn(value: false)        
        let tutorialController = TutorialController()        
        present(tutorialController, animated: true, completion: nil)
    }
    
    func openChat(room: String, chatId:Int, users:[GamvesParseUser])
    {
        
        self.chatLauncher.chatId = chatId
        self.chatLauncher.gamvesUsers = users
        self.chatLauncher.room = room
        self.chatLauncher.isStandAlone = true
        self.chatLauncher.view.backgroundColor = UIColor.white
        
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window!?.rootViewController = self.chatLauncher      
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first
        {
            if !didFindLocation
            {
                didFindLocation = true
                
                print(location.coordinate)
                
                var lat = Double(location.coordinate.latitude)
                var lng = Double(location.coordinate.longitude)
                
                self.getLastLocation(completionHandler: { ( point:PFGeoPoint, has:Bool ) -> () in
                    
                    var newLocation = Bool()
                    
                    if has
                    {
                        
                        let current = PFGeoPoint(latitude: lat, longitude: lng)
                        let distance = current.distanceInKilometers(to: point as! PFGeoPoint)
                        
                        if distance > 0.2
                        {
                            newLocation = true
                        }
                        
                    } else
                    {
                        newLocation = true
                    }
                    
                    if newLocation
                    {
                        let userLocation = PFObject(className: "Location")
                        
                        if let userId = PFUser.current()?.objectId
                        {
                            userLocation["userId"] = userId
                        }
                        
                        let geoPoint = PFGeoPoint(latitude: lat, longitude: lng)
                        userLocation["geolocation"] = geoPoint
                        
                        userLocation.saveInBackground(block: { (resutl, error) in
                            
                            if error != nil
                            {
                                print(error)
                            } else
                            {
                                print(resutl)
                            }
                            
                        })
                    }
                })
            }
        }
    }
    
    
    func getLastLocation(completionHandler : @escaping (_ point:PFGeoPoint, _ has:Bool) -> ()?)
    {
        let locationQuery = PFQuery(className:"Location")
        
        if let userId = PFUser.current()?.objectId
        {
            locationQuery.whereKey("userId", equalTo: userId)
        }
        locationQuery.order(byDescending: "createdAt")
        
        locationQuery.getFirstObjectInBackground { (location, error) in
            
            var point = PFGeoPoint()
            
            if error != nil
            {
                print("error: \(error)")
            }
            
            if location != nil
            {
                point = location?["geolocation"] as! PFGeoPoint
                
                completionHandler(point, true)
                
            } else
            {
                completionHandler(point, false)
                
            }
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp()
    {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to deliver pizza we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
   
    

}


