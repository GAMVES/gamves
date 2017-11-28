//
//  AppDelegate.swift
//  audible
//
//  Created by Brian Voong on 9/1/16.
//  Copyright © 2016 Lets Build That App. All rights reserved.
//

import UIKit
import Parse
import Bolts
import UserNotifications
import DeviceKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var gamvesParentsApplication:UIApplication?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        UINavigationBar.appearance().barTintColor = UIColor.gamvesColor
        
        //application.statusBarStyle = .lightContent
      
        var reached = false
        
        if Reachability.isConnectedToNetwork() == true
        {
            loadParse(application: application, launchOptions: launchOptions)
            print("Internet connection OK")
            
            reached = true
            
        } else {
            print("Internet connection FAILED")
            exit(0)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        window?.rootViewController = TabBarViewController()
        
        
        if PFUser.current() != nil
        {
            Global.getFamilyData()
            
            ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in })

            self.loadChatChannels()
        }
        
        if #available(iOS 10.0, *)
        {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                
                if error == nil
                {
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
        
        return true
    }

    
    func loadParse(application: UIApplication, launchOptions: [AnyHashable: Any]?)
    {
        //Back4app
        /*let configuration = ParseClientConfiguration {
            $0.applicationId = "qmTbd36dChKyopgav1JVUMGx2vnZSVdclkNpK6YU"
            $0.clientKey = "r1FBMzUkEemRnGllhvZdkFtKknu1CMUXUUwzP6ew"
            $0.server = "https://parseapi.back4app.com"
        }*/
        
        //Sashido
        let configuration = ParseClientConfiguration {
         $0.applicationId = "lTEkncCXc0jS7cyEAZwAr2IYdABenRsY86KPhzJT"
         $0.clientKey = "sMlMuxDQTs631WYXfS5rdnUQzeeRPB6JFNnKsVhY"
         $0.server = "https://pg-app-z97yidopqq2qcec1uhl3fy92cj6zvb.scalabl.cloud/1/"
         }
        Parse.initialize(with: configuration)
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        //Installation fr User and notification. 
        DispatchQueue.main.async()
        {
            self.userInstallation()
        }
 
    }

    func userInstallation()
    {
  
        //if (PFUser.current() != nil)
        //{
  
            let currentInstall:PFInstallation = PFInstallation.current()!

            let installed = Global.defaults.bool(forKey: "installed")
            if !installed
            {               
                
                let deviceobj = Device()
                let device:String = "\(deviceobj)"
                currentInstall["device"] = device                
                currentInstall.saveEventually({ (success, error) in                    
                    if success
                    {
                        UserDefaults.standard.set(true, forKey: "installed")
                        UserDefaults.standard.synchronize()
                    }
                })                
                
            } else 
            {

                let installed_user = Global.defaults.bool(forKey: "installed_user")
                if !installed_user
                {
                    
                    if PFUser.current() != nil
                    {        
                        currentInstall["user"] = PFUser.current()
                        currentInstall.saveEventually({ (success, error) in                    
                            if success
                            {
                                UserDefaults.standard.set(true, forKey: "installed_user")
                                UserDefaults.standard.synchronize()
                            }
                        })  
                    }
                }

            }
        //}    
    }


    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken as Data)
        
        let deviceobj = Device()
        let device:String = "\(deviceobj)"
        installation?["device"] = device
        
        installation?.saveInBackground(block: { (resutl, error) in
            
            print(resutl)
            print(error)
            
        })
        
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //PFPush.handle(userInfo)
        
    }

    func registerApplicationForPushNotifications(application: UIApplication) {
        // Set up push notifications
        // For more information about Push, check out:
        // https://developer.layer.com/docs/guides/ios#push-notification
     
        // Register device for iOS8
        //let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        
        let types:UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.sound]
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
        
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.letsbuildthatapp.fbMessenger" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    
  
    func loadChatChannels()
    {
        
        var queryChatFeed = PFQuery(className: "ChatFeed")
        
        queryChatFeed = PFQuery(className: "ChatFeed")
        
        if let userId = PFUser.current()?.objectId
        {
            queryChatFeed.whereKey("members", contains: userId)
        }
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
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
        })
    }




    
    

}

