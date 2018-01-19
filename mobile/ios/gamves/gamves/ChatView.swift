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
import AVFoundation
import AWSS3
import AWSCore

class GamvesAudio
{
    var audioObj:PFObject!
    var url = String()
    var uri:URL!
    var duration = String()
    var chatId = Int()
    var name = String()
}

class MessageChat
{
    var message:String!
    var chatId = Int()
    var userId = String()
    var userName = String()
    var date: Date?
    var isSender:Bool!
    var isAdmin:Bool!
    var isAudio:Bool!
    var audio = GamvesAudio()
    var time = String()
}

class ChatTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

class ChatView: UIView,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UITextFieldDelegate,
    AVAudioRecorderDelegate,
    AVAudioPlayerDelegate
{
    
    var activityView: NVActivityIndicatorView!
    
    let chatClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .lremoteWs)
    let feedClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .lremoteWs)
    let onlineClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .lremoteWs)
    
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
        //view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: ChatTextField = {
        let textField = ChatTextField()
        textField.placeholder = "  Enter message..."
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.send
        textField.backgroundColor = UIColor.white
        textField.layer.cornerRadius = 20
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.gamvesColor.cgColor
        return textField
    }()
    
    lazy var recSendButton: UIButton = {
        let button = UIButton(type: .system)
        let sendImage = UIImage(named: "rec_off")
        sendImage?.maskWithColor(color: UIColor.gamvesColor)
        button.setImage(sendImage, for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleSendRec), for: .touchDown)
        button.addTarget(self, action: #selector(handleSendRecUp), for: .touchUpInside)
        button.backgroundColor = UIColor.gamvesBlackColor
        button.layer.cornerRadius = 25
        button.tag = 1
        return button
    }()
    
    var tabGesture = UITapGestureRecognizer()
    
    // RECORDING
    
    var audioPlayer : AVAudioPlayer!
    var recordingSession : AVAudioSession!
    var audioRecorder    :AVAudioRecorder!
    var settings         = [String : Int]()
    var audioRecorded:GamvesAudio!
    var fileManager:FileManager!
    var timer = Timer()
    var startTime: Double = 0
    var time: Double = 0
    //var elapsed: Double = 0
    
    enum MediaStatus {
        case isRecording
        case isNotRecording
        case isPlaying
        case isPaused
        case isIdle
    }
    var mediaStatus:MediaStatus!
    
    var delegateDuration:UpdateDuration!
    
    var updater : CADisplayLink! = nil
    
    let backView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "background")
        imageView.image = image
        return imageView
    }()
    
    init(frame: CGRect, isVideo:Bool) {
        super.init(frame: frame)
        
        self.frame = frame
        
        self.mediaStatus = MediaStatus.isIdle
        
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
            
            self.titleContainerView.addConstraintsWithFormat("V:|[v0(0.5)][v1(29)]|", views: self.chatLineAboveView, self.chatHolderView)
        }
        
        self.addSubview(self.collectionView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        
        self.collectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        
        self.collectionView.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        self.addSubview(self.messageInputContainerView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.messageInputContainerView)
        
        let editSize:CGFloat = 65
        
        var height = self.frame.height
        let chatHeightVideo = height - (30 + editSize)
        let chatHeight = height - editSize
        
        let metricsMessageView = ["editSize" : editSize, "chatHeightVideo" : chatHeightVideo, "chatHeight" : chatHeight]
        
        if isVideo
        {
            
            self.addConstraintsWithFormat("V:|[v0(30)][v1(chatHeightVideo)][v2(editSize)]|", views: self.titleContainerView, self.collectionView, self.messageInputContainerView, metrics: metricsMessageView)
        } else
        {
            self.addConstraintsWithFormat("V:|-3-[v0(chatHeight)][v1(editSize)]|", views: self.collectionView, self.messageInputContainerView, metrics: metricsMessageView)
        }
        
        //self.messageInputContainerView.backgroundColor = UIColor.blue
        
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
        
        self.tabGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        self.activityView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Allow")
                    } else {
                        print("Dont Allow")
                    }
                }
            }
            
        } catch {
            print("failed to record!")
        }
        
        // Audio Settings
        
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        self.fileManager = FileManager.default
        
        self.addSubview(self.backView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.backView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.backView)
        
        self.bringSubview(toFront: self.collectionView)
        self.bringSubview(toFront: self.messageInputContainerView)
        
    }
    
    private func setupInputComponents() {
        
        self.messageInputContainerView.addSubview(inputTextField)
        self.messageInputContainerView.addSubview(recSendButton)
        
        self.messageInputContainerView.addConstraintsWithFormat("H:|-8-[v0]-10-[v1(50)]-8-|", views: inputTextField, recSendButton)
        
        self.messageInputContainerView.addConstraintsWithFormat("V:|-5-[v0]-10-|", views: inputTextField)
        self.messageInputContainerView.addConstraintsWithFormat("V:|-5-[v0(50)]-10-|", views: recSendButton)
        
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
                                                    
                                                    //Here sort or append new chats if brought by chunks
                                                    
                                                    messagesHandeled.sorted(by: {$0.date! < $1.date! })
                                                    
                                                    print(messagesHandeled)
                                                    
                                                    self.messages = messagesHandeled
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                        self.collectionView.reloadData()
                                                        self.scrollToLast()
                                                        self.activityView.stopAnimating()
                                                        
                                                    }
                                                    
                                                    
                                                    
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
        chatsQuery.addAscendingOrder("createdAt")
        //chatsQuery.addDescendingOrder("createdAt")
        chatsQuery.findObjectsInBackground(block: { (chatVideos, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                if (chatVideos?.count)! > 0 {
                    
                    let getChatData = chatVideos?.count
                    var i = 0
                    
                    var messagesHandeled = [MessageChat]()
                    
                    for chatVideo in chatVideos!
                    {
                        let message = MessageChat()
                        let userId = chatVideo["userId"] as! String
                        
                        message.userId = userId
                        var messageText = chatVideo["message"] as! String
                        
                        message.date = chatVideo.createdAt
                        message.chatId = chatVideo["chatId"] as! Int
                        
                        message.time = chatVideo["time"] as! String
                        
                        let delimitator = Global.admin_delimitator
                        if messageText.range(of:delimitator) != nil {
                            
                            message.isAdmin = true
                            
                            if let range = messageText.range(of: delimitator) {
                                messageText.removeSubrange(range)
                            }
                            
                        } else {
                            
                            message.isAdmin = false
                        }
                        
                        if PFUser.current()?.objectId == userId {
                            message.isSender = true
                        }
                        
                        //Apply
                        message.message = messageText
                        
                        if (messageText.contains(Global.audio_delimitator))
                        {
                            
                            message.isAudio = true
                            
                            
                            self.getAudio(id: i, messageText: messageText, completionHandler: { (gamvesAudio) in
                                
                                message.audio = gamvesAudio
                                
                                messagesHandeled.append(message)
                                
                                if (getChatData!-1) == i
                                {
                                    completionHandler(messagesHandeled)
                                    
                                }
                                i = i + 1
                                
                            })
                            
                            let messageArr : [String] = messageText.components(separatedBy: Global.audio_delimitator)
                            
                            let audioArr : [String] = messageArr[1].components(separatedBy: "----")
                            
                            var audioId : String = messageArr[0]
                            var audioTime : String = messageArr[1]
                            
                            let queryAudio = PFQuery(className:"Audios")
                            queryAudio.whereKey("objectId", equalTo: audioId)
                            
                            queryAudio.getFirstObjectInBackground(block: { (audioPF, error) in
                                
                                if error == nil {
                                    
                                    let audio = GamvesAudio()
                                    audio.audioObj = audioPF
                                    audio.url = audioPF?["url"] as! String
                                    audio.duration = audioPF?["duration"] as! String
                                    audio.chatId = audioPF?["chatId"] as! Int
                                    
                                }
                                
                            })
                            
                        } else {
                            
                            message.isAudio = false
                            
                            messagesHandeled.append(message)
                            
                            if (getChatData!-1) == i
                            {
                                completionHandler(messagesHandeled)
                            }
                            i = i + 1
                        }
                    }
                    
                } else
                {
                    self.activityView.stopAnimating()
                }
            }
        })
    }
    
    func getAudio(id: Int, messageText: String, completionHandler : @escaping (_ resutl:GamvesAudio) -> ()) {
        
        
        let messageArr : [String] = messageText.components(separatedBy: Global.audio_delimitator)
        
        let audioArr : [String] = messageArr[1].components(separatedBy: "----")
        
        var audioId : String = audioArr[0]
        var audioTime : String = audioArr[1]
        
        let queryAudio = PFQuery(className:"Audios")
        queryAudio.whereKey("objectId", equalTo: audioId)
        
        queryAudio.getFirstObjectInBackground(block: { (audioPF, error) in
            
            if error == nil {
                
                let audio = GamvesAudio()
                audio.audioObj = audioPF
                audio.url = audioPF?["url"] as! String
                audio.duration = audioPF?["duration"] as! String
                audio.chatId = audioPF?["chatId"] as! Int
                audio.name = audioPF?["name"] as! String
                audio.uri = self.directoryURL(name: audio.name) as! URL
                
                DispatchQueue.main.async {
                    self.doanloadIfExistAudio(id: id, url:audio.url, name:audio.name)
                }
                
                completionHandler(audio)
            } else {
                print(error)
            }
            
            
        })
        
    }
    
    func doanloadIfExistAudio(id: Int, url:String, name:String) {
        
        let chatIdDirectory = self.createIfNotExistChatFolder()
        
        let chatIdDirectoryUrl = URL(fileURLWithPath: chatIdDirectory)
        
        print(chatIdDirectory)
        
        //let localAudio = "\(chatIdDirectory)/\(name)"
        
        let localAudio = chatIdDirectoryUrl.appendingPathComponent(name)
        
        print(localAudio)
        
        if !fileManager.fileExists(atPath: localAudio.path) {
            
            let audioURL = URL(string: url)!
            
            let downloadPicTask = URLSession.shared.dataTask(with: audioURL) {
                (data, response, error) in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    let documentFolderURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    //let fileURL = documentFolderURL.appendingPathComponent(localAudio)
                    try data.write(to: localAudio)
                    
                } catch  {
                    print("error writing file \(name) : \(error)")
                }
                
                
                
                //HANDLE DOWNLOAD
                self.messages[id].audio.uri = localAudio
                
            }
            downloadPicTask.resume()
        }
    }
    
    
    func initializeSubscription()
    {
        
        let videoQuery = PFQuery(className: "ChatVideo").whereKey("chatId", equalTo: self.chatId)
        
        self.chatSubscription = chatClient.subscribe(videoQuery).handle(Event.created) { _, chatMessage in
            
            self.updateMessageFromServer(chatMessage: chatMessage)
            
            self.clearBargesForChatId()
            
        }
        
        let feedQuery = PFQuery(className: "ChatFeed").whereKey("chatId", equalTo: self.chatId)
        
        self.feedSubscription = feedClient.subscribe(feedQuery).handle(Event.created) { _, chatMessage in
            
            self.clearBargesForChatId()
        }
    }
    
    @objc func handleSendRec()
    {
        
        if self.recSendButton.tag == 1
        {
            //self.isRecording = true
            
            self.mediaStatus = MediaStatus.isRecording
            
            self.recSendButton.transform = CGAffineTransform(scaleX: 2, y: 2)
            
            if audioRecorder == nil {
                
                let onImage = UIImage(contentsOfFile: "rec_on")
                
                self.recSendButton.setImage(onImage, for: .normal)
                
                self.startRecording()
                
                //self.startCounting()
                
                self.startRecordTimer()
                
            }
            
        } else if self.recSendButton.tag == 2 {
            
            //self.isRecording = false
            
            self.mediaStatus = MediaStatus.isNotRecording
            
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
        
    }
    
    //func startCounting() {
    
    //}
    
    @objc func handleSendRecUp()
    {
        self.recSendButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        self.recSendButton.setImage(UIImage(named: "rec_off"), for: .normal)
        
        //if self.isRecording {
        
        if mediaStatus == MediaStatus.isRecording {
            
            self.finishRecording(success: true)
        }
        
    }
    
    
    //-- RECORD AUDIO
    
    func directoryURL(name: String) -> NSURL? {
        
        let chatIdDirectory = self.createIfNotExistChatFolder()
        
        let urls = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        
        let soundURL = documentDirectory.appendingPathComponent(name)
        
        return soundURL as NSURL?
        
    }
    
    
    func createIfNotExistChatFolder() -> String {
        
        let documentDirectoy: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])"
        
        print(self.chatId)
        
        let chatIdDirectory = "\(documentDirectoy)/\(self.chatId)"
        
        print(chatIdDirectory)
        
        if !self.fileManager.fileExists(atPath: chatIdDirectory) {
            
            do {
                try FileManager.default.createDirectory(atPath: chatIdDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        
        return chatIdDirectory
        
    }
    
    func startRecording() {
        
        let audioSession = AVAudioSession.sharedInstance()
        
        let currentTime = Date().toMillis()
        let currStr = String(describing: currentTime!)
        let audioName = "\(currStr).m4a"
        let soundURL = self.directoryURL(name: audioName)
        
        self.audioRecorded = GamvesAudio()
        self.audioRecorded.uri = soundURL as! URL
        self.audioRecorded.name = audioName
        
        do {
            
            self.audioRecorder = try AVAudioRecorder(url: soundURL as! URL,
                                                     settings: settings)
            self.audioRecorder.delegate = self
            
            self.audioRecorder.prepareToRecord()
            
        } catch {
            
            self.finishRecording(success: false)
        }
        
        do {
            
            try audioSession.setActive(true)
            
            self.audioRecorder.record()
            
        } catch {
            
        }
    }
    
    func finishRecording(success: Bool) {
        
        self.audioRecorder.stop()
        
        self.stopTimer()
        
        if success {
            
            print(success)
            
            let asset = AVURLAsset(url: self.audioRecorded.uri)
            let totalSeconds = Int(CMTimeGetSeconds(asset.duration))
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            let mediaTime = String(format:"%02i:%02i",minutes, seconds)
            
            self.saveAudio(duration: mediaTime, name: self.audioRecorded.name)
            
        } else {
            
            self.audioRecorder = nil
            
            print("Somthing Wrong.")
        }
        
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if !flag {
            self.finishRecording(success: false)
        }
    }
    
    func saveAudio(duration:String, name:String) {
        
        let audioPF = PFObject(className: "Audios")
        
        audioPF["chatId"] = self.chatId
        
        audioPF["duration"] = duration
        
        audioPF["name"] = name
        
        if let userId = PFUser.current()?.objectId {
            
            audioPF["senderId"] = userId
        }
        
        audioPF.saveInBackground { (result, error) in
            
            if error == nil {
                
                self.audioRecorded.audioObj = audioPF
                
                let messagePF: PFObject = PFObject(className: "ChatVideo")
                
                var userId = String()
                
                var textMessage = String()
                
                if PFUser.current() != nil
                {
                    userId = (PFUser.current()?.objectId)!
                    messagePF["userId"] = userId
                }
                
                messagePF["chatId"] = self.chatId
                
                var audioMessage = String()
                
                if let audioId = self.audioRecorded.audioObj.objectId {
                    
                    audioMessage  = "\(Global.audio_delimitator)\(audioId)----\(duration)"
                    
                    messagePF["message"] = audioMessage
                }
                
                let date = Date()
                let calendar = Calendar.current
                
                let minutes = calendar.component(.minute, from: date)
                let seconds = calendar.component(.second, from: date)
                
                let strMinutes = String(format: "%02d", minutes)
                let strSeconds = String(format: "%02d", seconds)
                
                messagePF["time"] = "\(strMinutes):\(strSeconds)"
                
                UserDefaults.standard.set(self.inputTextField.text!, forKey: "last_message")
                
                self.inputTextField.text = ""
                
                messagePF.saveInBackground { (resutl, error) in
                    
                    if error == nil
                    {
                        
                        var tempRecording = GamvesAudio()
                        
                        self.audioRecorded.audioObj = audioPF
                        
                        tempRecording = self.audioRecorded
                        
                        self.saveAudioToS3(audioStored: tempRecording, audioPF: audioPF)
                        
                        self.sendPushWithCoud(message: audioMessage)
                        
                    }
                }
            }
        }
    }
    
    func saveAudioToS3(audioStored:GamvesAudio, audioPF:PFObject) {
        
        
        DispatchQueue.main.async {
            
            let accessKey = "AKIAJP4GPKX77DMBF5AQ"
            let secretKey = "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"
            let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
            let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            let S3BucketName = "gamves/stpauls/audios"
            let uploadRequest = AWSS3TransferManagerUploadRequest()!
            uploadRequest.body = audioStored.uri
            uploadRequest.key = audioStored.name
            uploadRequest.bucket = S3BucketName
            uploadRequest.contentType = "audio/m4a" //"video/mp4" //"image/jpeg"
            uploadRequest.acl = .publicRead
            
            let transferManager = AWSS3TransferManager.default()
            transferManager.upload(uploadRequest).continueWith { (task) -> Any? in
                
                if let error = task.error {
                    print("Upload failed with error: (\(error.localizedDescription))")
                }
                
                //if let exception = task.exception {
                //    print("Upload failed with exception (\(exception))")
                //}
                
                if task.result != nil {
                    
                    let url = AWSS3.default().configuration.endpoint.url
                    
                    if let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!) {
                        
                        let s3url = "\(publicURL)" as String
                        
                        audioPF["url"] = s3url
                        
                        print("Uploaded to:\(publicURL)")
                        
                        audioPF.saveEventually()
                        
                    }
                }
                return nil
            }
        }
    }
    
    
    //-- MESSAGE
    
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
        
        let date = Date()
        let calendar = Calendar.current
        
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        messagePF["time"] = "\(strMinutes):\(strSeconds)"
        
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
                var textMessage = chatMessage["message"] as! String
                
                let userId = chatMessage["userId"] as! String
                message.userId = userId
                message.chatId = chatMessage["chatId"] as! Int
                message.date = chatMessage.updatedAt
                
                message.time = chatMessage["time"] as! String
                
                if let gamvesUser = Global.userDictionary[userId]
                {
                    message.isSender = gamvesUser.isSender
                } else if userId == PFUser.current()?.objectId
                {
                    message.isSender = true
                }
                
                if (textMessage.contains(Global.audio_delimitator))
                {
                    message.isAudio = true
                    
                } else {
                    
                    message.isAudio = false
                    
                }
                
                let delimitator = Global.admin_delimitator
                
                if textMessage.range(of:delimitator) != nil {
                    
                    message.isAdmin = true
                    
                    if let range = textMessage.range(of: delimitator) {
                        
                        textMessage.removeSubrange(range)
                        
                    }
                    
                } else {
                    
                    message.isAdmin = false
                }
                
                message.message = textMessage
                
                let gamvesUser = Global.userDictionary[userId]!
                
                message.isSender = gamvesUser.isSender           
                
                if ChatFeedMethods.chatFeeds[self.chatId] != nil
                {
                    ChatFeedMethods.chatFeeds[self.chatId]?.text = textMessage
                }
                
                self.messages.append(message)        

                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)

                self.collectionView.insertItems(at: [indexPath])
                self.scrollToLast()
        }
    }
    
    
    func initializeOnlineSubcritpion()
    {
        let userId = self.gamvesUsers[0].userId
        
        let onlineQuery = PFQuery(className: "UserOnline").whereKey("userId", equalTo: userId)
        
        onlineSubscription = onlineClient.subscribe(onlineQuery).handle(Event.updated) { _, onlineMessage in
            
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
            
            let videoId = self.chatId
            
            print(videoId)
            
            queryVideo.whereKey("videoId", equalTo: videoId)
            
            queryVideo.getFirstObjectInBackground(block: { (video, error) in
                
                if error != nil
                {
                    print(error)
                    
                    completionHandler(false)
                    
                } else {
                    
                    let description = video?["description"] as! String
                    
                    self.chatFeed["room"] = description
                    
                    self.saveChatFeed(file: groupImageFile, completionHandlerSave: { ( result:Bool ) -> () in
                        
                        completionHandler(result)
                        
                    })
                }
                
            })
            
            
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
                    
                    completionHandlerSave    (resutl)
                })
            }
        })
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
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
                
                
                self.addGestureRecognizer(self.tabGesture)
                
                
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
                
                self.removeGestureRecognizer(self.tabGesture)
                
                
            }
        }
    }
    
    @objc func dismissKeyboard() {
        
        self.endEditing(true)
        
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
    
    //func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let countText = updatedText.count
        
        if countText > 0 {
            
            self.setSendToText()
        } else {
            
            self.setSendToRect()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        self.setSendToRect()
        
        return true
    }
    
    func setSendToText() {
        
        let sendImage = UIImage(named: "send")
        
        sendImage?.maskWithColor(color: UIColor.gamvesColor)
        
        self.recSendButton.setImage(sendImage, for: .normal)
        
        self.recSendButton.tag = 2
    }
    
    func setSendToRect() {
        
        let sendImage = UIImage(named: "rec_off")
        
        sendImage?.maskWithColor(color: UIColor.gamvesColor)
        
        self.recSendButton.setImage(sendImage, for: .normal)
        
        self.recSendButton.tag = 1
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.inputTextField.resignFirstResponder()
        
        self.handleSendRec()
        
        return false
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end")
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        inputTextField.endEditing(true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        
        if indexPath.row == 4 {
            print("aca")
        }
        
        var message = self.messages[indexPath.row]
        
        print(self.messages.count)
        
        print(message)
        
        var messageText:String = message.message
        
        var time:String = message.time
        
        print(messageText)
        
        if message.isAdmin
        {
            message.isAdmin = true
            message.isSender = true
            
        } else
        {
            message.isAdmin = false
        }
        
        if message.isAudio {
            
            cell.messageTextView.isHidden = true
            cell.timeLabel.isHidden = true
            cell.isAudio = true
            
        } else {
            
            cell.messageTextView.text = messageText
            cell.timeLabel.text = time
            cell.isAudio = false
            
        }
        
        let userID = message.userId
        
        let gamvesUser = Global.userDictionary[userID]
        
        let profileImageName = gamvesUser?.userName
        let profileImage = gamvesUser?.avatar
        
        cell.profileImageView.image = profileImage
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let eFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
        
        var estimatedFrame = CGRect()
        
        if !message.isAudio && eFrame.width < 60 {
            
            estimatedFrame = createFrame(eFrame: eFrame, width: 60, height: eFrame.height)
        } else if message.isAudio {
            
            estimatedFrame = createFrame(eFrame: eFrame, width: 280, height: 30)
        } else {
            
            estimatedFrame = eFrame
        }
        
        var xAdmin:CGFloat = 20
        var widthAdmin = self.frame.width - 40
        
        if message.isAdmin
        {
            
            let height = estimatedFrame.height + 20
            
            cell.bubbleView.frame = CGRect(x: xAdmin, y: -4, width: widthAdmin, height: height + 6)
            
            cell.messageTextView.frame = CGRect(x: xAdmin + 20, y: 0, width: widthAdmin-20, height: height)
            
            cell.profileImageView.isHidden = true
            
            cell.bubbleImageView.image = ChatLogMessageCell.adminBubbleImage
            cell.bubbleImageView.tintColor = UIColor.lightGray
            cell.messageTextView.textColor = UIColor.gray       

            
        } else if message.isSender == nil || !message.isSender
        {     
                
            var x:CGFloat = 20
            var width = self.frame.width - 40

            let mx = x + 8
            let mwidth = estimatedFrame.width + 16
            let mheight = estimatedFrame.height + 20
            
            cell.messageTextView.frame = CGRect(x:mx, y:0, width:mwidth, height: mheight)
            
            let bx = x - 10
            let by:CGFloat = -4
            var bwidth = estimatedFrame.width + 16 + 8 + 16
            let bheight = estimatedFrame.height + 20 + 6 + 15 //spare space for text

            cell.bubbleView.frame = CGRect(x:bx, y: by, width:bwidth, height: bheight)
            
            if message.isAudio {
                
                cell.bHeight = bheight
                cell.chatView = self
                
                cell.bubbleImageView.image = ChatLogMessageCell.audioBubbleImage
                cell.audioDurationLabel.text = message.audio.duration
                print(indexPath.row)

                cell.isSender = false
                
                //DispatchQueue.main.async {
                //    cell.setAudioControl(view: self)
                //}
                
                cell.playPauseButton.tag = indexPath.row
                cell.playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchDown)
                
                //Not working
                //cell.playerSlider.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpInside)
                
            } else {
                
                //cell.drawTime(height: bheight)
                
                cell.profileImageView.isHidden = false                
                cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = UIColor.black
                
            }
            
        } else {           
                
            let mx = self.frame.width - estimatedFrame.width - 16 - 16 - 8
            let mwidth = estimatedFrame.width + 16
            let mheight = estimatedFrame.height + 20
            
            cell.messageTextView.frame = CGRect(x:mx, y:0, width:mwidth, height:mheight)
            
            let bx = self.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10
            let by:CGFloat = -4
            let bwidth = estimatedFrame.width + 16 + 8 + 10
            let bheight = estimatedFrame.height + 20 + 6 + 15 //spare space for text
            
            cell.bubbleView.frame = CGRect(x:bx, y:by, width: bwidth, height: bheight)
            
            if message.isAudio {
                
                cell.bHeight = bheight
                cell.chatView = self
                
                cell.bubbleImageView.image = ChatLogMessageCell.audioBubbleImage
                cell.audioDurationLabel.text = message.audio.duration
                print(indexPath.row)
                
                cell.isSender = true

                //DispatchQueue.main.async {
                //    cell.setAudioControl(view: self)
                //}
                
                cell.playPauseButton.tag = indexPath.row
                cell.playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchDown)
                
                //Not working
                //cell.playerSlider.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpInside)
                
            } else {
                
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                //cell.drawTime(height: bheight)
                cell.profileImageView.isHidden = true
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
                
            }
            
        }
        
        return cell
    }
    
    //func sliderTouchUp(sender: Any) {
    //     self.delegateDuration.seekSlider(slider: sender as! UISlider)
    //}
    
    @objc func handlePlayPause(sender: AnyObject) {
        
        if mediaStatus == MediaStatus.isPlaying {
            
            self.audioPlayer.pause()
            self.stopTimer()
            self.delegateDuration.showPlayIcon()
            
        } else if mediaStatus == MediaStatus.isPaused {
            
            self.audioPlayer.play()
            self.startTimer()
            self.delegateDuration.showPauseIcon()
            
        } else if mediaStatus == MediaStatus.isIdle {
            
            self.playAudio(sender: sender)
            self.delegateDuration.showPauseIcon()
        }
        
    }
    
    func createFrame(eFrame:CGRect, width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: eFrame.maxX, y: eFrame.maxY, width: width, height: height)
    }
    
    
    //-- PLAY AUDIO
    
    func playAudio(sender: AnyObject) {
        
        let button = sender as! UIButton
        let index = button.tag as Int
        let message = self.messages[index] as MessageChat
        let audio = message.audio as GamvesAudio
        
        //let url:URL  //URL(fileURLWithPath:)
        
        //print(url)
        
        self.delegateDuration.setDuration(time: audio.duration)
        
        self.updater = CADisplayLink(target: self, selector: #selector(ChatView.trackAudio))
        self.updater.frameInterval = 1
        self.updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
        let localAudio:URL = audio.uri
        
        if !fileManager.fileExists(atPath: localAudio.path) {
            
            let url = URL(fileURLWithPath: localAudio.path)
            
            do {
                
                self.audioPlayer = try! AVAudioPlayer(contentsOf: url)
                
            } catch  {
                print("error writing file \(localAudio.lastPathComponent) : \(error)")
            }
            
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self
            self.audioPlayer.volume = 1.0
            self.audioPlayer.play()
            
            self.mediaStatus = MediaStatus.isPlaying
            
            self.startTimer()
        }
    }
    
    
    @objc func trackAudio() {
        let normalizedTime = Float(self.audioPlayer.currentTime * 100.0 / self.audioPlayer.duration)
        self.delegateDuration.updateSlider(value: normalizedTime)
    }
    
    func startRecordTimer() {
        self.startTimer()
    }
    
    func startTimer(){
        
        DispatchQueue.main.async {
            
            self.startTime = Date().timeIntervalSinceReferenceDate //- self.elapsed
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
            
        }
    }
    
    func stopTimer() {
        
        timer.invalidate()
        
        if self.mediaStatus == MediaStatus.isRecording {
            
            self.inputTextField.text = ""
            
        }
    }
    
    @objc func timerRunning() {
        
        time = Date().timeIntervalSinceReferenceDate - startTime
        
        let minutes = UInt8(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        
        let seconds = UInt8(time)
        time -= TimeInterval(seconds)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        let timeCount = "\(strMinutes):\(strSeconds)"
        
        if mediaStatus == MediaStatus.isRecording {
            
            self.inputTextField.text = "     \(timeCount)"
            
        } else if mediaStatus == MediaStatus.isPlaying {
            
            self.delegateDuration.updateTime(time: timeCount)
            
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print(flag)
        self.mediaStatus = MediaStatus.isIdle
        self.stopTimer()
        self.delegateDuration.updateTime(time: "00:00")
        self.delegateDuration.showPlayIcon()
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        print(error.debugDescription)
    }
    internal func audioPlayerBeginInterruption(_ player: AVAudioPlayer){
        print(player.debugDescription)
    }
    
    
    func sliderValueChanged(sender: AnyObject) {
        
        let slider = sender as! UISlider
        
        let indexPath = IndexPath(row: slider.tag, section: 0)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        for view in cell.subviews {
            if let label = view as? UILabel {
                label.text = "\(slider.value)"
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = messages[indexPath.row]
        
        if let messageText = message.message {
            
            let size = CGSize(width:250, height:1000)
            
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            //[NSAttributedStringKey.fontNSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width:self.frame.width, height:estimatedFrame.height + 20 + 10)
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


protocol UpdateDuration {
    
    func setDuration(time: String)
    func showPlayIcon()
    func showPauseIcon()
    func updateTime(time: String)
    func updateSlider(value: Float)
    func seekSlider(slider:UISlider)
    
}

class ChatLogMessageCell: BaseCell, UpdateDuration  {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let playContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let playButtonView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    let centralContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        let playImage = UIImage(named: "play")
        playImage?.maskWithColor(color: UIColor.gamvesColor)
        button.setImage(playImage, for: UIControlState.normal)
        return button
    }()
    
    let playerSlider: UISlider = {
        let slider = UISlider()
        slider.layer.cornerRadius = 15
        slider.layer.masksToBounds = true
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isUserInteractionEnabled = true
        return slider
    }()
    
    let labelContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = UIColor.gamvesColor
        //label.backgroundColor = UIColor.green
        label.font = UIFont.boldSystemFont(ofSize: 10)
        //label.textAlignment = .left
        return label
    }()
    
    var audioDurationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let audioCountabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    var chatView:ChatView!
    var bHeight = CGFloat()
    var isSender = Bool()
    var isAudio = Bool()
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let adminBubbleImage = UIImage(named: "bubble_admin")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let audioBubbleImage = UIImage(named: "bubble_audio")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ChatLogMessageCell.grayBubbleImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(bubbleView)
        addSubview(messageTextView)
        
        print(messageTextView.text)
        
        //if !self.isAudio {
        
        //    addSubview(profileImageView)
        //    addConstraintsWithFormat("H:|-8-[v0(30)]", views: profileImageView)
        //    addConstraintsWithFormat("V:[v0(30)]|", views: profileImageView)
        //    profileImageView.backgroundColor = UIColor.red
        //}
        
        bubbleView.addSubview(bubbleImageView)
        bubbleView.addConstraintsWithFormat("H:|[v0]|", views: bubbleImageView)
        bubbleView.addConstraintsWithFormat("V:|[v0]|", views: bubbleImageView)
        
        //if isSender { }
        //bubbleView.addConstraintsWithFormat("V:|[v0][v1(15)]|", views: bubbleImageView, timeLabel)
        
    }
    
    override func layoutSubviews() {
        
        let bH = self.bHeight - 25
        
        let bubbleMetrics = ["bHeight":bH]
        
        bubbleView.addSubview(timeLabel)
        bubbleView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: timeLabel)
        bubbleView.addConstraintsWithFormat("V:|-bHeight-[v0(15)]-5-|", views: timeLabel, metrics: bubbleMetrics)
        
        if isSender {
            timeLabel.textAlignment = .left
        } else  {
            timeLabel.textAlignment = .right
        }
        
        /////////////////
        
        //self.chatView = view
        
        if self.isAudio {
        
            self.chatView.delegateDuration = self
            
            let myFrame = bubbleView.frame
            
            self.bubbleView.addSubview(self.playContainerView)
            self.bubbleView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.playContainerView)
            self.bubbleView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.playContainerView)
            
            self.playContainerView.addSubview(self.playButtonView)
            self.playContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.playButtonView)
            
            self.playContainerView.addSubview(self.centralContainerView)
            self.playContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.centralContainerView)
            
            self.playContainerView.addSubview(self.profileContainerView)
            self.playContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.profileContainerView)
            
            
            if isSender {
                
                self.playContainerView.addConstraintsWithFormat("H:|[v0(60)][v1][v2(60)]|", views:
                    self.playButtonView,
                                                                self.centralContainerView,
                                                                self.profileContainerView)
                
            } else {
                
                self.playContainerView.addConstraintsWithFormat("H:|[v0(60)][v1(60)][v2]|", views:
                    self.profileContainerView,
                                                                self.playButtonView,
                                                                self.centralContainerView)
            }
            
            playButtonView.backgroundColor = UIColor.green
            centralContainerView.backgroundColor = UIColor.cyan
            profileContainerView.backgroundColor = UIColor.red
            
            self.playButtonView.addSubview(self.playPauseButton)
            self.playButtonView.addConstraintsWithFormat("H:|-10-[v0(40)]-10-|", views: self.playPauseButton)
            self.playButtonView.addConstraintsWithFormat("V:|-10-[v0(40)]|", views: self.playPauseButton)
            
            self.centralContainerView.addSubview(self.playerSlider)
            self.centralContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.playerSlider)
            
            self.centralContainerView.addSubview(self.labelContainerView)
            self.centralContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.labelContainerView)
            
            self.centralContainerView.addConstraintsWithFormat("V:|[v0][v1]|", views:
                self.playerSlider,
                                                               self.labelContainerView)
            
            self.labelContainerView.addSubview(self.audioCountabel)
            self.labelContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.audioCountabel)
            
            self.labelContainerView.addSubview(self.separatorView)
            self.labelContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.separatorView)
            
            self.labelContainerView.addSubview(self.audioDurationLabel)
            self.labelContainerView.addConstraintsWithFormat("V:|-5-[v0]|", views: self.audioDurationLabel)
            
            self.labelContainerView.addConstraintsWithFormat("H:|-10-[v0(60)][v1][v2(60)]-10-|", views:
                self.audioCountabel,
                                                             self.separatorView,
                                                             self.audioDurationLabel)
            
            self.profileContainerView.addSubview(self.profileImageView)
            self.profileContainerView.addConstraintsWithFormat("H:|-10-[v0(40)]-10-|", views: self.profileImageView)
            self.profileContainerView.addConstraintsWithFormat("V:|-10-[v0(40)]|", views: self.profileImageView)
            
        }
            
    }
    
    func setDuration(time: String) {
        self.audioDurationLabel.text = time
    }
    
    func updateTime(time: String) {
        self.audioCountabel.text = time
    }
    
    func updateSlider(value: Float) {
        self.playerSlider.value = value
    }
    
    func seekSlider(slider:UISlider) {
        
        //self.chatView.audioPlayer.currentTime = TimeInterval(slider.value)
        //self.chatView.audioPlayer.play()
    }
    
    func showPauseIcon(){
        let pauseImage = UIImage(named: "pause")
        pauseImage?.maskWithColor(color: UIColor.gamvesColor)
        self.playPauseButton.setImage(pauseImage, for: UIControlState.normal)
    }
    
    func showPlayIcon(){
        let playImage = UIImage(named: "play")
        playImage?.maskWithColor(color: UIColor.gamvesColor)
        self.playPauseButton.setImage(playImage, for: UIControlState.normal)
    }
    
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

