//
//  Objects.swift
//  gamvescommunity
//
//  Created by Jose Vigil on 5/30/17.
//

import UIKit
import Parse
import NVActivityIndicatorView
import PopupDialog
import Foundation


class Global: NSObject
{
    
    static var userId = String()
    static var userPF:PFUser!
    static var levelDescription = String()
    static var schoolShort = String()       

    static var trends_stored = [GamvesTrendCategory]()

    static var listOfSwearWords = [String]()

    static func setBadWordsArray(words: String) {

        self.listOfSwearWords = words.split(separator: "|").map(String.init)
        
        print(listOfSwearWords)
    }

    static var listOfChatColors = [String]()

    static func setChatColorsArray(colors: String) {

        self.listOfChatColors = colors.split(separator: "|").map(String.init)
        
        print(listOfChatColors)
    }    
    
    static var pagesPageView = [UIViewController]()

    static var profileUser = GamvesUser()
    
    static func setProfileUser(user:GamvesUser) {
        self.profileUser = GamvesUser()
        self.profileUser = user
    }

    static var pictureRecorded = GamvesPicture()
    static var audioRecorded = GamvesAudio()
    
    static var device = String()
    
    static var notifications = [GamvesNotification]()
    static var notificationsNew = [GamvesNotification]()

    static var userTypes = Dictionary<Int, UserTypeGamves>()
    static var schools = Dictionary<String, GamvesSchools>()
    static var levels = Dictionary<String, GamvesLevel>()  
    static var consoles = Dictionary<String, [GamvesConsole]>()  

    static var serverUrl = "https://parseapi.back4app.com/"   
    
    static var localWs = "wss://gamvesalpha.back4app.io" 
    
    static var defaults = UserDefaults.standard
    
    static var timeOnlinePF:PFObject!

    static var gamves_official_id = String()
    
    static var api_key = "AIzaSyAMu_C1z2pMYGOgRi3dOiqCTh6pVGS59YU"

    static var search_engine = "010975053378915722447:h2ob_fkvam0"    
    
    static var api_image_base = "https://www.youtube.com/oembed?url=http://www.youtube.com/watch?v="
    static var api_image_format = "&format=json"
    
    static var api_desc_base = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id="
    static var api_desc_middle = "&fields=items/snippet/title,items/snippet/description&key="    
    
    static var api_suggestion_base = "https://suggestqueries.google.com/complete/search?hl=en&ds=yt&client=youtube&hjson=t&cp=1&q="
    static var api_suggestion_mid = "&key="
    static var api_suggestion_close = "=5&alt=json"
    
    static var admin_delimitator:String = "---is_admin_chat---"
    static var audio_delimitator:String = "---is_audio_chat---"
    static var picture_delimitator:String = "---is_picture_chat---"
    
    static var key_you_spouse_chat_id = "you_spouse_chat_id"
    static var key_you_son_chat_id = "you_son_chat_id"
    static var key_you_spouse_son_chat_id = "you_spouse_son_chat_id"
    
    //Notifications
    static var notificationKeyFamilyLoaded  = "com.gamves.familyLoaded"
    static var notificationKeyYourUserDataLoaded  = "com.gamves.yourUserDataLoaded"
    static var notificationKeyChatFeed      = "com.gamves.chatfeed"
    static var notificationKeyLoggedin      = "com.gamves.loggedin"
    static var notificationKeyCloseVideo    = "com.gamves.gamves.closeVideo"
    static var notificationKeyLevelsLoaded  = "com.gamves.levelsLoaded"
    static var notificationKeyMediaDelegate = "com.gamves.notificationKeyMediaDelegate"
    static var notificationKeyShowProfile   = "com.gamvess.notificationKeyShowProfile"
    static var notificationOpenChatFromUser   = "com.gamvess.notificationOpenChatFromUser"
    static var notificationKeyReloadPageFanpage   = "com.gamvess.notificationKeyReloadPageFanpage"        
        
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

    static var gamvesAllUsers = Dictionary<String, GamvesUser>()
    
    static var userDictionary = Dictionary<String, GamvesUser>()

    static var friends = Dictionary<String, GamvesUser>()

    static var allUsers = Dictionary<String, GamvesUser>()

    static var friendsAmount = Int()
    
    static var gamvesFamily = GamvesFamily()
    
    static var familyLoaded = Bool()
    static var chatFeedLoaded = Bool()
    
    static var chatVideos = Dictionary<Int, GamvesVideo>()
    
    static var hasNewFeed = Bool()
    
    static var categories_gamves = Dictionary<Int, GamvesCategory>()

