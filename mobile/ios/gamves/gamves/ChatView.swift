////
//  ChatView.swift
//  gamves
//
//  Created by Jose Vigil on 9/3/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery
import NVActivityIndicatorView
import PopupDialog

class MessageChat
{
    var message:String!
    var chatId = Int()
    var userId = String()    
    var userName = String()
    var date: Date?
    var isSender:Bool!
    var isAdmin:Bool!
}

class ChatView: UIView,
	UICollectionViewDataSource,
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout, 
    UITextFieldDelegate
{
    
    var activityView: NVActivityIndicatorView!

    let liveQueryClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .lremoteWs)
    
    private var chatSubscription: Subscription<PFObject>!
    private var feedSubscription: Subscription<PFObject>!
    private var onlineSubscription: Subscription<PFObject>!

    var messages = [MessageChat]()
    var chatId = Int()
    var chatIdStr = String()
    var isVideoChat = Bool()
    var thumbnailImage = UIImage()
    
    var gamvesUsers = [GamvesParseUser]()
    var gamvesUsersArray = [String]()
    var gamvesUsersPFuser = [PFUser]()
    
    var chatFeed:PFObject!
    var delegate:KeyboardDelegate!
    var delegateNavBar:NavBarDelegate!
    var isVideo = Bool()
    
    private let cellId = "cellId"
    
    var bottomConstraint: NSLayoutConstraint?
    var blockOperations = [BlockOperation]()

    let chatLineAboveView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()

    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chat_room")
        return imageView
    }()

     let chatLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Chat room"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .left
        return label
    }()

    let chatHolderView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let chatLineBelowView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.send
        return textField
    }()


    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        let sendImage = UIImage(named: "send")
        sendImage?.maskWithColor(color: UIColor.gamvesColor)
        button.setImage(sendImage, for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    init(frame: CGRect, isVideo:Bool) {
        super.init(frame: frame)
        
        self.frame = frame
        
        self.inputTextField.delegate = self
        
        self.isVideo = isVideo
        
        self.backgroundColor = UIColor.blue
        
        if isVideo
        {
            self.addSubview(self.titleContainerView)
            self.addConstraintsWithFormat("H:|[v0]|", views: self.titleContainerView)
            
            self.titleContainerView.addSubview(self.chatLineAboveView)
            self.titleContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.chatLineAboveView)
            
            self.titleContainerView.addSubview(self.chatHolderView)
            self.titleContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.chatHolderView)
            
            self.titleContainerView.addSubview(self.chatLineBelowView)
            self.titleContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.chatLineBelowView)
            
            self.titleContainerView.addConstraintsWithFormat("V:|[v0(0.5)][v1(29)][v2(0.5)]|", views: self.chatLineAboveView, self.chatHolderView, self.chatLineBelowView)

        }
    
        self.addSubview(self.collectionView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        
        //self.collectionView.backgroundColor = UIColor.gray
        
        self.collectionView.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        self.addSubview(self.messageInputContainerView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.messageInputContainerView)
        
        let editSize = 48
        let metricsMessageView = ["editSize": editSize]
        
        if isVideo
        {
            
            self.addConstraintsWithFormat("V:|[v0(30)][v1][v2(editSize)]|", views: self.titleContainerView, self.collectionView, self.messageInputContainerView, metrics: metricsMessageView)
        } else
        {
            self.addConstraintsWithFormat("V:|-3-[v0][v1(editSize)]|", views: self.collectionView, self.messageInputContainerView, metrics: metricsMessageView)
        }
        
        self.chatHolderView.addSubview(self.chatImageView)
        self.chatHolderView.addSubview(self.chatLabel)
        
        self.chatHolderView.addConstraintsWithFormat("H:|-10-[v0(19.5)]-10-[v1]|", views: self.chatImageView, self.chatLabel)
        
        self.chatHolderView.addConstraintsWithFormat("V:|-5-[v0(19.5)]-5-|", views: self.chatImageView)
        self.chatHolderView.addConstraintsWithFormat("V:|[v0(29.5)]|", views: self.chatLabel)
        
        self.bottomConstraint = NSLayoutConstraint(item: self.messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.addConstraint(self.bottomConstraint!)
        
        self.setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Looks for single or multiple taps.
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        self.activityView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
        
        
        self.collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
    }

    func dismissKeyboard()
    {
        self.endEditing(true)
    }
    

    func setParams(parameters: [String: Any?])
    {
        if parameters["chatId"] != nil {
            self.chatId = parameters["chatId"] as! Int
        }
        if parameters["isVideoChat"] != nil {
            self.isVideoChat = parameters["isVideoChat"] as! Bool
        }
        if parameters["gamvesUsers"] != nil {
            self.gamvesUsers = parameters["gamvesUsers"] as! [GamvesParseUser]
        }
        if parameters["thumbnailImage"] != nil {
            self.thumbnailImage = parameters["thumbnailImage"] as! UIImage
        }
        if parameters["delegate"] != nil {
            self.delegate = parameters["delegate"] as! KeyboardDelegate
        }
        if parameters["navBarProtocol"] != nil {
            self.delegateNavBar = parameters["navBarProtocol"] as! NavBarDelegate
        }
        
        print(self.chatId)
        
        if ChatFeedMethods.chatFeeds[self.chatId] != nil
        {
            
            if ChatFeedMethods.chatFeeds[self.chatId]?.badgeNumber != nil
            {
                if (ChatFeedMethods.chatFeeds[self.chatId]?.badgeNumber)! > 0 {
                    self.clearBargesForChatId()
                }
            }
        }
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadChatFeed()
    {
        
        self.activityView.startAnimating()
        
        print(self.chatId)
        let queryChatFeed = PFQuery(className:"ChatFeed")
        queryChatFeed.whereKey("chatId", equalTo: self.chatId)
        queryChatFeed.findObjectsInBackground { (chatFeeds, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                if let chatFeeds = chatFeeds
                {
                    
                    let chatsAmount = chatFeeds.count
                    
                    print(chatsAmount)
                    
                    if chatsAmount > 0
                    {
                        var total = Int()
                        total = chatsAmount - 1
                        var i = 0
                        
                        for chatFeed in chatFeeds
                        {
                            
                            self.chatFeed = chatFeed
                            
                            var members = chatFeed["members"] as! String
                            
                            let participantQuery = PFQuery(className:"_User")
                            
                            self.gamvesUsersArray = Global.parseUsersStringToArray(separated: members)
                            
                            participantQuery.whereKey("objectId", containedIn: self.gamvesUsersArray)
                            participantQuery.findObjectsInBackground(block: { (users, error) in
    
                                if error != nil
                                {
                                    print("error")
                                    
                                } else {
                                    
                                    if let users = users
                                    {
                                        
                                        var usersAmount = users.count
                                        
                                        print(chatsAmount)
                                        
                                        var total = Int()
                                        total = chatsAmount - 1
                                        var i = 0
                                        
                                        for user in users
                                        {
                                            self.gamvesUsersPFuser.append(user as! PFUser)
                                            
                                            let userId = user.objectId as! String
                                            
                                            if Global.userDictionary[userId] == nil
                                            {
                                        
                                                let gamvesUser = GamvesParseUser()
                                                let isQuened = gamvesUser.isAvatarQuened
                                                gamvesUser.userName = user["Name"] as! String
                                                
                                                if !isQuened
                                                {
                                                    
                                                    let picture = user["pictureSmall"] as! PFFile
                                                    
                                                    picture.getDataInBackground(block: { (data, error) in
                                                        
                                                        let image = UIImage(data: data!)
                                                        gamvesUser.avatar = image!
                                                        gamvesUser.isAvatarDownloaded = true
                                                        gamvesUser.isAvatarQuened = false
                                                        
                                                        if PFUser.current()?.objectId == userId
                                                        {
                                                            gamvesUser.isSender = true
                                                        }

                                                        Global.userDictionary[userId] = gamvesUser as GamvesParseUser
                                                        
                                                    })
                                                }
                                            }
                                            
                                            if i == (usersAmount-1)
                                            {
                                                self.loadChatsVideos(chatFeed: chatFeed, userCount: usersAmount, completionHandler: { ( messagesHandeled ) -> () in
                                            
                                                    //messagesHandeled.sorted(by: {$0.date! < $1.date! })
                                                    
                                                    self.messages = messagesHandeled
                                                    self.collectionView.reloadData()
                                                    self.scrollToLast()
                                                    self.activityView.stopAnimating()
                                                    
                                                })
                                                
                                                if self.isSingleUser() && !self.isVideo
                                                {
                                                    self.initializeOnlineSubcritpion()
                                                }
                                            }
                                            
                                            i = i + 1

                                        }
                                    }
                                }
                            })
                        }
                    } else
                    {
                        
                        self.activityView.stopAnimating()
                        
                        if !self.isVideo
                        {
                        
                            self.addNewFeedAppendUser(completionHandler: { ( result ) -> () in
                            
                                if self.isSingleUser()
                                {
                                    self.initializeOnlineSubcritpion()
                                }
                            })
                        }
                    }
                }
            }
        }
        
        self.initializeSubscription()

    }
    
    func loadChatsVideos(chatFeed:PFObject, userCount:Int, completionHandler : @escaping (_ resutl:[MessageChat]) -> ())
    {
        
        let chatsRealtion = chatFeed["chats"] as! PFRelation
        let chatsQuery = chatsRealtion.query()
        chatsQuery.findObjectsInBackground(block: { (chatVideos, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                if (chatVideos?.count)! > 0
                {
                    
                    let getChatData = chatVideos?.count
                    var i = 0
                    
                    var messagesHandeled = [MessageChat]()
                    
                    for chatVideo in chatVideos!
                    {
                        let message = MessageChat()
                        let userId = chatVideo["userId"] as! String
                        message.userId = userId
                        message.message = chatVideo["message"] as! String
                        message.date = chatVideo.createdAt
                        message.chatId = chatVideo["chatId"] as! Int
                        
                        if PFUser.current()?.objectId == userId
                        {
                            message.isSender = true
                        }
                        
                        messagesHandeled.append(message)
                        
                        if (getChatData!-1) == i
                        {
                            completionHandler(messagesHandeled)
                            
                        }
                        i = i + 1
                        
                    }
                } else
                {
                    self.activityView.stopAnimating()
                }
            }
        })
    }
    
    
    func initializeSubscription()
    {
        
        let videoQuery = PFQuery(className: "ChatVideo").whereKey("chatId", equalTo: self.chatId)
        
        self.chatSubscription = liveQueryClient.subscribe(videoQuery).handle(Event.created) { _, chatMessage in
            
            self.updateMessageFromServer(chatMessage: chatMessage)
            
            self.clearBargesForChatId()
            
        }
        
        let feedQuery = PFQuery(className: "ChatFeed").whereKey("chatId", equalTo: self.chatId)
        
        self.feedSubscription = liveQueryClient.subscribe(feedQuery).handle(Event.created) { _, chatMessage in
            
            self.clearBargesForChatId()
            
        }
        
    }
    
    func handleSend()
    {
        
        //Channel exists and isVideo
        
        if self.isVideo && ChatFeedMethods.chatFeeds[self.chatId] == nil
        {
         
            if self.chatFeed == nil
            {
                self.activityView.startAnimating()
                
                self.addNewFeedAppendUser(completionHandler: { ( result:Bool ) -> () in
                    
                    if result
                    {
                        self.sendMessage(sendPush: false)
                        
                        self.activityView.stopAnimating()
                    }
                    
                })

            } else
            {
             
                if let userId:String = PFUser.current()?.objectId
                {
                    
                    self.activityView.startAnimating()
                    
                    self.chatIdStr = String(self.chatId) as String
                    
                    Global.addChannels(userIds:[userId], channel: self.chatIdStr, completionHandlerChannel: { ( resutl ) -> () in
                        
                        let members = self.chatFeed["members"] as! String
                        
                        self.gamvesUsersArray = Global.parseUsersStringToArray(separated: members)
                        
                        self.gamvesUsersArray.append(userId)
                        
                        let membersAppend = String(describing: self.gamvesUsersArray)

                        self.chatFeed["members"] = membersAppend
                        
                        self.chatFeed.saveInBackground(block: { (resutl, error) in
                            
                            ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in })
                            
                            self.sendMessage(sendPush: false)
                            
                            self.activityView.stopAnimating()
                            
                        })
                        
                    })
                }
                
            }
            
        } else
        {
            self.sendMessage(sendPush: true)
        }
        
    }
    
    func sendMessage(sendPush:Bool)
    {
        print(inputTextField.text)
        
        let messagePF: PFObject = PFObject(className: "ChatVideo")
        
        var userId = String()
        
        var textMessage = String()
        
        if PFUser.current() != nil
        {
            userId = (PFUser.current()?.objectId)!
            messagePF["userId"] = userId
        }
        
        messagePF["chatId"] = self.chatId
        
        messagePF["message"] = self.inputTextField.text!
        
        UserDefaults.standard.set(self.inputTextField.text!, forKey: "last_message")
        
        var message = self.inputTextField.text!
        
        messagePF.saveInBackground { (resutl, error) in
            
            if error == nil
            {
                
                self.inputTextField.text = ""
                
                if sendPush
                {
                    //self.sendPushWithCoud(message: message)
                }
            }
        }

    }

    
    func sendPushWithCoud(message: String)
    {
        
        if var username = Global.userDictionary[(PFUser.current()?.objectId)!]?.name
        {
            
            if let name = UserDefaults.standard.object(forKey: "last_message")
            {
                
                let jsonObject: [String: Any] = [ "message": "\(message)", "chatId": "\(self.chatId)" ]
                
                let valid = JSONSerialization.isValidJSONObject(jsonObject)
                
                if valid
                {
            
                    let params = ["channels": String(self.chatId), "title": "\(username)", "alert": "\(name)", "data":jsonObject] as [String : Any]
                    
                    print(params)
                    
                    PFCloud.callFunction(inBackground: "push", withParameters: params) { (resutls, error) in
                     
                        print(resutls)
                    }
                }
            }
        }
    }
    
    func sendNotification() {
        
        let pushQuery = PFInstallation.query()
        
        pushQuery?.whereKey("channels", equalTo: "back4app")
        
        let push = PFPush()
        push.setQuery(pushQuery as! PFQuery<PFInstallation>)
        
        //let pushDictionary = ["alert": PFUser.current()!.value(forKey: "name") as! String, "badge": "increment", "sound":""]
        
        let pushDictionary = ["alert": "hola", "badge": "increment", "sound":"", "data":"refresh"]
        
        push.setData(pushDictionary)
        push.sendInBackground(block: nil)
        
    }

    
    func updateMessageFromServer(chatMessage: PFObject)
    {
        
        DispatchQueue.main.async
        {
            self.inputTextField.text = ""
            
            let message = MessageChat()
            let textMessage = chatMessage["message"] as! String
            message.message = textMessage
            
            let userId = chatMessage["userId"] as! String
            message.userId = userId
            message.chatId = chatMessage["chatId"] as! Int
            message.date = chatMessage.updatedAt
            
            if let gamvesUser = Global.userDictionary[userId]
            {
                message.isSender = gamvesUser.isSender
            } else if userId == PFUser.current()?.objectId
            {
                message.isSender = true
            }
            
            let gamvesUser = Global.userDictionary[userId]!
            
            message.isSender = gamvesUser.isSender
            
            self.messages.append(message)
            
            if ChatFeedMethods.chatFeeds[self.chatId] != nil
            {
                ChatFeedMethods.chatFeeds[self.chatId]?.text = textMessage
            }
            
            self.collectionView.reloadData()
            
            self.scrollToLast()
        }
    }
    
    
    func initializeOnlineSubcritpion()
    {
        let userId = self.gamvesUsers[0].userId
        
        let onlineQuery = PFQuery(className: "UserOnline").whereKey("userId", equalTo: userId)
        
        onlineSubscription = liveQueryClient.subscribe(onlineQuery).handle(Event.updated) { _, onlineMessage in
            
            self.changeSingleUserStatus(onlineMessage:onlineMessage)
        }
        
        let queryOnine = PFQuery(className:"UserOnline")
        queryOnine.whereKey("userId", equalTo: userId)
        queryOnine.findObjectsInBackground { (usersOnline, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                if (usersOnline?.count)!>0
                {
                    for monline in usersOnline!
                    {
                        self.changeSingleUserStatus(onlineMessage:monline)
                    }
                }
            }
        }
    }
    
    func changeSingleUserStatus(onlineMessage:PFObject)
    {
        let isOnline = onlineMessage["isOnline"] as! Bool
        
        if isOnline
        {
            delegateNavBar.updateSubTitle(latelText: "Online")
        } else
        {
            let updatedAt = onlineMessage.updatedAt as! Date
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let lastSeen = dateFormatter.string(from: updatedAt)
        
            delegateNavBar.updateSubTitle(latelText: lastSeen)
        }
        
    }
    
    func isSingleUser() -> Bool
    {
        if self.gamvesUsers.count > 1
        {
            return false
        } else {
            return true
        }
    }

    func addNewFeedAppendUser(completionHandler : @escaping (_ resutl:Bool) -> ())
    {
        
        let random = Int()
            
        self.chatFeed = PFObject(className: "ChatFeed")
        
        self.chatFeed["chatId"] = self.chatId
        
        self.chatFeed["isVideoChat"] = self.isVideoChat
        
        let groupImageFile:PFFile!
        
        if isVideoChat
        {
            groupImageFile = PFFile(data: UIImageJPEGRepresentation(self.thumbnailImage, 1.0)!)
            
            let queryVideo = PFQuery(className:"Videos")
            
            let videoId = String(self.chatId)
            
            print(videoId)
            
            queryVideo.whereKey("videoId", equalTo: videoId)
            
            queryVideo.findObjectsInBackground { (videos, error) in
                
                if error != nil
                {
                    print("error")
                    
                    completionHandler(false)
                    
                } else {
                    
                    if let videos = videos
                    {
                        
                        for video in videos
                        {
                            let description = video["description"] as! String
                            
                            self.chatFeed["room"] = description
                            
                            self.saveChatFeed(file: groupImageFile, completionHandlerSave: { ( result:Bool ) -> () in
                                
                                completionHandler(result)
                                
                            })
                        }
                    }
                }
            }
            
        } else
        {
            if self.gamvesUsers.count > 1
            {
            
                let imageGroup = UIImage(named: "community")
                groupImageFile = PFFile(data: UIImageJPEGRepresentation(imageGroup!, 1.0)!)
                
                var array = [String]()
                
                for user in self.gamvesUsers
                {
                    array.append(user.typeObj.objectId!)
                }
                let members = String(describing: array)
                self.chatFeed["members"] = members
                
            } else
            {
        
                groupImageFile = PFFile(data: UIImageJPEGRepresentation(self.gamvesUsers[0].avatar, 1.0)!)
                
                print(PFUser.current())
                
                if let myUser = PFUser.current()?.objectId
                {
                    let member = String(describing: [self.gamvesUsers[0].userId,myUser])
                    self.chatFeed["members"] = member
                    self.chatFeed["room"] = "\(self.gamvesUsers[0].userId)____\(myUser)"
                }
                
            }
            
        }
        
        if !self.isVideo
        {
            self.saveChatFeed(file: groupImageFile, completionHandlerSave: { ( result:Bool ) -> () in
                
                completionHandler(result)
                
            })
        
        }
        
    }
    
    func saveChatFeed(file:PFFile, completionHandlerSave : @escaping (_ resutl:Bool) -> ())
    {
        
        if let objectId = PFUser.current()?.objectId
        {
            self.chatFeed["lastPoster"] = objectId
            
            if self.isVideo
            {
                self.chatFeed["members"] = objectId
                self.chatFeed["lastMessage"] = self.inputTextField.text
            }
        }
        
        self.chatFeed.setObject(file, forKey: "thumbnail")
        
        self.chatIdStr = String(self.chatId) as String

        var message = self.inputTextField.text
        
        self.chatFeed.saveInBackground(block: { (saved, error) in
            
            if error == nil
            {
                
                //CREATE CHANNELS
                
                let userId = (PFUser.current()?.objectId)! as String
                
                var userIdArray = [String]()
                userIdArray.append(userId)
                
                if !self.isVideoChat
                {
                    for user in self.gamvesUsers
                    {
                        userIdArray.append(user.userId)
                    }
                }
                
                Global.addChannels(userIds:userIdArray, channel: self.chatIdStr, completionHandlerChannel: { ( resutl ) -> () in
                    
                    if resutl && !self.isVideo
                    {
                        self.sendPushWithCoud(message: message!)
                    } else
                    {
                        completionHandlerSave(resutl)
                    }
                    
                    completionHandlerSave(resutl)
                })
            }
        })
    }

    
    func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo
        {
            
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            
            if notification.name == NSNotification.Name.UIKeyboardWillShow
            {
               
                let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
                
                if (self.delegate != nil)
                {
                    self.delegate.keyboardOpened(keybordHeight: (keyboardFrame?.height)!)
                }
                
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    
                    self.layoutIfNeeded()
                    self.layoutSubviews()
                    
                }, completion: { (completed) in
                    
                    self.scrollToLast()
                    
                })
                
                
            } else if notification.name == NSNotification.Name.UIKeyboardWillHide
            {
                
                if (self.delegate != nil)
                {
                    self.delegate.keyboardclosed()
                }
                
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    
                    self.layoutIfNeeded()
                    self.layoutSubviews()
                    
                }, completion: { (completed) in
                    
                    self.scrollToLast()
                
                })
            }
        }
    }
    
    
    func clearBargesForChatId()
    {
    
        let queryBadges = PFQuery(className:"Badges")
        
        queryBadges.whereKey("chatId", equalTo: self.chatId)
        
        if let userId = PFUser.current()?.objectId
        {
            queryBadges.whereKey("userId", equalTo: userId)
        }
        queryBadges.findObjectsInBackground { (badges, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                if let badges = badges
                {
                    
                    let badgesAmount = badges.count
                    
                    if badgesAmount > 0
                    {
                        
                        for badge in badges
                        {
                            
                            badge["amount"] = 0
                            badge["seen"] = true
                            
                            badge.saveEventually({ (resutl, error) in
                                
                                print("")
                                
                                ChatFeedMethods.chatFeeds[self.chatId]?.badgeNumber = 0
                                
                                Global.loadBargesNumberForUser(completionHandler: { ( badgeNumber ) -> () in
                                    
                                    print(badgeNumber)
                                    
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.gamvesApplication?.applicationIconBadgeNumber = badgeNumber
                                    
                                })
                                
                            })
                        }
                    }
                }
            }
        }
    }
    
    func scrollToLast()
    {
        let lastItem = self.messages.count - 1
        
        let indexPath = NSIndexPath(item: lastItem, section: 0)
        
        if (self.collectionView != nil && self.messages.count>0)
        {
            self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        self.inputTextField.resignFirstResponder()
    
        self.handleSend()
        
        return false
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end")
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        inputTextField.endEditing(true)
    }
    
    private func setupInputComponents() {
        
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        self.messageInputContainerView.addSubview(inputTextField)
        self.messageInputContainerView.addSubview(sendButton)
        self.messageInputContainerView.addSubview(topBorderView)
        
        self.messageInputContainerView.addConstraintsWithFormat("H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        
        self.messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: inputTextField)
        self.messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: sendButton)
        
        self.messageInputContainerView.addConstraintsWithFormat("H:|[v0]|", views: topBorderView)
        self.messageInputContainerView.addConstraintsWithFormat("V:|[v0(0.5)]", views: topBorderView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        let message = messages[indexPath.row]
        
        var messageText:String = message.message
        
        print(messageText)
        
        let delimitator = Global.admin_delimitator
        
        if messageText.range(of:delimitator) != nil
        {
            message.isAdmin = true
            message.isSender = true
            
            if let range = messageText.range(of: delimitator)
            {
                messageText.removeSubrange(range)
            }
            
        } else
        {
            message.isAdmin = false
        }
        
        cell.messageTextView.text = messageText
        
        let userID = message.userId
        
        let gamvesUser = Global.userDictionary[userID]
        
        let profileImageName = gamvesUser?.userName
        let profileImage = gamvesUser?.avatar
        
        cell.profileImageView.image = profileImage
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
        
        if message.isSender == nil || !message.isSender
        {
            
            cell.messageTextView.frame = CGRect(x:48 + 8, y:0, width:estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            
            cell.textBubbleView.frame = CGRect(x:48 - 10,y: -4, width:estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
            
            cell.profileImageView.isHidden = false
            
            cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
            cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
            cell.messageTextView.textColor = UIColor.black
            
        } else {
            
            if message.isAdmin
            {
                
                let x:CGFloat = 20
                let width = self.frame.width - 40
                let height = estimatedFrame.height + 20
                
                cell.textBubbleView.frame = CGRect(x: x, y: -4, width: width, height: height + 6)
                
                cell.messageTextView.frame = CGRect(x: x + 20, y: 0, width: width-20, height: height)
                
                cell.profileImageView.isHidden = true
                
                cell.bubbleImageView.image = ChatLogMessageCell.adminBubbleImage
                cell.bubbleImageView.tintColor = UIColor.lightGray
                cell.messageTextView.textColor = UIColor.gray
                
            } else {
                
                cell.messageTextView.frame = CGRect(x:self.frame.width - estimatedFrame.width - 16 - 16 - 8,y:0, width:estimatedFrame.width + 16, height:estimatedFrame.height + 20)
                
                cell.textBubbleView.frame = CGRect(x:self.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                
                cell.profileImageView.isHidden = true
                
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
                
            }
        }
        return cell
    }   
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = messages[indexPath.row]

        if let messageText = message.message {
            
            let size = CGSize(width:250, height:1000)
            
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width:self.frame.width, height:estimatedFrame.height + 20)
        }
        
        return CGSize(width:self.frame.width, height:100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }


    /////////////////////////////////

    override func layoutSubviews() {
       super.layoutSubviews()
    
    }
}


class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let adminBubbleImage = UIImage(named: "bubble_admin")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)

    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ChatLogMessageCell.grayBubbleImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        
        print(messageTextView.text)
        
        addSubview(profileImageView)
        addConstraintsWithFormat("H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat("V:[v0(30)]|", views: profileImageView)
        profileImageView.backgroundColor = UIColor.red
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraintsWithFormat("H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraintsWithFormat("V:|[v0]|", views: bubbleImageView)
    }
    
}

