//
//  EventViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 25/12/2018.
//  Copyright © 2018 Gamves Parents. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import Floaty
import ParseLiveQuery
import Atributika

class RecommendationViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    
    var activityView: NVActivityIndicatorView!

     let liveQueryClientFeed: Client = ParseLiveQuery.Client(server: Global.localWs) // .localWs)
  
    private var subscription: Subscription<PFObject>!
    
    var queryRecommendation:PFQuery<PFObject>!
    
    var tabBarViewController:TabBarViewController?    

    var puserId = String()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    let cellId = "cellId"
    let sectionHeaderId = "recommendationSectionHeader"

     let rowHeight = CGFloat(130)

     var recommendationLoaded = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()   

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }             

        self.view.addSubview(collectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        self.activityView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)//,x: 0, y: 0, width: 80.0, height: 80.0)
        
        self.collectionView.register(RecommendationViewCell.self, forCellWithReuseIdentifier: cellId)

        self.collectionView.register(RecommendationSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: sectionHeaderId)

        self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor       

    }

    func registerLiveQuery()
    {
        queryRecommendation = PFQuery(className: "Notifications")
        
        //if let userId = PFUser.current()?.objectId {
        
            //let filterTarget = [
            //    Global.schoolShort,
            //    Global.levelDescription.lowercased(),
            //    userId] as [String]

            //queryRecommendation.whereKey("target", containedIn: filterTarget)
        //}
        
        self.subscription = liveQueryClientFeed.subscribe(queryRecommendation).handle(Event.created) { _, notification in            
            
            self.fetchNotification()
            
        }        
        
        //self.collectionView.reloadData()
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        var count = 0
        
        if recommendationLoaded {            
        
            count = 2
        }
        
        return count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! RecommendationSectionHeader
        
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

        if recommendationLoaded {        
        
            if section == 0 {
                
                countItems = Global.recommendations.count
                
            } else if section == 1 {

                countItems = Global.recommendationsVideo.count               
            }
        }
        
        print(countItems)

        return countItems

    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RecommendationViewCell

        let index = indexPath.item
        var notification = GamvesRecommendation()
        
        print(indexPath.section)
        
        if indexPath.section == 0 {
            
            notification = Global.recommendations[index]
            
        } else if indexPath.section == 1 {
            
            notification = Global.recommendationsVideo[index]
            
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

        if notification.type == 1 { //video

            cell.thumbnailImageView.image = notification.cover
            cell.iconImageView.image = UIImage(named: "video")?.withRenderingMode(.alwaysTemplate)
            cell.iconView.backgroundColor = UIColor.blue     

        } else if notification.type == 2 { //fanpage

            cell.thumbnailImageView.isHidden = true
            cell.iconImageView.image = UIImage(named: "like")?.withRenderingMode(.alwaysTemplate)
            cell.iconView.backgroundColor = UIColor.red

        } else if notification.type == 3 { //friend

            cell.thumbnailImageView.isHidden = true
            cell.iconImageView.image = UIImage(named: "user")?.withRenderingMode(.alwaysTemplate)                                    
            cell.iconView.backgroundColor = UIColor.green
            
        } else if notification.type == 4 { //birthday

            cell.thumbnailImageView.isHidden = true           
            cell.iconImageView.image = UIImage(named: "birthday")?.withRenderingMode(.alwaysTemplate)                                     
            cell.iconView.backgroundColor = UIColor.magenta
            
        } else if notification.type == 5 { //notification

            cell.thumbnailImageView.isHidden = true
            cell.iconImageView.image = UIImage(named: "notification")?.withRenderingMode(.alwaysTemplate)                                    
            cell.iconView.backgroundColor = UIColor.gamvesLightBlueColor

        } else if notification.type == 6 { //welcome

            cell.thumbnailImageView.image = notification.cover
            cell.iconImageView.image = UIImage(named: "smile")?.withRenderingMode(.alwaysTemplate)                                     
            cell.iconView.backgroundColor = UIColor.gamvesLightBlueColor

        }

        let b = Style("b").font(.boldSystemFont(ofSize: 18))       
        cell.posterLabel.attributedText = notification.title.style(tags: b).attributedString
        
        cell.descriptionTextView.text = notification.description
        
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

        var recommendation:GamvesRecommendation!

        if indexPath.section == 0 {
                
            recommendation = Global.recommendations[index]
            
        } else if indexPath.section == 1 {
            
            recommendation = Global.recommendationsVideo[index]
        }        

        if recommendation.type == 1 || recommendation.type == 6 { //video || welcome

            height = (self.view.frame.width - 16 - 16) * 9 / 16
            
            size = CGSize(width: self.view.frame.width, height: height + 16 + 100)

        } else { //if recommendation.type == 2 { //fanpage

            height = self.rowHeight
            
            size = CGSize(width: self.view.frame.width, height: height)

        }
        
        return size //CGSize(width: self.frame.width, height: rowHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()

        let index = indexPath.item
        var recommendation = GamvesRecommendation()
        
        print(indexPath.section)
        
        if indexPath.section == 0 {
            
            recommendation = Global.recommendations[index]
            
        } else if indexPath.section == 1 {
            
            recommendation = Global.recommendationsVideo[index]
            
        }
        
        //Everything here is wrong
        
        print(recommendation.posterId)

        if recommendation.posterId != PFUser.current()?.objectId {

            if recommendation.type == 0 { //recommendation

                          

            } else if recommendation.type == 2 { //fanpage

                //let fanpage = recommendation.fanpage

                //self.homeController?.switchToMenuIndex(index: 0)        
        
                let videoPF:PFObject = recommendation.video.videoObj as! PFObject
                
                print(videoPF.objectId)
                print(videoPF["title"] as! String)

                NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)

                Global.getGamvesVideoFromObject(videoPF: videoPF, completionHandler: { (videoGamves) in          
                    
                    let videoId = videoPF["videoId"] as! Int

                    print(videoId)

                    let videoLauncher = VideoLauncher()
                    videoLauncher.showVideoPlayer(videoGamves: videoGamves)

                })


            } 

            /*else if recommendation.type == 3 { //friend

                self.homeController!.showFriendApproval()

            } else if recommendation.type == 4 { //birthday  

                let posterId = recommendation.posterId

                let gamvesUserPoster = Global.userDictionary[posterId] as! GamvesUser

                let profileLauncher = PublicProfileLauncher()
                profileLauncher.showProfileView(gamvesUser: gamvesUserPoster) 

            } else if recommendation.type == 5 { //recommendation

                

            } else if recommendation.type == 6 { //welcome

                if self.homeController != nil
                {
                    self.homeController?.showWelcomeViewcontroller()
                }
            
            }*/

        }        
    }

    func fetchNotification()
    {
    
        self.activityView.startAnimating()
        
        queryRecommendation.findObjectsInBackground(block: { (notifications, error) in
            
            if error == nil
            {
                
                let notificationsCount = notifications?.count
                if notificationsCount! > 0
                {

                    var count = 0
                    
                    for notificationPF in notifications! {
                   
                        let notification = GamvesNotification()

                        notification.objectId = notificationPF.objectId as! String
                        notification.title = notificationPF["title"] as! String
                        
                        if notificationPF["referenceId"] != nil {
                            notification.referenceId = notificationPF["referenceId"] as! Int
                        }

                        notification.description = notificationPF["description"] as! String
                        notification.posterName = notificationPF["posterName"] as! String
                        notification.date = notificationPF["date"] as! Date
                        
                        if Calendar.current.isDateInToday(notification.date) {
                            notification.isNew = true
                        }
                        
                        notification.posterId = notificationPF["posterId"] as! String

                        let type =  notificationPF["type"] as? Int 

                        if type == 1 { //video

                            let videoGamves = GamvesVideo()
                            let videoObj:PFObject = notificationPF["video"] as! PFObject

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
                        
                        } else if type == 3 { //Friend

                            //Load friends again    
                            if let userId = PFUser.current()?.objectId {    

                                Global.getFriendsAmount(posterId: userId, completionHandler: { ( countFriends ) -> () in  })
                            }

                            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyFriendApprovalLoaded), object: self)

                        } else if notification.type == 4 { //Birthday


                        } else if notification.type == 5 { //Notification    


                        } else if notification.type == 6 { //Welcome

                        }

 
                        if let objectId:String = notificationPF.objectId {
                            notification.objectId = objectId   
                        }               

                        notification.type = type!
                        
                        var cover:AnyObject!                        

                        if notificationPF["cover"] != nil {
                            cover = notificationPF["cover"] as! PFFileObject
                        }                        

                        let avatar = notificationPF["posterAvatar"] as! PFFileObject

                        avatar.getDataInBackground(block: { (imageAvatar, error) in
                
                            if error == nil {

                                if let imageAvatarData = imageAvatar {

                                    notification.avatar = UIImage(data:imageAvatarData)  

                                    if cover != nil {

                                        cover!.getDataInBackground(block: { (imageCover, error) in
                    
                                            if error == nil {

                                                if let imageCoverData = imageCover {

                                                    notification.cover = UIImage(data:imageCoverData)

                                                    self.storeNotification(count: count, notificationsCount: notificationsCount!, notification: notification)

                                                    count = count + 1
                                                }
                                            }
                                        })

                                    } else {

                                        self.storeNotification(count: count, notificationsCount: notificationsCount!, notification: notification)

                                        count = count + 1
                                    }

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
