//
//  ChatLogController.swift
//  fbMessenger
//
//  Created by Jose Vigil 08/12/2017.
//

import UIKit
import Parse
import ParseLiveQuery
import Floaty
import NVActivityIndicatorView


class ChatFeedViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var activityView: NVActivityIndicatorView!
    
    var tabBarViewController:TabBarViewController?
    
    let liveQueryClientFeed: Client = ParseLiveQuery.Client(server: Global.localWs) 
    
    private var subscription: Subscription<PFObject>!
    
    var queryChatFeed:PFQuery<PFObject>!
    
    let cellId = "cellId"
    let sectionHeaderId = "feedSectionHeader"

    lazy var selectContactViewController: SelectContactViewController = {
        let selector = SelectContactViewController()
        return selector
    }()

    lazy var chatLauncher: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()
    
    lazy var groupNameViewController: GroupNameViewController = {
        let groupName = GroupNameViewController()
        return groupName
    }()
    
    var floaty = Floaty(size: 80)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.gamvesBackgoundColor
        
        self.collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView?.register(FeedSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: self.sectionHeaderId)
        
        self.registerLiveQuery()

        self.floaty.paddingY = 70
        self.floaty.paddingX = 25                    
        self.floaty.itemSpace = 30        
        
        self.floaty.hasShadow = true
        self.floaty.buttonColor = UIColor.gamvesColor
        var addImage = UIImage(named: "add_symbol")
        addImage = addImage?.maskWithColor(color: UIColor.white)
        addImage = Global.resizeImage(image: addImage!, targetSize: CGSize(width:40, height:40))
        self.floaty.buttonImage = addImage
        self.floaty.sizeToFit()

        let itemNewGroup = FloatyItem()
        var groupAddImage = UIImage(named: "group_add")
        groupAddImage = groupAddImage?.maskWithColor(color: UIColor.white)
        itemNewGroup.icon = groupAddImage
        itemNewGroup.buttonColor = UIColor.gamvesColor
        itemNewGroup.titleLabelPosition = .left
        itemNewGroup.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemNewGroup.title = "NEW GROUP"
        itemNewGroup.handler = { item in
            
            self.selectContact(group: true)
        }

        let itemSelectGroup = FloatyItem()
        var groupContactImage = UIImage(named: "account")
        groupContactImage = groupContactImage?.maskWithColor(color: UIColor.white)
        itemSelectGroup.icon = groupContactImage
        itemSelectGroup.buttonColor = UIColor.gamvesColor
        itemSelectGroup.titleLabelPosition = .left
        itemSelectGroup.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemSelectGroup.title = "SELECT CONTACT"
        itemSelectGroup.handler = { item in
            
            self.selectContact(group: false)
        }
        
        self.floaty.addItem(item: itemNewGroup)  
        self.floaty.addItem(item: itemSelectGroup)               
        self.view.addSubview(floaty)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadChatFeed), name: NSNotification.Name(rawValue: Global.notificationKeyChatFeed), object: nil)

    }
    
    
    @objc func loadChatFeed()
    {
        self.collectionView?.reloadData()
    }

    func reloadCollectionView() {
        
        ChatFeedMethods.sortAllFeeds()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            self.collectionView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    func layoutSubviews() {
        self.reloadCollectionView()
    }
    
    
    func registerLiveQuery()
    {
        
        queryChatFeed = PFQuery(className: "ChatFeed")
        
        if let userId = PFUser.current()?.objectId
        {
            queryChatFeed.whereKey("members", contains: userId)
        }
        
        self.subscription = liveQueryClientFeed.subscribe(queryChatFeed).handle(Event.created) { _, chatFeed in
            
            ChatFeedMethods.parseChatFeed(chatFeedObjs: [chatFeed], completionHandler: { ( restul:Int ) -> () in
                
                self.collectionView?.reloadData()
                
            })
            
        }
        
        self.subscription = liveQueryClientFeed.subscribe(queryChatFeed).handle(Event.updated) { _, chatFeed in
            
            ChatFeedMethods.parseChatFeed(chatFeedObjs: [chatFeed], completionHandler: { ( restul:Int ) -> () in
                
                self.collectionView?.reloadData()
                
            })
            
        }
        
        //self.fetchFeed()
        
        self.collectionView?.reloadData()
        
    }
    
    func fetchFeed()
    {
        
        self.activityView.startAnimating()
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
            if error == nil
            {
                
                let chatFeddsCount = chatfeeds?.count
                
                if chatFeddsCount! > 0
                {
                    let chatfeedsCount =  chatfeeds?.count
                    
                    ChatFeedMethods.parseChatFeed(chatFeedObjs: chatfeeds!, completionHandler: { ( restul:Int ) -> () in
                        
                        self.collectionView?.reloadData()
                        self.activityView.stopAnimating()
                        
                    })
                    
                } else
                {
                    self.activityView.stopAnimating()
                }
            }
        })
    }
    
    
    func uploadData()
    {
        self.reloadCollectionView()
    }
    
    /*func reloadCollectionView() {
        
        ChatFeedMethods.splitFeedSection()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.collectionView?.reloadData()
        }
    }*/

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = ChatFeedMethods.numChatFeedSections
        print(count)
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
                
        var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! FeedSectionHeader
        
        sectionHeaderView.backgroundColor = UIColor.black

        let sections = ChatFeedMethods.numChatFeedSections

        // Handle what is has and adjust accordingly
        
        if indexPath.section == 0 {
            
            var image  = UIImage(named: "admin_chat")?.withRenderingMode(.alwaysTemplate)
            image = image?.maskWithColor(color: UIColor.white)            
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "Admin"           

        } else {

            let has = hasFriendsAndVideSections(index: indexPath.section)
            
            if has == 1 {

                var image  = UIImage(named: "family_chat")?.withRenderingMode(.alwaysTemplate)
                image = image?.maskWithColor(color: UIColor.white)            
                sectionHeaderView.iconImageView.image = image
                
                sectionHeaderView.nameLabel.text = "Family" 

            } else if has == 2 {   

                var image  = UIImage(named: "friends")?.withRenderingMode(.alwaysTemplate)
                image = image?.maskWithColor(color: UIColor.white)            
                sectionHeaderView.iconImageView.image = image
                
                sectionHeaderView.nameLabel.text = "Friends"

            } else if has == 3 {        
            
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

        if index == 1 && ChatFeedMethods.chatFeedFamily.count > 0 {           

            result = 1

        } else if index == 2 && ChatFeedMethods.chatFeedFriends.count > 0 {           

            result = 2

        } else if index == 3 && ChatFeedMethods.chatFeedVideos.count > 0 {

            result = 3
        }

        return result
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

         var countItems = Int()
        
        if section == 0 {
            
            countItems = ChatFeedMethods.chatFeedAdmin.count           

        } else {

            let has = hasFriendsAndVideSections(index: section)

            if has == 1 {

                countItems = ChatFeedMethods.chatFeedFamily.count

            } else if has == 2 {

                countItems = ChatFeedMethods.chatFeedFriends.count

            } else if has == 3 {      

                countItems = ChatFeedMethods.chatFeedVideos.count                
            }

        }

        print(countItems)
        
        return countItems
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let index = indexPath.item

        let section = indexPath.section

        var chatfeed = ChatFeed()

         if section == 0 {           

            let key: Int = Array(ChatFeedMethods.chatFeedAdmin)[index].key
            chatfeed = ChatFeedMethods.chatFeedAdmin[key]!            

        } else {

            let has = hasFriendsAndVideSections(index: section)
            
            if has == 1 {

                let key: Int = Array(ChatFeedMethods.chatFeedFamily)[index].key
                chatfeed = ChatFeedMethods.chatFeedFamily[key]!

            } else if has == 2 {      

                let key: Int = Array(ChatFeedMethods.chatFeedFriends)[index].key
                chatfeed = ChatFeedMethods.chatFeedFriends[key]!

            } else if has == 3 {      

                let key: Int = Array(ChatFeedMethods.chatFeedVideos)[index].key
                chatfeed = ChatFeedMethods.chatFeedVideos[key]!   
            }
        }    
        
        cell.nameLabel.text = chatfeed.room

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
        
        if chatfeed.lasPoster != nil
        {
            let userId = chatfeed.lasPoster!
            
            let gamvesUser = Global.userDictionary[userId]
            
            cell.hasReadImageView.image = gamvesUser?.avatar
        }
        
        var image = String()
        
        if (chatfeed.isVideoChat)!
        {
            image = "movie"
        } else
        {
            image = "group"
        }
        
        let imagetype = UIImage(named: image)
        cell.isImageView.image = imagetype
        
        let elapsedTime = chatfeed.date?.elapsedTime
        
        cell.timeLabel.text = elapsedTime
        
        if chatfeed.badgeNumber != nil
        {
            if chatfeed.badgeNumber! > 0
            {
                let number = chatfeed.badgeNumber
                
                cell.badgeLabel.isHidden = false
                
                if let textNumber = number
                {
                    cell.badgeLabel.text = String (textNumber)
                }
                
            } else
            {
                cell.badgeLabel.text = ""
                //cell.badgeLabel.layer.backgroundColor = UIColor.gamvesLightGrayColor.cgColor
                cell.badgeLabel.isHidden = true
            }
        } else
        {
            cell.badgeLabel.isHidden = true
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {        
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
            
            print(video.videoId)
            
            let videoApprovalLauncher = VideoApprovalLauncher()
            videoApprovalLauncher.showVideoPlayer(videoGamves: video, approved: 1)
            
        } else {
            
            self.openChat(room: chatfeed.room!, chatId: chatfeed.chatId!, users: chatfeed.users!)
        
        }
    }
    
    func selectContact(group: Bool)
    {
        selectContactViewController.isGroup = group
        selectContactViewController.chatFeedViewController = self
        selectContactViewController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]        
        navigationController?.pushViewController(selectContactViewController, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    func openChat(room: String, chatId:Int, users:[GamvesUser])
    {
        self.chatLauncher.chatId = chatId
        self.chatLauncher.gamvesUsers = users
        self.chatLauncher.room = room
        chatLauncher.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(self.chatLauncher, animated: true)
    }

    
    func selectGroupName(users: [GamvesUser])
    {
        groupNameViewController.view.backgroundColor = UIColor.white
        groupNameViewController.gamvesUsers = users
        groupNameViewController.chatFeedViewController = self
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(groupNameViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}





