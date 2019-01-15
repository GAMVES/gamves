//
//  TabBarViewController.swift
//  audible
//
//  Created by Jose Vigil 08/12/2017.
//

import UIKit
import Parse

class TabBarViewController: UITabBarController, CLLocationManagerDelegate, UITabBarControllerDelegate  {
    
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
    
    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()
    
    lazy var accountViewController: AccountViewController = {
        let launcher = AccountViewController()
        launcher.tabBarViewController = self
        launcher.initilizeObservers()
        return launcher
    }()

    lazy var recommendationViewController: RecommendationViewController = {
        let event = RecommendationViewController()
        event.tabBarViewController = self        
        return event
    }()

    var puserId = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }
    
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

        let eventNavController = UINavigationController(rootViewController: recommendationViewController)

        let homeImage: UIImage = UIImage(named: "home")!.resizedImage(newWidth: 30)
        
        eventNavController.tabBarItem.image = homeImage //UIImage(named: "home")
        self.recommendationViewController.tabBarViewController = self

        let eventTitle = "Home"
        self.recommendationViewController.title = eventTitle
       
        let homeNavController = UINavigationController(rootViewController: homeViewController)
        homeViewController.initilizeObservers()

        let activityTitle = "Activity"
        self.homeViewController.title = activityTitle

        let starImage: UIImage = UIImage(named: "star")!.resizedImage(newWidth: 30)
        homeNavController.tabBarItem.image = starImage
        
        let layout = UICollectionViewFlowLayout()
        self.chatFeedViewController = ChatFeedViewController(collectionViewLayout: layout)
        self.chatFeedViewController.tabBarViewController = self
        self.chatFeedViewController.uploadData()       
        
        let chatFeedNavController = UINavigationController(rootViewController: chatFeedViewController)
        let groupImage: UIImage = UIImage(named: "group")!.resizedImage(newWidth: 30)
        self.chatFeedViewController.tabBarItem.image = groupImage
        
        let chatsTitle = "Chats"
        self.chatFeedViewController.title = chatsTitle
        
        let accountNavController = UINavigationController(rootViewController: accountViewController)
        let friendImage: UIImage = UIImage(named: "friend")!.resizedImage(newWidth: 30)
        self.accountViewController.tabBarItem.image = friendImage
        
        let accountTitle = "Account"
        self.accountViewController.title = accountTitle
        
        self.accountViewController.tabBarViewController = self

        if !Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_family_exist") {
            
            viewControllers = [eventNavController, chatFeedNavController, accountNavController]
            
        } else {

            viewControllers = [eventNavController, homeNavController, chatFeedNavController, accountNavController]
        }

        let blurEffect = UIBlurEffect(style: .light)
        blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView?.frame = view.bounds
        self.view.addSubview(blurVisualEffectView!)       
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.loggedOut), name: NSNotification.Name(rawValue: Global.notificationKeyLogOut), object: nil)      
     
        let array = viewControllers as! [UIViewController]
        for controller in array {
            controller.tabBarItem.title = ""
            controller.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        }

        print(UserDefaults.standard.isHasPhoneAndImage())
        print(UserDefaults.standard.isRegistered())
        print(UserDefaults.standard.isHasProfileInfo())
        print(UserDefaults.standard.isLoggedIn())
        print(Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_profile_completed"))
        print(Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_family_exist"))        

    }      
    
    override func viewDidAppear(_ animated: Bool) {
        
        if !isHasProfileInfo() && !isHasRegistered()
        {
            self.selectedIndex = 0

            if let userId = PFUser.current()?.objectId
            {
                self.puserId = userId
            }
            
            /*let pid = "\(self.puserId)_registrant_completed"
            
            print(pid)
            
            if Global.isKeyPresentInUserDefaults(key: pid)
            {
                let registrant_completed = Global.defaults.bool(forKey: "\(self.puserId)_registrant_completed")

                let picker_shown = Global.defaults.bool(forKey: "\(self.puserId)_picker_shown")

                if registrant_completed && !picker_shown
                {                   

                    DispatchQueue.main.async
                    {
                        self.accountViewController.showImagePicker(type: ProfileImagesTypes.Son)

                        Global.defaults.set(true, forKey: "\(self.puserId)_picker_shown")
                    }
                }
            }*/


        } else
        {
            self.selectedIndex = 0            
            
        }

        /*if !isHasRegistered() {
            self.selectedIndex = 2
        } else {
            self.selectedIndex = 0
        }*/

        

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }
       

        if isLoggedIn()
        {
            self.blurVisualEffectView?.removeFromSuperview()
        }
        
        //self.tabBarController!.tabBar.tintColor = UIColor.gamvesColor
        
    }

    func reloadHomeView() {

        self.homeViewController.loadStatistics()
            
        self.homeViewController.renderSon()            

        DispatchQueue.main.async {
            
            self.homeViewController.collectionView.reloadData()
        }
    }

    @objc private func loggedOut() {

        self.showLoginController(registered: true)
    }
    
    private func createDummyNavControllerWithTitle(title: String, imageName: String) -> UINavigationController {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
    
    func showControllerForSetting(_ setting: Setting) {
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func openSearch(params:[String : Any]) {
        let media = MediaController()
        media.delegate = params["targer"] as! MediaDelegate
        media.isImageMultiSelection = params["isImageMultiSelection"] as! Bool
        media.setType(type: params["type"] as! MediaType)
        media.termToSearch = params["termToSearch"] as! String
        media.searchType = params["searchType"] as! SearchType
        media.searchSize = params["searchSize"] as! SearchSize
        navigationController?.pushViewController(media, animated: true)
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
    
    func openChat(room: String, chatId:Int, users:[GamvesUser])
    {
        
        self.chatViewController.chatId = chatId
        self.chatViewController.gamvesUsers = users
        self.chatViewController.room = room
        self.chatViewController.isStandAlone = true
        self.chatViewController.view.backgroundColor = UIColor.white
        
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window!?.rootViewController = self.chatViewController      
        
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

                        Global.locationPF = geoPoint
                        
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


