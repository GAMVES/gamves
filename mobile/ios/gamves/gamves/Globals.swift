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
    
    static var userTypes = Dictionary<Int, UserTypeGamves>()
    
    static var levels = Dictionary<String, LevelsGamves>()
    
    static var localWs = "wss://192.168.16.22:1337/1/"
    static var remoteWs = "wss://pg-app-z97yidopqq2qcec1uhl3fy92cj6zvb.scalabl.cloud/1/"
    
    static var defaults = UserDefaults.standard

    static var gamves_official = "gamves_official"
    
    static var api_key = "AIzaSyAMu_C1z2pMYGOgRi3dOiqCTh6pVGS59YU"
    
    static var api_image_base = "https://www.youtube.com/oembed?url=http://www.youtube.com/watch?v="
    static var api_image_format = "&format=json"
    
    static var api_desc_base = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id="
    static var api_desc_middle = "&fields=items/snippet/title,items/snippet/description&key="
    
    
    static var api_suggestion_base = "https://suggestqueries.google.com/complete/search?hl=en&ds=yt&client=youtube&hjson=t&cp=1&q="
    static var api_suggestion_mid = "&key="
    static var api_suggestion_close = "=5&alt=json"
    
    
    static var admin_delimitator:String = "---is_admin_chat---"
    
    static var key_you_spouse_chat_id = "you_spouse_chat_id"
    static var key_you_son_chat_id = "you_son_chat_id"
    static var key_you_spouse_son_chat_id = "you_spouse_son_chat_id"
    
    //Notifications
    static var notificationKeyFamilyLoaded  = "com.gamves.gamvesparent.familyLoaded"
    static var notificationKeyChatFeed      = "com.gamves.gamvesparent.chatfeed"
    static var notificationKeyLoggedin      = "com.gamves.gamvesparent.loggedin"
    static var notificationKeyCloseVideo    = "com.gamves.gamves.closeVideo"
    static var notificationKeyLevelsLoaded  = "com.gamves.gamvesparent.levelsLoaded"
        
    static var REGISTER_MOTHER  = 0
    static var SPOUSE_MOTHER    = 1
    static var SON              = 2
    static var DAUGHTER         = 3
    static var SPOUSE_FATHER    = 4
    static var REGISTER_FATHER  = 5
    
    static var keySpouse = "spousePhotoImage"
    static var keyYour = "yourPhotoImage"
    static var keySon = "sonPhotoImage"
    
    static var keySpouseSmall   = String()
    static var keyYourSmall     = String()
    static var keySonSmall      = String()
    
    static var badgeNumber = Bool()
    
    static var userDictionary = Dictionary<String, GamvesParseUser>()
    
    static var gamvesFamily = GamvesFamily()
    
    static var familyLoaded = Bool()
    static var chatFeedLoaded = Bool()
    
    static var chatVideos = Dictionary<Int, VideoGamves>()
    
    static var hasNewFeed = Bool()
    
    //static var categories_gamves  = [CategoryGamves]()
    
    static var categories_gamves = Dictionary<Int, CategoryGamves>()
    
    static func sortCategoryByOrder()
    {
        self.categories_gamves.sorted(by: {$0.value.order > $1.value.order })
    }

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
            
            var registered = Bool()
            
            if user["isRegister"] != nil {
                registered = user["isRegister"] as! Bool
            }
            
            gamvesUser.isRegister = registered
            
            
            gamvesUser.userName = user["username"] as! String
            
            if user.email != nil {
                gamvesUser.email = user.email!
            }
            
            if user["status"] != nil
            {
                gamvesUser.status = user["status"] as! String
            }
            
            if PFUser.current()?.objectId == userId
            {
                gamvesUser.isSender = true
            }
            
            gamvesUser.userObj = user
            
            if user["pictureSmall"] != nil
            {
                
                let picture = user["pictureSmall"] as! PFFile
                
                picture.getDataInBackground(block: { (data, error) in
                    
                    if (error != nil) {
                        print(error)
                    } else {
                        
                        let image = UIImage(data: data!)
                        gamvesUser.avatar = image!
                        gamvesUser.isAvatarDownloaded = true
                        gamvesUser.isAvatarQuened = false
                        
                        var typeNumber = user["iDUserType"] as! Int
                        print(gamvesUser.firstName)
                        
                        gamvesUser.typeNumber = typeNumber
                        gamvesUser.typeObj = Global.userTypes[typeNumber]?.userTypeObj  //Global.getUserTypeObjById(id: typeNumber)
                        
                        print(gamvesUser.typeNumber)
                        
                        if isFamily {
                            
                            var gender = GamvesGender()
                            
                            if typeNumber == Global.REGISTER_MOTHER || typeNumber == Global.SPOUSE_FATHER
                            {
                                if typeNumber == Global.REGISTER_MOTHER {
                                    
                                    gender.female = true
                                } else if typeNumber == Global.SPOUSE_FATHER {
                                    
                                    gender.male = true
                                }
                                
                                gamvesUser.gender = gender
                                
                                adduserToFamilyFromGlobal(gamvesUser: gamvesUser)
                                
                                
                            } else if typeNumber == Global.SPOUSE_MOTHER || typeNumber == Global.REGISTER_FATHER
                            {
                                if typeNumber == Global.SPOUSE_MOTHER {
                                    
                                    gender.female = true
                                } else if typeNumber == Global.REGISTER_FATHER {
                                    
                                    gender.male = true
                                }
                                
                                gamvesUser.gender = gender
                                
                                adduserToFamilyFromGlobal(gamvesUser: gamvesUser)
                                
                                
                            } else if typeNumber == Global.SON || typeNumber == Global.DAUGHTER {
                                
                                if typeNumber == Global.SON {
                                    
                                    gender.male = true
                                } else if typeNumber == Global.DAUGHTER {
                                    gender.male = false
                                }
                                
                                gamvesUser.gender = gender
                                
                                if user["levelObjId"] != nil {
                                    
                                    let levelId = user["levelObjId"] as! String
                                    
                                    print(levelId)
                                    
                                    let levelGamves = Global.levels[levelId]
                                    
                                    print(levelGamves)
                                    
                                    gamvesUser.levelNumber = (levelGamves?.grade)!
                                    gamvesUser.levelDescription = (levelGamves?.description)!
                                    gamvesUser.levelId = levelId
                                    
                                }
                                
                                adduserToFamilyFromGlobal(gamvesUser: gamvesUser)
                                
                                completionHandler(gamvesUser)
                                
                                
                            }
                        }
                        
                        if typeNumber != Global.SON || typeNumber != Global.DAUGHTER {
                            
                            completionHandler(gamvesUser)
                        }
                    }
                })
            }
            
        } else {
            
            completionHandler(self.userDictionary[userId]!)
        }
    }
    
    static func adduserToFamilyFromGlobal(gamvesUser : GamvesParseUser){
        
        if let myId = PFUser.current()?.objectId {
            
            if myId == gamvesUser.userId {
                
                Global.gamvesFamily.youUser = gamvesUser
                Global.gamvesFamily.sonsUsers.append(gamvesUser)
                Global.gamvesFamily.levels.append(self.levels[gamvesUser.levelId]!)
                
            } else if gamvesUser.typeNumber == Global.REGISTER_MOTHER ||  gamvesUser.typeNumber == Global.REGISTER_FATHER {
                
                Global.gamvesFamily.registerUser = gamvesUser
                
            } else if gamvesUser.typeNumber == Global.SPOUSE_FATHER ||  gamvesUser.typeNumber == Global.SPOUSE_MOTHER {
                
                Global.gamvesFamily.spouseUser = gamvesUser
            }
            
        }
        
        self.userDictionary[gamvesUser.userId] = gamvesUser
        
    }
    
    static func loadUserTypes()
    {
        let queryLevel = PFQuery(className:"UserType")
        queryLevel.findObjectsInBackground { (userTypeObjects, error) in
            
            if error != nil
            {
                
                print("error")
                
            } else
            {
                
                if let userTypeObjects = userTypeObjects
                {
                    var countUserTypes = userTypeObjects.count
                    
                    print(countUserTypes)
                    
                    for userType in userTypeObjects {
                        
                        let userTypeGamves = UserTypeGamves()
                        userTypeGamves.description = userType["description"] as! String
                        let type = userType["idUserType"] as! Int
                        userTypeGamves.idUserType = type
                        userTypeGamves.userTypeObj = userType
                        
                        self.userTypes[type] = userTypeGamves
                        
                    }
                }
            }
        }
    }
   
    
    /*static func addUserToDictionary(user: PFUser, isFamily:Bool, completionHandler : @escaping (_ resutl:GamvesParseUser) -> ())
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
                                    
                                    var typeNumber = user["iDUserType"] as! Int
                                    
                                    print(gamvesUser.firstName)
                                    
                                    gamvesUser.typeNumber = typeNumber
                                    
                                    if user["isRegister"] != nil {
                                    
                                        let register = user["isRegister"] as! Bool
                                        gamvesUser.isRegister = register
                                        
                                    }
                                    
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
    }*/
    
    
    
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
    
    static func isKeyPresentInUserDefaults(key: String) -> Bool
    {
        return UserDefaults.standard.object(forKey: key) != nil
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

    static func alertWithTitle(viewController: UIViewController, title: String!, message: String, toFocus:UITextField?)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in
            
            if toFocus != nil
            {
                toFocus?.becomeFirstResponder()
            }
            
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
    
    static func loaLevels() {
        
        let queryLevel = PFQuery(className:"Level")
        queryLevel.order(byAscending: "order")
        queryLevel.findObjectsInBackground { (levelObjects, error) in
            
            if error != nil {
                print("error")
            } else {
                
                if let levelObjects = levelObjects {
                    
                    var countLevels = levelObjects.count
                    
                    var count = 0
                    
                    for level in levelObjects {
                        
                        let levelGamves = LevelsGamves()
                        levelGamves.description = level["description"] as! String
                        levelGamves.grade = level["grade"] as! Int
                        
                        let full = "\(levelGamves.grade) - \(levelGamves.description)"
                        
                        print(full)
                        
                        levelGamves.fullDesc = full
                        levelGamves.objectId = level.objectId!
                        levelGamves.levelObj = level
                        
                        self.levels[level.objectId!] = levelGamves
                        
                        if (countLevels-1)  == count {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyLevelsLoaded), object: self)
                        }
                        count = count + 1
                        
                    }
                }
            }
        }
    }
    
    static func getFamilyData(completionHandler : @escaping (_ resutl:Bool) -> ())
    {
        self.keySpouseSmall   = "\(self.keySpouse)Small"
        self.keyYourSmall     = "\(self.keyYour)Small"
        self.keySonSmall      = "\(self.keySon)Small"
        
        let familyQuery = PFQuery(className:"Family")
        familyQuery.whereKey("members", equalTo: PFUser.current())
        if !Global.hasDateChanged() {
            familyQuery.cachePolicy = .cacheElseNetwork
        }
        familyQuery.findObjectsInBackground(block: { (families, error) in
            
            if error == nil
            {
                for family in families!
                {
                    print(family)
                    
                    self.gamvesFamily.familyName = family["description"] as! String
                    self.gamvesFamily.familyChatId = family["familyChatId"] as! Int           
                    
                    if family["sonRegisterChatId"] != nil {
                       self.gamvesFamily.sonRegisterChatId  = family["sonRegisterChatId"] as! Int
                    }
                    
                    print(self.gamvesFamily.sonRegisterChatId)
                    
                    if family["sonSpouseChatId"] != nil {
                        self.gamvesFamily.sonSpouseChatId = family["sonSpouseChatId"] as! Int
                    }
                    
                    print(self.gamvesFamily.sonSpouseChatId)
                    
                    self.gamvesFamily.objectId = family.objectId!
                    
                    let picture = family["picture"] as! PFFile
                    
                    picture.getDataInBackground(block: { (data, error) in
                        
                        if (error != nil)
                        {
                            print(error)
                        } else
                        {
                            
                            let imageFamily = UIImage(data: data!)
                            
                            self.gamvesFamily.familyImage = imageFamily!
                            
                            let membersRelation = family.relation(forKey: "members") as PFRelation
                            
                            let queryMembers = membersRelation.query()
                            
                            queryMembers.findObjectsInBackground(block: { (members, error) in
                                
                                if error == nil
                                {
                                    var memberCount = members?.count
                                    var count = 0
                                    
                                    for member in members!
                                    {
                                        
                                        DispatchQueue.main.async
                                            {
                                                
                                                self.addUserToDictionary(user: member as! PFUser, isFamily: true, completionHandler: { ( gamvesUser ) -> () in
                                                    
                                                    print(gamvesUser.userName)
                                                    
                                                    if count == (memberCount!-1)
                                                    {
                                                        completionHandler(true)
                                                        
                                                        NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: self)
                                                    }
                                                    count = count + 1
                                                })
                                        }
                                    }
                                }
                            })
                            
                            let schoolRelation = family.relation(forKey: "school") as PFRelation
                            
                            let querySchool = schoolRelation.query()
                            
                            querySchool.findObjectsInBackground(block: { (schools, error) in
                                
                                if error == nil
                                {
                                    for school in schools!
                                    {
                                        self.gamvesFamily.school = school["name"] as! String
                                    }
                                }
                            })
                            
                            
                            
                        }
                    })
                }
            } else {
                print(error)
            }
        })
        
    }

    
    /*static func getFamilyData()
    {
        
        DispatchQueue.global().async {
            
            let familyQuery = PFQuery(className:"Family")
            familyQuery.whereKey("members", equalTo: PFUser.current())
            
            print(familyQuery.cachePolicy.hashValue)
            
            if !Global.hasDateChanged()
            {
                familyQuery.cachePolicy = .cacheThenNetwork
            }
            familyQuery.findObjectsInBackground(block: { (families, error) in
                
                if error == nil
                {
                    
                    for family in families!
                    {
                        
                        Global.gamvesFamily.familyName = family["description"] as! String
                        
                        let membersRelation = family.relation(forKey: "members") as PFRelation
                        
                        let queryMembers = membersRelation.query()
                        
                        queryMembers.findObjectsInBackground(block: { (members, error) in
                            
                            if error == nil
                            {
                                for member in members!
                                {
                                    Global.addUserToDictionary(user: member as! PFUser, isFamily: true, completionHandler: { ( gamvesUser ) -> () in
                                        
                                        Global.userDictionary[gamvesUser.userId] = gamvesUser
                                    })
                                }
                            }
                        })
                        
                        let schoolRelation = family.relation(forKey: "school") as PFRelation
                        
                        let querySchool = schoolRelation.query()
                        
                        querySchool.findObjectsInBackground(block: { (schools, error) in
                            
                            if error == nil
                            {
                                for school in schools!
                                {
                                    Global.gamvesFamily.school = school["name"] as! String
                                }
                            }
                        })
                    }
                }
            })
        }
    }*/
    
    
    static func updateUserOnline(online : Bool)
    {
        let queryOnine = PFQuery(className:"UserOnline")
        queryOnine.whereKey("userId", equalTo: PFUser.current()?.objectId)
        queryOnine.findObjectsInBackground { (usersOnline, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                if (usersOnline?.count)!>0
                {
                    for userOnline in usersOnline!
                    {
                        userOnline["isOnline"] = online
                        
                        userOnline.saveInBackground(block: { (resutl, error) in
                            print("saved")
                        })
                        
                    }
                    
                } else
                {
                    let userOnline = PFObject(className: "UserOnline")
                    userOnline["userId"] = PFUser.current()?.objectId
                    userOnline["isOnline"] = online
                    
                    userOnline.saveInBackground(block: { (resutl, error) in
                        print("saved")
                    })
                    
                }
                
            }
        }
        
    }

}








