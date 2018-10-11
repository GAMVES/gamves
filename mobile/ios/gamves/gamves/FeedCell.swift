

//
//  FeedCell.swift
//  youtube
//
//  Created by Jose Vigil on 12/12/17.
//

import UIKit
import Parse
import ParseLiveQuery
import Floaty
import NVActivityIndicatorView
import PopupDialog

class FeedCell: BaseCell, 
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout, 
FeedDelegate {
    
    var activityView: NVActivityIndicatorView!
    
    var homeController: HomeController?    
    
    let liveQueryClientFeed: Client = ParseLiveQuery.Client(server: Global.localWs) // .localWs)
  
    private var subscription: Subscription<PFObject>!
    
    var queryChatFeed:PFQuery<PFObject>!

    let sectionHeaderId = "feedSectionHeader"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellId = "cellId"

    var floaty = Floaty(size: 80)     
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .brown
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.delegateFeed = self
    
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        self.activityView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)//,x: 0, y: 0, width: 80.0, height: 80.0)
        
        self.collectionView.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        self.registerLiveQuery()        
        
        //FLOATY             

        self.floaty.paddingY = 35
        self.floaty.paddingX = 20                    
        self.floaty.itemSpace = 30
        self.floaty.shadowRadius = 20
        self.floaty.hasShadow = true
        self.floaty.shadowColor = UIColor.black
        self.floaty.buttonColor = UIColor.gamvesGreenColor
        var addImage = UIImage(named: "add_symbol")
        addImage = addImage?.maskWithColor(color: UIColor.white)
        addImage = Global.resizeImage(image: addImage!, targetSize: CGSize(width:40, height:40))
        self.floaty.buttonImage = addImage
        self.floaty.sizeToFit()

        //floaty.verticalDirection = .down        
        
        let itemNewGroup = FloatyItem()
        var groupAddImage = UIImage(named: "group_add")
        groupAddImage = groupAddImage?.maskWithColor(color: UIColor.white)
        itemNewGroup.icon = groupAddImage
        itemNewGroup.buttonColor = UIColor.gamvesGreenColor
        itemNewGroup.titleLabelPosition = .left
        itemNewGroup.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemNewGroup.title = "NEW GROUP"
        itemNewGroup.handler = { item in
            
            if self.homeController != nil {
                self.homeController?.selectContact(group: true)
            }
        }

        let itemNewChat = FloatyItem()    
        var chatRoomImage = UIImage(named: "chat_room_black")
        chatRoomImage = chatRoomImage?.maskWithColor(color: UIColor.white)
        itemNewChat.icon = chatRoomImage
        itemNewChat.buttonColor = UIColor.gamvesGreenColor
        itemNewChat.titleLabelPosition = .left
        itemNewChat.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemNewChat.title = "NEW CHAT"
        itemNewChat.handler = { item in
            
            if self.homeController != nil {
                self.homeController?.selectContact(group: false)
            }    

        }
        
        let itemAddFriend = FloatyItem()
        var addFriendImage = UIImage(named: "friend_add")
        addFriendImage = addFriendImage?.maskWithColor(color: UIColor.white)
        itemAddFriend.icon = addFriendImage
        itemAddFriend.buttonColor = UIColor.gamvesGreenColor
        itemAddFriend.titleLabelPosition = .left
        itemAddFriend.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemAddFriend.title = "ADD FRIEND"
        itemAddFriend.handler = { item in
            
            if self.homeController != nil {
                self.homeController?.addFriend()
            }    

        }

        self.floaty.addItem(item: itemNewGroup)  
        self.floaty.addItem(item: itemNewChat)  
        self.floaty.addItem(item: itemAddFriend)       
        self.addSubview(floaty) 
        
        let homeImage = "background_horizontal"
        let image = UIImage(named: homeImage)
        
        self.collectionView.backgroundView = UIImageView(image: image!)

        self.collectionView.register(FeedSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: sectionHeaderId)
        
    }
    
    override func layoutSubviews() {
        self.reloadCollectionView()
    }
    
    func registerLiveQuery() {
    
        queryChatFeed = PFQuery(className: "ChatFeed")
        
        if let userId = PFUser.current()?.objectId {
            queryChatFeed.whereKey("members", contains: userId)
        }
        
        self.subscription = liveQueryClientFeed.subscribe(queryChatFeed).handle(Event.created) { _, chatFeed in
            
            ChatFeedMethods.parseChatFeed(chatFeedObjs: [chatFeed], completionHandler: { ( restul:Int ) -> () in
                
                self.collectionView.reloadData()
            })           
        }
        
        self.subscription = liveQueryClientFeed.subscribe(queryChatFeed).handle(Event.updated) { _, chatFeed in
            
            ChatFeedMethods.parseChatFeed(chatFeedObjs: [chatFeed], completionHandler: { ( restul:Int ) -> () in
                
                self.collectionView.reloadData()
            })
        }
        
        self.collectionView.reloadData()
        
    }
    

    func fetchFeed() {
    
        self.activityView.startAnimating()
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
            if error == nil {
                
                let chatFeddsCount = chatfeeds?.count
                
                if chatFeddsCount! > 0 {
                    
                    let chatfeedsCount =  chatfeeds?.count
                    
                    ChatFeedMethods.parseChatFeed(chatFeedObjs: chatfeeds!, completionHandler: { ( restul:Int ) -> () in
                        
                        self.collectionView.reloadData()
                        self.activityView.stopAnimating()
                    })
                    
                } else {
                    self.activityView.stopAnimating()
                }
                
            }
        })
    
    }
    
    
    func uploadData() {
        self.reloadCollectionView()
    }
    
    func reloadCollectionView() {
        
        ChatFeedMethods.sortAllFeeds()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            self.collectionView.reloadData()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = ChatFeedMethods.numChatFeedSections
        print(count)
        return count
    }
        
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
                
        var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! FeedSectionHeader
        
        sectionHeaderView.backgroundColor = UIColor.black

        let sections = ChatFeedMethods.numChatFeedSections

        // Handle what is has and adjust accordingly
        
        if indexPath.section == 0 {
            
            var image  = UIImage(named: "family")?.withRenderingMode(.alwaysTemplate)
            image = image?.maskWithColor(color: UIColor.white)            
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "Family"   

        }  else if indexPath.section == 1 {
            
            var image  = UIImage(named: "admin")?.withRenderingMode(.alwaysTemplate)
            image = image?.maskWithColor(color: UIColor.white)            
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "Admin"

        } else {

            let has = hasFriendsAndVideSections(index: indexPath.section)
            
            if has == 1 {

                var image  = UIImage(named: "friends")?.withRenderingMode(.alwaysTemplate)
                image = image?.maskWithColor(color: UIColor.white)            
                sectionHeaderView.iconImageView.image = image
                
                sectionHeaderView.nameLabel.text = "Friends"

            } else if has == 2 {        
            
                var image  = UIImage(named: "video")?.withRenderingMode(.alwaysTemplate)
                image = image?.maskWithColor(color: UIColor.white)            
                sectionHeaderView.iconImageView.image = image
                
                sectionHeaderView.nameLabel.text = "Videos"

            }
        }
        
        return sectionHeaderView
        
    }

    func hasFriendsAndVideSections(index: Int) -> Int
    {
        var result = 0

        if index == 2 && ChatFeedMethods.chatFeedFriends.count > 0 {           

            result = 1

        } else if index == 3 && ChatFeedMethods.chatFeedVideos.count > 0 {

            result = 2
        }

        return result
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

         var countItems = Int()
        
        if section == 0 {
            
            countItems = ChatFeedMethods.chatFeedFamily.count
            
        } else if section == 1 {
            
            countItems = ChatFeedMethods.chatFeedAdmin.count  

        } else {

            let has = hasFriendsAndVideSections(index: section)
            
            if has == 1 {

                countItems = ChatFeedMethods.chatFeedFriends.count

            } else if has == 2 {      

                countItems = ChatFeedMethods.chatFeedVideos.count                
            }

        }

        print(countItems)
        
        return countItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let index = indexPath.item

        let section = indexPath.section

        var chatfeed = ChatFeed()

        if section == 0 {           

            let key: Int = Array(ChatFeedMethods.chatFeedFamily)[index].key
            chatfeed = ChatFeedMethods.chatFeedFamily[key]!
            
        } else if section == 1 {           
            
            let key: Int = Array(ChatFeedMethods.chatFeedAdmin)[index].key
            chatfeed = ChatFeedMethods.chatFeedAdmin[key]!

        } else {

            let has = hasFriendsAndVideSections(index: section)
            
            if has == 1 {

                let key: Int = Array(ChatFeedMethods.chatFeedFriends)[index].key
                chatfeed = ChatFeedMethods.chatFeedFriends[key]!

            } else if has == 2 {      

                let key: Int = Array(ChatFeedMethods.chatFeedVideos)[index].key
                chatfeed = ChatFeedMethods.chatFeedVideos[key]!   
            }
        }        
        
        cell.nameLabel.text = chatfeed.room
        
        print(chatfeed.room)

        var message = String()
        
        message = chatfeed.text!

        if message.range(of:Global.admin_delimitator) != nil {
            
            if let range = message.range(of: Global.admin_delimitator) {
                message.removeSubrange(range)
            }
            
            cell.audioIconView.isHidden = true
            cell.pictureIconView.isHidden = true
        
        } else if message.range(of:Global.audio_delimitator) != nil {
            
            if let range = message.range(of: Global.audio_delimitator) {
                
                message.removeSubrange(range)
                
                if (message.contains("----")) {
                    
                    let messageArr : [String] = message.components(separatedBy: "----")
                    
                    var audioId : String = messageArr[0]
                    var audioTime : String = messageArr[1]
                    
                    cell.audioIconView.isHidden = false
                    cell.pictureIconView.isHidden = true
                    
                    message = "      \(audioTime)"
                    
                }
            }
            
        } else if message.range(of:Global.picture_delimitator) != nil {
            
            if let range = message.range(of: Global.picture_delimitator) {
                
                message.removeSubrange(range)
                
                if (message.contains("----")) {
                    
                    let messageArr : [String] = message.components(separatedBy: "----")
                    
                    var pictureId : String = messageArr[0]
                    var chatId : String = messageArr[1]
                    
                    cell.audioIconView.isHidden = true
                    cell.pictureIconView.isHidden = false
                    
                    message = "        Photo"
                }
            }
            
        } else {
            
            cell.audioIconView.isHidden = true
            cell.pictureIconView.isHidden = true
            
        }
        
        cell.messageLabel.text = message
        
        cell.profileImageView.image = chatfeed.chatThumbnail
        
        if chatfeed.lasPoster != nil {
            
            let userId = chatfeed.lasPoster!
            let gamvesUser = Global.userDictionary[userId]
            cell.hasReadImageView.image = gamvesUser?.avatar
        }
        
        var image = String()
        
        if (chatfeed.isVideoChat)! {
            image = "movie"
        } else {
            image = "group"
        }
        
        let imagetype = UIImage(named: image)
        cell.isImageView.image = imagetype
        
        let elapsedTime = chatfeed.date?.elapsedTime
        
        cell.timeLabel.text = elapsedTime
        
        if chatfeed.badgeNumber != nil {
            
            if chatfeed.badgeNumber! > 0 {
                
                let number = chatfeed.badgeNumber
                cell.badgeLabel.isHidden = false
                
                if let textNumber = number {
                    cell.badgeLabel.text = String (textNumber)
                }
            
            } else {
                
                cell.badgeLabel.text = ""                
                cell.badgeLabel.isHidden = true
            }
            
        } else {
            cell.badgeLabel.isHidden = true
        } 

        let gr = Gradients()
        
        var gradient : CAGradientLayer = CAGradientLayer()       

        gradient = gr.getPastelGradient()        
        gradient.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        cell.layer.insertSublayer(gradient, at: 0)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()
        
        /*let index = indexPath.item
        let key: Int = Array(ChatFeedMethods.chatFeeds)[index].key
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[key]!
    
        print(chatfeed.chatId)*/

        let index = indexPath.item

        let section = indexPath.section

        var chatfeed = ChatFeed()

        if section == 0 {           

            let key: Int = Array(ChatFeedMethods.chatFeedFamily)[index].key
            chatfeed = ChatFeedMethods.chatFeedFamily[key]!
            
        } else if section == 1 {           
            
            let key: Int = Array(ChatFeedMethods.chatFeedAdmin)[index].key
            chatfeed = ChatFeedMethods.chatFeedAdmin[key]!

        } else {

            let has = hasFriendsAndVideSections(index: section)
            
            if has == 1 {

                let key: Int = Array(ChatFeedMethods.chatFeedFriends)[index].key
                chatfeed = ChatFeedMethods.chatFeedFriends[key]!

            } else if has == 2 {      

                let key: Int = Array(ChatFeedMethods.chatFeedVideos)[index].key
                chatfeed = ChatFeedMethods.chatFeedVideos[key]!   
            }
        } 
        
        let isVideoChat:Bool = chatfeed.isVideoChat! as Bool
        
        if isVideoChat {
            
            let chatId = chatfeed.chatId! as Int
            print(chatId)
            var video = GamvesVideo()
                
            video = Global.chatVideos[chatId]!
            
            print(video.ytb_videoId)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)
            
            let videoLauncher = VideoLauncher()
            videoLauncher.showVideoPlayer(videoGamves: video)
            
        } else {
            
            if self.homeController != nil {
                self.homeController?.openChat(room: chatfeed.room!, chatId: chatfeed.chatId!, users: chatfeed.users!)
            }
        }
    }
}


















