//
//  Classes.swift
//  gamves
//
//  Created by Jose Vigil on 11/5/17.
//

import Foundation
import UIKit
import Parse


class GamvesPet
{
    var objectId = String()
    var thumbnail:UIImage?    
    var status = Int()
    var name = String()   
    var description = String()   
    var isChecked = Bool()
    var petOBj:PFObject!   
}

class Approvals
{
    var objectId = String()
    var thumbnail:UIImage?
    var referenceId = Int()
    var title = String()
    var description = String()
    var approved = Int()
    var video = GamvesVideo()
    var fanpage = GamvesFanpage()
    var type = Int()
}

class FriendApproval
{
    var objectId = String()       
    var objectPF:PFObject!

    var user = GamvesUser()

    var title = String()

    var posterId = String()    
    var friendId = String() 

    var approved = Int()    
    
    var type = Int()

    var invite = Bool()
    
}

class GamvesBug
{
    var objectId = String()       
    var objectPF:PFObject!   

    var title = String()
    var description = String()
    var screenshot:UIImage?   

    var approved = Int()   
}

class GamvesWelcome {

    var objectId = String()       
    var title = String()                   
    var description = String()                       
    var thumbnail:UIImage?      
    var welcomeOBj:PFObject!    
}

class GamvesGift {

    var objectId = String()       
    var title = String()                   
    var description = String()                   
    var price = Int()
    var points = Int()
    var thumbnail:UIImage?  
    var isChecked = Bool()
    var giftOBj:PFObject!    
}

class GamvesConsole {

    var consoleOBj:PFObject!
    var objectId = String()    
    var username = String()       

}

class GamvesTrend {

    var objectId = String()
    var name = String()      
    //var description = String()       

}

class GamvesTrendCategory {

    var objectId = String()
    var name = String()      
    var description = String()  

    var trend = [GamvesTrend]()    

}

class GamvesNotification {

    var objectId = String()
    var avatar:UIImage?
    var cover:UIImage?    
    var referenceId = Int()
    var title = String()
    var description = String()
    var posterName = String()
    var date = Date()
    var video = GamvesVideo()
    var fanpage = GamvesFanpage()
    var user = GamvesUser()
    var type = Int()
    var posterId = String()
    var isNew = Bool()    
}

class ChatFeed {

    // Insert code here to add functionality to your managed object subclass
    var date: Date?
    var room: String?
    var text: String?
    var isVideoChat: Bool?
    var chatThumbnail:UIImage?
    var userThumbnail:UIImage?
    var chatId:Int?
    var lasPoster: String?
    var users: [GamvesUser]?
    var usersLoaded:Bool?
    var imagesLoaded:Bool?
    var badgeIsActive:Bool?
    var badgeNumber:Int?
    var key:Int?
    var type:Int?
}

class GamvesSchools
{
    var objectId = String()
    var icon:UIImage?
    var thumbnail:UIImage?
    var schoolName = String()    
    var schoolOBj:PFObject!
    var userCount = Int()
}

class GamvesUser {

    var userObj:PFUser! = nil
    var name = String()
    var firstName = String()
    var lastName = String()
    var userName = String()
    var userId = String()
    var email = String()
    
    var avatar = UIImage()
    var isAvatarDownloaded = Bool()
    var isAvatarQuened = Bool()
    var isSender = Bool()
    
    var isRegister = Bool()
    
    var levelNumber = Int()
    var levelDescription = String()   

    var schoolId = String()
    var levelId = String()   

    var school = GamvesSchools()
    var level  = GamvesLevel()
    
    var typeNumber = Int()
    var typeObj:PFObject!
    
    var typeDescription = String()
    var status = String()
    var chatId = Int()
    var isChecked = Bool()

    var wasInvited = Bool()    

    var gender = GamvesGender()
    
    var familyId = String()

    var consoles = [GamvesConsole]()
}

class GamvesLevel {

    var objectId = String()
    var description = String()
    var grade = Int()
    var fullDesc = String()
    var levelObj:PFObject?
}

class UserTypeGamves {

    var objectId = String()
    var description = String()
    var idUserType = Int()
    var userTypeObj:PFObject?
}


class GamvesGender {

    var male =  Bool()
    var female =  Bool()
}

class GamvesVideo {

    var authorized = Bool()
    var title = String()
    var description = String()
    var videoId = Int()
    var categoryName = String()
    var thumbnail:PFFileObject?
    var s3_source = String()        
    //var thumbnail_source = String()
    var ytb_video_id = String()
    var upload_date = Date()
    var view_count = Int()
    var tags = [String]()
    var duration = Double()
    var categories = [String]()
    var order = Int()
    var fanpageId = Int()
    var image = UIImage()
    var videoObj:PFObject?
    var posterId = String()
    var posterName = String()
    var posterImage = UIImage()
    var published = Date()
    var checked = Bool()

}

class GamvesCategory {

    var cover = String()
    var name = String()
    
    var cover_image = UIImage()
    var thum_image  = UIImage()
    
    var cateobj:PFObject?
    
    var fanpages = [GamvesFanpage]()
    
    var selected = Bool()
    
    var order = Int()
}

class GamvesFanpage {

    var fanpageId = Int()
    var cover   = String()
    var name    = String()
    var icon    = String()
    var link    = String()
    var about   = String()
    var author  = PFUser()
    var posterId = String()
    
    var cover_image = UIImage()
    var icon_image  = UIImage()
    var author_image  = UIImage()
    
    func seCoverImage(image:UIImage) {
        self.cover_image = image
    }
    
    var videos = [GamvesVideo]()
    
    var fanpageObj:PFObject?
    
    var categoryObj:PFObject?
    var categoryName = String()
    
    var fanpage_images  = [GamvesAlbum]()
    
    var isFavorite = Bool()
    var favoritePF:PFObject?

    var isFortnite = Bool()
    
}

class GamvesAlbum {

    var albumPF:PFObject!
    var objectId = String()
    var source = String()
    var name = String()
    var description = String()
    var cover_image = UIImage()
    var type = String()
}

struct Page {

    let title: String
    let message: String
    let imageName: String
}


class GamvesFamily {

    var sonsUsers:[GamvesUser]!
    var levels:[GamvesLevel]!
    
    var youUser:GamvesUser!
    var registerUser:GamvesUser!
    var spouseUser:GamvesUser!
    
    var familyName = String()
    var objectId = String()
    var schoolName = String()
    var schoolShort = String()
    
    var sonRegisterChatId = Int()
    var sonSpouseChatId = Int()
    var familyChatId = Int()    
    
    var familyImage = UIImage()

    var school = GamvesSchools()
    
    init()
    {
        self.sonsUsers = [GamvesUser]()
        self.levels = [GamvesLevel]()
    }
    
    func getFamilyUserById(userId : String) -> GamvesUser?
    {
        if registerUser.userId == userId
        {
            return registerUser
            
        } else if spouseUser.userId == userId
        {
            return spouseUser
        }
        
        var sonwithId = GamvesUser()
        
        for son in sonsUsers
        {
            if son.userId == userId
            {
                sonwithId = son
                
            }
        }
        
        return sonwithId
    }
    
}

class UserStatistics {
    
    var desc = String()
    var data = String()
    var icon = UIImage()
}


class SuggestionSearch
{
    var id = Int()
    var desc = String()
    var icon = UIImage()
}
