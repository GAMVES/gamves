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
    
    let liveQueryClientFeed: Client = ParseLiveQuery.Client(server: Global.localWs) // .remoteWs .localWs
    
    //"wss://gamves.back4app.io"
    //"https://pg-app-z97yidopqq2qcec1uhl3fy92cj6zvb.scalabl.cloud/1/"
    
    private var subscription: Subscription<PFObject>!
    
    var queryChatFeed:PFQuery<PFObject>!
    
    let cellId = "cellId"

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.gamvesBackgoundColor
        
        self.collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        self.registerLiveQuery()
        
        let floaty = Floaty()
        floaty.addItem(title: "New Group", handler: { item in
        
            self.selectContact(group: true)
        })
        
        floaty.addItem(title: "Select Contact", handler: { item in
            
            self.selectContact(group: false)
            
        })
        
        floaty.paddingY = 110
        
        self.view.addSubview(floaty)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadChatFeed), name: NSNotification.Name(rawValue: Global.notificationKeyChatFeed), object: nil)

    }
    
    
    func loadChatFeed()
    {
        self.collectionView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
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
    
    func reloadCollectionView() {
        
        ChatFeedMethods.sortFeedByDate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.collectionView?.reloadData()
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        print(ChatFeedMethods.chatFeeds.count)
        return ChatFeedMethods.chatFeeds.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let index = indexPath.item
        let key: Int = Array(ChatFeedMethods.chatFeeds)[index].key
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[key]!
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]        
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
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(self.chatLauncher, animated: true)
    }

    
    func selectGroupName(users: [GamvesUser])
    {
        groupNameViewController.view.backgroundColor = UIColor.white
        groupNameViewController.gamvesUsers = users
        groupNameViewController.chatFeedViewController = self
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(groupNameViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}





