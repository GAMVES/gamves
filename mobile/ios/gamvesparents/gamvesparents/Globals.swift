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
import TaskQueue

class Global: NSObject
{

    static var adminUser = GamvesUser()

    static var listOfSwearWords = [String]()

    static func setBadWordsArray(words: String)
    {
        self.listOfSwearWords = words.split(separator: "|").map(String.init)
        
        print(listOfSwearWords)
    }

    static var listOfChatColors = [String]()

    static func setChatColorsArray(colors: String)
    {
        self.listOfChatColors = colors.split(separator: "|").map(String.init)
        
        print(listOfChatColors)
    }
    
    static var trends_stored = [GamvesTrendCategory]()
    
    static var pictureRecorded = GamvesPicture()
    static var audioRecorded = GamvesAudio()

    static var device = String()
    
    static var levels = Dictionary<String, GamvesLevel>()
    
    static var levelsLoaded = Bool()
    static var familyLoaded = Bool()
    
    static var familyDataGromGlobal = Bool()
    
    static var schools = Dictionary<String, GamvesSchools>() 

    static var serverUrl = "https://parseapi.back4app.com/"
    
    static var localWs = "wss://gamvesalpha.back4app.io"

    static var locationPF = PFGeoPoint()       
   
    static var userTypes = Dictionary<Int, UserTypeGamves>()
    
    static var youImageName = "youImage"
    static var youImageNameSmall = "youImageSmall"
    static var sonImageName = "sonImage"
    static var sonImageNameSmall = "sonImageSmall"
    static var spouseImageName = "spouseImage"
    static var spouseImageNameSmall = "spouseImageSmall"
    static var familyImageName = "familyImage"
    static var familyImageNameSmall = "familyImageSmall"
    
    static func getTypeDescById(id:Int) -> String {
        let descType = userTypes[id]?.description
        return descType!
    }
    
    static var REGISTER_MOTHER  = 0
    static var SPOUSE_MOTHER    = 1
    static var SON              = 2
    static var DAUGHTER         = 3
    static var SPOUSE_FATHER    = 4
    static var REGISTER_FATHER  = 5       
    
    static var approvals = Dictionary<Int, Approvals>()
    static var friendApproval = Dictionary<String, FriendApproval>()   
    static var friends = Dictionary<String, GamvesUser>() 
    static var histories = [HistoryGamves]()
    
    static var admin_delimitator:String = "---is_admin_chat---"
    static var audio_delimitator:String = "---is_audio_chat---"
    static var picture_delimitator:String = "---is_picture_chat---"

    static var defaults = UserDefaults.standard
    
    static var keySpouse = "spousePhotoImage"
    static var keyYour = "yourPhotoImage"
    static var keySon = "sonPhotoImage"

    static var key_you_spouse_chat_id = "you_spouse_chat_id"
    static var key_you_son_chat_id = "you_son_chat_id"
    static var key_you_spouse_son_chat_id = "you_spouse_son_chat_id"
    
    static var keySpouseSmall   = String() 
    static var keyYourSmall     = String() 
    static var keySonSmall      = String() 
    
    //Notifications
    static var notificationKeyFriendApprovalLoaded              = "com.gamves.gamvesparent.friendApprovalLoaded"
    static var notificationKeyFamilyLoaded              = "com.gamves.gamvesparent.familyLoaded"
    static var notificationKeyLevelsLoaded              = "com.gamves.gamvesparent.levelsLoaded"
    static var notificationKeyLoadDataAfterLogin        = "com.gamves.gamvesparent.loadDataAfterLogin"
    static var notificationKeyChatFeed                  = "com.gamves.gamvesparent.chatfeed"
    static var notificationYourAccountInfoLoaded        = "com.gamves.gamvesparent.notificationYourAccountInfoLoaded"
    static var notificationKeyLoadFamilyDataGromGlobal  = "com.gamves.gamvesparent.loadfamilydatagromglobal"
    static var notificationKeyLogOut                    = "com.gamves.gamvesparent.notificationLogOut"
    static var notificationKeyCloseVideo    = "com.gamves.gamves.closeVideo"
    
    static var badgeNumber = Bool()
    
    static var userDictionary = Dictionary<String, GamvesUser>()
    
    static var gamvesFamily = GamvesFamily()
    
    static var chatVideos = Dictionary<Int, GamvesVideo>()    
    
    static var hasNewFeed = Bool()
    
    static var yourAccountBackImage = UIImage()
    
    static var api_key = "AIzaSyAMu_C1z2pMYGOgRi3dOiqCTh6pVGS59YU"
    
    static var search_engine = "010975053378915722447:h2ob_fkvam0"
    
