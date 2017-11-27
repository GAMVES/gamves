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


class GamvesParseUser
{
    var gamvesUser:PFUser! = nil
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
    var levelNumber = Int()
    var levelDescription = String()
    var typeNumber = Int()
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
    var video_category = String()
    var video_title = String()
    
    var video_fromName = String()
    var description = String()
    
    var thum_image = UIImage()
    
    var thumb_url = String()
    var video_url = String()
    
    var fanpageId = String()
    
    var videoId = String()
    
    var videoobj:PFObject?
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


class UserStatistics
{
    var desc = String()
    var data = String()
    var icon = UIImage()
}
