

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
    
    let sonViewContent: UIView = {
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
        v.backgroundColor = UIColor.cyan
        return v
    }()
    
    // SON VIEW
    
    let sonRowImage: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let leftSonRowImage: UIView = {
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

    let rightSonRowImage: UIView = {
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

    ///////////////////////////

    /*lazy var yourPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "your_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()

    lazy var sonPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))
        imageView.isUserInteractionEnabled = true        
        imageView.tag = 1
        return imageView
    }()   

    lazy var spousePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spouse_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 2           
        return imageView
    }()*/

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

/////////////////////////////////////////////////////////////

    
    var youSonChatId = Int()
    var youSpouseChatId = Int()
    var groupChatId = Int()
    
    /*let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.white
        return v
    }()*/
    

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

    var checkLabelSon: UILabel = {
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

    /*var sonLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        //label.backgroundColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()*/
    

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
    
    var sonOnline = Bool()
   
    
    override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.sonViewContent)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.sonViewContent)
        
        self.addSubview(self.lineView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
 
        self.addSubview(self.dataView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.dataView)
        
        self.addConstraintsWithFormat("V:|[v0(150)][v1(2)][v2]|", views: self.sonViewContent, self.lineView, self.dataView)
        
        // SON VIEW
        
        self.sonViewContent.addSubview(self.sonRowImage)
        self.sonViewContent.addConstraintsWithFormat("H:|[v0]|", views: self.sonRowImage)
        
        self.sonRowImage.addSubview(self.leftSonRowImage)
        self.sonRowImage.addSubview(self.sonProfileImageView)
        self.sonRowImage.addSubview(self.rightSonRowImage)
        
        self.sonRowImage.addConstraintsWithFormat("V:|[v0]|", views: self.leftSonRowImage)
        self.sonRowImage.addConstraintsWithFormat("V:|[v0]|", views: self.sonProfileImageView)
        self.sonRowImage.addConstraintsWithFormat("V:|[v0]|", views: self.rightSonRowImage)
        
        let width = self.frame.width
        let paddingSon = (width - 100)/2
        let metricsSonView = ["paddingSon": paddingSon]
        
        print(metricsSonView)
        
        self.sonRowImage.addConstraintsWithFormat("H:|[v0(paddingSon)][v1(100)][v2(paddingSon)]|", views: self.leftSonRowImage, self.sonProfileImageView, self.rightSonRowImage, metrics: metricsSonView)
        
        let userId = PFUser.current()?.objectId
        
        if let sonImage:UIImage = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.avatar
        {
            self.sonProfileImageView.image = sonImage
            Global.setRoundedImage(image: sonProfileImageView, cornerRadius: 50, boderWidth: 2, boderColor: UIColor.white)
        }
        
        self.sonViewContent.addSubview(self.sonLabel)
        self.sonViewContent.addConstraintsWithFormat("H:|[v0]|", views: self.sonLabel)
        
        self.sonViewContent.addConstraintsWithFormat("V:|-30-[v0(100)][v1(30)]-40-|", views: self.sonRowImage, self.sonLabel)
        
        let name = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.name
        self.sonLabel.text = name
        self.sonLabel.textAlignment = NSTextAlignment.center

        /////////////////////////////////////////////////


        self.cellId = "homeCellId"
        
         self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor
        
        self.dataView.addSubview(self.familyLabel)
        self.dataView.addSubview(self.photosContainerView)
        self.dataView.addSubview(self.sonLabel)
        self.dataView.addSubview(self.collectionView)
        self.dataView.addSubview(self.footerView)
        
        self.dataView.addConstraintsWithFormat("H:|[v0]|", views: self.familyLabel)
        self.dataView.addConstraintsWithFormat("H:|[v0]|", views: self.photosContainerView)
        self.dataView.addConstraintsWithFormat("H:|[v0]|", views: self.sonLabel)
        self.dataView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.collectionView)
        self.dataView.addConstraintsWithFormat("H:|[v0]|", views: self.footerView)
        
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
        
        self.dataView.addConstraintsWithFormat(
            "V:|-midPadding-[v0(midPadding)]-midPadding-[v1(photoSize)]-midPadding-[v2(midPadding)][v3(300)][v4(30)]|", views:
            self.familyLabel,
            self.photosContainerView,
            self.sonLabel,
            self.collectionView,
            self.footerView,
            metrics: metricsHome)

        self.checkLabelSon =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        self.checkLabelSpouse =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        self.checkLabelGroup =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)        

        self.photosContainerView.addSubview(self.sonPhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelSon)

        self.photosContainerView.addSubview(self.spousePhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelSpouse)

        self.photosContainerView.addSubview(self.groupPhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelGroup)
        
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.sonPhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.spousePhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.groupPhotoImageView)

        var metricsVerBudge = [String:Int]()

        metricsVerBudge["verPadding"] = photoSize - 25 
        
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelSon, metrics: metricsVerBudge)    
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelSpouse, metrics: metricsVerBudge)
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelGroup, metrics: metricsVerBudge)
        
        self.photosContainerView.addConstraintsWithFormat(
            "H:|-padding-[v0(photoSize)]-padding-[v1(photoSize)]-padding-[v2(photoSize)]-padding-|", views:
            self.sonPhotoImageView,
            self.spousePhotoImageView,
            self.groupPhotoImageView,
            metrics: metricsHome)

        var metricsHorBudge = [String:Int]()

        let paddingBudge = (padding + photoSize) - 25

        metricsHorBudge["sonPadding"]      = paddingBudge 
        metricsHorBudge["spousePadding"]   = (paddingBudge * 2) + 25
        metricsHorBudge["groupPadding"]    = (paddingBudge * 3) + 50

        self.photosContainerView.addConstraintsWithFormat("H:|-sonPadding-[v0(25)]", views: self.checkLabelSon, metrics: metricsHorBudge)
        self.photosContainerView.addConstraintsWithFormat("H:|-spousePadding-[v0(25)]", views: self.checkLabelSpouse, metrics: metricsHorBudge)
        self.photosContainerView.addConstraintsWithFormat("H:|-groupPadding-[v0(25)]", views: self.checkLabelGroup, metrics: metricsHorBudge)
        
        NotificationCenter.default.addObserver(self, selector: #selector(familyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(chatFeedLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyChatFeed), object: nil)
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)
        
        self.collectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
        
        self.activityIndicatorView?.startAnimating()
        
        self.checkLabelSon.isHidden = true
        self.checkLabelSpouse.isHidden = true
        self.checkLabelGroup.isHidden = true
        

        let _status = UserStatistics()
        _status.desc = "Offline"
        _status.icon = UIImage(named: "status_offline")!
        self.userStatistics.append(_status)

        let _location = UserStatistics()
        _location.desc = "Current location"
        _location.data = "5 Km"
        _location.icon = UIImage(named: "map")!
        self.userStatistics.append(_location)

        let _time = UserStatistics()
        _time.desc = "Week count"
        _time.data = "04:50 hs"
        _time.icon = UIImage(named: "time")!
        self.userStatistics.append(_time)

        let _videos = UserStatistics()
        _videos.desc = "Videos watched"
        _videos.data = "12 videos"
        _videos.icon = UIImage(named: "movie")!
        self.userStatistics.append(_videos)

        let _chats = UserStatistics()
        _chats.desc = "Chats talked"
        _chats.data = "22 chats"
        _chats.icon = UIImage(named: "chat_room_black")!
        self.userStatistics.append(_chats)


    }
    
    override func layoutSubviews() {
        
    }

     func chatFeedLoaded()
    {
        let sonChatId:Int = Global.gamvesFamily.sonChatId
        if ChatFeedMethods.chatFeeds[sonChatId]! != nil
        {
            let sonBadge = ChatFeedMethods.chatFeeds[sonChatId]?.badgeNumber
            
            if sonBadge! > 0
            {
                self.checkLabelSon.isHidden = false
                
                let sob = "\(sonBadge!)"
                
                self.checkLabelSon.text = sob
            }
            
        }
        
        let spouseChatId:Int = Global.gamvesFamily.spouseChatId
        if ChatFeedMethods.chatFeeds[spouseChatId]! != nil
        {
            let spouseBadge = ChatFeedMethods.chatFeeds[spouseChatId]?.badgeNumber
            
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
        self.familyLabel.text = Global.gamvesFamily.familyName

        if self.isKeyPresentInUserDefaults(key:"son_object_id")
        {
            let sonId = Global.defaults.object(forKey: "son_object_id") as! String
            if Global.userDictionary[sonId] != nil
            {
                self.sonLabel.text = Global.userDictionary[sonId]?.firstName
                self.sonPhotoImageView.image = Global.userDictionary[sonId]?.avatar
                Global.setRoundedImage(image: self.sonPhotoImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.gamvesColor)
            }
        }
        
        if self.isKeyPresentInUserDefaults(key:"spouse_object_id")
        {
            
            let spouseId = Global.defaults.object(forKey: "spouse_object_id") as! String
            if Global.userDictionary[spouseId] != nil
            {
                self.spousePhotoImageView.image = Global.userDictionary[spouseId]?.avatar
                Global.setRoundedImage(image: self.spousePhotoImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.gamvesColor)
            }
        }
        
        self.groupPhotoImageView.image = Global.gamvesFamily.familyImage //self.generateGroupImage() 
        Global.setRoundedImage(image: self.groupPhotoImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.gamvesColor)
        
        self.activityIndicatorView?.stopAnimating()
        
        //self.initializeOnlineSubcritpion()
        
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
        
        let sonChatId:Int = Global.gamvesFamily.sonChatId
    
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
           
            //navigationController?.pushViewController(self.chatViewController, animated: true)
    
        }
        
    }

    func handleSpousePhotoImageView(sender: UITapGestureRecognizer)
    {
        
        let spouseChatId:Int = Global.gamvesFamily.spouseChatId
        
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
            
            //navigationController?.pushViewController(self.chatViewController, animated: true)
            
        }
        
    }

    func handleGroupPhotoImageView(sender: UITapGestureRecognizer)
    {
        let familyChatId:Int = Global.gamvesFamily.familyChatId
        
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

        if id == 0
        {
            if self.sonOnline
            {
                stats.icon = UIImage(named: "status_online")!
                cell.descLabel.text = "Online"
            } else 
            {
                stats.icon = UIImage(named: "status_offline")!
                cell.descLabel.text = "Offline"
            }

            cell.dataLabel.isHidden = true
            
        }
   
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
            self.sonOnline = true
        } else
        {
            self.sonOnline = false
        }
        
        self.collectionView.reloadData()
        
    }
    
}








