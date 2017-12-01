//
//  Objects.swift
//  gamvescommunity
//
//  Created by Jose Vigil on 5/30/17.
//  Copyright © 2017 Jose Vigil. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import PopupDialog

class Global: NSObject
{
    static var admin_delimitator:String = "---is_admin_chat---"
    
    static var key_you_spouse_chat_id = "you_spouse_chat_id"
    static var key_you_son_chat_id = "you_son_chat_id"
    static var key_you_spouse_son_chat_id = "you_spouse_son_chat_id"
    
    //Notifications
    static var notificationKeyFamilyLoaded  = "com.gamves.gamvesparent.familyLoaded"
    static var notificationKeyChatFeed      = "com.gamves.gamvesparent.chatfeed"
    static var notificationKeyLoggedin      = "com.gamves.gamvesparent.loggedin"
    
    static var badgeNumber = Bool()
    
    static var userDictionary = Dictionary<String, GamvesParseUser>()
    
    static var gamvesFamily = GamvesFamily()
    
    static var chatVideos = Dictionary<Int, VideoGamves>()
    
    static var hasNewFeed = Bool()   

    //Bool to foce download and skip chache. 
    static var forceFromNetworkCache = Bool()
   
    
    static func addUserToDictionary(user: PFUser, isFamily:Bool, completionHandler : @escaping (_ resutl:GamvesParseUser) -> ())
    {
        let userId = user.objectId!
        
        if self.userDictionary[userId] == nil
        {
            
            let gamvesUser = GamvesParseUser()
            
            gamvesUser.name = user["Name"] as! String
            gamvesUser.userId = user.objectId!
            
            gamvesUser.firstName = user["firstName"] as! String
            gamvesUser.lastName = user["lastName"] as! String
            
            gamvesUser.userName = user["username"] as! String
            
            //gamvesUser.email = user.email!
            
            if user["status"] != nil
            {
                gamvesUser.status = user["status"] as! String
            }
            
            if PFUser.current()?.objectId == userId
            {
                gamvesUser.isSender = true
            }
            
            gamvesUser.gamvesUser = user
            
            let levelRelation = user.relation(forKey: "level") as PFRelation
            
            let queryLevel = levelRelation.query()
            
            queryLevel.findObjectsInBackground(block: { (levels, error) in
                
                if error == nil
                {
                    let countLevels = levels?.count
                    var count = 0
                    
                    for level in levels!
                    {
                        gamvesUser.levelNumber = level["grade"] as! Int
                        gamvesUser.levelDescription = level["description"] as! String
                        
                        if user["pictureSmall"] != nil
                        {
                            
                            let picture = user["pictureSmall"] as! PFFile
                            
                            picture.getDataInBackground(block: { (data, error) in
                                
                                if (error != nil)
                                {
                                    print(error)
                                } else
                                {
                                    
                                    let image = UIImage(data: data!)
                                    gamvesUser.avatar = image!
                                    gamvesUser.isAvatarDownloaded = true
                                    gamvesUser.isAvatarQuened = false
                                    
                                    var typeNumber = user["userType"] as! Int
                                    
                                    print(gamvesUser.firstName)
                                    
                                    gamvesUser.typeNumber = typeNumber
                                    
                                    print(gamvesUser.typeNumber)
                                    
                                    //No me interesa
                                    //gamvesUser.typeDescription = user["description"] as! String
                                    
                                    if isFamily
                                    {
                                        var gender = GamvesGender()
                                        
                                        if typeNumber == 0 || typeNumber == 4
                                        {
                                            if typeNumber == 0
                                            {
                                                gender.female = true
                                            } else if typeNumber == 4
                                            {
                                                gender.male = true
                                            }
                                            gamvesUser.gender = gender
                                            
                                            Global.gamvesFamily.youUser = gamvesUser
                                            
                                        } else if typeNumber == 1 || typeNumber == 5
                                        {
                                            if typeNumber == 1
                                            {
                                                gender.female = true
                                            } else if typeNumber == 5
                                            {
                                                gender.male = true
                                            }
                                            
                                            gamvesUser.gender = gender
                                            
                                            Global.gamvesFamily.spouseUser = gamvesUser
                                            
                                        } else if typeNumber == 2 || typeNumber == 3
                                        {
                                            
                                            if typeNumber == 2
                                            {
                                                gender.male = true
                                            } else if typeNumber == 3
                                            {
                                                gender.male = false
                                            }
                                            gamvesUser.gender = gender
                                            
                                            Global.gamvesFamily.sonsUsers.append(gamvesUser)
                                        }
                                    }
                                    
                                    if count == (countLevels!-1)
                                    {
                                        
                                        self.userDictionary[userId] = gamvesUser
                                        
                                        completionHandler(gamvesUser)
                                        
                                    }
                                    
                                    count = count + 1
                                    
                                }
                                
                            })
                        }
                    }
                }
            })
            
        } else {
            
            completionHandler(self.userDictionary[userId]!)
        }
    }
    
