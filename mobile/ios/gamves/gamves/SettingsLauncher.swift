//
//  SettingsLauncher.swift
//  youtube
//
//  Created by Jose Vigil on 12/12/17.
//

import UIKit
import Parse

class Setting: NSObject {
    let name: SettingName
    let imageName: String
    
    init(name: SettingName, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

enum SettingName: String
{
    //case Notifications    = "Notifications"
    //case WatchLater       = "Watch Later"
    //case Likes            = "Likes"
    //case Help             = "Help"
    
    case Cancel             = "Cancel & Dismiss Completely"
    case History            = "History"
    case ReportBug          = "Report a bug"
    case Settings           = "Settings"
    case SwitchAccount      = "Log out"
    case Likes              = "Likes"
    case BugList            = "Bug list"
}

class SettingsLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let blackView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    
    let settings: [Setting] =
    {
        
        //let likesSetting = Setting(name: .Likes, imageName: "like_gray")
        //let historySetting = Setting(name: .History, imageName: "history")
        let reportBugSetting = Setting(name: .ReportBug, imageName: "report_bug")
        //let settingsSetting = Setting(name: .Settings, imageName: "settings")
        let bugListSetting = Setting(name: .BugList, imageName: "list")
        let logoutSetting = Setting(name: .SwitchAccount, imageName: "switch_account")
        let cancelSetting = Setting(name: .Cancel, imageName: "cancel")

        
        return [ 
                 //likesSetting,
                 //historySetting,
                 reportBugSetting,
                 //settingsSetting,
                 bugListSetting,
                 logoutSetting,
                 cancelSetting ]

    }()
    
    var homeController: HomeController?
    
    func showSettings() {
        //show menu
        
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            
            window.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(settings.count) * cellHeight
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(_ setting: Setting) {

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
            
        }) { (completed: Bool) in
            
            if setting.name != .Cancel {

                if setting.imageName == "report_bug" { 

                    let title = "Report a bug!"
                    let message = "A screenchot will capture the bug below, press OK and wait please."
                    
                    let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in

                        let screenShoot = Global.captureScreenshot()

                        self.homeController?.showBugViewControllerForSetting(setting,image: screenShoot, bug: nil)
                        
                    }))
                    
                    self.appDelegate.window?.rootViewController?.present(alert, animated: true)

                    
                } else if setting.imageName == "list" {

                    self.homeController?.showBugList() 
                
                } else {

                    self.homeController?.showControllerForSetting(setting)
                
                }

                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SettingCell
        
        let setting = settings[indexPath.item]
        cell.setting = setting
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let setting = self.settings[indexPath.item]
        
        if setting.imageName == "switch_account" {


            let title = "Log Out"
            let message = "Are you sure you want to log out?"
            
            var alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes log me out", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                
                PFUser.logOutInBackground { (error) in
                
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyLogOut), object: self)
                    
                }
                
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alertAction: UIAlertAction!) in
                
                   alert.dismiss(animated: true, completion: nil)
        
                
            }))
            
            // show the alert            
            self.appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)

       } 

       /*else if setting.imageName == "list" {


            self.homeController?.showBugList()

       }*/
        
        handleDismiss(setting)                
        
        
    }
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellId)
    }
    
}







