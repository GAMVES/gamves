//
//  HomeViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 9/26/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import Foundation
import Parse
import NVActivityIndicatorView

class HomeViewController: UIViewController {

	var metricsHome = [String:Int]()
    
    var tabBarViewController:TabBarViewController?    
    
    var youSonChatId = Int64()
    var youSpouseChatId = Int64()
    var groupChatId = Int64()
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()
    
    let photosContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    let homeBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        return view
    }()
	
    lazy var sonPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSonPhotoImageView)))
        imageView.isUserInteractionEnabled = true        
        imageView.tag = 1
        return imageView
    }()   

    lazy var spousePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spouse_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSpousePhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 2           
        return imageView
    }()

    lazy var groupPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "your_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGroupPhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()
    
    let detailsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.lightGray
        return v
    }()


    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    var activityIndicatorView:NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

         tabBarController?.tabBar.isHidden = false

         self.view.backgroundColor = UIColor.blue

        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.photosContainerView)
        self.scrollView.addSubview(self.detailsView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView)
        self.view.addConstraintsWithFormat("V:|[v0]-50-|", views: self.scrollView)
        
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.photosContainerView)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.detailsView)
        
        let width:Int = Int(view.frame.size.width)
        
        let topPadding = 40
        let photoSize = width / 4
        let padding = photoSize / 4
        
        self.metricsHome["topPadding"]  = topPadding
        self.metricsHome["photoSize"]   = photoSize
        self.metricsHome["padding"]     = padding
        
        self.scrollView.addConstraintsWithFormat(
            "V:|-topPadding-[v0(photoSize)]-topPadding-[v1]-20-|", views:
            self.photosContainerView,
            self.detailsView,
            metrics: metricsHome)

        self.photosContainerView.addSubview(self.sonPhotoImageView)
        self.photosContainerView.addSubview(self.spousePhotoImageView)
        self.photosContainerView.addSubview(self.groupPhotoImageView)
        
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.sonPhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.spousePhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.groupPhotoImageView)
        
        self.photosContainerView.addConstraintsWithFormat(
            "H:|-padding-[v0(photoSize)]-padding-[v1(photoSize)]-padding-[v2(photoSize)]-padding-|", views:
            self.sonPhotoImageView,
            self.spousePhotoImageView,
            self.groupPhotoImageView,
            metrics: metricsHome)
        
        NotificationCenter.default.addObserver(self, selector: #selector(familyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(chatFeedLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyChatFeed), object: nil)
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)
        
        self.activityIndicatorView?.startAnimating()        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func chatFeedLoaded()
    {
        print("llega")
    }
    
    func familyLoaded()
    {
        if self.isKeyPresentInUserDefaults(key:"son_object_id")
        {
            let sonId = Global.defaults.object(forKey: "son_object_id") as! String
            if Global.userDictionary[sonId] != nil
            {
                self.sonPhotoImageView.image = Global.userDictionary[sonId]?.avatar
                Global.setRoundedImage(image: self.sonPhotoImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.black)
            }
        }
        
        if self.isKeyPresentInUserDefaults(key:"spouse_object_id")
        {
            
            let spouseId = Global.defaults.object(forKey: "spouse_object_id") as! String
            if Global.userDictionary[spouseId] != nil
            {
                self.spousePhotoImageView.image = Global.userDictionary[spouseId]?.avatar
                Global.setRoundedImage(image: self.spousePhotoImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.black)
            }
        }
        
        self.groupPhotoImageView.image = self.generateGroupImage()
        Global.setRoundedImage(image: self.groupPhotoImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.black)
        
        self.activityIndicatorView?.stopAnimating()
        
    }
    
   
    func isKeyPresentInUserDefaults(key: String) -> Bool
    {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    
    func generateGroupImage() -> UIImage
    {
        let LeftImage = self.sonPhotoImageView.image // 355 X 200
        let RightImage = self.spousePhotoImageView.image  // 355 X 60
        
        let size = CGSize(width: LeftImage!.size.width, height: LeftImage!.size.height)
        
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        LeftImage?.draw(in: CGRect(x: 0, y: 0, width:size.width, height: size.height))
        RightImage?.draw(in: CGRect(x: size.width/2, y: 0, width:size.width, height: size.height))
        
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }

    func handleSonPhotoImageView(sender: UITapGestureRecognizer)
    {
        
        let sonChatId:Int64 = Global.gamvesFamily.sonChatId
    
        if ChatFeedMethods.chatFeeds[sonChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[sonChatId]!
            
            var users = [GamvesParseUser]()
            users.append(Global.gamvesFamily.sonsUsers[0])
            users.append(Global.gamvesFamily.youUser)

            self.chatViewController.chatId = sonChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            //self.chatViewController.isStandAlone = true
            self.chatViewController.view.backgroundColor = UIColor.white
           
            navigationController?.pushViewController(self.chatViewController, animated: true)
    
        }
        
    }

    func handleSpousePhotoImageView(sender: UITapGestureRecognizer)
    {
        
        let spouseChatId:Int64 = Global.gamvesFamily.spouseChatId
        
        if ChatFeedMethods.chatFeeds[spouseChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[spouseChatId]!
            
            var users = [GamvesParseUser]()
            users.append(Global.gamvesFamily.spouseUser)
            users.append(Global.gamvesFamily.youUser)
            
            self.chatViewController.chatId = spouseChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            //self.chatViewController.isStandAlone = true
            self.chatViewController.view.backgroundColor = UIColor.white
            
            navigationController?.pushViewController(self.chatViewController, animated: true)
            
        }
    	
    }

    func handleGroupPhotoImageView(sender: UITapGestureRecognizer)
    {
        let familyChatId:Int64 = Global.gamvesFamily.familyChatId
        
        if ChatFeedMethods.chatFeeds[familyChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[familyChatId]!
            
            var users = [GamvesParseUser]()
            users.append(Global.gamvesFamily.sonsUsers[0])
            users.append(Global.gamvesFamily.spouseUser)
            users.append(Global.gamvesFamily.youUser)
            
            self.chatViewController.chatId = familyChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            //self.chatViewController.isStandAlone = true
            self.chatViewController.view.backgroundColor = UIColor.white
            
            navigationController?.pushViewController(self.chatViewController, animated: true)
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
   
    
    

    
}