    static func addUserToDictionary(user: PFUser, isFamily:Bool, completionHandler : @escaping (_ resutl:GamvesUser) -> ())
    {
        var userId = user.objectId!
        
        print(user.username)
        
        if userId == PFUser.current()?.objectId {
            print(PFUser.current()?.username)
        }
        
        print(userId)
        
        if self.userDictionary[userId] == nil
        {
            
            let gamvesUser = GamvesUser()
            
            gamvesUser.name = user["Name"] as! String
            gamvesUser.userId = user.objectId!
            
            gamvesUser.firstName = user["firstName"] as! String
            gamvesUser.lastName = user["lastName"] as! String
            
            var registered = Bool()
            
            if user["isRegister"] != nil {
                registered = user["isRegister"] as! Bool
            }
            
            gamvesUser.isRegister = registered    

            if user["familyId"] != nil {
                gamvesUser.familyId = user["familyId"] as! String
            }        
            
            gamvesUser.userName = user["username"] as! String

            if user["schoolId"] != nil {
                
                let schoolId = user["schoolId"] as! String
                gamvesUser.schoolId = schoolId

                if Global.schools[schoolId] != nil {
                    gamvesUser.school = Global.schools[schoolId]!
                    if isFamily {
                        Global.gamvesFamily.school = gamvesUser.school
                    }
                }
            }
            
            if user["birthday"] != nil {
                gamvesUser.birthday = user["birthday"] as! String
            }

            if user["levelId"] != nil {
                let levelId = user["levelId"] as! String
                gamvesUser.levelId = levelId

                if Global.levels[levelId] != nil {
                    gamvesUser.level = Global.levels[levelId]!
                }
            }          
            
            print(user.email)
            
            if user.email != nil {
                
                gamvesUser.email = user.email!

            } else {
                
                gamvesUser.email = user["username"] as! String
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
                
                     self.getImage(gamvesUser: gamvesUser, file:picture, completionHandler: { ( userGamves, image ) -> () in
                
                        print(userGamves.name)
                        
                        userGamves.avatar = image
                        userGamves.isAvatarDownloaded = true
                        userGamves.isAvatarQuened = false
                        
                        var typeNumber = user["iDUserType"] as! Int
                        print(userGamves.firstName)
                        
                        userGamves.typeNumber = typeNumber
                        userGamves.typeObj = Global.userTypes[typeNumber]?.userTypeObj  //Global.getUserTypeObjById(id: typeNumber)
                        
                        print(userGamves.typeNumber)
                        
                        //if isFamily {
                            
                            var gender = GamvesGender()
                            
                            if typeNumber == Global.REGISTER_MOTHER || typeNumber == Global.SPOUSE_FATHER
                            {
                                if typeNumber == Global.REGISTER_MOTHER {
                                    
                                    gender.female = true
                                } else if typeNumber == Global.SPOUSE_FATHER {
                                    
                                    gender.male = true
                                }
                                
                                userGamves.gender = gender
                                
                                adduserToFamilyFromGlobal(gamvesUser: userGamves)
                                
                                
                            } else if typeNumber == Global.SPOUSE_MOTHER || typeNumber == Global.REGISTER_FATHER
                            {
                                if typeNumber == Global.SPOUSE_MOTHER {
                                    
                                    gender.female = true
                                } else if typeNumber == Global.REGISTER_FATHER {
                                    
                                    gender.male = true
                                }
                                
                                gamvesUser.gender = gender
                                
                                adduserToFamilyFromGlobal(gamvesUser: userGamves)
                                
                                
                            } else if typeNumber == Global.SON || typeNumber == Global.DAUGHTER {
                                
                                if typeNumber == Global.SON {
                                    
                                    gender.male = true
                                } else if typeNumber == Global.DAUGHTER {
                                    gender.male = false
                                }
                                
                                userGamves.gender = gender
                                
                                if user["levelId"] != nil {
                                
                                    let levelId = user["levelId"] as! String
                                    
                                    print(levelId)
                                    
                                    let levelGamves = Global.levels[levelId]
                                    
                                    print(levelGamves)
                                    
                                    userGamves.levelNumber = (levelGamves?.grade)!
                                    let description = (levelGamves?.description)!
                                    
                                    print(description)

                                    let full = "\(userGamves.levelNumber) - \(description)"
                                    
                                    userGamves.levelDescription = full
                                    userGamves.levelId = levelId
                                
                                }
                                
                                adduserToFamilyFromGlobal(gamvesUser: userGamves)
                                
                                completionHandler(userGamves)
                            
                            } else if  gamvesUser.userName == "gamvesadmin" {
                            
                                self.userDictionary[gamvesUser.userId] = gamvesUser
                                
                            }
                            
                        //}
                        
                        if typeNumber != Global.SON && typeNumber != Global.DAUGHTER {
                            
                            completionHandler(userGamves)
                        }
                    
                    })
                
                
            }
        
        } else {
            
            completionHandler(self.userDictionary[userId]!)
        }
    }
        
