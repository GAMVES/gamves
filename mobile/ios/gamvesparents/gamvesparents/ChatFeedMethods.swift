//
//  ChatFeedMethods.swift
//  gamvesparents
//
//  Created by Jose Vigil on 11/16/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//


import UIKit
import Parse

class ChatFeedMethods: NSObject
{    
    
    static var chatFeeds = Dictionary<Int, ChatFeed>()

    static func sortFeedByDate()
    {
        self.chatFeeds.sorted(by: {$0.value.date! > $1.value.date! })
    }
    
    static func queryFeed(chatId:Int?, completionHandlerChatId : @escaping (_ chatId:Int) -> ()?)
    {

        var queryChatFeed = PFQuery(className: "ChatFeed")

        if chatId != nil
        {
            queryChatFeed.whereKey("chatId", equalTo: chatId)
        } else 
        {            
            
            if let userId = PFUser.current()?.objectId
            {
                queryChatFeed.whereKey("members", contains: userId)
            }            
        }
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
            let chatFeddsCount = chatfeeds?.count
            
            print(chatFeddsCount)
            
            if chatFeddsCount! > 0
            {
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
            chatfeed.userId = chatFeedObj["lastPoster"] as? String
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
                                
                                if first == PFUser.current()?.objectId
                                {
                                    chatFeedRoom = (Global.userDictionary[second]?.name)!
                                } else {
                                    chatFeedRoom = (Global.userDictionary[first]?.name)!
                                }
                                
                                chatfeed.room = chatFeedRoom
                            }
                            
                            Global.getBadges(chatId : chatId, completionHandler: { ( counter ) -> () in
                                
                                chatfeed.badgeNumber = counter
                                
                                print(chatId)
                                
                                self.sortFeedByDate()
                                
                                self.chatFeeds[chatId] = chatfeed
                                
                                if (chatfeedsCount-1) == fcount
                                {
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
                                for video in videos
                                {
                                    let videoGamves = VideoGamves()
                                    let videothumburl:String = video["thumbnailUrl"] as! String
                                    let videoDescription:String = video["description"] as! String
                                    let videoCategory:String = video["category"] as! String
                                    let videoUrl:String = video["source"] as! String
                                    let videoTitle:String = video["title"] as! String
                                    let videoFromName:String = video["fromName"] as! String
                                    
                                    videoGamves.video_title = videoTitle
                                    videoGamves.thumb_url = videothumburl
                                    videoGamves.description = videoDescription
                                    videoGamves.video_category = videoCategory
                                    videoGamves.video_url = videoUrl
                                    videoGamves.video_fromName = videoFromName
                                    videoGamves.videoobj = video
                                    
                                    if let vurl = URL(string: videothumburl)
                                    {
                                        if let data = try? Data(contentsOf: vurl)
                                        {
                                            videoGamves.thum_image = UIImage(data: data)!
                                        }
                                    }
                                    Global.chatVideos[chatId] = videoGamves
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
                var usersArray = [GamvesParseUser]()
                
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
    
    
    static func loadChatChannels()
    {

        var queryChatFeed = PFQuery(className: "ChatFeed")
        
        queryChatFeed = PFQuery(className: "ChatFeed")
        
        if let userId = PFUser.current()?.objectId
        {
            queryChatFeed.whereKey("members", contains: userId)
        }      
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
            let chatFeddsCount = chatfeeds?.count
            
            print(chatFeddsCount)
            
            if chatFeddsCount! > 0
            {
                let chatfeedsCount =  chatfeeds?.count

                print(chatfeedsCount)

                if chatfeedsCount! > 0
                {
                    
                    var installation:PFInstallation = PFInstallation.current()!

                    for feed in chatfeeds!
                    {
                        let chatId:Int = feed["chatId"] as! Int
                        
                        let chatIdStr = String(chatId) as String
                        
                        installation.channels?.append(chatIdStr)
                    }
                    
                    do
                    {
                    
                        try installation.save()
                    
                    } catch
                    {
                        
                    }

                }         
            
            }
            
        })
    }

}
