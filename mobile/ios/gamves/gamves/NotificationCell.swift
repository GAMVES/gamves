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

    let fanpageHeight = CGFloat(90)    
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .brown
    
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        self.activityView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)//,x: 0, y: 0, width: 80.0, height: 80.0)
        
        self.collectionView.register(NotificationFeedCell.self, forCellWithReuseIdentifier: cellId)

        self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor
        
        self.registerLiveQuery()
        self.fetchNotification()
        
        let homeImage = "background_horizontal"
        let image = UIImage(named: homeImage)
        
        self.collectionView.backgroundView = UIImageView(image: image!)
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

                        let cover 	= notificationPF["cover"] as! PFFile

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

                                                    var sortedNotifications = Global.notifications.sorted(by: {
                                                            $0.date.compare($1.date) == .orderedAscending
                                                    })
                                                        
                                                    Global.notifications = sortedNotifications

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

        if notification.type == 1 { //video

            cell.thumbnailImageView.image = notification.cover

        } else if notification.type == 2 { //fanpage

            cell.thumbnailImageView.isHidden = true   
            cell.checkLabel.isHidden = true            

        }                
        
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

        cell.notficationTimeElapsed.text = notification.date.elapsedTime

        let gr = Gradients()
        
        var gradient : CAGradientLayer = CAGradientLayer()
        
        /*if  notification.type == 1 {
            gradient = gr.getPastelGradient(UIColor.init(netHex: 0xd5f7d1))      
        } else if notification.type == 2 {
            cell.setupFanpage()
             gradient = gr.getPastelGradient(UIColor.init(netHex: 0xf7d1f7))      
        } */

        if notification.type == 2 {
            cell.setupFanpage()
        }

        Global.auxiliarColorArray.shuffle()

        //let randomIndex = Int(arc4random_uniform(UInt32(Global.notificationColorArray.count)))
        //let randomIndex = Int(arc4random_uniform(UInt32(Global.pasterColorArray.count)))        

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
            
            size = CGSize(width: self.frame.width, height: height + 16 + 88)        

        } else if notification.type == 2 { //fanpage

            height = fanpageHeight
            
            size = CGSize(width: self.frame.width, height: height)

        }        
        
        return size //CGSize(width: self.frame.width, height: 100)
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
}