    static func adduserToFamilyFromGlobal(gamvesUser : GamvesUser){
        
        if let myId = PFUser.current()?.objectId {
            
            if myId == gamvesUser.userId {
                
                Global.gamvesFamily.youUser = gamvesUser
                
            } else if gamvesUser.typeNumber == Global.SON ||  gamvesUser.typeNumber == Global.DAUGHTER {
                
                Global.gamvesFamily.sonsUsers.append(gamvesUser)
                Global.gamvesFamily.levels.append(self.levels[gamvesUser.levelId]!)
                
            } else {
                
                Global.gamvesFamily.spouseUser = gamvesUser
            }
            
        }
        
        self.userDictionary[gamvesUser.userId] = gamvesUser

    }
    
    static func getImage(gamvesUser: GamvesUser, file:PFFile, completionHandler : @escaping (_ user:GamvesUser, _ image:UIImage) -> Void)
    {
        
        print(gamvesUser.name)
        
        file.getDataInBackground(block: { (data, error) in
            
            if (error != nil) {
                
                print(error)
                
            } else {
                
                let image = UIImage(data: data!)
                
                print(gamvesUser.name)
                
                completionHandler(gamvesUser, image!)
                
            }
            
        })
        
    }
    
    static func getImageVideo(videothumburl: String, video:GamvesVideo, completionHandler : (_ video:GamvesVideo) -> Void)
    {
        
        if let vurl = URL(string: videothumburl)
        {
            
            if let data = try? Data(contentsOf: vurl)
            {
                video.image = UIImage(data: data)!
                
                completionHandler(video)
            }
        }
    }

    static func loadAditionalData() {
        
        if PFUser.current() != nil {                       
            
            self.loadConfigData()           
            
        }
    }
    
    static func loadConfigData() {

        let configQuery = PFQuery(className:"Config")        
        configQuery.getFirstObjectInBackground(block: { (config, error) in
        
            if error == nil
            {   

                let badWords = config!["badWords"] as! String
                
                self.setBadWordsArray(words: badWords)   

                let colorsChat = config!["colorsChat"] as! String
                
                self.setChatColorsArray(colors: colorsChat)    
            }
        })

    }


