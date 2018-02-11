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
    
    static var pictureRecorded = GamvesPicture()
    static var audioRecorded = GamvesAudio()
    
    static var levels = Dictionary<String, LevelsGamves>()
    
    static var schools = [GamvesSchools]()
    
    static var serverUrl = "http://127.0.0.1:1337/1/"
    //static var serverUrl = "https://pg-app-z97yidopqq2qcec1uhl3fy92cj6zvb.scalabl.cloud/1/"
    
    static var localWs = "wss://127.0.0.1:1337/1/"
    static var remoteWs = "wss://pg-app-z97yidopqq2qcec1uhl3fy92cj6zvb.scalabl.cloud/1/"
    
    static var userTypes = Dictionary<Int, UserTypeGamves>()
    
    static var youImageName = "youImage"
    static var youImageNameSmall = "youImageSmall"
    static var sonImageName = "sonImage"
    static var sonImageNameSmall = "sonImageSmall"
    static var spouseImageName = "spouseImage"
    static var spouseImageNameSmall = "spouseImageSmall"
    static var familyImageName = "familyImage"
    static var familyImageNameSmall = "familyImageSmall"
    
    /*static func getUserTypeObjById(id:Int) -> PFObject {
        
        var obj:PFObject!
        
        for ust in userTypes {
            if ust.idUserType == id {
                obj = ust.userTypeObj!
            }
        }
        
        return obj
    }*/
    
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
        
    //static var approvals = [Approvals]()
    static var approvals = Dictionary<Int, Approvals>()
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
    
    static var keySpouseSmall   = String() //"\(Global.keySpouse)Small"
    static var keyYourSmall     = String() //"\(Global.keyYour)Small"
    static var keySonSmall      = String() //"\(Global.keySon)Small"
    
    //Notifications
    static var notificationKeyFamilyLoaded  = "com.gamves.gamvesparent.familyLoaded"
    static var notificationKeyLevelsLoaded  = "com.gamves.gamvesparent.levelsLoaded"
    static var notificationKeyChatFeed      = "com.gamves.gamvesparent.chatfeed"
    static var notificationYourAccountInfoLoaded  = "com.gamves.gamvesparent.notificationYourAccountInfoLoaded"
    static var notificationKeyLoadFamilyDataGromGlobal  = "com.gamves.gamvesparent.loadfamilydatagromglobal"
    
    static var badgeNumber = Bool()
    
    static var userDictionary = Dictionary<String, GamvesParseUser>()
    
    static var gamvesFamily = GamvesFamily()
    
    static var chatVideos = Dictionary<Int, VideoGamves>()
    
    static var hasNewFeed = Bool()
    
    static var yourAccountBackImage = UIImage()
    
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
                
            } else if gamvesUser.typeNumber == Global.SON ||  gamvesUser.typeNumber == Global.DAUGHTER {
                
                Global.gamvesFamily.sonsUsers.append(gamvesUser)
                Global.gamvesFamily.levels.append(self.levels[gamvesUser.levelId]!)
                
            } else {
                
                Global.gamvesFamily.spouseUser = gamvesUser
            }
            
        }
        
        self.userDictionary[gamvesUser.userId] = gamvesUser

    }

    
    static func getImageVideo(videothumburl: String, video:VideoGamves, completionHandler : (_ video:VideoGamves) -> Void)
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
    
    
    static func setActivityIndicator(container: UIView, type: Int, color:UIColor, x:CGFloat, y:CGFloat, width: CGFloat, height:CGFloat) -> NVActivityIndicatorView
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
            familyQuery.findObjectsInBackground(block: { (families, error) in
                
                if error == nil
                {
                    for family in families!
                    {                       
                        
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
                                            self.gamvesFamily.schoolName = school["name"] as! String
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
    
    
    static func loaLevels(completionHandler : @escaping (_ resutl:Bool) -> ()){
        
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
            } else
            {
                
                if let approvalObjects = approvalObjects
                {
                    
                    var countAapprovals = approvalObjects.count
                    var count = 0
                    
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
                                                
                                                let gamvesVideo = Global.parseVideo(video: videoObject!, chatId : videoId, videoImage: thumbImage! )
                                                
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
                                                    
                                                    let gamvesFanpage = Global.parseFanpage(fanpage: fanpageObject!, fanpageId : fanpageId, fanpageImage: iconImage!, completionHandler: { ( fanpageGamves:FanpageGamves ) -> () in
                                                        
                                                        approval.fanpage = fanpageGamves
                                                        
                                                        print(fanpageGamves.name)
                                                        
                                                        print(fanpageGamves.fanpage_images.count)
                                                        
                                                        approval.title = fanpagePF["pageName"] as! String
                                                        approval.description = fanpagePF["pageAbout"] as! String
                                                        
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
                }
            }
        }
    }
    
    static func parseFanpage(fanpage:PFObject, fanpageId :Int, fanpageImage: UIImage, completionHandler : @escaping (_ resutl:FanpageGamves) -> ())
    {
        
        let fanpageGamves = FanpageGamves()
        
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
                                    
                                    var fanpage_images  = [FanpageImageGamves]()
                                    
                                    for album in albumsPF {
                                        
                                        let cover = album["cover"] as! PFFile
                                        
                                        cover.getDataInBackground(block: { (data, error) in
                                            
                                            if error == nil {
                                                
                                                let image_album = UIImage(data: data!)
                                                
                                                let gamves_image = FanpageImageGamves()
                                                
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
    
    
    
    static func parseVideo(video:PFObject, chatId :Int, videoImage: UIImage ) -> VideoGamves
    {
    
        let videoGamves = VideoGamves()
       
        let title = video["title"] as! String
        
        videoGamves.title = title
        
        videoGamves.description = video["description"] as! String
        videoGamves.videoId = video["videoId"] as! Int                
        videoGamves.authorized = video["authorized"] as! Bool

        videoGamves.categoryName = video["categoryName"] as! String
        videoGamves.s3_source = video["s3_source"] as! String
        
        if video["ytb_source"] != nil {
        
            videoGamves.ytb_source = video["ytb_source"] as! String
            videoGamves.ytb_thumbnail_source = video["ytb_thumbnail_source"] as! String
            
            videoGamves.ytb_upload_date = video["ytb_upload_date"] as! String     
            videoGamves.ytb_view_count = video["ytb_view_count"] as! Int 

            videoGamves.ytb_tags = video["ytb_tags"] as! [String]
            videoGamves.ytb_duration = video["ytb_duration"] as! String     
            videoGamves.ytb_categories = video["ytb_categories"] as! [String]

            //videoGamves.ytb_like_count = video["ytb_like_count"] as! Int
        }
        
        videoGamves.fanpageId = video["fanpageId"] as! Int

        videoGamves.posterId = video["posterId"] as! String    
        videoGamves.videoObj = video

        videoGamves.thumbnail = video["thumbnail"] as! PFFile
        
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
    
    static func storeImgeLocally(imagePath: String, imageToStore:UIImage) {
        
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imagePath).png"
        
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        do {
            try? UIImagePNGRepresentation(imageToStore)?.write(to: imageUrl)
        } catch {
            
        }
    }
}





