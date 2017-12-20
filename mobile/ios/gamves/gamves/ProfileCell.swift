

//
//  ProfileCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/10/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class ProfileCell: BaseCell, UIScrollViewDelegate,
 UICollectionViewDataSource,
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout {
    
    var metricsHome = [String:Int]()

    var userStatistics = [UserStatistics]()
    
    let registerViewContent: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    let dataView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white
        return v
    }()
    
    // SON VIEW
    
    let registerRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.blue
        return view
    }()
    
    let leftregisterRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var sonProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let rightregisterRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let sonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.backgroundColor = UIColor.white
        return label
    }()   

    lazy var familyPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "family_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 3           
        return imageView
    }()


    //--
    // FAMILY VIEW

    let familyRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.blue
        return view
    }()

    var familyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        //label.backgroundColor = UIColor.white        
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.gray
        return label
    }()

    let photosContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    let homeBackgroundView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var registerPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "register_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleregisterPhotoImageView)))
        imageView.isUserInteractionEnabled = true        
        imageView.tag = 1
        return imageView
    }()   

    var checkLabelRegister: UILabel = {
        let label = UILabel()
        return label
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

    var checkLabelSpouse: UILabel = {
        let label = UILabel()
        return label
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

    var checkLabelGroup: UILabel = {
        let label = UILabel()
        return label
    }()  
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    let footerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.red
        return v
    }()

    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var cellId = String()
    
    var registerOnline = Bool()

    var youRegisterChatId = Int()
    var youSpouseChatId = Int()
    var groupChatId = Int()
   
    
    override func setupViews() {
        super.setupViews()
        
        let width = self.frame.width
        let paddingRegister = (width - 80)/2
        let metricsRegisterView = ["paddingRegister": paddingRegister]
        
        print(metricsRegisterView)

        self.addSubview(self.registerViewContent)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.registerViewContent)
        
        self.addSubview(self.lineView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
 
        self.addSubview(self.dataView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.dataView)
        
        self.addConstraintsWithFormat("V:|[v0(250)][v1(2)][v2]|", views: 
            self.registerViewContent, 
            self.lineView, 
            self.dataView, 
            metrics: metricsRegisterView)
        
        // SON VIEW

        //registerViewContent.backgroundColor = UIColor.red       
        
        self.registerViewContent.addSubview(self.registerRowView)
        self.registerViewContent.addConstraintsWithFormat("H:|[v0]|", views: self.registerRowView)
        self.registerViewContent.addConstraintsWithFormat("V:|-10-[v0(paddingRegister)]|", views: self.registerRowView,
            metrics: metricsRegisterView)

        //registerViewContent.backgroundColor = UIColor.blue 
        
        self.registerRowView.addSubview(self.leftregisterRowView)
        self.registerRowView.addSubview(self.sonProfileImageView)
        self.registerRowView.addSubview(self.rightregisterRowView)
        
        self.registerRowView.addConstraintsWithFormat("V:|[v0]|", views: self.leftregisterRowView)
        self.registerRowView.addConstraintsWithFormat("V:|[v0]|", views: self.sonProfileImageView)
        self.registerRowView.addConstraintsWithFormat("V:|[v0]|", views: self.rightregisterRowView)    
        
        
        self.registerRowView.addConstraintsWithFormat("H:|[v0(paddingRegister)][v1(80)][v2(paddingRegister)]|", views: 
            self.leftregisterRowView, 
            self.sonProfileImageView, 
            self.rightregisterRowView, 
            metrics: metricsRegisterView)
       
        let userId = PFUser.current()?.objectId
        print(userId)
        
        if let sonImage:UIImage = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.avatar {
            self.sonProfileImageView.image = sonImage
            Global.setRoundedImage(image: sonProfileImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.white)
        }
        
        var metricsVerBudge = [String:Int]()

        let topPadding = 40
        let midPadding =  topPadding / 2
        let smallPadding =  midPadding / 2
        let photoSize:Int = (Int(width) / 4)
        let padding = photoSize / 4      

        self.metricsHome["topPadding"]      = topPadding
        self.metricsHome["midPadding"]      = midPadding
        self.metricsHome["smallPadding"]    = smallPadding
        self.metricsHome["photoSize"]       = photoSize
        self.metricsHome["padding"]         = padding

        metricsVerBudge["verPadding"] = photoSize - 25   

        self.registerViewContent.addSubview(self.sonLabel)
        self.registerViewContent.addConstraintsWithFormat("H:|[v0]|", views: self.sonLabel)


        self.registerViewContent.addSubview(self.photosContainerView)
        self.registerViewContent.addConstraintsWithFormat("H:|[v0]|", views: self.photosContainerView)
        
        self.registerViewContent.addConstraintsWithFormat("V:|-10-[v0(80)][v1(30)][v2(photoSize)]-30-|", 
            views: 
            self.registerRowView, 
            self.sonLabel, 
            self.photosContainerView, 
            metrics:self.metricsHome)
        
        
        let name = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.name
        self.sonLabel.text = "Clemente"
        self.sonLabel.textAlignment = NSTextAlignment.center

        // FAMILY       

        self.checkLabelRegister =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        self.checkLabelSpouse =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        self.checkLabelGroup =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)        
  

        self.photosContainerView.addSubview(self.registerPhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelRegister)

        self.photosContainerView.addSubview(self.spousePhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelSpouse)

        self.photosContainerView.addSubview(self.groupPhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelGroup)
        
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.registerPhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.spousePhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.groupPhotoImageView)
        
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelRegister, metrics: metricsVerBudge)    
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelSpouse, metrics: metricsVerBudge)
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelGroup, metrics: metricsVerBudge)
        
        self.photosContainerView.addConstraintsWithFormat(
            "H:|-padding-[v0(photoSize)]-padding-[v1(photoSize)]-padding-[v2(photoSize)]-padding-|", views:
            self.registerPhotoImageView,
            self.spousePhotoImageView,
            self.groupPhotoImageView,
            metrics: metricsHome)   


        var metricsHorBudge = [String:Int]()

        let paddingBudge = (padding + photoSize) - 25

        metricsHorBudge["registerPadding"]      = paddingBudge 
        metricsHorBudge["spousePadding"]   = (paddingBudge * 2) + 25
        metricsHorBudge["groupPadding"]    = (paddingBudge * 3) + 50

        self.photosContainerView.addConstraintsWithFormat("H:|-registerPadding-[v0(25)]", views: self.checkLabelRegister, metrics: metricsHorBudge)
        self.photosContainerView.addConstraintsWithFormat("H:|-spousePadding-[v0(25)]", views: self.checkLabelSpouse, metrics: metricsHorBudge)
        self.photosContainerView.addConstraintsWithFormat("H:|-groupPadding-[v0(25)]", views: self.checkLabelGroup, metrics: metricsHorBudge)
                
        //NotificationCenter.default.addObserver(self, selector: #selector(familyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(chatFeedLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyChatFeed), object: nil)
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)

        
        self.dataView.addSubview(self.collectionView)
        self.dataView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.collectionView)
        self.dataView.addConstraintsWithFormat("V:|-20-[v0]-20-|", views: self.collectionView)

        self.dataView.backgroundColor = UIColor.gamvesBackgoundColor

        // DATA VIEW
               
       /*self.dataView.addSubview(self.familyLabel)        
        self.dataView.addSubview(self.sonLabel)
        self.dataView.addSubview(self.collectionView)
        self.dataView.addSubview(self.footerView)
        
        self.dataView.addConstraintsWithFormat("H:|[v0]|", views: self.familyLabel)        
        self.dataView.addConstraintsWithFormat("H:|[v0]|", views: self.sonLabel)
        self.dataView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.collectionView)
        self.dataView.addConstraintsWithFormat("H:|[v0]|", views: self.footerView)
        
        
        
        self.dataView.addConstraintsWithFormat(
            "V:|-midPadding-[v0(midPadding)]-midPadding-[v1(photoSize)]-midPadding-[v2(midPadding)][v3(300)][v4(30)]|", views:
            self.familyLabel,
            //self.photosContainerView,
            self.sonLabel,
            self.collectionView,
            self.footerView,
            metrics: metricsHome)

        self.checkLabelRegister =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        self.checkLabelSpouse =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        self.checkLabelGroup =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)        */

                
         
        self.cellId = "homeCellId"        
        self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor
        self.collectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
        
        //self.activityIndicatorView?.startAnimating()
        
        self.checkLabelRegister.isHidden = true
        self.checkLabelSpouse.isHidden = true
        self.checkLabelGroup.isHidden = true
        

        let _notifications = UserStatistics()
        _notifications.desc = "Notifications"
        _notifications.icon = UIImage(named: "notifications")!
        self.userStatistics.append(_notifications)

        let _history = UserStatistics()
        _history.desc = "History"
        _history.data = "12 videos"
        _history.icon = UIImage(named: "history")!
        self.userStatistics.append(_history)

        let _watchLater = UserStatistics()
        _watchLater.desc = "Watch later"
        _watchLater.data = "2 videos"
        _watchLater.icon = UIImage(named: "watch_later")!
        self.userStatistics.append(_watchLater)

        let _likedVideos = UserStatistics()
        _likedVideos.desc = "Videos liked"
        _likedVideos.data = "12 videos"
        _likedVideos.icon = UIImage(named: "like_gray")!
        self.userStatistics.append(_likedVideos)    

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if Global.familyLoaded {
            self.familyLoaded()
        }
        
        if Global.chatFeedLoaded {
            self.chatFeedLoaded()
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }

    func chatFeedLoaded() {
        
        let sonRegisterChatId:Int = Global.gamvesFamily.sonRegisterChatId
        if ChatFeedMethods.chatFeeds[sonRegisterChatId]! != nil
        {
            let registerBadge = ChatFeedMethods.chatFeeds[sonRegisterChatId]?.badgeNumber
            
            if registerBadge! > 0
            {
                self.checkLabelRegister.isHidden = false
                
                let sob = "\(registerBadge!)"
                
                self.checkLabelRegister.text = sob
            }
            
        }
        
        let spouseRegisterChatId:Int = Global.gamvesFamily.sonSpouseChatId
        if ChatFeedMethods.chatFeeds[spouseRegisterChatId]! != nil
        {
            let spouseBadge = ChatFeedMethods.chatFeeds[spouseRegisterChatId]?.badgeNumber
            
            if spouseBadge! > 0
            {
                self.checkLabelSpouse.isHidden = false
                
                let spb = "\(spouseBadge!)"
               
                self.checkLabelSpouse.text = spb
            }
        }
        
        let groupChatId:Int = Global.gamvesFamily.familyChatId
        if ChatFeedMethods.chatFeeds[groupChatId]! != nil
        {
            let groupBadge = ChatFeedMethods.chatFeeds[groupChatId]?.badgeNumber       
            
            if groupBadge! > 0
            {
                self.checkLabelGroup.isHidden = false
                
                let grb = "\(groupBadge!)"
                
                self.checkLabelGroup.text = grb
            }
            
        }
        
        self.familyLoaded()
    }
    
    func familyLoaded()
    {
        self.familyLabel.text = "Clemente"// Global.gamvesFamily.familyName

        let registerId = Global.gamvesFamily.registerUser.userId
        if Global.userDictionary[registerId] != nil
        {
            self.sonLabel.text = Global.userDictionary[registerId]?.firstName
            self.registerPhotoImageView.image = Global.userDictionary[registerId]?.avatar
            Global.setRoundedImage(image: self.registerPhotoImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.gamvesColor)
        }
        
        let spouseId = Global.gamvesFamily.spouseUser.userId
        if Global.userDictionary[spouseId] != nil
        {
            self.spousePhotoImageView.image = Global.userDictionary[spouseId]?.avatar
            Global.setRoundedImage(image: self.spousePhotoImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.gamvesColor)
        }
        
        
        self.groupPhotoImageView.image = Global.gamvesFamily.familyImage
        Global.setRoundedImage(image: self.groupPhotoImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.gamvesColor)
        
        self.activityIndicatorView?.stopAnimating()
        
        //self.initializeOnlineSubcritpion()
        
    }

    
    func generateGroupImage() -> UIImage
    {
        let LeftImage = self.registerPhotoImageView.image // 355 X 200
        let RightImage = self.spousePhotoImageView.image  // 355 X 60
        
        let size = CGSize(width: LeftImage!.size.width, height: LeftImage!.size.height)
        
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        LeftImage?.draw(in: CGRect(x: 0, y: 0, width:size.width, height: size.height))
        RightImage?.draw(in: CGRect(x: size.width/2, y: 0, width:size.width, height: size.height))
        
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }

    func handleregisterPhotoImageView(sender: UITapGestureRecognizer)
    {
        
        var sonRegisterChatId:Int = Global.gamvesFamily.sonRegisterChatId
    
        if ChatFeedMethods.chatFeeds[sonRegisterChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[sonRegisterChatId]!
            
            var users = [GamvesParseUser]()
            users.append(Global.gamvesFamily.registerUser)
            users.append(Global.gamvesFamily.youUser)

            self.chatViewController.chatId = sonRegisterChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            self.chatViewController.view.backgroundColor = UIColor.white
           
            //navigationController?.pushViewController(self.chatViewController, animated: true)
    
        }
        
    }

    func handleSpousePhotoImageView(sender: UITapGestureRecognizer)
    {
        
        var sonSpouseChatId:Int = Global.gamvesFamily.sonSpouseChatId
        
        if ChatFeedMethods.chatFeeds[sonSpouseChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[sonSpouseChatId]!
            
            var users = [GamvesParseUser]()
            users.append(Global.gamvesFamily.spouseUser)
            users.append(Global.gamvesFamily.youUser)
            
            self.chatViewController.chatId = sonSpouseChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            //self.chatViewController.isStandAlone = true
            self.chatViewController.view.backgroundColor = UIColor.white
            
            //navigationController?.pushViewController(self.chatViewController, animated: true)
            
        }
        
    }

    func handleGroupPhotoImageView(sender: UITapGestureRecognizer)
    {
        var familyChatId:Int = Global.gamvesFamily.familyChatId
        
        if ChatFeedMethods.chatFeeds[familyChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[familyChatId]!
            
            var users = [GamvesParseUser]()
            users.append(Global.gamvesFamily.registerUser)
            users.append(Global.gamvesFamily.spouseUser)
            users.append(Global.gamvesFamily.youUser)
            
            self.chatViewController.chatId = familyChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            //self.chatViewController.isStandAlone = true
            self.chatViewController.view.backgroundColor = UIColor.white
            
            //navigationController?.pushViewController(self.chatViewController, animated: true)
            
        }

    }

   
    ////collectionView


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userStatistics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileCollectionViewCell
        
        let id = indexPath.row
        
        var stats = self.userStatistics[id]
        
        
        cell.descLabel.text = stats.desc
        cell.dataLabel.text = stats.data        
   
        cell.iconImageView.image = stats.icon
        
        if id > 0
        {
            cell.iconImageView.alpha = 0.4
        }
        
        return cell
    }    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let userStatistic = userStatistics[indexPath.row]


        /*if let description = userStatistic.description {
            
            let size = CGSize(width:250, height:1000)
            
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width:self.frame.width, height:estimatedFrame.height + 20)
        }*/
        
        return CGSize(width:self.collectionView.frame.width, height:50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
    
    
    func changeSingleUserStatus(onlineMessage:PFObject)
    {
        let isOnline = onlineMessage["isOnline"] as! Bool
        
        if isOnline
        {
            self.registerOnline = true
        } else
        {
            self.registerOnline = false
        }
        
        self.collectionView.reloadData()
        
    }
    
}