    static var fanpageData:AnyObject!
    
    static func sortCategoryByOrder()
    {
        self.categories_gamves.sorted(by: {$0.value.order > $1.value.order })
    }

    //Bool to foce download and skip chache. 
    static var forceFromNetworkCache = Bool()    
    
    static func addUserToDictionary(user: PFUser, isFamily:Bool, completionHandler : @escaping (_ resutl:GamvesUser) -> ())
    {
        let userId = user.objectId!
        
        print(user.username)
        
        if self.userDictionary[userId] == nil {
            
            let gamvesUser = GamvesUser()
            
            gamvesUser.name = user["Name"] as! String
            gamvesUser.userId = user.objectId!
            
            gamvesUser.firstName = user["firstName"] as! String
            gamvesUser.lastName = user["lastName"] as! String
            
            var registered = Bool()
            
            if user["isRegister"] != nil {
                registered = user["isRegister"] as! Bool
            }
            
            if user["familyId"] != nil {
                gamvesUser.familyId = user["familyId"] as! String
            }

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

            if user["levelId"] != nil {
                let levelId = user["levelId"] as! String
                gamvesUser.levelId = levelId

                if Global.levels[levelId] != nil {
                    gamvesUser.level = Global.levels[levelId]!
                }
            } 
            
            gamvesUser.isRegister = registered
            
            gamvesUser.userName = user["username"] as! String
            
            if user.email != nil {
                gamvesUser.email = user.email!
            }
            
            if user["status"] != nil {
                gamvesUser.status = user["status"] as! String
            }
            
            if PFUser.current()?.objectId == userId
            {
                gamvesUser.isSender = true
            }
            
            gamvesUser.userObj = user

            if Global.consoles[userId] != nil {
                gamvesUser.consoles = Global.consoles[userId] as! [GamvesConsole]
            }
            
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
                                    
                                    if Global.levels[levelId] != nil {
                                    
                                        let levelGamves = Global.levels[levelId]
                                        
                                        print(levelGamves)
                                        
                                        gamvesUser.levelNumber = (levelGamves?.grade)!
                                        gamvesUser.levelDescription = (levelGamves?.description)!
                                
                                        gamvesUser.levelId = levelId
                                    }
                                }
                                
                                adduserToFamilyFromGlobal(gamvesUser: gamvesUser)
                                
                                completionHandler(gamvesUser)
                                
                            }
                            
