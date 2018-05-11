//
//  AppDelegate.swift
//  audible
//
//  Created by Jose Vigil 08/12/2017.
//

import UIKit
import Parse
import Bolts
import UserNotifications
import DeviceKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var gamvesApplication:UIApplication?
    
    var connect = Bool()

    var puserId = String()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {       
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        UINavigationBar.appearance().barTintColor = UIColor.gamvesColor
        
        //application.statusBarStyle = .lightContent
      
        var reached = false

        let deviceobj = Device()
        let device:String = "\(deviceobj)"
        Global.device = device
        
        //connect = true
        //if connect {
            
        if Reachability.isConnectedToNetwork() == true {
    
            loadParse(application: application, launchOptions: launchOptions)
            print("Internet connection OK")
            
            reached = true
            
        } else {
            
            window?.rootViewController = UINavigationController(rootViewController: NoConnectionController())
            
            let title = "Internet Connection"
            let message = "Your device is not connected to the Internet, please check your connection. The app is closing.. bye!"
            
            let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                
                exit(0)
                
            }))
            
            // show the alert
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        window?.rootViewController = TabBarViewController()
        
        Global.loaLevels(completionHandler: { ( result:Bool ) -> () in
        
            if PFUser.current() != nil
            {
                
                Global.getFamilyData(completionHandler: { ( result:Bool ) -> () in
                
                    ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in })
                
                })

                self.loadChatChannels()
            
            }
            
        })

        
        if PFUser.current() != nil
        {
            if let userId = PFUser.current()?.objectId
            {
                self.puserId = userId
            }
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
        
        Global.loadUserTypes()

        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let fileName = "\(Date()).log"
        let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
        freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stderr)  

        Global.loadAditionalData()     
        
        return true
    }

    
    func loadParse(application: UIApplication, launchOptions: [AnyHashable: Any]?)
    {
        //Local
        /*let configuration = ParseClientConfiguration {
            $0.applicationId = "0123456789"
            $0.server = Global.serverUrl
        }
        Parse.initialize(with: configuration)*/
        
        //Back4app
        let configuration = ParseClientConfiguration {
            $0.applicationId = "fyJV5DhvVXJz2Vlk53K3eeqNKzwdBQhftfBwCyQ7"
            $0.clientKey = "IPoWpsp5ub2qqCmAGgZmjlBuvzQKEaHoeBm8SFuX"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        
        //Sashido
        /*let configuration = ParseClientConfiguration {
         $0.applicationId = "lTEkncCXc0jS7cyEAZwAr2IYdABenRsY86KPhzJT"
         $0.clientKey = "sMlMuxDQTs631WYXfS5rdnUQzeeRPB6JFNnKsVhY"
         $0.server = Global.serverUrl
         }
         Parse.initialize(with: configuration)*/

        
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

                let installed_user = Global.defaults.bool(forKey: "\(self.puserId)_last_message")
                if !installed_user
                {
                    
                    if PFUser.current() != nil
                    {        
                        currentInstall["user"] = PFUser.current()
                        currentInstall.saveEventually({ (success, error) in                    
                            if success
                            {
                                UserDefaults.standard.set(true, forKey: "\(self.puserId)_last_message")
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
    
    //func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("")
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

    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {  
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
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
    
    func openSearch(params:[String : Any]) {
        //self.homeController.openSearch(params:params)
    }

}

