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
    var chatId:Int64?
    var userId: String?
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
    var avatar = UIImage()
    var isAvatarDownloaded = Bool()
    var isAvatarQuened = Bool()
    var isSender = Bool()
    var levelNumber = Int()
    var levelDescription = String()
    var typeNumber = Int()
    var typeDescription = String()
    var status = String()
    var chatId = Int64()
    var isChecked = Bool()
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

class GamvesFamily
{
    var sonUser:GamvesParseUser!
    var registerUser:GamvesParseUser!
    var spouseUser:GamvesParseUser!
    var doughterUser:GamvesParseUser!
    
    var familyName = String()
    var objectId = String()
    var school = String()
    
    func getFamilyUserById(userId : String) -> GamvesParseUser
    {
        if sonUser.userId == userId
        {
            return sonUser
        } else if registerUser.userId == userId
        {
            return registerUser
        } else if spouseUser.userId == userId
        {
            return spouseUser
        } else if doughterUser.userId == userId
        {
            return doughterUser
        } else
        {
            return sonUser
        }
    }
}


