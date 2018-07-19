//
//  Classes.swift
//  gamves
//
//  Created by Jose Vigil on 11/5/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import Foundation
import UIKit
import Parse

class FriendApproval
{
    var objectId = String()       
    var objectPF:PFObject!

    var user = GamvesUser()

    var title = String()

    var posterId = String()    
    var friendId = String() 

    var approved = Int()    
    //var thumbnail:UIImage?
    var type = Int()
    
}

class LocationGamves {
    var objectPF:PFObject!
    var objectId = String()
    var geopoint:PFGeoPoint!
    var date = Date()
    var address = String()
    var city = String()
    var state = String()
    var country = String()
}

class ActivityGamves
{
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
}

class HistoryGamves
{
    var objectId = String()
    var thumbnail:UIImage?
    var referenceId = Int()
    var title = String()
    var description = String()
    var videoId = Int()
    var videoGamves = GamvesVideo()
}


class ChatFeed
{
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


class GamvesSchools
{
    var objectId = String()
    var thumbnail:UIImage?
    var schoolName = String()    
    var schoolOBj:PFObject!
}

class GamvesUser
{
    var userObj:PFUser! = nil
    var name = String()
    var firstName = String()
    var lastName = String()
    var userName = String()
    var userId = String()
    var email = String()
    var password = String()
    
    var avatar = UIImage()
    var isAvatarDownloaded = Bool()
    var isAvatarQuened = Bool()
    var isSender = Bool()
    
    var isRegister = Bool()
    
    var levelNumber = Int()
    var levelDescription = String()  
    
    var typeNumber = Int()
    var typeObj:PFObject!
    
    var typeDescription = String()
    var status = String()
    var chatId = Int()
    var isChecked = Bool()
    var gender = GamvesGender()

    var schoolId = String()
    var levelId = String()

    var school = GamvesSchools()
    var level  = GamvesLevel()

    var familyId = String()
}

class GamvesGender
{
    var male =  Bool()
    var female =  Bool()
}

class GamvesVideo
{    
    var title = String()
    var description = String()
    var videoId = Int()    

    var authorized = Bool()
    var categoryName = String()
    var s3_source = String()
    var ytb_source = String()
    var ytb_thumbnail_source = String()
    var ytb_videoId = String()   
    
    var ytb_upload_date = String()
    
    var ytb_view_count = Int()

    var ytb_tags = [String]()

    var ytb_duration = String()        
    var ytb_categories = [String]()

    //var ytb_like_count = Int()
    var fanpageId = Int()  
    var posterId = String()  
    
    var videoObj:PFObject?
    var thumbnail:PFFile!
    var image = UIImage()

}

class GamvesCategory
{
    var cover = String()
    var name = String()
    
    var cover_image = UIImage()
    var thum_image  = UIImage()
    
    var cateobj:PFObject?
    
    var fanpages = [GamvesFanpage]()
    
    var selected = Bool()
}

class GamvesFanpage
{
    var objectId = String()
    var cover   = String()
    var name    = String()
    var icon    = String()
    var link    = String()
    var about   = String()
    
    var fanpageId = Int()
    
    var cover_image = UIImage()
    var icon_image  = UIImage()
    
    var videos = [GamvesVideo]()
    
    var fanpageObj:PFObject?
    
    var categoryObj:PFObject?
    var categoryName = String()
    
    var fanpage_images  = [GamvesFanpageImage]()
}

class GamvesFanpageImage
{
    var objectId = String()
    var source = String()
    var name = String()
    var cover_image = UIImage()
}

struct Page {
    let title: String
    let message: String
    let imageName: String
}

class GamvesFamily
{
    var sonsUsers:[GamvesUser]!
    var levels:[GamvesLevel]!
    
    var youUser:GamvesUser!
    var spouseUser:GamvesUser!
    
    var familyName = String()
    var objectId = String()
    var schoolName = String()
    var schoolShort = String()
    
    var sonRegisterChatId = Int()
    var spouseRegisterChatId = Int()
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
        if youUser.userId == userId
        {
            return youUser
       
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


class GamvesLevel
{
    var objectId = String()
    var description = String()
    var grade = Int()   
    var fullDesc = String() 
    var levelObj:PFObject?
}

class UserTypeGamves
{
    var objectId = String()
    var description = String()
    var idUserType = Int()
    var userTypeObj:PFObject?
}

class UserStatistics
{
    var id = Int()
    var desc = String()
    var data = String()
    var icon = UIImage()
    var second_icon = UIImage()
    var approval = Int()
}

class AccountButton
{
    var id = Int()
    var desc = String()
    var icon = UIImage()
}


