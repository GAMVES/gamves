//
//  ChatFeedMethods.swift
//  gamvesparents
//
//  Created by Jose Vigil on 11/16/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//


import UIKit
import Parse

class ChatFeedMethods: NSObject {
    
    static var chatFeeds = Dictionary<Int, ChatFeed>()

    static func sortFeedByDate() {
        
        var sortedFeeds = self.chatFeeds.sorted(by: {
            $0.value.date?.compare($1.value.date!) == .orderedDescending
        })
        
        self.chatFeeds = Dictionary<Int, ChatFeed>()
        
        for sorted in sortedFeeds {
            self.chatFeeds[sorted.key] = sorted.value
        }
    }
    
    func before(value1: String, value2: String) -> Bool {
        // One string is alphabetically first.
        // ... True means value1 precedes value2.
        return value1 < value2;
    }
    
    static func queryFeed(chatId:Int?, completionHandlerChatId : @escaping (_ chatId:Int) -> ()?)
    {

        var queryChatFeed = PFQuery(className: "ChatFeed")

        if chatId != nil
        {
            queryChatFeed.whereKey("chatId", equalTo: chatId)
        } else 
        {
            queryChatFeed = PFQuery(className: "ChatFeed")
            
            if let userId = PFUser.current()?.objectId
            {
                queryChatFeed.whereKey("members", contains: userId)
            }            
        }
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
            let chatFeddsCount = chatfeeds?.count
            
            print(chatFeddsCount)
            
            if chatFeddsCount! > 0 {
                
                let chatfeedsCount =  chatfeeds?.count
                
                self.parseChatFeed(chatFeedObjs: chatfeeds!, completionHandler: { ( chatId:Int ) -> () in
                
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyChatFeed), object: self)

                    completionHandlerChatId(chatId)
                })
            }
        })
    }
    
    static func parseChatFeed(chatFeedObjs: [PFObject], completionHandler : @escaping (_ chatId:Int) -> ()?)
    {
        var chatfeedsCount = chatFeedObjs.count
        
        print(chatfeedsCount)
        var fcount = 0
        
        for chatFeedObj in chatFeedObjs
        {
            
            let chatfeed = ChatFeed()
            chatfeed.text = chatFeedObj["lastMessage"] as? String
            
            var room = chatFeedObj["room"] as? String
            
            chatfeed.room = room
            
            chatfeed.date = chatFeedObj.updatedAt
            
            chatfeed.lasPoster = chatFeedObj["lastPoster"] as? String
            let isVideoChat = chatFeedObj["isVideoChat"] as! Bool
            chatfeed.isVideoChat = isVideoChat
            var chatId = chatFeedObj["chatId"] as! Int
            chatfeed.chatId = chatId
            
            let picture = chatFeedObj["thumbnail"] as! PFFile
            
            picture.getDataInBackground(block: { (imageData, error) in
                
                if error == nil
                {
                    if let imageData = imageData
                    {
                        chatfeed.chatThumbnail = UIImage(data:imageData)
                        
                        self.getParticipants(chatFeedObj : chatFeedObj, chatfeed: chatfeed, isVideoChat: isVideoChat, chatId : chatId, completionHandler: { ( chatfeed ) -> () in
                            
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
                                
                                chatfeed.chatThumbnail = chatThumbnail
                                
                                chatfeed.room = chatFeedRoom
                                
                            }
                            
                            Global.getBadges(chatId : chatId, completionHandler: { ( counter ) -> () in
                                
                                chatfeed.badgeNumber = counter
                                
                                self.chatFeeds[chatId] = chatfeed
                        
                                if (chatfeedsCount-1) == fcount {
                                
                                    self.sortFeedByDate()
                                    
                                    completionHandler(chatId)
                                }
                                
                                fcount = fcount + 1
                                
                            })
                        
                        })
                    }
                }
                
                //self.collectionView.reloadData()
            })
            
            if chatfeed.isVideoChat!
            {
                let videoId = "\(chatfeed.chatId!)" //String(message.chatId)
                
                let videosQuery = PFQuery(className:"Videos")
                videosQuery.whereKey("videoId", equalTo: videoId)
                videosQuery.whereKey("approved", equalTo: true)
                videosQuery.findObjectsInBackground(block: { (videos, error) in
                    
                    if error != nil
                    {
                        
                        print("error")
                        
                    } else {
                        
                        if (videos?.count)! > 0
                        {
                            var videosGamves = [VideoGamves]()
                            
                            if let videos = videos
                            {
                                for qvideoinfo in videos
                                {
                                    /*let videoGamves = VideoGamves()
                                    
                                    let video = VideoGamves()
                                    
                                    var videothum = qvideoinfo["thumbnail"] as! PFFile
                                    
                                    video.title                     = qvideoinfo["title"] as! String
                                    video.description               = qvideoinfo["description"] as! String
                                    video.thumbnail                 = videothum
                                    video.categoryName              = qvideoinfo["categoryName"] as! String
                                    video.videoId                   = qvideoinfo["videoId"] as! Int
                                    video.s3_source                 = qvideoinfo["s3_source"] as! String
                                    video.ytb_thumbnail_source      = qvideoinfo["ytb_thumbnail_source"] as! String
                                    video.ytb_videoId               = qvideoinfo["ytb_videoId"] as! String
                                    
                                    let dateStr = qvideoinfo["ytb_upload_date"] as! String
                                    let dateDouble = Double(dateStr)
                                    let date = NSDate(timeIntervalSince1970: dateDouble!)
                                    
                                    video.ytb_upload_date           = date as Date
                                    video.ytb_view_count            = qvideoinfo["ytb_view_count"] as! Int
                                    video.ytb_tags                  = qvideoinfo["ytb_tags"] as! [String]
                                    
                                    let durStr = qvideoinfo["ytb_upload_date"] as! String
                                    let durDouble = Double(durStr)
                                    video.ytb_duration              = durDouble!
                                    
                                    video.ytb_categories            = qvideoinfo["ytb_categories"] as! [String]
                                    //video.ytb_like_count            = qvideoinfo["ytb_like_count"] as! Int
                                    video.order                     = qvideoinfo["order"] as! Int
                                    video.fanpageId                 = qvideoinfo["fanpageId"] as! Int
                                    
                                    video.posterId                  = qvideoinfo["posterId"] as! String
                                    video.posterName                = qvideoinfo["poster_name"] as! String
                                    
                                    video.published                 = qvideoinfo.createdAt as! Date
                                    
                                    video.videoObj = qvideoinfo
                                                                       
                                    videothum.getDataInBackground(block: { (data, error) in
                                        
                                        if error != nil{
                                            
                                            videoGamves.image = UIImage(data: data!)!
                                            
                                            Global.chatVideos[chatId] = videoGamves
                                        }

                                    })*/
                                    
                                    Global.getGamvesVideoFromObject(videoPF: qvideoinfo, completionHandler: { (videoGamves) in
                                        
                                        Global.chatVideos[chatId] = videoGamves
                                    })
                                
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    
    static func getParticipants(chatFeedObj : PFObject, chatfeed : ChatFeed, isVideoChat: Bool, chatId : Int, completionHandler : @escaping (_ resutl:ChatFeed) -> ())
    {
        
        var members = chatFeedObj["members"] as! String
        
        let participantQuery = PFQuery(className:"_User")
        participantQuery.whereKey("objectId", containedIn: Global.parseUsersStringToArray(separated: members))
        participantQuery.findObjectsInBackground(block: { (users, error) in
            
            if error == nil
            {
                
                let countUsers = users?.count
                var count = 0
                var usersArray = [GamvesUser]()
                
                for user in users!
                {
                    //Add single chat flag, avoided query users alone participant
                    
                    if users?.count == 2 && user.objectId != PFUser.current()?.objectId && !isVideoChat
                    {
                        user.add(chatId, forKey: "chatId")
                        
                        if Global.userDictionary[user.objectId!] != nil
                        {
                            Global.userDictionary[user.objectId!]?.chatId = chatId
                        }
                    }
                    
                    Global.addUserToDictionary(user: user as! PFUser, isFamily: false, completionHandler: { ( gamvesUser ) -> () in
                        
                        if user.objectId != PFUser.current()?.objectId
                        {
                            usersArray.append(gamvesUser)
                        }
                        
                        if (countUsers!-1) == count
                        {
                            chatfeed.users = usersArray
                            completionHandler(chatfeed)
                        }
                        
                        count = count + 1
                    })
                }
            }
        })
    }

}
