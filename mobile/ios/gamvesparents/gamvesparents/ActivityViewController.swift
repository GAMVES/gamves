//
//  AddChatViewController.swift
//  gamves
//
//  Created by Jose Vigil on 10/13/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import GameKit
//import Floaty
import PopupDialog
import NVActivityIndicatorView

protocol ActivityProtocol {
    func closedRefresh()
}

class ActivityViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ApprovalProtocol {
    
    var activityIndicatorView:NVActivityIndicatorView?

    var homeViewController:HomeViewController? 
    
    var isGroup = Bool()
    
    var popUp:PopupDialog?
    
    var videoApprovalLauncher = VideoApprovalLauncher()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No chat activity was found for your son, other than the family chat activities"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 4
        label.textAlignment = .center
        return label
    }()
    
    let activityCellId = "activityCellId"
    
    var familyId = String()

    var activities = [ActivityGamves]()

    lazy var chatLauncher: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Activity"
        
        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
    
        self.collectionView.register(ActivityCell.self, forCellWithReuseIdentifier: activityCellId)

        self.view.addSubview(self.messageLabel)
        
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.messageLabel)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.messageLabel)
    
        self.messageLabel.isHidden = true
        
        self.familyId = Global.gamvesFamily.objectId

        self.queryActivity()
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gray) 

        self.activityIndicatorView?.startAnimating()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func queryActivity() {
        
        let queryChatFeed = PFQuery(className: "ChatFeed")
        
        if let spouseId = Global.gamvesFamily.spouseUser.userObj.objectId {
            
            if let userId = PFUser.current()?.objectId {
                
                let userId = Global.gamvesFamily.sonsUsers[0].userId
                queryChatFeed.whereKey("members", contains: userId)
                
                queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
                    
                    let chatFeddsCount = chatfeeds?.count
                    
                    if chatFeddsCount! > 0 {

                        var chatsFiltered = [PFObject]()
                        
                        for chatfeed in chatfeeds! {
                            
                            let membersStr = chatfeed["members"] as! String

                            //let membersArray = Global.parseUsersStringToArray(separated: membersStr)
                            
                            //if !membersArray.contains(spouseId) || !membersArray.contains(userId) {
                                
                                chatsFiltered.append(chatfeed)
                            //}
                        }

                        if chatsFiltered.count > 0 {
                        
                            self.parseActivity(chatFeedObjs: chatsFiltered, completionHandler: { ( chatId:Int ) -> () in
                                
                                self.collectionView.reloadData()

                                self.activityIndicatorView?.stopAnimating()
                                
                            })

                        } else {

                            self.messageLabel.isHidden = false

                            self.activityIndicatorView?.stopAnimating()
                        }
                    }
                })                
            }            
        }                
    }
    
    func parseActivity(chatFeedObjs: [PFObject], completionHandler : @escaping (_ chatId:Int) -> ()?)
    {
        var chatfeedsCount = chatFeedObjs.count
        
        print(chatfeedsCount)
        var fcount = 0
        
        for chatFeedObj in chatFeedObjs
        {
            
            let activity = ActivityGamves()
            activity.text = chatFeedObj["lastMessage"] as? String
            
            var room = chatFeedObj["room"] as? String
            
            activity.room = room
            
            activity.date = chatFeedObj.updatedAt
            activity.lasPoster = chatFeedObj["lastPoster"] as? String
            let isVideoChat = chatFeedObj["isVideoChat"] as! Bool
            activity.isVideoChat = isVideoChat
            var chatId = chatFeedObj["chatId"] as! Int
            activity.chatId = chatId
            
            let picture = chatFeedObj["thumbnail"] as! PFFile
            picture.getDataInBackground(block: { (imageData, error) in
                
                if error == nil
                {
                    if let imageData = imageData
                    {
                        activity.chatThumbnail = UIImage(data:imageData)
                        
                        //self.getParticipants(chatFeedObj : chatFeedObj, chatfeed: chatfeed, isVideoChat: isVideoChat, chatId : chatId, completionHandler: { ( chatfeed ) -> () in
                            
                        var chatFeedRoom = String()
                        
                        if (room?.contains("____"))!
                        {
                            let roomArr : [String] = room!.components(separatedBy: "____")
                            
                            var first : String = roomArr[0]
                            var second : String = roomArr[1]
                            
                            var chatThumbnail = UIImage()
                            
                            if first == PFUser.current()?.objectId
                            {
                                chatFeedRoom = (Global.userDictionary[second]?.name)!
                                chatThumbnail = (Global.userDictionary[second]?.avatar)!
                            } else {
                                chatFeedRoom = (Global.userDictionary[first]?.name)!
                                chatThumbnail = (Global.userDictionary[first]?.avatar)!
                            }
                            
                            activity.chatThumbnail = chatThumbnail
                            
                            activity.room = chatFeedRoom
                            
                        }  

                        self.activities.append(activity)

                        if (chatfeedsCount-1) == fcount
                        {
                            //self.sortFeedByDate()
                            
                            completionHandler(chatId)
                        }

                        fcount = fcount + 1

                        //})
                    }
                }                
            })
            
            if activity.isVideoChat!
            {
                let videoId = "\(activity.chatId!)"
                
                let videosQuery = PFQuery(className:"Videos")
                videosQuery.whereKey("videoId", equalTo: videoId)
                videosQuery.findObjectsInBackground(block: { (videos, error) in
                    
                    if error != nil
                    {
                        print("error")
                    } else {
                        
                        if (videos?.count)! > 0
                        {
                            var videosGamves = [GamvesVideo]()
                            
                            if let videos = videos
                            {
                                for video in videos
                                {
                                    
                                    let thumbnail = video["thumbnail"] as! PFFile
                                 
                                    thumbnail.getDataInBackground(block: { (data, error) in
                                        
                                        
                                        if error == nil
                                        {
                                            let thumbImage = UIImage(data:data!)
                                                                                        
                                            Global.parseVideo(videoPF: video, chatId : chatId, videoImage: thumbImage! )

                                        }
                                    })
                                }
                            }
                        }
                    }
                })
            }
        }
    }



    func closedRefresh() {
        
        //Global.approvals = [Approvals]()
        
        Global.getApprovasByFamilyId(familyId: self.familyId) { ( count ) in
            
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //let countItems = ChatFeedMethods.chatFeeds.count
        let countItems = activities.count
        return countItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: activityCellId, for: indexPath) as! ActivityCell
        
        //let lkeys = Array(ChatFeedMethods.chatFeeds.keys)        
        //let index = indexPath.item
        //let indexKey = lkeys[index]

        //let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[indexKey]!

        let activity = self.activities[indexPath.item]
        
        cell.nameLabel.text = activity.room
        
        cell.profileImageView.image = activity.chatThumbnail!

         let time = activity.date as! Date

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let elapsedTimeInSeconds = Date().timeIntervalSince(time)
        
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "MM/dd/yy"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEE"
        }
        
        cell.timeLabel.text = dateFormatter.string(from: time)        
        
        let formatterLong = DateFormatter()
        
        formatterLong.dateFormat = "HH:mm:ss"

        let timeLong = formatterLong.string(from: time)

        cell.elapsedLabel.text = timeLong          

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.gamvesLightGrayColor
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /*let index = indexPath.item
        let key: Int = Array(ChatFeedMethods.chatFeeds)[index].key
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[key]!*/


        let index = indexPath.item

        let section = indexPath.section        

        var chatfeed = ChatFeed()

        if section == 0 {           

            let key: Int = Array(ChatFeedMethods.chatFeedFamily)[index].key
            chatfeed = ChatFeedMethods.chatFeedFamily[key]!
            
        } else if section == 1 {           
            
            let key: Int = Array(ChatFeedMethods.chatFeedAdmin)[index].key
            chatfeed = ChatFeedMethods.chatFeedAdmin[key]!

        } else {

            let has = hasFriendsAndVideSections(index: section)
            
            if has == 1 {

                let key: Int = Array(ChatFeedMethods.chatFeedFriends)[index].key
                chatfeed = ChatFeedMethods.chatFeedFriends[key]!

            } else if has == 2 {      

                let key: Int = Array(ChatFeedMethods.chatFeedVideos)[index].key
                chatfeed = ChatFeedMethods.chatFeedVideos[key]!   
            }
        } 

        let isVideoChat:Bool = chatfeed.isVideoChat! as Bool
        
        if isVideoChat {
            
            let chatId = chatfeed.chatId! as Int
            print(chatId)
            var video = GamvesVideo()
            
            video = Global.chatVideos[chatId]!
            
            print(video.videoId)
            
            let videoApprovalLauncher = VideoApprovalLauncher()
            videoApprovalLauncher.showVideoPlayer(videoGamves: video, approved: 1)
            
        } else {
            
            self.openChat(room: chatfeed.room!, chatId: chatfeed.chatId!, users: chatfeed.users!)
        
        }

        //let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[indexPath.item]!
   
        /*if self.homeViewController != nil {
        
            var video = VideoGamves()
            
            video = Global.chatVideos[chatfeed.chatId!]!
            
            videoApprovalLauncher = VideoApprovalLauncher()
            videoApprovalLauncher.delegate = self
            videoApprovalLauncher.showVideoPlayer(videoGamves: video, approved: 0)
            
        }*/
    }


    func hasFriendsAndVideSections(index: Int) -> Int
    {
        var result = 0

        if index == 2 && ChatFeedMethods.chatFeedFriends.count > 0 {           

            result = 1

        } else if index == 3 && ChatFeedMethods.chatFeedVideos.count > 0 {

            result = 2
        }

        return result
    }

    func openChat(room: String, chatId:Int, users:[GamvesUser])
    {
        self.chatLauncher.chatId = chatId
        self.chatLauncher.gamvesUsers = users
        self.chatLauncher.room = room
        chatLauncher.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(self.chatLauncher, animated: true)
    }

    
    func pauseVideo() {
        videoApprovalLauncher.pauseVideo()
    }
    
    
}