    static func setTitle(title:String, subtitle:String) -> UIView
    {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-2, width:0, height:0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.tag = 0
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        subtitleLabel.tag = 1
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width:max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height:30))
        
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
        
        return titleView
    }

    static func containsSwearWord(text: String, swearWords: [String]) -> Bool {
        //print(swearWords)
        let searchText = text.lowercased()
        return swearWords.reduce(false) { $0 || searchText.contains($1.lowercased()) }
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
    
    static func registerInstallationAndRole(completionHandlerRole : @escaping (_ resutl:Bool) -> ())
    {
        if let user = PFUser.current()
        {
            
            let installation = PFInstallation.current()
            installation?["user"] = PFUser.current()
            installation?.saveInBackground(block: { (resutl, error) in
                
                PFPush.subscribeToChannel(inBackground: "GamvesChannel")
                
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
                                    
                                    if error != nil
                                    {
                                        completionHandlerRole(false)
                                    } else {
                                        completionHandlerRole(true)
                                    }
                                    
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
    
    
    static func setActivityIndicatorForChat(container: UIView, type: Int, color:UIColor, x:CGFloat, y:CGFloat, width: CGFloat, height:CGFloat) -> NVActivityIndicatorView
    {
        
        var aiView:NVActivityIndicatorView?
        
        if aiView == nil
        {
            aiView = NVActivityIndicatorView(frame: CGRect(x: x, y: y, width: width, height: height), type: NVActivityIndicatorType(rawValue: type), color: color, padding: 0.0)
            
            // add subview
            container.addSubview(aiView!)
            
            
            // autoresizing mask
            aiView?.translatesAutoresizingMaskIntoConstraints = false
            
            if x==0 && y==0 {
                
                // constraints
                container.addConstraint(NSLayoutConstraint(item: aiView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                
                container.addConstraint(NSLayoutConstraint(item: aiView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
                
            } else {
                
                let metricsNAV = ["x":x, "y":y, "width":width, "height":height ]
                
                container.addConstraintsWithFormat("H:|-x-[v0(width)]|", views: aiView!, metrics: metricsNAV)
                container.addConstraintsWithFormat("V:|-y-[v0(height)]|", views: aiView!, metrics: metricsNAV)
                
            }
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
   
    static func getBadges(chatId:Int, completionHandler : @escaping (_ resutl:Int) -> ()) {
        
        let badgesQuery = PFQuery(className:"Badges")
        
        if let userId = PFUser.current()?.objectId
        {
            badgesQuery.whereKey("userId", equalTo: userId)
        }
        badgesQuery.whereKey("chatId", equalTo: chatId)
        badgesQuery.findObjectsInBackground(block: { (badges, error) in
            
            if error == nil {
                
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
            
            if toFocus != nil {
                toFocus?.becomeFirstResponder()
            }

        });
        alert.addAction(action)
        viewController.present(alert, animated: true, completion:nil)
    }

    static func isValidEmail (test:String) ->Bool
    {
        // your email validation here...
        return true
    }
    
    
    static func getFamilyData(completionHandler : @escaping (_ resutl:Bool) -> ())
    {
        self.keySpouseSmall   = "\(self.keySpouse)Small"
        self.keyYourSmall     = "\(self.keyYour)Small"
        self.keySonSmall      = "\(self.keySon)Small"
        
        DispatchQueue.global().async {
            
            let familyQuery = PFQuery(className:"Family")
            familyQuery.whereKey("members", equalTo: PFUser.current())
            //familyQuery.cachePolicy = .cacheElseNetwork
            familyQuery.getFirstObjectInBackground(block: { (familyPF, error) in
                
                if error == nil {
                    
                    if let family = familyPF {
                        
                        self.gamvesFamily.familyName = family["description"] as! String
                        self.gamvesFamily.familyChatId = family["familyChatId"] as! Int
                        
                        self.gamvesFamily.sonRegisterChatId = family["sonRegisterChatId"] as! Int
                        self.gamvesFamily.spouseRegisterChatId = family["spouseRegisterChatId"] as! Int
                        self.gamvesFamily.objectId = family.objectId!                
                        
                        let picture = family["picture"] as! PFFile
                        
                        picture.getDataInBackground(block: { (data, error) in
                            
                            if (error != nil)
                            {
                                print(error)
                            } else {
                                
                                let imageFamily = UIImage(data: data!)
                                
                                self.gamvesFamily.familyImage = imageFamily!
                                
                                let membersRelation = family.relation(forKey: "members") as PFRelation
                                
                                let queryMembers = membersRelation.query()
                                
                                queryMembers.findObjectsInBackground(block: { (members, error) in
                                    
                                    if error == nil
                                    {
                                        var memberCount = members?.count
                                        var count = 0
                                        
                                        DispatchQueue.main.async {
                                        
                                                let queue = TaskQueue()
                                            
                                                queue.tasks += { result, next in
                                                    
                                                    self.addMembersToDictionary(members: members as! [PFUser], completionHandler: { ( gamvesUser ) -> () in
                                                        
                                                        next(nil)
                                                        
                                                    })
                                        
                                                }
                                        
                                                queue.run {
                                                    
                                                    NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: self)
                                                    
                                                    self.familyLoaded = true
                                                    
                                                    completionHandler(true)
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
                                            self.gamvesFamily.schoolName = school["name"] as! String

                                            self.gamvesFamily.schoolShort = school["short"] as! String                                       

                                            print(self.gamvesFamily.schoolShort)
                                        }
                                    }
                                })
                            }
                        })
                    }
                }
            })
        }
    }
    
    static func addMembersToDictionary(members: [PFObject], completionHandler : @escaping (_ resutl:Bool) -> ()){
      
        var countMembers = members.count
        
        var count = 0
        
        for member in members
        {
            print(member)
            
            self.addUserToDictionary(user: member as! PFUser, isFamily: true, completionHandler: { ( gamvesUser ) -> () in
                
                print(gamvesUser.userName)
                
                if count == ( countMembers - 1 ) {
                    completionHandler(true)
                }
                
                count = count + 1
                
            })
        }
        
    }
    
    static func loaLevels(completionHandler : @escaping (_ resutl:Bool) -> ()){
        
        let queryLevel = PFQuery(className:"Level")
        queryLevel.order(byAscending: "order")
        queryLevel.findObjectsInBackground { (levelObjects, error) in
            
            if error != nil {
                print("error: \(error)")
            } else {
                
                if let levelObjects = levelObjects {
                    
                    var countLevels = levelObjects.count
                    
                    var count = 0
                    
                    for level in levelObjects {
                        
                        let levelGamves = GamvesLevel()
                        levelGamves.description = level["description"] as! String
                        levelGamves.schoolId = level["schoolId"] as! String
                        levelGamves.grade = level["grade"] as! Int
                        
                        let full = "\(levelGamves.grade) - \(levelGamves.description)"
                        
                        print(full)
                        
                        levelGamves.fullDesc = full
                        levelGamves.objectId = level.objectId!
                        levelGamves.levelObj = level
                                                
                        self.levels[level.objectId!] = levelGamves
                        
                        if (countLevels-1)  == count {
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyLevelsLoaded), object: self)
                            
                            self.levelsLoaded = true
                            
                            completionHandler(true)
                        }
                        count = count + 1
                        
                    }
                }
            }
        }
    }
    
    static func getApprovasByFamilyId(familyId:String, completionHandler : @escaping (_ resutl: Int) -> ()) {
        
        let queryApproval = PFQuery(className:"Approvals")
        queryApproval.whereKey("familyId", equalTo: familyId)
        print(familyId)
        queryApproval.findObjectsInBackground { (approvalObjects, error) in
            
            if error != nil
            {
                print("error")
                completionHandler(0)
            } else
            {
                
                if let approvalObjects = approvalObjects
                {
                    
                    var countAapprovals = approvalObjects.count

                    if countAapprovals > 0 {

                        var count = 0
                        
                        print(countAapprovals)
                        
                        var countNotApproved = 0
                        
                        for approvalObj in approvalObjects
                        {
                            let approval = Approvals()
                            
                            approval.referenceId = approvalObj["referenceId"] as! Int
                            
                            if Global.approvals[approval.referenceId] == nil {
                            
                                approval.objectId = approvalObj.objectId!
                                
                                let approved = approvalObj["approved"] as! Int
                                
                                approval.approved = approved
                                
                                if approved == 0 {

                                    countNotApproved = countNotApproved + 1

                                }
                                
                                let type = approvalObj["type"] as! Int
                                
                                approval.type = type
                                
                                if type == 1 {
                                
                                    let queryVideo = PFQuery(className:"Videos")
                                    print(approval.referenceId)
                                    queryVideo.whereKey("videoId", equalTo: approval.referenceId)
                                    queryVideo.getFirstObjectInBackground(block: { (videoObject, error) in
                                        
                                        if error != nil
                                        {
                                            print("error: \(error)")
                                            
                                        } else {
                                            
                                            let thumImage = videoObject?["thumbnail"] as! PFFile
                                            let videoId = videoObject?["videoId"] as! Int
                                            thumImage.getDataInBackground(block: { (data, error) in
                                                
                                                if error == nil
                                                {
                                                    let thumbImage = UIImage(data:data!)
                                                    
                                                    approval.thumbnail = thumbImage
                                                    
                                                    let gamvesVideo = Global.parseVideo(videoPF: videoObject!, chatId : videoId, videoImage: thumbImage! )
                                                    
                                                    approval.video = gamvesVideo
                                                    
                                                    approval.title = videoObject?["title"] as! String
                                                    approval.description = videoObject?["description"] as! String
                                                    
                                                    //self.approvals.append(approval)
                                                    
                                                    self.approvals[approval.referenceId] = approval
                                                    
                                                    if (countAapprovals-1) == count {
                                                        completionHandler(countNotApproved)
                                                    }
                                                    count = count + 1
                                                }
                                            })

                                        }
                                        
                                    })
                                    
                                    
                                } else if type == 2 {
                                    
                                    
                                    let queryFanpage = PFQuery(className:"Fanpages")
                                    let refId = approval.referenceId
                                    print(refId)
                                    queryFanpage.whereKey("fanpageId", equalTo: refId)
                                    
                                    queryFanpage.getFirstObjectInBackground(block: { (fanpageObject, error) in
                                        
                                        if error != nil
                                        {
                                            print("error: \(error)")
                                            
                                        } else {
                                            
                                            if let fanpagePF = fanpageObject {
                                            
                                                let icon = fanpagePF["pageIcon"] as! PFFile
                                            
                                                let fanpageId = fanpagePF["fanpageId"] as! Int
                                            
                                                icon.getDataInBackground(block: { (data, error) in
                                                    
                                                    if error == nil
                                                    {
                                                        let iconImage = UIImage(data:data!)
                                                        
                                                        approval.thumbnail = iconImage
                                                        
                                                        let gamvesFanpage = Global.parseFanpage(fanpage: fanpageObject!, fanpageId : fanpageId, fanpageImage: iconImage!, completionHandler: { ( fanpageGamves:GamvesFanpage ) -> () in
                                                            
                                                            approval.fanpage = fanpageGamves
                                                            
                                                            print(fanpageGamves.name)
                                                            
                                                            print(fanpageGamves.fanpage_images.count)
                                                            
                                                            approval.title = fanpagePF["pageName"] as! String
                                                            
                                                            let pageAbout = fanpagePF["pageAbout"] as! String
                                                            
                                                            approval.description = pageAbout
                                                            
                                                            approval.fanpage.about = pageAbout
                                                            
                                                            self.approvals[approval.referenceId] = approval
                                                            
                                                            //self.approvals.append(approval)
                                                            
                                                            if (countAapprovals-1) == count {
                                                                completionHandler(countNotApproved)
                                                            }
                                                            count = count + 1
                                                            
                                                            
                                                        })
                                                    }
                                                })
                                            }
                                        }
                                    })
                                }
                            }
                        }

                    } else {
                        
                        completionHandler(0)
                    } 
                }
            }
        }
    }

    static func getFriendsApprovasByFamilyId(familyId:String, completionHandler : @escaping (_ invites:Int, _ invited:Int, _ updated:Bool) -> ()) {
        
        let queryFriendApproval = PFQuery(className:"FriendsApproval")
        queryFriendApproval.whereKey("familyId", equalTo: familyId)
        print(familyId)
        queryFriendApproval.findObjectsInBackground { (friendApprovalObjects, error) in
            
            if error != nil
            {
                print("error")

                completionHandler(0,0, false)

            } else
            {
                
                var countNotApproved = 0
                var countInvite = 0
                var countInvited = 0 

                if let friendApprovalObjects = friendApprovalObjects
                {
                    
                    var countFriendAapprovals = friendApprovalObjects.count
                    var count = 0                  
                    
                    
                    var updated = Bool()                 

                    var countFriends = Int()
                    var countRequests = Int()
                    
                    if countFriendAapprovals > 0 {

                        for friendApprovalObj in friendApprovalObjects
                        {
                            let friendApproval = FriendApproval()  

                            let type = friendApprovalObj["type"] as! Int
                            let approved = friendApprovalObj["approved"] as! Int

                            if type == 1 {

                                if approved == 0 {

                                    updated = true

                                } 

                                countInvite = countInvite + 1

                            } else if type == 2 {

                                if approved == 0 {

                                    updated = true

                                } 

                                countInvited = countInvited + 1

                            }
                                
                            let posterId = friendApprovalObj["posterId"] as! String

                            let friendId = friendApprovalObj["friendId"] as! String

                            friendApproval.objectId = friendApprovalObj.objectId!
                            friendApproval.objectPF = friendApprovalObj
                            friendApproval.posterId = posterId
                            friendApproval.friendId = friendId                            
                            friendApproval.approved = approved  
                            friendApproval.type     = type                                                       

                            var userId = String()

                            if type == 1 {

                                userId = friendId

                            } else if type == 2 {

                                userId = posterId
                            }

                            if self.userDictionary[userId] == nil
                            {

                                print(userId)

                                Global.addUnknownUserToDictionary(userId: userId, completionHandlerUnknownUser: { ( gamvesUser ) -> () in                                            

                                    friendApproval.approved = approved

                                    friendApproval.user = gamvesUser

                                    friendApproval.title = gamvesUser.name                                    

                                    self.friendApproval[userId] = friendApproval    

                                    if count == (countFriendAapprovals - 1) {
                                        completionHandler(countInvite, countInvited, updated)
                                    }

                                    count = count + 1

                                }) 

                            } else {

                                friendApproval.approved = approved
                                
                                let user =  self.userDictionary[userId] as! GamvesUser
                                
                                friendApproval.title = user.name 

                                friendApproval.user = user                         

                                self.friendApproval[userId] = friendApproval    

                                if count == (countFriendAapprovals - 1) {
                                    completionHandler(countInvite, countInvited, updated)
                                }

                                count = count + 1       

                            }

                        }    
                        

                    } else {

                        completionHandler(0,0, false)

                    }                    
                }
            } 
        }
    }

    static func loadAdminUser()
    {

        let adminQuery = PFQuery(className:"_User")
        adminQuery.whereKey("username", equalTo: "gamvesadmin")
        adminQuery.getFirstObjectInBackground(block: { (user, error) in
        
            if error == nil
            {
                let adminId = (user?.objectId)!
                
                if Global.userDictionary[adminId] == nil {
                
                    Global.addUserToDictionary(user: user as! PFUser, isFamily: false, completionHandler: { ( gamvesUser ) -> () in
                        
                        self.adminUser = gamvesUser
                        
                    })
                }
            }
        })
        
    }


    static func addUnknownUserToDictionary(userId: String, completionHandlerUnknownUser : @escaping (_ gamvesUser: GamvesUser) -> ()) {

        let userQuery = PFQuery(className:"_User")
        userQuery.whereKey("objectId", equalTo: userId)
        userQuery.getFirstObjectInBackground(block: { (user, error) in
        
            if error == nil
            {               
                
                Global.addUserToDictionary(user: user as! PFUser, isFamily: false, completionHandler: { ( gamvesUser ) -> () in                                           
                    
                    if let objectId = user?.objectId {

                        completionHandlerUnknownUser(gamvesUser)                         
                                                         
                    }
                    
                })             
            }
        })

    }

    static func getFriendsAmount(posterId:String, completionHandler : @escaping (_ amount: Int) -> ()) {

        let userQuery = PFQuery(className:"Friends")
        userQuery.whereKey("userId", equalTo: posterId)
        userQuery.getFirstObjectInBackground(block: { (friendObject, error) in
        
            if error == nil
            {

                let friendsIds = friendObject!["friends"] as! [String]

                let countFriends = friendsIds.count

                if countFriends == 0 {
                                
                    completionHandler(0)
                }

                var count = Int()

                for friendId in friendsIds {

                    let userQuery = PFQuery(className:"_User")
                    userQuery.whereKey("objectId", equalTo: friendId)
                    userQuery.getFirstObjectInBackground(block: { (userPF, error) in
        
                        if error == nil
                        { 

                            if let user = userPF {
                                
                                if self.userDictionary[user.objectId!] == nil
                                {
                                    
                                    Global.addUserToDictionary(user: user as! PFUser, isFamily: false, completionHandler: { ( gamvesUser ) -> () in
                                        
                                        if let objectId = user.objectId {
                                            
                                            self.friends[gamvesUser.userId] = gamvesUser                                   
                                            
                                            if count == (countFriends - 1) {
                                                completionHandler(countFriends)
                                            }

                                            count = count + 1
                                            
                                        }
                                    })
                                    
                                }  else {
                                    
                                    if let userId = user.objectId {
                                        
                                        let user = self.userDictionary[userId]
                                        
                                        self.friends[userId] = user                               
                                        
                                        if count == (countFriends - 1) {
                                            completionHandler(countFriends)
                                        }

                                        count = count + 1
                                    }
                                }
                            }                      
                        }                        
                    })                        
                }      


            } else {

                completionHandler(0)   
            }
        })


    }
    
    static func parseFanpage(fanpage:PFObject, fanpageId :Int, fanpageImage: UIImage, completionHandler : @escaping (_ resutl:GamvesFanpage) -> ())
    {
        
        let fanpageGamves = GamvesFanpage()
        
        let name = fanpage["pageName"] as! String
        
        fanpageGamves.name = name
        
        let fanpageId = fanpage["fanpageId"] as! Int
        
        fanpageGamves.fanpageId = fanpageId
        
        let cover = fanpage["pageCover"] as! PFFile
        
        cover.getDataInBackground { (data, error) in
            
            if error == nil {
                
                let image_cover = UIImage(data: data!)
                
                fanpageGamves.cover_image = image_cover!
                
                let avatar = fanpage["pageIcon"] as! PFFile
                
                avatar.getDataInBackground(block: { (data, error) in
                    
                    if error == nil {
                        
                        let image_avatar = UIImage(data: data!)
                        
                        fanpageGamves.icon_image = image_avatar!
                        
                        completionHandler(fanpageGamves)
                        
                        let queryAlbums = PFQuery(className:"Albums")
                        queryAlbums.whereKey("referenceId", equalTo: fanpageGamves.fanpageId)
                        
                        print(fanpageGamves.fanpageId)
                        
                        queryAlbums.findObjectsInBackground(block: { (albumObjects, error) in
                            
                            if error == nil
                            {
                                if let albumsPF = albumObjects {
                                    
                                    let countAlbums = albumObjects?.count
                                    
                                    print(countAlbums)
                                    
                                    var count = Int()
                                    
                                    var fanpage_images  = [GamvesFanpageImage]()
                                    
                                    for album in albumsPF {
                                        
                                        let cover = album["cover"] as! PFFile
                                        
                                        cover.getDataInBackground(block: { (data, error) in
                                            
                                            if error == nil {
                                                
                                                let image_album = UIImage(data: data!)
                                                
                                                let gamves_image = GamvesFanpageImage()
                                                
                                                gamves_image.cover_image = image_album!
                                                
                                                fanpage_images.append(gamves_image)
                                                
                                                if count == (countAlbums!-1) {
                                                    
                                                    fanpageGamves.fanpage_images = fanpage_images
                                                    
                                                    completionHandler(fanpageGamves)
                                                    
                                                }
                                                
                                                count = count + 1
                                                
                                            }
                                        })
                                    }
                                }
                            }
                        })
                    }
                })
            }
        }
    }
    
    
    
    static func parseVideo(videoPF:PFObject, chatId :Int, videoImage: UIImage ) -> GamvesVideo
    {
    
        let videoGamves = GamvesVideo()
       
        let title = videoPF["title"] as! String
        
        videoGamves.title = title
        
        videoGamves.description = videoPF["description"] as! String
        videoGamves.videoId = videoPF["videoId"] as! Int                
        videoGamves.authorized = videoPF["authorized"] as! Bool

        videoGamves.categoryName = videoPF["categoryName"] as! String
        videoGamves.s3_source = videoPF["s3_source"] as! String
        
        if videoPF["ytb_source"] != nil {
        
            videoGamves.ytb_source = videoPF["ytb_source"] as! String
            videoGamves.ytb_thumbnail_source = videoPF["ytb_thumbnail_source"] as! String
            
            videoGamves.ytb_upload_date = videoPF["ytb_upload_date"] as! String     
            videoGamves.ytb_view_count = videoPF["ytb_view_count"] as! Int 

            videoGamves.ytb_tags = videoPF["ytb_tags"] as! [String]
            videoGamves.ytb_duration = videoPF["ytb_duration"] as! String     
            videoGamves.ytb_categories = videoPF["ytb_categories"] as! [String]

            //videoGamves.ytb_like_count = video["ytb_like_count"] as! Int
        }
        
        videoGamves.fanpageId = videoPF["fanpageId"] as! Int

        videoGamves.posterId = videoPF["posterId"] as! String    
        videoGamves.videoObj = videoPF

        videoGamves.thumbnail = videoPF["thumbnail"] as! PFFile

        videoGamves.published  = videoPF.createdAt as! Date
        
        Global.chatVideos[chatId] = videoGamves
        
        return videoGamves
        
    }
    
    
    static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    
    static func loadUserTypes()
    {
        let queryLevel = PFQuery(className:"UserType")
        queryLevel.findObjectsInBackground { (userTypeObjects, error) in
            
            if error != nil
            {
                
                print("error: \(error)")
                
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
    
    static func storeImgeLocally(imagePath: String, imageToStore:UIImage) {
        
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imagePath).png"
        
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        do {
            try? UIImagePNGRepresentation(imageToStore)?.write(to: imageUrl)
        } catch {
            
        }
    }
    
    static func isAudio(type: MessageType) -> Bool {
        if type == MessageType.isAudio || type == MessageType.isAudioDownloading {
            return true
        } else {
            return false
        }
    }
    
    static func isPicture(type: MessageType) -> Bool {
        if type == MessageType.isPicture || type == MessageType.isPictureDownloading {
            return true
        } else {
            return false
        }
    }

    static func isText(type: MessageType) -> Bool {
        if type == MessageType.isText  {
            return true
        } else {
            return false
        }
    }
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let adminBubbleImage = UIImage(named: "bubble_admin")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let audioBubbleImage = UIImage(named: "bubble_audio")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let grayPictureBubbleImage = UIImage(named: "bubble_picture_gray")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let bluePictureBubbleImage = UIImage(named: "bubble_picture_blue")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)


    static func loadSchools(completionHandler : @escaping (_ user:Bool, _ schoolsArray: NSMutableArray) -> ()) {
        
        let schoolsArray:NSMutableArray = []
        
        let querySchool = PFQuery(className:"Schools")
        
        querySchool.findObjectsInBackground(block: { (schools, error) in
            
            if error == nil
            {
                if let schools = schools
                {
                    var countSchools = schools.count
                    var count = 0
                    
                    for school in schools
                    {
                        let schoolName = school["name"] as! String
                        schoolsArray.add(schoolName)
                        
                        let short = school["short"] as! String
                        
                        let gSchool = GamvesSchools()
                        
                        gSchool.objectId = school.objectId!
                        gSchool.schoolName = schoolName
                        gSchool.schoolOBj = school as PFObject
                        gSchool.short = short

                        let thumnail = school["thumbnail"] as! PFFile
                        
                        thumnail.getDataInBackground(block: { (data, error) in
                                            
                            if error == nil {
                                
                                let image_school = UIImage(data: data!)

                                gSchool.thumbnail = image_school                                

                                Global.schools[school.objectId!] = gSchool

                                if count == (countSchools - 1)
                                {
                                    completionHandler(true, schoolsArray)
                                }
                                count = count + 1

                            }
                        })

                        
                    }
                }
            }
        })
    }

    static var userChatColorArray = [        
        UIColor.init(netHex: 0xf750da),         
        UIColor.init(netHex: 0xf75050),         
        UIColor.init(netHex: 0x5c50f7), 
        UIColor.init(netHex: 0x2eb33e),
        UIColor.init(netHex: 0x189ea6),
        UIColor.init(netHex: 0x97a618)        
    ]


    static func getCurrentViewController() -> UIViewController? {

        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil

    }

    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height:  size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width:newSize.width, height:newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    static func isMailValid(email:String?) -> Bool {
        
        guard email != nil else { return false }
    
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
}





