//
//  AppDelegate.swift
//  youtube
//
//  Created by Brian Voong on 6/1/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import UserNotifications
import DeviceKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var delegateFeed:FeedDelegate!
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    var inBackground = Bool()
    
    var gamvesApplication:UIApplication?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Global.forceFromNetworkCache = true
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        var reached = false
        
        if Reachability.isConnectedToNetwork() == true
        {
            loadParse(application: application, launchOptions: launchOptions)
            print("Internet connection OK")
            
            reached = true
            
        } else {
            print("Internet connection FAILED")
        }
        
         UINavigationBar.appearance().barTintColor = UIColor.gamvesColor
        
         application.statusBarStyle = .lightContent
        
        // get rid of black bar underneath navbar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        if let user = PFUser.current()
        {
            window?.rootViewController = UINavigationController(rootViewController: HomeController(collectionViewLayout: layout))
        } else
        {
            window?.rootViewController = UINavigationController(rootViewController: LoginController())
        }
        
        print(PFUser.current()?.username)
        
        let statusBarBackgroundView = UIView()
        statusBarBackgroundView.backgroundColor = UIColor.gamvesBlackColor
        
        window?.addSubview(statusBarBackgroundView)
        window?.addConstraintsWithFormat("H:|[v0]|", views: statusBarBackgroundView)
        window?.addConstraintsWithFormat("V:|[v0(20)]", views: statusBarBackgroundView)
        
        
        if #available(iOS 10.0, *)
        {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                
                if error == nil {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
        } else {
            
            if #available(iOS 7, *)
            {
                //application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
                registerApplicationForPushNotifications(application: application)
            } else {
                
                let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
                
                let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
                
                UIApplication.shared.registerUserNotificationSettings(notificationSettings)
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        
        if PFUser.current() != nil {
            
            Global.loaLevels()
            
            Global.getFamilyData(completionHandler: { ( result:Bool ) -> () in
                
                Global.familyLoaded = true
                
                ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in
                
                    Global.chatFeedLoaded = true
                    
                })
                
            })
            
            self.loadChatChannels()

            
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogin), name: NSNotification.Name(rawValue: Global.notificationKeyLoggedin), object: nil)
        
        return true
        
    }
    
    func registerApplicationForPushNotifications(application: UIApplication) {
        // Set up push notifications
        // For more information about Push, check out:
        // https://developer.layer.com/docs/guides/ios#push-notification
        
        // Register device for iOS8
        //let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: UIUserNotificationType.badge, categories: nil)
        
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }

    
    func loadParse(application: UIApplication, launchOptions: [AnyHashable: Any]?)
    {
        Parse.enableLocalDatastore()
        
        //Local
        let configuration = ParseClientConfiguration {
            $0.applicationId = "0123456789"            
            $0.server = "http://192.168.16.22:1337/1/"
        }
        Parse.initialize(with: configuration)

        //Back4app
        /*let configuration = ParseClientConfiguration {
         $0.applicationId = "qmTbd36dChKyopgav1JVUMGx2vnZSVdclkNpK6YU"
         $0.clientKey = "r1FBMzUkEemRnGllhvZdkFtKknu1CMUXUUwzP6ew"
         $0.server = "https://parseapi.back4app.com"
         }*/
        
        //Sashido
        /*let configuration = ParseClientConfiguration {
            $0.applicationId = "lTEkncCXc0jS7cyEAZwAr2IYdABenRsY86KPhzJT"
            $0.clientKey = "sMlMuxDQTs631WYXfS5rdnUQzeeRPB6JFNnKsVhY"
            $0.server = "https://pg-app-z97yidopqq2qcec1uhl3fy92cj6zvb.scalabl.cloud/1/"
        }
        Parse.initialize(with: configuration)*/
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        

        //Notifications
        /*let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()*/
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    @objc(application:didRegisterForRemoteNotificationsWithDeviceToken:) func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        
        let deviceobj = Device()
        let device:String = "\(deviceobj)"
        installation?["device"] = device
        
        installation?.saveInBackground()
    
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        
        if let data = userInfo["data"] as? [String:Any] {
            let message = data["message"]
            print(message)
            let chatId = data["chatId"]
            print(chatId)
        }
        
        if let title = userInfo["title"] as? [String:Any]
        {
            print(title)
        }
        
        self.gamvesApplication = application
        
        Global.loadBargesNumberForUser(completionHandler: { ( badgeNumber ) -> () in
            
            print(badgeNumber)
            self.gamvesApplication?.applicationIconBadgeNumber = badgeNumber
            
        })

        ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in })
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        self.inBackground = true
        
        Global.updateUserOnline(online: false)
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.inBackground = true
        
        
    }
  
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        self.inBackground = true
        
        Global.updateUserOnline(online: false)
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.inBackground = false
        
        self.gamvesApplication = application
        
        Global.loadBargesNumberForUser(completionHandler: { ( badgeNumber ) -> () in

            print(badgeNumber)
            self.gamvesApplication?.applicationIconBadgeNumber = badgeNumber
        
        })
        
        Global.updateUserOnline(online: true)
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        self.inBackground = true
        
        Global.updateUserOnline(online: false)

    }
    
        
    
    
    func handleLogin()
    {
        self.loadChatChannels()
    }
    
    func loadChatChannels()
    {
        
        var queryChatFeed = PFQuery(className: "ChatFeed")
        
        queryChatFeed = PFQuery(className: "ChatFeed")
        
        if let userId = PFUser.current()?.objectId
        {
            queryChatFeed.whereKey("members", contains: userId)
        }
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
            if chatfeeds != nil {
            
                let chatFeddsCount = chatfeeds?.count
                
                print(chatFeddsCount)
                
                if chatFeddsCount! > 0
                {
                    let chatfeedsCount =  chatfeeds?.count
                    
                    print(chatfeedsCount)
                    
                    if chatfeedsCount! > 0
                    {
                        
                        for feed in chatfeeds!
                        {
                            let chatId:Int = feed["chatId"] as! Int
                            
                            let chatIdStr = String(chatId) as String
                            
                            PFPush.subscribeToChannel(inBackground: chatIdStr)
                            
                        }
                        
                    }
                    
                }
            }
        })
    }
    
}

