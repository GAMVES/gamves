//
//  ChatViewController.swift
//  gamves
//
//  Created by Jose Vigil on 10/13/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ChatViewController: UIViewController, NavBarDelegate, KeyboardDelegate {
    
    //var delegateFeed:FeedDelegate!
    
    var chatView:ChatView!
    var chatId = Int()
    
    let avatar:UIImageView! = nil
    
    var gamvesUsers = [GamvesParseUser]()
    
    var params = [String: Any]()

    var loaded = Bool()
    
    var buttonAvatar: UIButton!
    
    var room = String()
    
    var isStandAlone = Bool()
    
    var navHeight = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageUser:UIImage!
        
        self.title = "Home"
        
        if gamvesUsers.count>2
        {
            imageUser = UIImage(named: "community")
        } else
        {
            imageUser = gamvesUsers[0].avatar
        }
    
        self.setNavBar(image: imageUser)
        
        print(gamvesUsers[0].name)           
        
        tabBarController?.tabBar.isHidden = true
        
        
    }
    
    @objc func backButtonPressed(sender: UIBarButtonItem)
    {
        //self.delegateFeed.uploadData()
        //self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

         tabBarController?.tabBar.isHidden = true
        
        if loaded
        {
            self.loadChatView()
            
            let imageUser:UIImage!

            if gamvesUsers.count>2
            {
                imageUser = UIImage(named: "community")
            } else
            {
                imageUser = gamvesUsers[0].avatar
            }
            
            if self.buttonAvatar == nil
            {
                print("not nil")
            }
            
            self.setNavBar(image: imageUser)
            
            if imageUser != nil
            {            
                self.buttonAvatar.setImage(imageUser, for: UIControlState.normal)
            }
            
        }      
        
    
    }
    
    override func viewDidLayoutSubviews()
    {
        if !loaded
        {
            self.loadChatView()
            loaded = true
            
            if isStandAlone
            {
                
                let imageUser:UIImage = gamvesUsers[0].avatar
                self.setNavBar(image: imageUser)
                
            }

        }
        
        
    }
    
    func setNavBar(image:UIImage)
    {
        //let height: CGFloat = 80
        //let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        
        let navItem = UINavigationItem()
        navItem.title = "Title"
        
        let buttonArrowBack: UIButton = UIButton (type: UIButtonType.custom)
        buttonArrowBack.setImage(UIImage(named: "arrow_back_white"), for: UIControlState.normal)
        buttonArrowBack.frame = CGRect(x:0, y:0, width:30, height:30)
        buttonArrowBack.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
        buttonAvatar = UIButton (type: UIButtonType.custom)
        
        buttonAvatar.setImage(image, for: UIControlState.normal)
        buttonAvatar.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
        buttonAvatar.frame = CGRect(x:0, y:0, width:40, height:40)
        buttonAvatar.layer.cornerRadius = 20
        buttonAvatar.clipsToBounds = true
        
        if #available(iOS 9.0, *) {
            buttonAvatar.widthAnchor.constraint(equalToConstant: 40).isActive = true
            buttonAvatar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        let avatarButton = UIBarButtonItem(customView: buttonAvatar)
        let arrowButton = UIBarButtonItem(customView: buttonArrowBack)
        
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -20
        
        navigationItem.leftBarButtonItems = [negativeSpacer, arrowButton, avatarButton]
        
       
    }
    
    func loadChatView()
    {
        var subtitle = "                "
        
        var userArray =  [String]()
        
        if self.gamvesUsers.count > 1
        {
            let subTitle = String()
            for guser in self.gamvesUsers
            {
                //subtitle = "\(subtitle) \(guser.name),"
                userArray.append(guser.firstName)
            }
            
            subtitle = userArray.description
            subtitle = subtitle.replacingOccurrences(of: "[", with: "")
            subtitle = subtitle.replacingOccurrences(of: "]", with: "")
            subtitle = subtitle.replacingOccurrences(of: "\"", with: "")
        }
        
        self.navigationItem.titleView = Global.setTitle(title: self.room, subtitle: subtitle)                

        let bounds = self.navigationController!.navigationBar.bounds

        navHeight = bounds.height
        
        print(navHeight)
        
        let chatHeight = self.view.frame.height-navHeight
        
        let chatFrame = CGRect(x: 0, y: navHeight, width: self.view.frame.width, height: chatHeight)
        
        chatView = ChatView(frame: chatFrame, isVideo: false)
        
        params = ["chatId": chatId, "isVideoChat": false, "gamvesUsers": gamvesUsers, "navBarProtocol": self, "delegate": self] as [String : Any]
        
        chatView.setParams(parameters: params)
        
        chatView.loadChatFeed()
        
        self.view.addSubview(chatView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func updateTitle(latelText:String)
    {
        
    }
    
    func updateSubTitle(latelText:String)
    {
        print(latelText)
        let subTitleLabel = self.navigationItem.titleView?.subviews[1] as! UILabel
        subTitleLabel.text = latelText
    
    }
    
    func keyboardOpened(keybordHeight keybordEditHeight: CGFloat)
    {
        let chatHeight = self.view.frame.height - keybordEditHeight - navHeight
        self.chatView.frame.size.height = chatHeight
    }
    
    func keyboardclosed()
    {
        self.chatView.frame.size.height = self.view.frame.height - navHeight
    }
    

}



