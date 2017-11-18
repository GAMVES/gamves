//
//  ChatMethods.swift
//  gamvesparents
//
//  Created by Jose Vigil on 11/15/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import Foundation
import Parse


class ChatMethods: NSObject
{
    
    
    static func addNewFeedAppendgroup(gamvesUsers:[GamvesParseUser], chatId:Int64, completionHandler : @escaping (_ resutl:Bool) -> ())
    {
        
        let random = Int()
            
        var chatFeed = PFObject(className: "ChatFeed")
        
        chatFeed["chatId"] = chatId
        
        chatFeed["isVideoChat"] = false

        let groupImageFile:PFFile!

        if gamvesUsers.count > 2
        {
        
            let imageGroup = UIImage(named: "community")
            groupImageFile = PFFile(data: UIImageJPEGRepresentation(imageGroup!, 1.0)!)
            
            var array = [String]()
            
            for user in gamvesUsers
            {
                array.append(user.gamvesUser.objectId!)
            }
            let members = String(describing: array)
            chatFeed["members"] = members

            chatFeed["room"] = Global.gamvesFamily.familyName
            
        } else
        {
    
            groupImageFile = PFFile(data: UIImageJPEGRepresentation(gamvesUsers[1].avatar, 1.0)!)          
            
            let member = String(describing: [gamvesUsers[1].userId, gamvesUsers[0].userId])
            chatFeed["members"] = member
            chatFeed["room"] = "\(gamvesUsers[1].userId)____\(gamvesUsers[0].userId)"
            
        } 

        chatFeed.setObject(groupImageFile, forKey: "thumbnail")       
        
        var chatMembers = String()
        var countUsers = gamvesUsers.count
        var count = Int()
        
        for user in gamvesUsers
        {
        	chatMembers += "\(user.firstName) "
        	if count < (countUsers-1)
            {
            	//if
            	chatMembers += " and "
            }

            count = count + 1
        }
        chatFeed["lastMessage"] = "---is_admin_chat---New chat with \(chatMembers)"      
        
        chatFeed.saveInBackground(block: { (saved, error) in
            
            if error == nil
            {                
                //CREATE CHANNELS
                
                let userId = (PFUser.current()?.objectId)! as String
                
                var userIdArray = [String]()
                userIdArray.append(userId)                
                
                for user in gamvesUsers
                {
                    userIdArray.append(user.userId)
                }         

                var chatIdStr = String(chatId) as String             
                
                self.addChannels(userIds:userIdArray, channel: chatIdStr, completionHandlerChannel: { ( resutl ) -> () in
                    
                    if resutl
                    {                        
                        
                        completionHandler(resutl)
                        
                    } else
                    {
                        completionHandler(false)
                    }
                    
                })
            }
        })

    }

    static func addChannels(userIds:[String], channel:String, completionHandlerChannel : @escaping (_ resutl:Bool) -> ())
    {
        
        var method = String()
        
        let users:AnyObject
        
        if userIds.count > 1
        {
            method = "subscribeUsersToChannel"
            users = userIds as AnyObject
        } else
        {
            method = "subscribeUserToChannel"
            users = userIds[0] as String as AnyObject
        }
        
        let params = ["userIds":users, "channel":channel] as [String : Any]
        
        PFCloud.callFunction(inBackground: method, withParameters: params) { (resutls, error) in
            
            if error != nil
            {
                
                UIAlertController(title:"Error", message:
                    error as? String, preferredStyle: .actionSheet)
                
                
                completionHandlerChannel(false)
                
            } else
            {
                completionHandlerChannel(true)
            }
        }
    }

    func getchatIdByUserId()
    {




    }
    
}