                            if typeNumber != Global.SON || typeNumber != Global.DAUGHTER {
                                
                                completionHandler(gamvesUser)
                            }

                        } else {

                            adduserToFamilyFromGlobal(gamvesUser: gamvesUser)
                                
                            completionHandler(gamvesUser)
                            
                        }
                    }
                })
            }
            
        } else {
            
            completionHandler(self.userDictionary[userId]!)
        }
    }

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
                        
                        let gSchool = GamvesSchools()
                        
                        gSchool.objectId = school.objectId!
                        gSchool.schoolName = schoolName
                        gSchool.schoolOBj = school as PFObject                  

                        let thumnail = school["thumbnail"] as! PFFile
                        
                        thumnail.getDataInBackground(block: { (data_thumbnail, error) in
                                            
                            if error == nil {
                                
                                let thumb_school = UIImage(data: data_thumbnail!)

                                gSchool.thumbnail = thumb_school 

                                let icon = school["iso"] as! PFFile
                            
                                icon.getDataInBackground(block: { (data_icon, error) in

                                    let icon_school = UIImage(data: data_icon!)

                                    gSchool.icon = icon_school 

                                    Global.schools[school.objectId!] = gSchool

                                    if count == (countSchools - 1)
                                    {
                                        completionHandler(true, schoolsArray)
                                    }
                                    count = count + 1

                                })                      

                            }
                        })                       
                    }
                }
            }
        })
    }

    static func getFriendsAmount(posterId:String, completionHandler : @escaping (_ amount: Int) -> ()) {

        let friendQuery = PFQuery(className:"Friends")
        friendQuery.whereKey("userId", equalTo: posterId)
        friendQuery.getFirstObjectInBackground(block: { (friendObject, error) in
        
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
                            
                            if self.userDictionary[(userPF?.objectId)!] == nil
                            {
                                
                                Global.addUserToDictionary(user: userPF as! PFUser, isFamily: false, completionHandler: { ( gamvesUser ) -> () in
                                    
                                    if let objectId = userPF?.objectId {
                                        
                                        self.friends[gamvesUser.userId] = gamvesUser                                   
                                        
                                        if count == (countFriends - 1) {
                                            completionHandler(countFriends)
                                        }

                                        count = count + 1
                                        
                                    }
                                })
                                
                            }  else {
                                
                                if let userId = userPF?.objectId {
                                    
                                    let user = self.userDictionary[userId]
                                    
                                    self.friends[userId] = user                               
                                    
                                    if count == (countFriends - 1) {
                                        completionHandler(countFriends)
                                    }

                                    count = count + 1
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

    static func adduserToFamilyFromGlobal(gamvesUser : GamvesUser){
        
        if let myId = PFUser.current()?.objectId {
            
            if myId == gamvesUser.userId {
                
                Global.gamvesFamily.youUser = gamvesUser
                Global.gamvesFamily.sonsUsers.append(gamvesUser)
                
                let typeNumber = gamvesUser.typeNumber
                
                if typeNumber == Global.SON || typeNumber == Global.DAUGHTER {
                
                    print(gamvesUser.levelId)
                    let level = self.levels[gamvesUser.levelId]!
                
                    Global.gamvesFamily.levels.append(level)
                    
                }
                
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
                        
                        if let objectId = user?.objectId {
                            
                            print(objectId)
                            
                            self.gamves_official_id = objectId
                            
                        }                        
                    })
                }
            }
        })        
    }

    static func fetchUsers(completionHandler : @escaping (_ resutl:Bool) -> ())
    {
        let userQuery = PFQuery(className:"_User")        
        userQuery.whereKey("iDUserType", containedIn: [2,3])

        if let userId = PFUser.current() {
            userQuery.whereKey("objectId", notEqualTo: userId)
        }

        userQuery.findObjectsInBackground(block: { (users, error) in
            
            if error == nil
            {
                let usersCount =  users?.count
                var count = 0
                
                print(usersCount)
                
                for user in users!
                {
                    let userId = user.objectId

                    if Global.userDictionary[userId!] == nil {

                        Global.addUserToDictionary(user: user as! PFUser, isFamily: false, completionHandler: { (gamvedUser) in

                            Global.gamvesAllUsers[gamvedUser.userId] = gamvedUser //.append(gamvedUser)                           

                            if (usersCount! - 1) == count
                            {
                                completionHandler(true)
                            }

                            count = count + 1

                        })

                    } else {

                        Global.gamvesAllUsers[userId!] = Global.userDictionary[userId!]

                        //Global.gamvesAllUsers.append(Global.userDictionary[userId!]!)                        

                        if (usersCount! - 1) == count
                        {
                            completionHandler(true)
                        }
                        
                        count = count + 1
                    }                    
                }
            }
        })
    }  

    static func getYourUserData(id:String, completionHandler : @escaping (_ result:Bool) -> ())
    {

        let userQuery = PFQuery(className:"_User")                       
        userQuery.whereKey("objectId", equalTo: id)
        userQuery.getFirstObjectInBackground(block: { (userPF, error) in
            
            if error == nil
            {
                if let userId = userPF?.objectId {

                    Global.userId = userId
                    Global.userPF = userPF as! PFUser

                    let levelId  = userPF!["levelId"] as! String                    

                    let queryLevel = PFQuery(className:"Level")
                    queryLevel.whereKey("objectId", equalTo: levelId)
                    queryLevel.getFirstObjectInBackground { (levelPF, error) in        
                        
                        if error != nil {

                            print("error")
                            
                        } else {
                            
                            if levelPF != nil {

                                Global.levelDescription = levelPF!["description"] as! String

                                var schoolId = userPF!["schoolId"] as! String

                                let querySchool = PFQuery(className:"Schools")
                                querySchool.whereKey("objectId", equalTo: schoolId)
                                querySchool.getFirstObjectInBackground { (schoolPF, error) in   

                                    if error == nil {

                                        Global.schoolShort = schoolPF!["short"] as! String

                                       completionHandler(true)

                                    } else {
                                       completionHandler(false)
                                    }
                                }

                            } else {
                                completionHandler(false)
                            }

                        }
                    }
                }
            }
        })
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


    static func containsSwearWord(text: String, swearWords: [String]) -> Bool {
        //print(swearWords)
        let searchText = text.lowercased()
        return swearWords.reduce(false) { $0 || searchText.contains($1.lowercased()) }
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
                var usersArray = [GamvesUser]()
                
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
                    
                    print(user)
                    
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

    static func alertWithTitle(viewController: UIViewController, title: String!, message: String, toFocus:AnyObject?)
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
    
    static func loadAditionalData() {
        
        if PFUser.current() != nil {
            
            Global.loadLevels(completionHandler: { ( result:Bool ) -> () in
                
                Global.getFamilyData(completionHandler: { ( result:Bool ) -> () in
                    
                    Global.familyLoaded = true
                    
                    ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in
                        
                        Global.chatFeedLoaded = true
                    })

                    let userId = Global.gamvesFamily.sonsUsers[0].userId

                    Global.getFriendsAmount(posterId: userId, completionHandler: { ( countFriends ) -> () in

                        self.friendsAmount = countFriends
                    })
                    
                })
            })

            self.loadConstoles()
            
            self.loadChatChannels()

            self.loadAdminUser()

            self.loadConfigData()
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleLogin), name: NSNotification.Name(rawValue: Global.notificationKeyLoggedin), object: nil)
        }

        Global.loadSchools(completionHandler: { ( user, schoolsArray ) -> () in })


        Global.loadLevels(completionHandler: { ( result:Bool ) -> () in })
    }
    
    @objc func handleLogin() {
        Global.loadChatChannels()
    }

    static func loadConstoles() {

        var queryConsoles = PFQuery(className: "Consoles")   
        
        if let userId = PFUser.current()?.objectId {

            queryConsoles.whereKey("userId", contains: userId)        
        
            queryConsoles.findObjectsInBackground(block: { (consolesPF, error) in
                
                if consolesPF != nil {
                    
                    let consoleCount = consolesPF?.count

                    var consoles = [GamvesConsole]()

                    for consolePF in consolesPF! {

                        let contole  = GamvesConsole()
                        contole.objectId    = consolePF.objectId!
                        contole.consoleOBj = consolePF
                        contole.username    = consolePF["username"] as! String

                        consoles.append(contole)
                    }

                    Global.consoles[userId] = consoles
                }

            })    
        }        

    }
    
    static func loadChatChannels()
    {
        
        var queryChatFeed = PFQuery(className: "ChatFeed")
        
        queryChatFeed = PFQuery(className: "ChatFeed")
        
        if let userId = PFUser.current()?.objectId {
            queryChatFeed.whereKey("members", contains: userId)
        }
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
            if chatfeeds != nil {
                
                let chatFeddsCount = chatfeeds?.count
                
                print(chatFeddsCount)
                
                if chatFeddsCount! > 0 {
                    
                    let chatfeedsCount =  chatfeeds?.count
                    
                    print(chatfeedsCount)
                    
                    if chatfeedsCount! > 0
                    {
                        
                        for feed in chatfeeds! {
                            
                            let chatId:Int = feed["chatId"] as! Int
                            
                            let chatIdStr = String(chatId) as String
                            
                            PFPush.subscribeToChannel(inBackground: chatIdStr)
                        }
                    }
                }
            }
        })
    }
    
    static func loadLevels(completionHandler : @escaping (_ resutl:Bool) -> ()){
        
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
                        
                        let levelGamves = GamvesLevel()
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


    static func loadLevelByUserId(userId:String, completionHandler : @escaping (_ resutl:Bool) -> ()){
        
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
                        
                        let levelGamves = GamvesLevel()
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
                                        self.gamvesFamily.schoolName = school["name"] as! String

                                        self.gamvesFamily.schoolShort = school["short"] as! String                                       

                                        print(self.gamvesFamily.schoolShort)
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
   
    static func updateUserStatus(status : Int) {
        
        DispatchQueue.main.async {
            self.updateTimeOnline(status: status)
        }
        
        let queryOnine = PFQuery(className:"UserStatus")
        
        if let userId = PFUser.current()?.objectId {
            queryOnine.whereKey("userId", equalTo: userId)
        }    
        
        queryOnine.getFirstObjectInBackground { (userStatus, error) in
            
            if error != nil || userStatus == nil {
                
                let newUserStatus = PFObject(className: "UserStatus")
                newUserStatus["userId"] = PFUser.current()?.objectId
                newUserStatus["status"] = status
                newUserStatus.saveEventually()               
                

            } else {

                userStatus!["status"] = status
                userStatus?.saveEventually()               
                
            }
        }
    }

    static func queryPoints(completionHandler : @escaping (_ resutl:Int) -> ()) {

        let userId = Global.profileUser.userId 

        let queryPoints = PFQuery(className:"Points")
        queryPoints.whereKey("userId", equalTo: userId)
        queryPoints.findObjectsInBackground(block: { (pointsPF, error) in
            
            if error != nil
            {
                print("error")

            } else {

                let countPoints:Int = (pointsPF?.count)!

                if countPoints > 0 {

                    var countPoints = Int()

                    for pointPF in pointsPF! {

                        let point = pointPF["points"] as! Int

                        countPoints = countPoints + point

                    }

                    completionHandler(countPoints)
                    //self.pointsLabel.text = "\(countPoints)"

                }            
            }
        })
    }
    
    static func updateTimeOnline(status : Int) {
        
        if status == 2 || Global.timeOnlinePF == nil {
            
            var timeOnline = PFObject(className: "TimeOnline")
            if let userId = PFUser.current()?.objectId {
                timeOnline["userId"] = userId
            }
            
            let datePF = Date()
            timeOnline["timeStarted"] = datePF
            timeOnline["statusStarted"] = status
            
            timeOnline.saveInBackground(block: { (resutl, error) in
                Global.timeOnlinePF = timeOnline
            })
            
        } else {
            
            let timeOnlinePF = Global.timeOnlinePF
            
            if let objectId = PFUser.current()?.objectId {
                timeOnlinePF!["userId"] = objectId
            }
            
            let datePF = Date()
            timeOnlinePF!["timeEnded"] = datePF
            
            timeOnlinePF!["statusEnded"] = status
            timeOnlinePF?.saveEventually()
            
        }
    }
    
    static func getGamvesVideoFromObject(videoPF:PFObject, completionHandler : @escaping (_ video:GamvesVideo) -> ()) {
        
        let video = GamvesVideo()      
        
        video.title                     = videoPF["title"] as! String
        video.description               = videoPF["description"] as! String

        var videothum = videoPF["thumbnail"] as! PFFile

        video.thumbnail                 = videothum
        video.categoryName              = videoPF["categoryName"] as! String
        video.videoId                   = videoPF["videoId"] as! Int
        video.s3_source                 = videoPF["s3_source"] as! String
        video.ytb_thumbnail_source      = videoPF["ytb_thumbnail_source"] as! String
        video.ytb_videoId               = videoPF["ytb_videoId"] as! String
        
        let dateStr = videoPF["ytb_upload_date"] as! String
        let dateDouble = Double(dateStr)
        let date = NSDate(timeIntervalSince1970: dateDouble!)
        
        video.ytb_upload_date           = date as Date
        video.ytb_view_count            = videoPF["ytb_view_count"] as! Int
        video.ytb_tags                  = videoPF["ytb_tags"] as! [String]
        
        let durStr = videoPF["ytb_upload_date"] as! String
        let durDouble = Double(durStr)
        video.ytb_duration              = durDouble!
        
        video.ytb_categories            = videoPF["ytb_categories"] as! [String]
        //video.ytb_like_count            = videoPF["ytb_like_count"] as! Int
        video.order                     = videoPF["order"] as! Int
        video.fanpageId                 = videoPF["fanpageId"] as! Int
        
        video.posterId                  = videoPF["posterId"] as! String
        video.posterName                = videoPF["poster_name"] as! String
        
        video.published                 = videoPF.createdAt as! Date
        
        video.videoObj = videoPF
                                           
        videothum.getDataInBackground(block: { (data, error) in
            
            if error == nil {
                
                video.image = UIImage(data: data!)!
                
                completionHandler(video)                    
            }

        }) 
    }

    
    static func generateFileName() -> String
    {
        var name = String()
        
        if let userId = PFUser.current()?.objectId {
            
            print(userId)
            
            let date = Date()
            let calendar = Calendar.current
            
            let hour = String(calendar.component(.hour, from: date))
            
            let minutes = String(calendar.component(.minute, from: date))
            
            let seconds = String(calendar.component(.second, from: date))
            
            let hm:String = "\(hour)\(minutes)\(seconds)"
            
            print(hm)
            
            name = "\(userId)_\(hm)"
            
            print(name)
            
        }
        
        return name
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


    static var pastelColorArray = [        
        UIColor.init(netHex: 0xf6bbf8),         
        UIColor.init(netHex: 0xbbbef8),         
        UIColor.init(netHex: 0xc3f8bb), 
        UIColor.init(netHex: 0xf8f7bb)        
    ]

    static var auxiliarColorArray = [        
        UIColor.gamvesTurquezeColor,         
        UIColor.gamvesCyanColor,         
        UIColor.gamvesYellowColor, 
        UIColor.gamvesGreenColor       
    ]

    static var userChatColorArray = [        
        UIColor.init(netHex: 0xf750da),         
        UIColor.init(netHex: 0xf75050),         
        UIColor.init(netHex: 0x5c50f7), 
        UIColor.init(netHex: 0x2eb33e),
        UIColor.init(netHex: 0x189ea6),
        UIColor.init(netHex: 0x97a618)        
    ]


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

    


}
