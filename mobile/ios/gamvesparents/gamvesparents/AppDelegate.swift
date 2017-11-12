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

    let defaults = UserDefaults.standard
    
    var gamvesParentsApplication:UIApplication?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
        
        if #available(iOS 10.0, *)
        {
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil {
                    application.registerForRemoteNotifications()
                }
            }
        } else {
            if #available(iOS 7, *) {
                application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
            } else {
                let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
                let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
                
                UIApplication.shared.registerUserNotificationSettings(notificationSettings)
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        if PFUser.current() != nil
        {
            self.getFamilyData()
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

            let installed = defaults.bool(forKey: "installed")
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

                let installed_user = defaults.bool(forKey: "installed_user")
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


   func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
       
        // Store the deviceToken in the current installation and save it to Parse. 
    
        let currentInstallation: PFInstallation = PFInstallation.current()!
    
        currentInstallation.setDeviceTokenFrom(deviceToken as Data)
    
        currentInstallation.saveInBackground()
        // We want to register the installation in the back4app channel.
    
        //currentInstallation.addUniqueObject("back4app", forKey: "channels")
    
        //PFPush.subscribeToChannel(inBackground: "globalChannel")

        let currentChannels = currentInstallation.channels
        print(currentChannels)        
           
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PFPush.handle(userInfo)
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
    
    
    
    func getFamilyData()
    {
        
        DispatchQueue.global().async {
            
            let familyQuery = PFQuery(className:"Family")
            familyQuery.whereKey("members", equalTo: PFUser.current())
            familyQuery.cachePolicy = .cacheElseNetwork
            familyQuery.findObjectsInBackground(block: { (families, error) in
                
                if error == nil
                {
                    
                    for family in families!
                    {
                        
                        Global.gamvesFamily.familyName = family["description"] as! String
                        
                        let membersRelation = family.relation(forKey: "members") as PFRelation
                        
                        let queryMembers = membersRelation.query()
                        
                        queryMembers.findObjectsInBackground(block: { (members, error) in
                            
                            if error == nil
                            {

                                var memberCount = members?.count
                                var count = 0

                                for member in members!
                                {
                                    Global.addUserToDictionary(user: member as! PFUser, isFamily: true, completionHandler: { ( gamvesUser ) -> () in
                                        
                                        print(gamvesUser.userName)
                                        
                                        Global.userDictionary[gamvesUser.userId] = gamvesUser

                                        if count == (memberCount!-1)
                                        {
                                            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: self)
                                        }
                                        count = count + 1
                                    })
                                }
                            }
                        })
                        
                        let schoolRelation = family.relation(forKey: "school") as PFRelation
                        
                        let querySchool = schoolRelation.query()
                        
                        querySchool.findObjectsInBackground(block: { (schools, error) in
                            
                            if error == nil
                            {
                                for school in schools!
                                {
                                    Global.gamvesFamily.school = school["name"] as! String
                                }
                            }
                        })
                    }
                }
            })
        }
    }
   

}