    static func getImageVideo(videothumburl: String, video:VideoGamves, completionHandler : (_ video:VideoGamves) -> Void)
    {
        
        if let vurl = URL(string: videothumburl)
        {
            
            if let data = try? Data(contentsOf: vurl)
            {
                video.thum_image = UIImage(data: data)!
                
                completionHandler(video)
            }
        }
    }
    
    static func setTitle(title:String, subtitle:String) -> UIView
    {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-2, width:0, height:0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        //titleLabel.textAlignment = .left
        titleLabel.sizeToFit()
        titleLabel.tag = 0
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        //subtitleLabel.textAlignment = .left
        subtitleLabel.sizeToFit()
        subtitleLabel.tag = 1
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width:max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height:30))
        
        //let titleView = UIView(frame: CGRect(x:0, y:0, width:250, height:30))
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        //titleView.backgroundColor = UIColor.blue
        
        return titleView
    }
    
    static func parseUsersStringToArray(separated: String) -> [String]
    {
        var feed = separated
        
        feed = feed.replacingOccurrences(of: "[", with: "")
        feed = feed.replacingOccurrences(of: "]", with: "")
        feed = feed.replacingOccurrences(of: "\\", with: "")
        feed = feed.replacingOccurrences(of: "\"", with: "")
        feed = feed.replacingOccurrences(of: " ", with: "")
        
        return feed.components(separatedBy:",")
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
    
    static func registerInstallationAndRole()
    {
        if let user = PFUser.current()
        {
            
            let installation = PFInstallation.current()
            installation?["user"] = PFUser.current()
            installation?.saveInBackground(block: { (resutl, error) in
                
                //PFPush.subscribeToChannel(inBackground: "Gamves")
                
                var queryRole = PFRole.query() // You need to get role object
                queryRole?.whereKey("name", equalTo:"admin")
                
                queryRole?.getFirstObjectInBackground(block: { (role, error) in
                    
                    
                    if error == nil
                    {
                        
                        let roleQuery = PFRole.query()
                        
                        roleQuery?.whereKey("name", equalTo: "admin")
                        
                        roleQuery?.getFirstObjectInBackground(block: { (role, error) in
                            
                            if error == nil
                            {
                                let admin = role as! PFRole
                                
                                let acl = PFACL(user: PFUser.current()!)
                                
                                acl.setWriteAccess(true, for: admin)
                                acl.setReadAccess(true, for: admin)
                                
                                admin.users.add(PFUser.current()!)
                                
                                admin.saveInBackground(block: { (resutl, error) in
                                    
                                    print("")
                                    
                                })
                            }
                        })
                    }
                })
            })
        }
    }
    
    
    static func setActivityIndicator(container: UIView, type: Int, color:UIColor) -> NVActivityIndicatorView
    {
        
        var aiView:NVActivityIndicatorView?
        
        if aiView == nil
        {
            aiView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60.0, height: 60.0), type: NVActivityIndicatorType(rawValue: type), color: color, padding: 0.0)
            
            // add subview
            container.addSubview(aiView!)
            // autoresizing mask
            aiView?.translatesAutoresizingMaskIntoConstraints = false
            // constraints
            container.addConstraint(NSLayoutConstraint(item: aiView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
            container.addConstraint(NSLayoutConstraint(item: aiView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        }
        
        return aiView!
    }
    
    static func buildPopup(viewController: UIViewController, params: [String:Any] ) -> PopupDialog
    {
        
        // Prepare the popup assets
        let title = params["title"] //"THIS IS THE DIALOG TITLE"
        let message = params["message"] //"This is the message section of the popup dialog default view"
        
        var image = UIImage()
        
        if params["image"] != nil
        {
            image = UIImage(named: params["image"] as! String)!
        }
        
        // Create the dialog
        let popup = PopupDialog(title: title as! String, message: message as! String, image: image)
        
        if params["buttons"] != nil
        {
            let buttons = params["buttons"] as! [DefaultButton]
            
            for button in buttons
            {
                popup.addButton(button)
            }
        }
        
        // Create buttons
        /*let buttonOne = CancelButton(title: "CANCEL")
        {
            print("You canceled the car dialog.")
        }
        
        let buttonTwo = DefaultButton(title: "ADMIRE CAR")
        {
            print("What a beauty!")
        }
        
        let buttonThree = DefaultButton(title: "BUY CAR", height: 60)
        {
            print("Ah, maybe next time :)")
        }
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo, buttonThree])*/
        
        // Present dialog
        viewController.present(popup, animated: true, completion: nil)
        
        return popup
        
    }
    
    static func createCircularLabel(text: String, size: CGFloat, fontSize: CGFloat, borderWidth: CGFloat, color: UIColor) -> UILabel
    {
        let mSize:CGFloat = size
        
        let countLabel = UILabel(frame: CGRect(x : 0.0,y : 0.0, width : mSize, height :  mSize))
        countLabel.text = text
        countLabel.textColor = UIColor.white
        countLabel.textAlignment = .center
        
        countLabel.font = UIFont.systemFont(ofSize: fontSize)
        countLabel.layer.cornerRadius = size / 2
        countLabel.layer.borderWidth = borderWidth //3.0
        countLabel.layer.masksToBounds = true
        countLabel.layer.backgroundColor = color.cgColor //UIColor.orange.cgColor
        countLabel.layer.borderColor = UIColor.white.cgColor
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return countLabel
    }
    
    static func setRoundedImage(image: UIImageView, cornerRadius : Int, boderWidth: CGFloat, boderColor: UIColor)
    {
        image.layer.borderWidth = boderWidth
        image.layer.masksToBounds = false
        image.layer.borderColor = boderColor.cgColor
        //let radius:CGFloat = image.frame.size.height/2
        image.layer.cornerRadius = CGFloat(cornerRadius)
        image.clipsToBounds = true
    }
    
    static func loadBargesNumberForUser(completionHandler : @escaping (_ resutl:Int) -> ())
    {
        
        let queryBadges = PFQuery(className:"Badges")
        
        if let userId = PFUser.current()?.objectId
        {
            queryBadges.whereKey("userId", equalTo: userId)
        }
        queryBadges.findObjectsInBackground { (badges, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                if let badges = badges
                {
                    
                    let badgesAmount = badges.count
                    
                    if badgesAmount > 0
                    {
                        
                        var count = Int()
                        
                        for badge in badges
                        {
                            
                            let amount = badge["amount"] as! Int
                            
                            count = count + amount
                        }
                        
                        completionHandler(count)
                        
                    } else
                    {
                        completionHandler(0)
                    }
                    
                }
            }
        }
    }

    static func getRandomInt() -> Int {
        var randomNumber: Int = 0
        withUnsafeMutablePointer(to: &randomNumber, { (randomNumberPointer) -> Void in
            _ = randomNumberPointer.withMemoryRebound(to: UInt8.self, capacity: 1, { SecRandomCopyBytes(kSecRandomDefault, 2, $0) })
        })
        return abs(randomNumber)
    }
    
    static func getParticipants(chatFeedObj : PFObject, chatfeed : ChatFeed, isVideoChat: Bool, chatId : Int, completionHandler : @escaping (_ resutl:ChatFeed) -> ())
    {
        
        var members = chatFeedObj["members"] as! String
        
        let participantQuery = PFQuery(className:"_User")
        participantQuery.whereKey("objectId", containedIn: self.parseUsersStringToArray(separated: members))
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
                        
                        if self.userDictionary[user.objectId!] != nil
                        {
                            self.userDictionary[user.objectId!]?.chatId = chatId
                        }
                    }
                    
                    self.addUserToDictionary(user: user as! PFUser, isFamily: false, completionHandler: { ( gamvesUser ) -> () in
                        
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
    
    static func getBadges(chatId:Int, completionHandler : @escaping (_ resutl:Int) -> ())
    {
        
        let badgesQuery = PFQuery(className:"Badges")
        
        if let userId = PFUser.current()?.objectId
        {
            badgesQuery.whereKey("userId", equalTo: userId)
        }
        badgesQuery.whereKey("chatId", equalTo: chatId)
        badgesQuery.findObjectsInBackground(block: { (badges, error) in
            
            if error == nil
            {
                
                let badgesUsers = badges?.count
                
                var counter = Int()
                
                for badge in badges!
                {
                    let amount = badge["amount"] as! Int
                    counter = counter + amount
                }
                
                completionHandler(counter)
                
            }
        })
        
    }
    
    static func alertWithTitle(viewController: UIViewController, title: String!, message: String, toFocus:UITextField) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            toFocus.becomeFirstResponder()
        });
        alert.addAction(action)
        viewController.present(alert, animated: true, completion:nil)
    }

    static func hasDateChanged() -> Bool
    {
        let last_day = "last_day";

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        let dateString = formatter.string(from: date)
        let defaults = UserDefaults.standard
        let changedDate = defaults.object(forKey: last_day) as? String
        
        var has = Bool()
        if dateString != changedDate
        {   
            has = true          
        }
        else
        {
            has = false
        }

        if  forceFromNetworkCache
        {
            has = true
        }
        
        defaults.set(dateString, forKey: last_day)

        return has

    }

}








