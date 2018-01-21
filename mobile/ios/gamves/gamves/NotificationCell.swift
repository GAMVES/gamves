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
import ParseLiveQuery

class NotificationCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	 var activityView: NVActivityIndicatorView!
    
    var homeController: HomeController?    
    
    let liveQueryClientFeed: Client = ParseLiveQuery.Client(server: Global.remoteWs) // .localWs)
  
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
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .brown
    
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        self.activityView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
        
        self.collectionView.register(NotificationFeedCell.self, forCellWithReuseIdentifier: cellId)
        
        self.registerLiveQuery()
        self.fetchNotification()        
    }
    
    func registerLiveQuery()
    {
        queryNotification = PFQuery(className: "Notifications")    
        
        self.subscription = liveQueryClientFeed.subscribe(queryNotification).handle(Event.created) { _, notification in            
            
            self.fetchNotification()
            
        }        
        
        self.collectionView.reloadData()
        
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
                        notification.date = (notificationPF.createdAt as? Date)!

                        let type =  notificationPF["type"] as? Int 

                        if type == 1 { //video

                            let videoGamves = VideoGamves()
                            let videoObj = notificationPF["video"] as? PFObject
                            videoGamves.videoObj = videoObj
                            notification.video = videoGamves
                            
                        } else if type == 2 { //Fanpage
                            
                            let fanpageGamves = FanpageGamves()
                            let fanpageObj = notificationPF["fanpage"] as? PFObject
                            fanpageGamves.fanpageObj = fanpageObj
                            notification.fanpage = fanpageGamves
                        }
 
                        if let objectId:String = notificationPF.objectId {
                            notification.objectId = objectId   
                        }               

                        notification.type = type!

                        let cover = notificationPF["cover"] as! PFFile

                        let avatar = notificationPF["posterAvatar"] as! PFFile

                        avatar.getDataInBackground(block: { (imageAvatar, error) in
                
                            if error == nil {

                                if let imageAvatarData = imageAvatar {

                                    notification.avatar = UIImage(data:imageAvatarData)                                  

                                    cover.getDataInBackground(block: { (imageCover, error) in
                
                                        if error == nil {

                                            if let imageCoverData = imageCover {

                                                notification.cover = UIImage(data:imageCoverData)

                                                Global.notifications.append(notification)

                                                if count == (notificationsCount! - 1) {

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
        ChatFeedMethods.sortFeedByDate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.collectionView.reloadData()
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        print(Global.notifications.count)
        return Global.notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NotificationFeedCell

        let index = indexPath.item
        let notification:GamvesNotification = Global.notifications[index]
        
        cell.notificationName.text = notification.title

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
        
        cell.thumbnailImageView.image = notification.cover
        
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
        
        cell.notficationDatePublish.text = dateFormatter.string(from: notification.date)
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var size = CGSize()

        let height = (self.frame.width - 16 - 16) * 9 / 16
            
        size = CGSize(width: self.frame.width, height: height + 16 + 88)
        
        return size //CGSize(width: self.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()
        
        let index = indexPath.item
        let key: Int = Array(ChatFeedMethods.chatFeeds)[index].key
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[key]!
    
        print(chatfeed.chatId)
        
        let isVideoChat:Bool = chatfeed.isVideoChat! as Bool
        
        if isVideoChat
        {
            
            let chatId = chatfeed.chatId! as Int
            print(chatId)
            var video = VideoGamves()
                
            video = Global.chatVideos[chatId]!
            
            print(video.ytb_videoId)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)
            
            let videoLauncher = VideoLauncher()
            videoLauncher.showVideoPlayer(videoGamves: video)
            
        } else
        {
            if self.homeController != nil
            {
                self.homeController?.openChat(room: chatfeed.room!, chatId: chatfeed.chatId!, users: chatfeed.users!)
            }
            
        }
        
    }


}
