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
 
    static func addNewFeedAppendgroup(gamvesUsers:[GamvesUser], chatId:Int, type:Int,  completionHandlerGroup : @escaping (_ resutl:Bool) -> ())
    {
        
        let random = Int()
            
        var chatFeed = PFObject(className: "ChatFeed")
        
        chatFeed["chatId"] = chatId
        
        chatFeed["isVideoChat"] = false

        chatFeed["type"] = type

        let date = Date()

        let calendar = Calendar.current        

        let minutes = calendar.component(.minute, from: date)

        let seconds = calendar.component(.second, from: date)        

        let strMinutes = String(format: "%02d", minutes)

        let strSeconds = String(format: "%02d", seconds)                   

        chatFeed["time"] = "\(strMinutes):\(strSeconds)"

        let groupImageFile:PFFileObject!

        if gamvesUsers.count > 2
        {

            var imageGroup = UIImage()
            
            if chatId == Global.gamvesFamily.familyChatId
            {
                imageGroup = Global.gamvesFamily.familyImage
            } else
            {
                imageGroup = UIImage(named: "community")!
                
            }
            
            groupImageFile = PFFileObject(data: UIImageJPEGRepresentation(imageGroup, 1.0)!)
            
            var array = [String]()
            
            for gamvesUser in gamvesUsers
            {
                let userObjectId = gamvesUser.userId
                print(userObjectId)
                array.append(userObjectId)
            }
            let members = String(describing: array)
            chatFeed["members"] = members

            chatFeed["room"] = Global.gamvesFamily.familyName
            
        } else
        {
    
            groupImageFile = PFFileObject(data: UIImageJPEGRepresentation(gamvesUsers[1].avatar, 1.0)!)          
            
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

        var message = "---is_admin_chat---New chat with \(chatMembers)"      
        
        chatFeed["lastMessage"] = message


        let randomColorIndex = Int(arc4random_uniform(UInt32(Global.listOfChatColors.count))) 

        let colorString = Global.listOfChatColors[randomColorIndex]

        chatFeed["senderColor"] = colorString
        
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
                    
                    if resutl {                        
                        
                        ChatMethods.sendMessage(sendPush: false, chatId: chatId, text: message, textField: nil, completionHandlerMessage: { ( resutl:Bool ) -> () in
                            
                            if resutl {
                                completionHandlerGroup(true)
                            } else {
                                completionHandlerGroup(false)
                            }
                            
                        })

                    } else {
                        completionHandlerGroup(false)
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

    static func sendMessage(sendPush:Bool, chatId:Int, text:String, textField:UITextField?, completionHandlerMessage : @escaping (_ resutl:Bool) -> ())
    {
        print(text)
        
        let messagePF: PFObject = PFObject(className: "ChatVideo")
        
        var userId = String()
        
        var textMessage = String()
        
        if PFUser.current() != nil
        {
            userId = (PFUser.current()?.objectId)!
            messagePF["userId"] = userId
        }
        
        messagePF["chatId"] = chatId
        
        messagePF["message"] = text

        if let puserId = PFUser.current()?.objectId
        {        
            UserDefaults.standard.set(text, forKey: "\(puserId)_last_message")
        }
        
        var message = text
        
        messagePF.saveInBackground { (resutl, error) in
            
            if error == nil
            {
                
                if textField != nil
                {
                    textField?.text = ""
                }
                
                if sendPush
                {
                    self.sendPushWithCoud(message: message, chatId: chatId)
                }
                
                completionHandlerMessage(true)
                
            } else
            {
                completionHandlerMessage(false)
            }
        }

    }

    static func sendPushWithCoud(message: String, chatId:Int)
    {
        
        if var username = Global.userDictionary[(PFUser.current()?.objectId)!]?.name
        {

            if let puserId = PFUser.current()?.objectId
            {
                
                if let name = UserDefaults.standard.object(forKey: "\(puserId)_last_message")
                {
                    
                    let jsonObject: [String: Any] = [ "message": "\(message)", "chatId": "\(chatId)" ]
                    
                    let valid = JSONSerialization.isValidJSONObject(jsonObject)
                    
                    if valid
                    {
                
                        let params = ["channels": String(chatId), "title": "\(username)", "alert": "\(name)", "data":jsonObject] as [String : Any]
                        
                        print(params)
                        
                        PFCloud.callFunction(inBackground: "push", withParameters: params) { (resutls, error) in
                         
                            print(resutls)
                        }
                    }
                }
                
            }
        }
    }    
    
}
