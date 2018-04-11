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

class GamvesNotification {

    var objectId = String()
    var avatar:UIImage?
    var cover:UIImage?    
    var referenceId = Int()
    var title = String()
    var description = String()
    var date = Date()
    var video = VideoGamves()
    var fanpage = FanpageGamves()
    var type = Int()
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
    
    var levelId = String()
    
    var typeNumber = Int()
    var typeObj:PFObject!
    
    var typeDescription = String()
    var status = String()
    var chatId = Int()
    var isChecked = Bool()
    var gender = GamvesGender()
}


class LevelsGamves {

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

class VideoGamves {

    var title = String()
    var description = String()
    var videoId = Int()
    var categoryName = String()
    var thumbnail:PFFile?
    var s3_source = String()        
    var ytb_thumbnail_source = String()
    var ytb_videoId = String()
    var ytb_upload_date = Date()
    var ytb_view_count = Int()
    var ytb_tags = [String]()
    var ytb_duration = Double()
    var ytb_categories = [String]()
    //var ytb_like_count = Int()
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

class CategoryGamves {

    var cover = String()
    var name = String()
    
    var cover_image = UIImage()
    var thum_image  = UIImage()
    
    var cateobj:PFObject?
    
    var fanpages = [FanpageGamves]()
    
    var selected = Bool()
    
    var order = Int()
}

class FanpageGamves {

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
    
    var videos = [VideoGamves]()
    
    var fanpageObj:PFObject?
    
    var categoryObj:PFObject?
    var categoryName = String()
    
    var fanpage_images  = [FanpageImageGamves]()
    
    var isFavorite = Bool()
    var favoritePF:PFObject?
}

class FanpageImageGamves {

    var albumPF:PFObject!
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


class GamvesFamily {

    var sonsUsers:[GamvesUser]!
    var levels:[LevelsGamves]!
    
    var youUser:GamvesUser!
    var registerUser:GamvesUser!
    var spouseUser:GamvesUser!
    
    var familyName = String()
    var objectId = String()
    var school = String()
    
    var sonRegisterChatId = Int()
    var sonSpouseChatId = Int()
    var familyChatId = Int()    
    
    var familyImage = UIImage()
    
    init()
    {
        self.sonsUsers = [GamvesUser]()
        self.levels = [LevelsGamves]()
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
