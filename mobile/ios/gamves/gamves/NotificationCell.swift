//
//  NotificationCell.swift
//  gamves
//
//  Created by Jose Vigil on 1/16/18.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Parse
import Floaty
import ParseLiveQuery
import Atributika

class NotificationCell: BaseCell, 
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {

	var activityView: NVActivityIndicatorView!
    
    var homeController: HomeController?    
    
    let liveQueryClientFeed: Client = ParseLiveQuery.Client(server: Global.localWs) // .localWs)
  
    private var subscription: Subscription<PFObject>!
    
    var queryNotification:PFQuery<PFObject>!
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellId = "cellId"
    let sectionHeaderId = "notificationSectionHeader"

    let rowHeight = CGFloat(110)

    var floaty = Floaty(size: 80)   

    var notificationLoaded = Bool() 
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .brown
    
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        self.activityView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)//,x: 0, y: 0, width: 80.0, height: 80.0)
        
        self.collectionView.register(NotificationFeedCell.self, forCellWithReuseIdentifier: cellId)

        self.collectionView.register(NotificationSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: sectionHeaderId)

        self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor
        
        self.registerLiveQuery()
        self.fetchNotification()
        
        let homeImage = "background_horizontal"
        let image = UIImage(named: homeImage)
        
        self.collectionView.backgroundView = UIImageView(image: image!)

         //FLOATY      

        self.floaty.paddingY = 35
        self.floaty.paddingX = 20                    
        self.floaty.itemSpace = 30
        self.floaty.shadowRadius = 20
        self.floaty.buttonColor = UIColor.gamvesTurquezeColor
        var addImage = UIImage(named: "add_symbol")
        addImage = addImage?.maskWithColor(color: UIColor.white)
        addImage = Global.resizeImage(image: addImage!, targetSize: CGSize(width:40, height:40))
        self.floaty.buttonImage = addImage
        self.floaty.sizeToFit()

        //floaty.verticalDirection = .down        
        
        let itemGift = FloatyItem()
        var giftImage = UIImage(named: "gift")
        giftImage = giftImage?.maskWithColor(color: UIColor.white)
        itemGift.icon = giftImage                   
        itemGift.buttonColor = UIColor.gamvesTurquezeColor
        itemGift.titleLabelPosition = .left
        itemGift.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemGift.title = "GIFTS"
        itemGift.handler = { item in
            
            if self.homeController != nil
            {
                self.homeController?.showGiftViewcontroller()
            }

        }

        self.floaty.addItem(item: itemGift)          
        self.addSubview(floaty) 
    }
    
    func registerLiveQuery()
    {
        queryNotification = PFQuery(className: "Notifications")
        
        if let userId = PFUser.current()?.objectId {
        
            queryNotification.whereKey("target", contains: userId)
        }
        
        self.subscription = liveQueryClientFeed.subscribe(queryNotification).handle(Event.created) { _, notification in            
            
            self.fetchNotification()
            
        }        
        
        //self.collectionView.reloadData()
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! NotificationSectionHeader
        
        sectionHeaderView.backgroundColor = UIColor.black
        
        if indexPath.section == 0 {
            
            var image  = UIImage(named: "add_notification_white")?.withRenderingMode(.alwaysTemplate)
            //image = image?.maskWithColor(color: UIColor.white)
            //image = Global.resizeImage(image: image!, targetSize: CGSize(width:40, height:40))
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "New"
            
        } else if indexPath.section == 1 {
            
            var image  = UIImage(named: "time_earlier_white")?.withRenderingMode(.alwaysTemplate)
            //image = image?.maskWithColor(color: UIColor.white)
            //image = Global.resizeImage(image: image!, targetSize: CGSize(width:40, height:40))
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "Earlier"
        }
        
        return sectionHeaderView
        
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {

        var countItems = Int()

        if notificationLoaded {        
        
            if section == 0 {
                
                countItems = Global.notificationsNew.count
                
            } else if section == 1 {
                
                countItems = Global.notifications.count
                
                if countItems == 0
                {
                    countItems = 1
                    
                }
            }
        }

        return countItems

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NotificationFeedCell       

        let index = indexPath.item
        var notification = GamvesNotification()
        
        if indexPath.section == 0 {
            notification = Global.notificationsNew[index]
        } else if indexPath.section == 1 {
            notification = Global.notifications[index]
        }        

        if notification.type == 2 {
            cell.setThumbnailSize()
        }

        var message:String = notification.description

        let delimitator = Global.admin_delimitator

        if message.range(of:delimitator) != nil
        {            
            if let range = message.range(of: delimitator) 
            {
                message.removeSubrange(range)
            }
        } 

        cell.descriptionTextView.text = message
        
        cell.userProfileImageView.image = notification.avatar

        var posterdesc = String()

        if notification.type == 1 { //video

            cell.thumbnailImageView.image = notification.cover

            cell.iconImageView.image = UIImage(named: "video")?.withRenderingMode(.alwaysTemplate)
            
            posterdesc = "shared a new video"

            cell.iconView.backgroundColor = UIColor.blue     

        } else if notification.type == 2 { //fanpage

            cell.thumbnailImageView.isHidden = true

            cell.iconImageView.image = UIImage(named: "like")?.withRenderingMode(.alwaysTemplate)                         

            posterdesc = "shared a new fanpage"  

            cell.iconView.backgroundColor = UIColor.red

        } else if notification.type == 3 { //friend

            cell.thumbnailImageView.isHidden = true

            cell.iconImageView.image = UIImage(named: "user")?.withRenderingMode(.alwaysTemplate)                         

            posterdesc = notification.title

            cell.iconView.backgroundColor = UIColor.green
            
        } else if notification.type == 4 { //birthday

            cell.thumbnailImageView.isHidden = true

            cell.iconImageView.image = UIImage(named: "birthday")?.withRenderingMode(.alwaysTemplate)                         

            posterdesc = notification.title

            cell.iconView.backgroundColor = UIColor.magenta
            
        } else if notification.type == 4 { //notification

            cell.thumbnailImageView.isHidden = true

            cell.iconImageView.image = UIImage(named: "notification")?.withRenderingMode(.alwaysTemplate)                         

            posterdesc = notification.title

            cell.iconView.backgroundColor = UIColor.gamvesLightBlueColor

        }


        let b = Style("b").font(.boldSystemFont(ofSize: 18))

        cell.posterLabel.attributedText = "<b>\(notification.posterName)</b> \(posterdesc)".style(tags: b).attributedString
        
        cell.descriptionTextView.text = notification.title
        
        var image = String()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let elapsedTimeInSeconds = Date().timeIntervalSince(notification.date)
        
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "MM/dd/yy"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEE"
        }
        
        //cell.notficationDatePublish.text = dateFormatter.string(from: notification.date)

        cell.timeLabel.text = notification.date.elapsedTime       

        //GRADIENT

        let gr = Gradients()        
        var gradient : CAGradientLayer = CAGradientLayer()
        gradient = gr.getPastelGradient()        
        gradient.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        cell.layer.insertSublayer(gradient, at: 0)
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var size = CGSize()
        var height = CGFloat()

        let index = indexPath.item
        let notification:GamvesNotification = Global.notifications[index]

        if notification.type == 1 { //video

            height = (self.frame.width - 16 - 16) * 9 / 16
            
            size = CGSize(width: self.frame.width, height: height + 16 + 100)        

        } else if notification.type == 2 { //fanpage

            height = self.rowHeight
            
            size = CGSize(width: self.frame.width, height: height)

        }
        
        return size //CGSize(width: self.frame.width, height: rowHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()

        let index = indexPath.item
        let notification:GamvesNotification = Global.notifications[index]

        //Everything here is wrong 

        if notification.posterId != PFUser.current()?.objectId {

            if notification.type == 1 {

                let videoPF:PFObject = notification.video.videoObj as! PFObject
                
                print(videoPF.objectId)
                print(videoPF["title"] as! String)

                NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)

                Global.getGamvesVideoFromObject(videoPF: videoPF, completionHandler: { (videoGamves) in          
                    
                    let videoId = videoPF["videoId"] as! Int

                    print(videoId)

                    let videoLauncher = VideoLauncher()
                    videoLauncher.showVideoPlayer(videoGamves: videoGamves)

                })          

            } else if notification.type == 2 {

                let fanpage = notification.fanpage

                self.homeController?.switchToMenuIndex(index: 0)        
        
                //Moving to selected GamveFampage is not woking, commenting.

                /*print(fanpage.fanpageObj?.objectId)                
                Global.fanpageData = fanpage                          
                print(fanpage.fanpageObj?.objectId)
                self.homeController?.setCurrentPage(current: 2, direction: 1, data: fanpage)*/

            }           
        }        
    }

    func fetchNotification()
    {
    
        self.activityView.startAnimating()
        
        queryNotification.findObjectsInBackground(block: { (notifications, error) in
            
            if error == nil
            {
                
                let notificationsCount = notifications?.count
                if notificationsCount! > 0
                {

                    var count = 0
                    
                    for notificationPF in notifications! {
                   
                        let notification = GamvesNotification()

                        notification.objectId = (notificationPF.objectId as? String)!
                        notification.title = (notificationPF["title"] as? String)!
                        notification.referenceId = (notificationPF["referenceId"] as? Int)!
                        notification.description = (notificationPF["description"] as? String)!
                        notification.posterName = (notificationPF["posterName"] as? String)!
                        notification.date = (notificationPF["date"] as? Date!)!
                        
                        if Calendar.current.isDateInToday(notification.date) {
                            notification.isNew = true
                        }
                        
                        notification.posterId = (notificationPF["posterId"] as? String)!

                        let type =  notificationPF["type"] as? Int 

                        if type == 1 { //video

                            let videoGamves = GamvesVideo()
                            let videoObj:PFObject = (notificationPF["video"] as? PFObject)!

                            do {
                                try videoObj.fetchIfNeeded()
                            } catch _ {
                               print("There was an error fetching video poiner")         
                            }

                            videoGamves.videoObj = videoObj
                            notification.video = videoGamves
                            print(videoObj["title"] as! String)
                            
                        } else if type == 2 { //Fanpage
                            
                            let fanpageGamves = GamvesFanpage()
                            let fanpageObj = notificationPF["fanpage"] as? PFObject

                            do {
                                try fanpageObj?.fetchIfNeeded()
                            } catch _ {
                               print("There was an error fetching fanpage poiner")         
                            }

                            fanpageGamves.fanpageObj = fanpageObj
                            notification.fanpage = fanpageGamves
                        }
 
                        if let objectId:String = notificationPF.objectId {
                            notification.objectId = objectId   
                        }               

                        notification.type = type!

                        let cover   = notificationPF["cover"] as! PFFile

                        let avatar = notificationPF["posterAvatar"] as! PFFile

                        avatar.getDataInBackground(block: { (imageAvatar, error) in
                
                            if error == nil {

                                if let imageAvatarData = imageAvatar {

                                    notification.avatar = UIImage(data:imageAvatarData)                                  

                                    cover.getDataInBackground(block: { (imageCover, error) in
                
                                        if error == nil {

                                            if let imageCoverData = imageCover {

                                                notification.cover = UIImage(data:imageCoverData)

                                                if notification.isNew {
                                                    
                                                    Global.notificationsNew.append(notification)                                     
                                                    
                                                } else {
                                                
                                                    Global.notifications.append(notification)
                                                }

                                                if count == (notificationsCount! - 1) {                          
                                                    

                                                    var sortedNotifications = Global.notifications.sorted(by: {
                                                            $0.date.compare($1.date) == .orderedDescending
                                                    })
                                                        
                                                    Global.notifications = sortedNotifications
                                                    
                                                    if Global.notificationsNew.count > 0 {
                                                    
                                                        var sortedNewNotifications = Global.notificationsNew.sorted(by: {
                                                            $0.date.compare($1.date) == .orderedDescending
                                                        })
                                                        
                                                        Global.notificationsNew = sortedNewNotifications
                                                    }

                                                    self.notificationLoaded = true
                                                    
                                                    self.collectionView.reloadData()
                                                    
                                                    self.activityView.stopAnimating()
                                                }
                                                
                                                count = count + 1
                                            }
                                        }
                                    })
                                }
                            }
                        })
                    }
                    
                } else
                {
                    self.activityView.stopAnimating()
                }
                
            }
        })
    
    }
    
    
    func uploadData()
    {
        self.reloadCollectionView()
    }
    
    func reloadCollectionView()
    {
        ChatFeedMethods.sortAllFeeds()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.collectionView.reloadData()
        }
    }

}

