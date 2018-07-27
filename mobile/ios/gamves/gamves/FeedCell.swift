

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

class FeedCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FeedDelegate {
    
    var activityView: NVActivityIndicatorView!
    
    var homeController: HomeController?    
    
    let liveQueryClientFeed: Client = ParseLiveQuery.Client(server: Global.localWs) // .localWs)
  
    private var subscription: Subscription<PFObject>!
    
    var queryChatFeed:PFQuery<PFObject>!
    
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



        /*let homeImage = "background"
        let image = UIImage(named: homeImage)        

        self.collectionView.backgroundView = UIImageView(image: image!)*/
        
        let homeImage = "background_horizontal"
        let image = UIImage(named: homeImage)
        
        self.collectionView.backgroundView = UIImageView(image: image!)
        
        
        
        
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
        
        ChatFeedMethods.sortFeedByDate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            self.collectionView.reloadData()
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(ChatFeedMethods.chatFeeds.count)
        return ChatFeedMethods.chatFeeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let index = indexPath.item
        let key: Int = Array(ChatFeedMethods.chatFeeds)[index].key
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[key]!
        
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
                //cell.badgeLabel.layer.backgroundColor = UIColor.gamvesLightGrayColor.cgColor
                cell.badgeLabel.isHidden = true
            }
            
        } else {
            cell.badgeLabel.isHidden = true
        } 


        //let gr = Gradients()        
        //var gradient : CAGradientLayer = CAGradientLayer()
        
        /*let gr = Gradients()        
        let randomIndex = Int(arc4random_uniform(UInt32(gr.colors.count)))
        let descgradient = Array(gr.colors)[randomIndex].key
        if gr.colors[descgradient] != nil
        {
            let gradient: CAGradientLayer  = gr.getGradientByDescription(descgradient)
            gradient.frame = CGRect(x: 0, y: 0,width: cell.frame.width, height: cell.frame.height) //cellC.image.bounds
            cell.layer.insertSublayer(gradient, at: 0)            
        }*/

        //cell.backgroundColor = Global.notificationColorArray[randomIndex]  

        //gradient = gr.getPastelGradient(randomIndex) 
        //gradient.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        //cell.layer.insertSublayer(gradient, at: 0)       

        let gr = Gradients()
        
        var gradient : CAGradientLayer = CAGradientLayer()

        //let randomIndex = Int(arc4random_uniform(UInt32(Global.pasterColorArray.count)))        

        gradient = gr.getPastelGradient()        
        gradient.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        cell.layer.insertSublayer(gradient, at: 0)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()
        
        let index = indexPath.item
        let key: Int = Array(ChatFeedMethods.chatFeeds)[index].key
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[key]!
    
        print(chatfeed.chatId)
        
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


















