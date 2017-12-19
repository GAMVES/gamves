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
    var lastPoster: String?
    var users: [GamvesParseUser]?
    var usersLoaded:Bool?
    var imagesLoaded:Bool?
    var badgeIsActive:Bool?
    var badgeNumber:Int?
}

class Approvals
{
    var objectId = String()
    var thumbnail:UIImage?
    var videoId = Int()    
    var videoTitle = String()
    var videoDescription = String()
    var approved = Int()
    var video = VideoGamves()
}


class GamvesSchools
{
    var objectId = String()
    var thumbnail:UIImage?
    var schoolName = String()
    var schoolOBj:PFObject!
}

class GamvesParseUser
{
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
    
    var levelId = String()
    
    var typeNumber = Int()
    var typeObj:PFObject!
    
    var typeDescription = String()
    var status = String()
    var chatId = Int()
    var isChecked = Bool()
    var gender = GamvesGender()
}

class GamvesGender
{
    var male =  Bool()
    var female =  Bool()
}

class VideoGamves
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

    var ytb_like_count = Int() 
    var fanpageId = Int()  
    var posterId = String()  
    
    var videoObj:PFObject?
    var thumbnail:PFFile!
    var image = UIImage()

}

class CategoryGamves
{
    var cover = String()
    var name = String()
    
    var cover_image = UIImage()
    var thum_image  = UIImage()
    
    var cateobj:PFObject?
    
    var fanpages = [FanpageGamves]()
    
    var selected = Bool()
}

class FanpageGamves
{
    var fanpageId = String()
    var cover   = String()
    var name    = String()
    var icon    = String()
    var link    = String()
    var about   = String()
    
    var cover_image = UIImage()
    var icon_image  = UIImage()
    
    var videos = [VideoGamves]()
    
    var fanpageObj:PFObject?
    
    var categoryObj:PFObject?
    var categoryName = String()
    
    var fanpage_images  = [FanpageImageGamves]()
}

class FanpageImageGamves
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
    var sonsUsers:[GamvesParseUser]!
    var levels:[LevelsGamves]!
    
    var youUser:GamvesParseUser!
    var spouseUser:GamvesParseUser!
    
    var familyName = String()
    var objectId = String()
    var school = String()
    
    var sonChatId = Int()
    var spouseChatId = Int()
    var familyChatId = Int()
    
    var familyImage = UIImage()
    
    init()
    {
        self.sonsUsers = [GamvesParseUser]()
        self.levels = [LevelsGamves]()
    }
    
    func getFamilyUserById(userId : String) -> GamvesParseUser?
    {
        if youUser.userId == userId
        {
            return youUser
       
        } else if spouseUser.userId == userId
        {
            return spouseUser
        }
        
        var sonwithId = GamvesParseUser()
        
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


class LevelsGamves
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
    var approval = Int()
    
}
