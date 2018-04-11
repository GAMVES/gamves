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
    import ISEmojiView

    class GamvesPicture
    {
        var pictureObj:PFObject!
        var picture:PFFile!
        var pictureSmall:PFFile!
        var chatId = Int()
        var image = UIImage()
        var imageSmall = UIImage()
    }

    class GamvesAudio
    {
        var audioObj:PFObject!
        var url = String()
        var localUri:URL!
        var duration = String()
        var chatId = Int()
        var name = String()
    }

    enum MessageType {
        case isAdmin
        case isAudio
        case isAudioDownloading
        case isPicture
        case isPictureDownloading
        case isText
        case isVideo
    }

    class MessageChat
    {
        var message:String!
        var chatId = Int()
        var userId = String()
        var userName = String()
        
        var createdAt:Date!
        var date:Date!
        var isSender:Bool!
        
        var audio = GamvesAudio()
        var audioLocalUri:URL!
        
        var picture = GamvesPicture()
        var time = String()
        var type:MessageType!
    }

    class ChatTextField: UITextField {
        
        let padding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 5);
        
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
        ISEmojiViewDelegate,
        TimerDelegate,
        MediaDelegate
    {
        
        var activityView: NVActivityIndicatorView!
        
        let chatClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .lremoteWs)
        let feedClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .lremoteWs)
        let audioClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .lremoteWs)
        let onlineClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .lremoteWs)
        
        private var chatSubscription: Subscription<PFObject>!
        private var feedSubscription: Subscription<PFObject>!
        private var audioSubscription: Subscription<PFObject>!
        private var onlineSubscription: Subscription<PFObject>!
        
        var videoQuery:PFQuery<PFObject>!
        var feedQuery:PFQuery<PFObject>!
        var audioQuery:PFQuery<PFObject>!
        var onlineQuery:PFQuery<PFObject>!
        
        var messages = [MessageChat]()
        var chatId = Int()
        var chatIdStr = String()
        var isVideoChat = Bool()
        var thumbnailImage = UIImage()
        
        var gamvesUsers = [GamvesUser]()
        var gamvesUsersArray = [String]()
        var gamvesUsersPFuser = [PFUser]()
        
        var chatFeed:PFObject!
        var keyboardDelegate:KeyboardDelegate!
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
        
        let messageContainerView: UIView = {
            let view = UIView()
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
            button.addTarget(self, action: #selector(handleSendRecUp), for: .touchUpOutside)
            button.addTarget(self, action: #selector(handleSendRecUp), for: .touchCancel)
            button.backgroundColor = UIColor.gamvesBlackColor
            button.layer.cornerRadius = 25
            button.tag = 1
            return button
        }()
        
        lazy var emojisKeyboardButton: UIButton = {
            let button = UIButton(type: .system)
            let emoticonImage = UIImage(named: "insert_emoticon")
            emoticonImage?.maskWithColor(color: UIColor.gamvesColor)
            button.setImage(emoticonImage, for: UIControlState.normal)
            button.addTarget(self, action: #selector(handleEmoticonsKeyboard), for: .touchUpInside)
            button.layer.cornerRadius = 20
            button.tag = 1
            return button
        }()
        
        lazy var picureButton: UIButton = {
            let button = UIButton(type: .system)
            let cameraImage = UIImage(named: "camera_black")
            cameraImage?.maskWithColor(color: UIColor.gamvesColor)
            button.setImage(cameraImage, for: UIControlState.normal)
            button.addTarget(self, action: #selector(handleAddPicture), for: .touchUpInside)
            button.layer.cornerRadius = 20
            button.tag = 1
            return button
        }()
        
        
        var tabGesture = UITapGestureRecognizer()
        
        // RECORDING
        var recordingSession : AVAudioSession!
        var audioRecorder    :AVAudioRecorder!
        var settings         = [String : Int]()
        
        var fileManager:FileManager!
        
        //var delegateChat:UpdateChatCell!
        
        let backView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage(named: "background")
            imageView.image = image
            return imageView
        }()
        
        let emojiView = ISEmojiView()
        
        enum RecordStatus {
            case isRecording
            case isNotRecording
        }
        
        var recordingStatus = RecordStatus.isNotRecording
        
        var chatTextTimer:ChatTimer!
        
        var emoticonKeyboardState:EmoticonKeyboardState!
        
        //var homeController:HomeController!
        
        var pictureWidth = CGFloat()
        var pictureHeight = CGFloat()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        init(frame: CGRect, isVideo:Bool) {
            super.init(frame: frame)
            
            self.frame = frame
            
            let vWidth = self.frame.width
            self.pictureWidth = (vWidth / 3) * 2
            self.pictureHeight = self.pictureWidth * 9 / 16
            
            self.inputTextField.delegate = self
            
            self.emoticonKeyboardState = EmoticonKeyboardState.isKeyboard
            
            self.chatTextTimer = ChatTimer()
            self.chatTextTimer.delegate = self
            
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
            
            //self.collectionView.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))
            
            self.addSubview(self.messageContainerView)
            
            self.addConstraintsWithFormat("H:|[v0]|", views: self.messageContainerView)
            
            let editSize:CGFloat = 65
            
            let height = self.frame.height
            let chatHeightVideo = height - (30 + editSize)
            let chatHeight = height - ( editSize + 5 )
            
            let metricsMessageView = ["editSize" : editSize, "chatHeightVideo" : chatHeightVideo, "chatHeight" : chatHeight]
            
            if isVideo
            {
                
                self.addConstraintsWithFormat("V:|[v0(30)][v1(chatHeightVideo)][v2(editSize)]|", views: self.titleContainerView, self.collectionView, self.messageContainerView, metrics: metricsMessageView)
            } else
            {
                self.addConstraintsWithFormat("V:|[v0(chatHeight)][v1(editSize)]|", views: self.collectionView, self.messageContainerView, metrics: metricsMessageView)
            }
            
            self.chatHolderView.addSubview(self.chatImageView)
            self.chatHolderView.addSubview(self.chatLabel)
            
            self.chatHolderView.addConstraintsWithFormat("H:|-10-[v0(19.5)]-10-[v1]|", views: self.chatImageView, self.chatLabel)
            
            self.chatHolderView.addConstraintsWithFormat("V:|-5-[v0(19.5)]-5-|", views: self.chatImageView)
            self.chatHolderView.addConstraintsWithFormat("V:|[v0(29.5)]|", views: self.chatLabel)
            
            self.bottomConstraint = NSLayoutConstraint(item: self.messageContainerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            
            self.addConstraint(self.bottomConstraint!)
            
            self.setupInputComponents()
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
            self.tabGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))       

            self.activityView = Global.setActivityIndicator(container: self, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gray) //,x: 0, y: 0, width: 80.0, height: 80.0)
                       
            self.recordingSession = AVAudioSession.sharedInstance()
            
            do {
                
                try self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try self.recordingSession.setActive(true)
                
                self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                    
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
            self.bringSubview(toFront: self.messageContainerView)
            self.bringSubview(toFront: self.activityView)
            
        }
        
        func timeCount(time: String) {
            self.inputTextField.text = time
        }
        
        func timeReset(time: String) {
            self.inputTextField.text = time
        }
        
        private func setupInputComponents() {
            
            self.messageContainerView.addSubview(self.inputTextField)
            self.messageContainerView.addSubview(self.recSendButton)
            self.messageContainerView.addSubview(self.emojisKeyboardButton)
            self.messageContainerView.addSubview(self.picureButton)
            
            self.messageContainerView.backgroundColor = UIColor.gamvesColor
            
            self.messageContainerView.addConstraintsWithFormat("H:|-8-[v0]-10-[v1(50)]-8-|", views: self.inputTextField, self.recSendButton)
            
            self.messageContainerView.addConstraintsWithFormat("V:|-5-[v0]-10-|", views: self.inputTextField)
            self.messageContainerView.addConstraintsWithFormat("V:|-5-[v0(50)]-10-|", views: self.recSendButton)
            
            self.messageContainerView.addConstraintsWithFormat("H:|-8-[v0]-10-[v1(50)]-8-|", views: self.inputTextField, self.recSendButton)
            
            self.messageContainerView.addConstraintsWithFormat("H:|-12-[v0(40)]|", views: self.emojisKeyboardButton)
            self.messageContainerView.addConstraintsWithFormat("V:|-10-[v0(40)]|", views: self.emojisKeyboardButton)
            
            let width = self.frame.width
            let paddingleft = width - 110
            
            let metricsImage = ["paddingleft":paddingleft]
            
            self.messageContainerView.addConstraintsWithFormat("H:|-paddingleft-[v0(40)]-60-|", views: self.picureButton, metrics: metricsImage)
            self.messageContainerView.addConstraintsWithFormat("V:|-10-[v0(40)]|", views: self.picureButton)
            
            self.messageContainerView.bringSubview(toFront: self.recSendButton)
            
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
                self.gamvesUsers = parameters["gamvesUsers"] as! [GamvesUser]
            }
            if parameters["thumbnailImage"] != nil {
                self.thumbnailImage = parameters["thumbnailImage"] as! UIImage
            }
            if parameters["delegate"] != nil {
                self.keyboardDelegate = parameters["delegate"] as! KeyboardDelegate
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
       
        
        func loadChatFeed() {
            
            if self.activityView != nil {           
                    
                self.activityView.startAnimating()     
            }
            
            print(self.chatId)
            let queryChatFeed = PFQuery(className:"ChatFeed")
            
            queryChatFeed.whereKey("chatId", equalTo: self.chatId)
            
            queryChatFeed.findObjectsInBackground { (chatFeeds, error) in
                
                if error != nil {
                    
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
                            
                            for chatFeed in chatFeeds {
                                
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
                                                    
                                                    let gamvesUser = GamvesUser()
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
                                                            
                                                            Global.userDictionary[userId] = gamvesUser as GamvesUser
                                                            
                                                        })
                                                    }
                                                }
                                                
                                                if i == (usersAmount-1)
                                                {
                                                    self.loadChatsVideos(chatFeed: chatFeed, userCount: usersAmount, completionHandler: { ( messagesHandeled ) -> () in
                                                        
                                                        var sortedMessages = messagesHandeled.sorted(by: {
                                                            $0.date.compare($1.date) == .orderedAscending
                                                        })
                                                        
                                                        self.messages = sortedMessages
                                                        
                                                        DispatchQueue.main.async {
                                                            
                                                            //self.collectionView.addObserver(self, forKeyPath: "contentSize", options:   NSKeyValueObservingOptions.old.union(NSKeyValueObservingOptions.new), context: nil)
                                                            
                                                            self.collectionView.reloadData()
                                                            self.activityView.stopAnimating()
                                                            self.scrollToLast()
                                                            
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
            
            self.initializeChatSubscription()
            
        }
        
        func loadChatsVideos(chatFeed:PFObject, userCount:Int, completionHandler : @escaping (_ resutl:[MessageChat]) -> ()) {
            
            let chatsRealtion = chatFeed["chats"] as! PFRelation
            let chatsQuery = chatsRealtion.query()
            chatsQuery.addAscendingOrder("createdAt")
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
                            
                            message.type = MessageType.isText
                            
                            let userId = chatVideo["userId"] as! String
                            
                            message.userId = userId
                            var messageText = chatVideo["message"] as! String
                            
                            message.date = chatVideo.createdAt
                            message.createdAt = chatVideo.createdAt
                            
                            message.chatId = chatVideo["chatId"] as! Int
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "h:mm a"
                            
                            let elapsedTimeInSeconds = Date().timeIntervalSince(message.date!)
                            
                            let secondInDays: TimeInterval = 60 * 60 * 24
                            
                            if elapsedTimeInSeconds > 7 * secondInDays {
                                dateFormatter.dateFormat = "MM/dd/yy"
                            } else if elapsedTimeInSeconds > secondInDays {
                                dateFormatter.dateFormat = "EEE"
                            }
                            
                            message.time = dateFormatter.string(from: message.date!)
                            
                            if messageText.range(of:Global.admin_delimitator) != nil {
                                
                                message.type = MessageType.isAdmin
                                
                                if let range = messageText.range(of: Global.admin_delimitator) {
                                    messageText.removeSubrange(range)
                                }
                                
                            }
                            
                            print(messageText)
                            
                            if PFUser.current()?.objectId == userId {
                                message.isSender = true
                            } else {
                                message.isSender = false
                            }
                            
                            //Apply
                            message.message = messageText
                            
                            if (messageText.contains(Global.audio_delimitator)) {
                                
                                message.type = MessageType.isAudio
                                
                                self.getAudio(id: i, messageText: messageText, completionHandler: { (gamvesAudio, id) in
                                    
                                    message.audio = gamvesAudio
                                    
                                    messagesHandeled.append(message)
                                    
                                    if (getChatData!-1) == i
                                    {
                                        completionHandler(messagesHandeled)
                                        
                                    }
                                    i = i + 1
                                    
                                })
                                
                            } else if (messageText.contains(Global.picture_delimitator)) {
                                
                                message.type = MessageType.isPictureDownloading
                                
                                self.getPicture(id: i, messageText: messageText, completionHandler: { (gamvesPicture, id) in
                                    
                                    message.picture = gamvesPicture
                                    
                                    message.type = MessageType.isPicture
                                    
                                    messagesHandeled.append(message)
                                    
                                    if (getChatData!-1) == i
                                    {
                                        completionHandler(messagesHandeled)
                                        
                                    }
                                    i = i + 1
                                    
                                })
                                
                            } else {
                                
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
        
        func getAudio(id: Int, messageText: String, completionHandler : @escaping (_ resutl:GamvesAudio, _ id:Int) -> ()) {
            
            let messageArr : [String] = messageText.components(separatedBy: Global.audio_delimitator)
            
            let audioArr : [String] = messageArr[1].components(separatedBy: "----")
            
            var audioId : String = audioArr[0]
            var audioTime : String = audioArr[1]
            
            let queryAudio = PFQuery(className:"Audios")
            queryAudio.whereKey("objectId", equalTo: audioId)
            
            print(audioId)
            
            queryAudio.getFirstObjectInBackground(block: { (_audio, error) in
                
                if error == nil {
                    
                    if let audioPF:PFObject = _audio {
                        
                        let audio = GamvesAudio()
                        audio.audioObj = audioPF
                        audio.duration = audioPF["duration"] as! String
                        audio.chatId = audioPF["chatId"] as! Int
                        audio.name = audioPF["name"] as! String
                        
                        if audioPF["url"] != nil {
                            
                            audio.url = audioPF["url"] as! String
                            
                            self.downloadIfNotExistAudio(id: id, url:audio.url, name:audio.name, completionHandler: { ( localUri, exist ) -> () in
                                
                                audio.localUri = localUri
                                completionHandler(audio, id)
                                
                            })
                            
                        } else {
                            completionHandler(audio, id)
                        }
                    }
                    
                } else {
                    print(error)
                }
            })
        }
        
        func getPicture(id: Int, messageText: String, completionHandler : @escaping (_ resutl:GamvesPicture, _ id:Int) -> ()) {
            
            let messageArr : [String] = messageText.components(separatedBy: Global.picture_delimitator)
            
            let pictureArr : [String] = messageArr[1].components(separatedBy: "----")
            
            var pictureId : String = pictureArr[0]
            var chatId : String = pictureArr[1]
            
            let queryPicture = PFQuery(className:"Pictures")
            queryPicture.whereKey("objectId", equalTo: pictureId)
            
            queryPicture.getFirstObjectInBackground(block: { (_picture, error) in
                
                if error == nil {
                    
                    if let picturePF:PFObject = _picture {
                        
                        let picture = GamvesPicture()
                        picture.pictureObj = picturePF
                        picture.chatId = picturePF["chatId"] as! Int
                        
                        let image = picturePF["picture"] as! PFFile
                        
                        let imageSmall = picturePF["pictureSmall"] as! PFFile
                        
                        picture.picture = image
                        
                        picture.pictureSmall = imageSmall
                        
                        imageSmall.getDataInBackground(block: { (imageSmallData, error) in
                            
                            if error == nil {
                                
                                var pictrureSmallImage = UIImage(data:imageSmallData!)
                                
                                picture.imageSmall = pictrureSmallImage!
                                
                                completionHandler(picture, id)
                            }
                        })
                        
                    }
                    
                } else {
                    print(error)
                }
            })
        }
        
        func downloadIfNotExistAudio(id: Int, url:String, name:String, completionHandler : @escaping (_ localUri:URL, _ exist:Bool) -> ()) {
            
            let chatIdDirectory = self.createIfNotExistChatFolder()
            
            let localAudio = chatIdDirectory.appendingPathComponent(name)
            
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
                    
                    completionHandler(localAudio, false)
                    
                }
                downloadPicTask.resume()
                
            } else {
                
                completionHandler(localAudio, true)
            }
        }
        
        
        func initializeChatSubscription()
        {
            
            self.videoQuery = PFQuery(className: "ChatVideo").whereKey("chatId", equalTo: self.chatId)
            
            self.chatSubscription = chatClient.subscribe(self.videoQuery).handle(Event.created) { _, chatMessage in
                
                print(chatMessage)
                
                self.updateMessageFromServer(chatMessage: chatMessage)
                
                self.clearBargesForChatId()
                
            }
            
            self.feedQuery = PFQuery(className: "ChatFeed").whereKey("chatId", equalTo: self.chatId)
            
            self.feedSubscription = feedClient.subscribe(self.feedQuery).handle(Event.created) { _, chatMessage in
                
                self.clearBargesForChatId()
            }
            
            self.audioQuery = PFQuery(className: "Audios").whereKey("chatId", equalTo: self.chatId)
            
            self.audioSubscription = audioClient.subscribe(self.audioQuery).handle(Event.updated) { _, audioPF in
                
                var sender = Bool()
                
                let userId = audioPF["senderId"] as! String
                
                if userId == PFUser.current()?.objectId {
                    sender = true
                }
                
                if audioPF["url"] != nil && !sender {
                    
                    print(audioPF["url"])
                    
                    let url = audioPF["url"] as! String
                    
                    self.getMessageByAudioName(audio:audioPF, completionHandler: { ( message, indexPath ) -> () in
                        
                        print(indexPath)
                        
                        let audio = message.audio
                        
                        self.downloadIfNotExistAudio(id: indexPath.row, url:url, name:audio.name, completionHandler: { ( localUri, exist ) -> () in
                            
                            audio.localUri = localUri
                            audio.url = url
                            
                            self.messages[indexPath.row].type = MessageType.isAudio
                            self.messages[indexPath.row].audio.localUri = localUri
                            self.messages[indexPath.row].audio.url = url
                            
                            DispatchQueue.main.async {
                                
                                print()
                                print("-------------------------------------")
                                print("SOCKET")
                                print("-------------------------------------")
                                
                                self.collectionView.reloadItems(at: [indexPath])
                            }
                            
                            
                        })
                    })
                }
            }
        }
        
        func getMessageByAudioName(audio: PFObject, completionHandler : @escaping (_ message:MessageChat,_ indexPath:IndexPath ) -> ()) {
            
            let audioName = audio["name"] as! String
            
            var count = 0
            
            for message in messages {
                
                if Global.isAudio(type: message.type) {
                    
                    print(audioName)
                    
                    let audioStoredName = message.audio.name
                    
                    print(audioStoredName)
                    
                    if audioName == audioStoredName {
                        
                        let indexPath = IndexPath(item: count, section: 0)
                        
                        completionHandler(message , indexPath)
                    }
                }
                count = count + 1
            }
        }
        
        @objc func handleSendRec() {
            
            if self.recSendButton.tag == 1 {
                
                self.recordingStatus = RecordStatus.isRecording
                
                self.recSendButton.transform = CGAffineTransform(scaleX: 3, y: 3)
                
                if self.audioRecorder == nil {
                    
                    let onImage = UIImage(contentsOfFile: "rec_on")
                    
                    self.recSendButton.setImage(onImage, for: .normal)
                    
                    self.startRecording()
                    
                    self.chatTextTimer.startTimer()
                    
                }
                
            } else if self.recSendButton.tag == 2 {
                
                self.recordingStatus = RecordStatus.isNotRecording
                
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
                    
                } else {
                    self.sendMessage(sendPush: true)
                }
            }
            
        }
        
        @objc func handleSendRecUp() {
            
            self.recSendButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            self.recSendButton.setImage(UIImage(named: "rec_off"), for: .normal)
            
            self.recSendButton.tag = 1
            
            if recordingStatus == RecordStatus.isRecording {
                
                self.finishRecording(success: true)
            }
        }
        
        //-- RECORD AUDIO
        
        func directoryURL(name: String) -> NSURL? {
            
            let chatIdDirectory = self.createIfNotExistChatFolder()
            
            let soundURL = chatIdDirectory.appendingPathComponent(name)
            
            print(soundURL)
            
            return soundURL as NSURL?
            
        }
        
        enum EmoticonKeyboardState {
            case isEmoticon
            case isKeyboard
        }
        
        @objc func handleEmoticonsKeyboard() {
            
            if self.emoticonKeyboardState == EmoticonKeyboardState.isKeyboard {
                
                self.emojiView.delegate = self
                self.inputTextField.inputView = self.self.emojiView
                
                self.inputTextField.reloadInputViews()
                
                let keyboard_image = UIImage(named: "keyboard")
                keyboard_image?.maskWithColor(color: UIColor.lightGray)
                self.emojisKeyboardButton.setImage(keyboard_image, for: UIControlState.normal)
                
                self.emoticonKeyboardState = EmoticonKeyboardState.isEmoticon
                
                
            } else if self.emoticonKeyboardState == EmoticonKeyboardState.isEmoticon {
                
                self.keyboardDownEmojiOn()
                
            }
            
            self.inputTextField.becomeFirstResponder()
        }
        
        func keyboardDownEmojiOn() {
            
            DispatchQueue.main.async {
                self.inputTextField.inputView = nil
                self.inputTextField.reloadInputViews()
            }
            
            let emoticon_image = UIImage(named: "insert_emoticon")
            emoticon_image?.maskWithColor(color: UIColor.lightGray)
            self.emojisKeyboardButton.setImage(emoticon_image, for: UIControlState.normal)
            
            self.emoticonKeyboardState = EmoticonKeyboardState.isKeyboard
        }
        
        
        @objc func handleAddPicture() {
            
            self.unsubcribeClients()
            
            let params = ["targer":self,
                          "isImageMultiSelection":false,
                          "type":MediaType.selectImage,
                          "termToSearch":self.inputTextField.text!,
                          "searchType":SearchType.isSingleImage,
                          "searchSize":SearchSize.imageSmall] as [String : Any]
            
            self.appDelegate.openSearch(params:params)
            
        }
        
        func unsubcribeClients() {
            
            self.chatClient.unsubscribe(self.videoQuery)
            self.feedClient.unsubscribe(self.feedQuery)
            self.audioClient.unsubscribe(self.audioQuery)
            self.onlineClient.unsubscribe(self.onlineQuery)
            
        }
        
        func didPickImage(_ image: UIImage) {
            
            self.savePicture(image: image)
            
        }
        
        func didPickImages(_ images: [UIImage]) {
            
        }
        
        func didPickVideo(url: URL, data: Data, thumbnail: UIImage){
            
        }
        
        func contentsOf(folder: URL) -> [URL] {
            let fileManager = FileManager.default
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
                let urls = contents.map { return folder.appendingPathComponent($0) }
                return urls
            } catch {
                return []
            }
        }
        
        
        func createIfNotExistChatFolder() -> URL {
            
            let directory = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let chatIdString = "\(self.chatId)"
            let chatIdDirectory = directory[0].appendingPathComponent(chatIdString, isDirectory: true)
            
            if !self.fileManager.fileExists(atPath: chatIdDirectory.path) {
                
                do {
                    try FileManager.default.createDirectory(atPath: chatIdDirectory.path, withIntermediateDirectories: true, attributes: nil)
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
            let soundUri = self.directoryURL(name: audioName)
            
            Global.audioRecorded = GamvesAudio()
            Global.audioRecorded.localUri = soundUri as! URL
            Global.audioRecorded.name = audioName
            
            do {
                
                self.audioRecorder = try AVAudioRecorder(url: soundUri as! URL,
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
            
            self.chatTextTimer.reset()
            
            var asset = AVURLAsset(url: Global.audioRecorded.localUri)
            var totalSeconds = Int(CMTimeGetSeconds(asset.duration))
            
            if totalSeconds > 1 {
                
                if success {
                    
                    print(success)
                    
                    self.audioRecorder = nil
                    
                    let minutes = totalSeconds / 60
                    let seconds = totalSeconds % 60
                    let duration = String(format:"%02i:%02i",minutes, seconds)
                    
                    self.saveAudio(duration: duration, name: Global.audioRecorded.name)
                    
                } else {
                    
                    self.audioRecorder = nil
                    print("Somthing Wrong.")
                }
                
            } else {
                
                self.inputTextField.text = ""
                self.audioRecorder = nil
                
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
                    
                    Global.audioRecorded.audioObj = audioPF
                    
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
                    
                    if let audioId = Global.audioRecorded.audioObj.objectId {
                        
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
                            
                            Global.audioRecorded.audioObj = audioPF
                            
                            tempRecording = Global.audioRecorded
                            
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
                uploadRequest.body = audioStored.localUri
                uploadRequest.key = audioStored.name
                uploadRequest.bucket = S3BucketName
                uploadRequest.contentType = "audio/m4a" //"video/mp4" //"image/jpeg"
                uploadRequest.acl = .publicRead
                
                let transferManager = AWSS3TransferManager.default()
                transferManager.upload(uploadRequest).continueWith { (task) -> Any? in
                    
                    if let error = task.error {
                        print("Upload failed with error: (\(error.localizedDescription))")
                    }
                    
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
        
        func savePicture(image: UIImage) {
            
            let picturePF = PFObject(className: "Pictures")
            
            picturePF["chatId"] = self.chatId
            
            let picture = PFFile(name: "picture.png", data: UIImageJPEGRepresentation(image, 1.0)!)
            picturePF.setObject(picture!, forKey: "picture")
            
            let dataLow = image.lowestQualityJPEGNSData as Data
            var imageSmall = UIImage(data: dataLow)
            
            let pictureSmall = PFFile(name: "pictureSmall.png", data: UIImageJPEGRepresentation(image, 1.0)!)
            picturePF.setObject(pictureSmall!, forKey: "pictureSmall")
            
            if let userId = PFUser.current()?.objectId {
                picturePF["senderId"] = userId
            }
            
            picturePF.saveInBackground { (result, error) in
                
                if error == nil {
                    
                    Global.pictureRecorded = GamvesPicture()
                    Global.pictureRecorded.image = image
                    Global.pictureRecorded.imageSmall = imageSmall!
                    Global.pictureRecorded.picture = picture
                    Global.pictureRecorded.pictureSmall = pictureSmall
                    Global.pictureRecorded.pictureObj = picturePF
                    
                    let messagePF: PFObject = PFObject(className: "ChatVideo")
                    
                    var userId = String()
                    
                    if PFUser.current() != nil {
                        userId = (PFUser.current()?.objectId)!
                        messagePF["userId"] = userId
                    }
                    
                    messagePF["chatId"] = self.chatId
                    
                    var pictureMessage = String()
                    
                    if let pictureId = picturePF.objectId {
                        
                        pictureMessage  = "\(Global.picture_delimitator)\(pictureId)----\(self.chatId)"
                        
                        messagePF["message"] = pictureMessage
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
                        
                        if error == nil {
                            
                            self.sendPushWithCoud(message: pictureMessage)
                            
                        }
                    }
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
        
        
        func updateMessageFromServer(chatMessage: PFObject) {
            
            print()
            print("-------------------------------------")
            print("UPDATE")
            print("-------------------------------------")
            print()
            
            let message = MessageChat()
            
            message.type = MessageType.isText
            
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
            
            if (textMessage.contains(Global.audio_delimitator)) {
                
                if !message.isSender {
                    
                    message.type = MessageType.isAudioDownloading
                    
                    self.getAudio(id: self.messages.count, messageText: textMessage, completionHandler: { (gamvesAudio, id) in
                        
                        self.messages[id].audio = gamvesAudio
                    })
                    
                } else {
                    
                    message.type = MessageType.isAudio
                    
                    message.audioLocalUri = Global.audioRecorded.localUri
                }
                
            } else if (textMessage.contains(Global.picture_delimitator)) {
                
                if !message.isSender {
                    
                    message.type = MessageType.isPictureDownloading
                    
                    self.getPicture(id: self.messages.count, messageText: textMessage, completionHandler: { (gamvesPicture, id) in
                        
                        print(self.messages.count)
                        
                        print(id)
                        
                        self.messages[id].picture = gamvesPicture
                        self.messages[id].type = MessageType.isPicture
                        
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(item: id, section: 0)
                            self.collectionView.reloadItems(at: [indexPath])
                        }
                        
                    })
                    
                } else  {
                    
                    message.type = MessageType.isPicture
                    
                    if Global.pictureRecorded != nil {
                        
                        message.picture = Global.pictureRecorded
                    }
                }
            }
            
            if textMessage.range(of:Global.admin_delimitator) != nil {
                
                message.type = MessageType.isAdmin
                
                if let range = textMessage.range(of: Global.admin_delimitator) {
                    
                    textMessage.removeSubrange(range)
                }
                
            }
            
            message.message = textMessage
            
            let gamvesUser = Global.userDictionary[userId]!
            
            message.isSender = gamvesUser.isSender
            
            if ChatFeedMethods.chatFeeds[self.chatId] != nil {
                
                ChatFeedMethods.chatFeeds[self.chatId]?.text = textMessage
            }
            
            self.messages.append(message)
            
            print(self.messages.count)
            
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            
            print(indexPath)
            
            print("-----------------------------------------------------------------------------")
            
            DispatchQueue.main.async {
                
                self.inputTextField.text = ""
                
                self.collectionView.insertItems(at: [indexPath])
                
                self.scrollToLast()
            }
            
        }
        
        func initializeOnlineSubcritpion() {
            
            let userId = self.gamvesUsers[0].userId
            
            self.onlineQuery = PFQuery(className: "UserStatus").whereKey("userId", equalTo: userId)
            
            onlineSubscription = onlineClient.subscribe(self.onlineQuery).handle(Event.updated) { _, onlineMessage in
                
                self.changeSingleUserStatus(onlineMessage:onlineMessage)
            }
            
            let queryOnline = PFQuery(className:"UserStatus")
            queryOnline.whereKey("userId", equalTo: userId)
            queryOnline.getFirstObjectInBackground { (usersOnline, error) in 
                
                if error != nil
                {
                    print("error")

                    self.delegateNavBar.updateSubTitle(latelText: "Idle")
                    
                } else {

                    
                    self.changeSingleUserStatus(onlineMessage:usersOnline!)
                    
                }
            }
        }
        
        func changeSingleUserStatus(onlineMessage:PFObject)
        {
            let status = onlineMessage["status"] as! Int
            
            if status == 2 {
                
                delegateNavBar.updateSubTitle(latelText: "Online")
                
            } else if status == 1 {
                
                delegateNavBar.updateSubTitle(latelText: "Idle")
                
            } else if status == 0 {
                
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
        
        func addNewFeedAppendUser(completionHandler : @escaping (_ resutl:Bool) -> ()) {
            
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
                    
                    if error != nil {
                        
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
                
            } else {
                
                if self.gamvesUsers.count > 1 {
                    
                    let imageGroup = UIImage(named: "community")
                    groupImageFile = PFFile(data: UIImageJPEGRepresentation(imageGroup!, 1.0)!)
                    
                    var array = [String]()
                    
                    for user in self.gamvesUsers {
                        
                        array.append(user.typeObj.objectId!)
                    }
                    let members = String(describing: array)
                    self.chatFeed["members"] = members
                    
                } else {
                    
                    groupImageFile = PFFile(data: UIImageJPEGRepresentation(self.gamvesUsers[0].avatar, 1.0)!)
                    
                    print(PFUser.current())
                    
                    if let myUser = PFUser.current()?.objectId {
                        let member = String(describing: [self.gamvesUsers[0].userId,myUser])
                        self.chatFeed["members"] = member
                        self.chatFeed["room"] = "\(self.gamvesUsers[0].userId)____\(myUser)"
                    }
                }
            }
            
            if !self.isVideo {
                
                self.saveChatFeed(file: groupImageFile, completionHandlerSave: { ( result:Bool ) -> () in
                    
                    completionHandler(result)
                })
            }
        }
        
        func saveChatFeed(file:PFFile, completionHandlerSave : @escaping (_ resutl:Bool) -> ()) {
            
            if let objectId = PFUser.current()?.objectId {
                
                self.chatFeed["lastPoster"] = objectId
                
                if self.isVideo {
                    self.chatFeed["members"] = objectId
                    self.chatFeed["lastMessage"] = self.inputTextField.text
                }
            }
            
            self.chatFeed.setObject(file, forKey: "thumbnail")
            
            self.chatIdStr = String(self.chatId) as String
            
            var message = self.inputTextField.text
            
            self.chatFeed.saveInBackground(block: { (saved, error) in
                
                if error == nil {
                    
                    //CREATE CHANNELS
                    
                    let userId = (PFUser.current()?.objectId)! as String
                    
                    var userIdArray = [String]()
                    userIdArray.append(userId)
                    
                    if !self.isVideoChat {
                        
                        for user in self.gamvesUsers {
                            userIdArray.append(user.userId)
                        }
                    }
                    
                    Global.addChannels(userIds:userIdArray, channel: self.chatIdStr, completionHandlerChannel: { ( resutl ) -> () in
                        
                        if resutl && !self.isVideo {
                            
                            self.sendPushWithCoud(message: message!)
                        } else {
                            
                            completionHandlerSave(resutl)
                        }
                        completionHandlerSave    (resutl)
                    })
                }
            })
        }
        
        
        @objc func handleKeyboardNotification(notification: NSNotification) {
            
            if let userInfo = notification.userInfo {
                
                let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
                
                if notification.name == NSNotification.Name.UIKeyboardWillShow {
                    
                    let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
                    
                    if (self.keyboardDelegate != nil) {
                        
                        self.keyboardDelegate.keyboardOpened(keybordHeight: (keyboardFrame?.height)!)
                        
                    }
                    
                    self.addGestureRecognizer(self.tabGesture)
                    
                    
                } else if notification.name == NSNotification.Name.UIKeyboardWillHide {
                    
                    if (self.keyboardDelegate != nil) {
                        
                        self.keyboardDownEmojiOn()
                        
                        self.keyboardDelegate.keyboardclosed()
                        
                    }
                    
                    self.removeGestureRecognizer(self.tabGesture)
                }
            }
        }
        
        func animateKeyboard() {
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                
                self.layoutIfNeeded()
                self.layoutSubviews()
                
            }, completion: { (completed) in
                
                self.scrollToLast()
                
            })
            
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
        
        
        func scrollToLast() {
            
            let lastItem = self.messages.count - 1
            let indexPath = NSIndexPath(item: lastItem, section: 0)
            
            if (self.collectionView != nil && self.messages.count > 0) {
                
                self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
                
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
        
        func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
            self.inputTextField.insertText(emoji)
            self.setSendToText()
        }
        
        func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
            self.inputTextField.deleteBackward()
            self.setSendToRect()
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
            
            if !(textField.text?.isEmpty)! {
                
                let sendImage = UIImage(named: "send")
                
                sendImage?.maskWithColor(color: UIColor.gamvesColor)
                
                self.recSendButton.setImage(sendImage, for: .normal)
                
                self.recSendButton.tag = 2
                
                self.handleSendRec()
                
            }
            
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
            
            print(indexPath)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
            
            var message = self.messages[indexPath.row]
            
            cell.type = message.type
            cell.isSender = message.isSender

            cell.usersAmount = self.gamvesUsers.count
            
            print(self.messages.count)
            
            print(message)
            
            var messageText:String = message.message
            
            cell.messageText = messageText
            
            var time:String = message.time

            print(time)            
            
            cell.timeLabel.text = time            
            
            print(messageText)
            
            if Global.isAudio(type: message.type) || Global.isPicture(type: message.type) {
                
                cell.messageTextView.isHidden = true
            } else {
                
                cell.messageTextView.text = messageText
            }
            
            let userID = message.userId
            
            let gamvesUser = Global.userDictionary[userID]

            print(gamvesUser?.name)           

            cell.userLabel.text = gamvesUser?.name.components(separatedBy: " ")[0]
            
            let profileImageName = gamvesUser?.userName
            let profileImage = gamvesUser?.avatar
            
            cell.profileImageView.image = profileImage
            
            var estimatedFrame = getEstimatedFrame(message: message)
            
            var xAdmin:CGFloat = 20
            var widthAdmin = self.frame.width - 40
            
            if message.type == MessageType.isAdmin {
                
                let height = estimatedFrame.height + 20
                
                cell.bubbleView.frame = CGRect(x: xAdmin, y: -4, width: widthAdmin, height: height + 6)
                cell.messageTextView.frame = CGRect(x: xAdmin + 20, y: 0, width: widthAdmin-20, height: height)
                cell.profileImageView.isHidden = true
                
                
            } else if message.isSender == nil || !message.isSender {
                
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
                
                if Global.isAudio(type: message.type) {
                    
                    print(message.audio.localUri)
                    cell.gamvesAudio = message.audio
                    
                    cell.bHeight = bheight
                    cell.audioDurationLabel.text = message.audio.duration
                    cell.playPauseButton.tag = indexPath.row
                    
                } else if Global.isPicture(type: message.type) {
                    
                    cell.gamvesPicture = message.picture
                    
                    cell.bHeight = self.pictureHeight
                    cell.pictureImageView.image = message.picture.imageSmall
                    
                    cell.isSender = false
                    
                } else {
                    
                    cell.profileImageView.isHidden = false
                    cell.messageTextView.textColor = UIColor.white
                    
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
                
                if Global.isAudio(type: message.type){
                    
                    if message.audioLocalUri != nil {
                        message.audio.localUri = message.audioLocalUri
                    }
                    
                    cell.gamvesAudio = message.audio
                    
                    cell.bHeight = bheight
                    cell.audioDurationLabel.text = message.audio.duration
                    
                    
                    cell.playPauseButton.tag = indexPath.row
                    
                } else if Global.isPicture(type: message.type) {
                    
                    cell.gamvesPicture = message.picture
                    cell.bHeight = self.pictureHeight
                    cell.pictureImageView.image = message.picture.imageSmall
                    
                    
                } else {
                    
                    cell.profileImageView.isHidden = true
                    cell.messageTextView.textColor = UIColor.white
                    
                }
            }
            
            //cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)

            cell.bubbleWidth = cell.bubbleView.frame.width
            
            cell.setupSubviews()
            
            return cell
        }
        
        func getEstimatedFrame(message: MessageChat) -> CGRect {
            
            var estimatedFrame = CGRect()
            
            let messageText = message.message
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let eFrame = NSString(string: messageText!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            if  Global.isAudio(type: message.type) && eFrame.width < 60 {
                
                estimatedFrame = createFrame(eFrame: eFrame, width: 60, height: eFrame.height)
            } else if Global.isAudio(type: message.type) {
                
                let dWidth = self.frame.width
                let minWidth = (dWidth / 4) * 3
                
                estimatedFrame = createFrame(eFrame: eFrame, width: minWidth, height: 30)
            } else if Global.isPicture(type: message.type) {
                
                estimatedFrame = createFrame(eFrame: eFrame, width: self.pictureWidth, height: self.pictureHeight)
            } else {
                
                estimatedFrame = eFrame
            }
            return estimatedFrame
            
        }
        
        func createFrame(eFrame:CGRect, width: CGFloat, height: CGFloat) -> CGRect {
            return CGRect(x: eFrame.maxX, y: eFrame.maxY, width: width, height: height)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let message = messages[indexPath.row]
            let estimatedFrame = getEstimatedFrame(message: message)
            return CGSize(width:self.frame.width, height:estimatedFrame.height + 20 + 10)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsMake(8, 0, 0, 0)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
        }
    }



    class ChatLogMessageCell: BaseCell,
        AVAudioPlayerDelegate,
        TimerDelegate
    {
        
        var usersAmount = Int()       

        var type:MessageType!
        var isSender = Bool()
        
        //--
        // AUDIO
        
        var gamvesAudio = GamvesAudio()
        var updater : CADisplayLink! = nil
        var audioPlayer : AVAudioPlayer!
        var progressAudio: NVActivityIndicatorView!
        
        //--
        // IMAGE
        
        var gamvesPicture = GamvesPicture()
        var progressPicture: NVActivityIndicatorView!
        
        var messageText = String()
        
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

        let labelTextContainerView: UIView = {
            let view = UIView()
            view.layer.masksToBounds = true
            return view
        }()
        
        let timeLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "00:00"
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 10)
            return label
        }()
        
        let userLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false            
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 12)
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
        
        let pictureImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 5
            imageView.layer.masksToBounds = true
            imageView.layer.backgroundColor = UIColor.gamvesColor.cgColor
            return imageView
        }()
        
        let pictureImageButton: UIButton = {
            let button = UIButton()
            button.contentMode = .scaleAspectFill
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
            return button
        }()
        
        var bubbleImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.tintColor = UIColor(white: 0.90, alpha: 1)
            return imageView
        }()
        
        enum PayerStatus {
            case isPlaying
            case isPaused
            case isIdle
        }
        var playerStatus:PayerStatus!
        
        var audioTimer:ChatTimer!
        
        var bHeight = CGFloat()
        var bubbleWidth = CGFloat()
        
        override func prepareForReuse() {
            
            self.pictureImageView.isHidden = true
            self.playContainerView.isHidden = true
            self.messageTextView.isHidden = true
            
            if self.progressPicture != nil {
                self.progressPicture.stopAnimating()
            }
            if self.progressAudio != nil {
                self.progressAudio.stopAnimating()
            }
        }
        
        override func setupViews() {
            super.setupViews()
            
            addSubview(self.bubbleView)
            addSubview(self.messageTextView)
            
            self.bubbleView.addSubview(self.bubbleImageView)
            self.bubbleView.addConstraintsWithFormat("H:|[v0]|", views: self.bubbleImageView)
            self.bubbleView.addConstraintsWithFormat("V:|[v0]|", views: self.bubbleImageView)
            
            self.playerStatus = PayerStatus.isIdle
        }
        
        func setupSubviews() {
            
            switch self.type {
                
                case .isText:
                    
                    if self.isSender {
                        self.bubbleImageView.image = Global.blueBubbleImage
                        self.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                    } else {
                        self.bubbleImageView.image = Global.grayBubbleImage
                        self.bubbleImageView.tintColor = UIColor(white: 0.5, alpha: 1)
                    }
                    break
                    
                case .isPicture, .isPictureDownloading:
                    
                    if self.isSender {
                        self.bubbleImageView.image = Global.bluePictureBubbleImage
                        self.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                    } else {
                        self.bubbleImageView.image = Global.grayPictureBubbleImage
                        self.bubbleImageView.tintColor = UIColor(white: 0.5, alpha: 1)
                    }
                    break
                    
                case .isAudio, .isAudioDownloading:
                    self.bubbleImageView.image = Global.audioBubbleImage
                    break
                    
                case .isAdmin:
                    self.bubbleImageView.image = Global.adminBubbleImage
                    self.bubbleImageView.tintColor = UIColor.lightGray
                    self.messageTextView.textColor = UIColor.gray
                    break
                    
                case .none: break
                case .some(_): break
                
            }
            
            let bHeight = self.frame.height - 10
            
            let bubbleMetrics = ["bHeight" : bHeight]

            print(self.usersAmount)

            self.usersAmount = 2

            if self.type == MessageType.isText || self.type == MessageType.isPicture {

                if self.isSender {

                    self.bubbleView.addSubview(self.timeLabel)
                    self.bubbleView.addConstraintsWithFormat("H:|-15-[v0]-15-|", views: self.timeLabel)
                    self.bubbleView.addConstraintsWithFormat("V:|-bHeight-[v0(15)]|", views: self.timeLabel, metrics: bubbleMetrics)
                    
                    if self.isSender {
                        self.timeLabel.textAlignment = .left
                    } else  {
                        self.timeLabel.textAlignment = .right
                    }

                } else {

                    self.bubbleView.addSubview(self.labelTextContainerView)
                    self.bubbleView.addConstraintsWithFormat("H:|[v0]|", views: self.labelTextContainerView)
                    self.bubbleView.addConstraintsWithFormat("V:|-bHeight-[v0(15)]|", views: self.labelTextContainerView, metrics: bubbleMetrics)

                    //self.labelTextContainerView.backgroundColor = UIColor.white

                    self.labelTextContainerView.addSubview(self.timeLabel)                
                    self.labelTextContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.timeLabel)

                    //self.timeLabel.backgroundColor = UIColor.green

                    self.labelTextContainerView.addSubview(self.userLabel)                
                    self.labelTextContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.userLabel)

                    //self.userLabel.backgroundColor = UIColor.cyan

                    let labelSize = self.bubbleWidth / 2

                    let bubbleWidthMetrics = ["labelSize" : labelSize]

                    self.labelTextContainerView.addConstraintsWithFormat("H:|[v0(labelSize)][v1(labelSize)]|", views: self.userLabel, self.timeLabel, metrics: bubbleWidthMetrics)               

                    self.timeLabel.textAlignment = .center
                    self.userLabel.textAlignment = .center


                }
            
            }
            
            if Global.isAudio(type: self.type) {
                
                self.playContainerView.isHidden = false
                
                self.playerStatus = PayerStatus.isIdle
                
                self.audioTimer = ChatTimer()
                self.audioTimer.delegate = self
                
                self.bubbleView.addSubview(self.playContainerView)
                self.bubbleView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.playContainerView)
                self.bubbleView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.playContainerView)
                
                self.playContainerView.addSubview(self.playButtonView)
                self.playContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.playButtonView)
                
                self.playContainerView.addSubview(self.centralContainerView)
                self.playContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.centralContainerView)
                
                self.playContainerView.addSubview(self.profileContainerView)
                self.playContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.profileContainerView)
                
                if self.isSender {
                    
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
                
                self.playButtonView.backgroundColor = UIColor.green
                self.centralContainerView.backgroundColor = UIColor.gamvesColor
                self.profileContainerView.backgroundColor = UIColor.red
                
                let playImage = UIImage(named: "play")
                playImage?.maskWithColor(color: UIColor.gamvesColor)
                self.playPauseButton.setImage(playImage, for: UIControlState.normal)
                self.playPauseButton.addTarget(self, action:#selector(self.playPause(button:)), for: .touchUpInside)
                
                self.playButtonView.addSubview(self.playPauseButton)
                self.playButtonView.addConstraintsWithFormat("H:|-10-[v0(40)]-10-|", views: self.playPauseButton)
                self.playButtonView.addConstraintsWithFormat("V:|-10-[v0(40)]|", views: self.playPauseButton)
                
                self.playerSlider.addTarget(self, action:#selector(sliderValueDidChange(sender:)), for: .valueChanged)
                
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
                
                if self.type == MessageType.isAudioDownloading {
                    self.progressAudio = Global.setActivityIndicatorForChat(container: self.profileContainerView, type: NVActivityIndicatorType.ballScaleRipple.rawValue, color: UIColor.black,x: 10, y: 10, width: 40.0, height: 40.0)
                    self.profileImageView.isHidden = true
                    self.progressAudio.startAnimating()
                }
                
            } else if Global.isPicture(type: self.type) {
                
                self.pictureImageView.isHidden = false
                
                var left = Int()
                var  right = Int()
                
                if self.isSender {
                    left = 10
                    right = 15
                } else {
                    left = 15
                    right = 10
                }
                
                let metricsPicture = ["left":left,"right": right]
                
                self.bubbleView.addSubview(self.pictureImageView)
                self.bubbleView.addConstraintsWithFormat("H:|-left-[v0]-right-|", views: self.pictureImageView, metrics: metricsPicture)
                self.bubbleView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.pictureImageView)
                
                self.pictureImageButton.addTarget(self, action:#selector(self.showImage(button:)), for: .touchUpInside)
                
                self.pictureImageButton.frame = self.pictureImageView.frame
                
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = self.pictureImageView.frame
                gradientLayer.colors = [UIColor.clear.cgColor, UIColor.gamvesBlackColor.cgColor]
                gradientLayer.locations = [0.2, 1.2]
                self.pictureImageView.layer.addSublayer(gradientLayer)
                
                if self.type == MessageType.isPictureDownloading {
                    self.progressPicture = Global.setActivityIndicatorForChat(container: self.bubbleView, type: NVActivityIndicatorType.ballScaleRipple.rawValue, color: UIColor.black,x: 0, y: 0, width: 80.0, height: 80.0)
                    self.progressPicture.startAnimating()
                }
                
            } else {
                
                self.messageTextView.isHidden = false
            }
        }

        
        func showImage(button: UIButton) {
            
            let image = self.gamvesPicture
            
        }
        
        func playPause(button: UIButton) {
            
            if self.playerStatus == PayerStatus.isPlaying {
                
                self.audioPlayer.pause()
                self.audioTimer.pause()
                
            } else if self.playerStatus == PayerStatus.isPaused {
                
                self.audioPlayer.play()
                self.audioTimer.startTimer()
                
            } else if self.playerStatus == PayerStatus.isIdle {
                
                self.audioTimer.startTimer()
                self.playAudio()
            }
            
        }
        
        //-- PLAY AUDIO
        
        func playAudio() {
            
            self.audioDurationLabel.text = self.gamvesAudio.duration
            
            self.updater = CADisplayLink(target: self, selector: #selector(trackAudio))
            self.updater.frameInterval = 1
            self.updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
            
            print(self.gamvesAudio.localUri)
            
            let localAudio:URL = self.gamvesAudio.localUri
            
            if ( FileManager.default.fileExists(atPath: (localAudio.path)) ) {
                
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
                
                self.playerStatus = PayerStatus.isPlaying
                
                self.audioTimer.startTimer()
            }
        }
        
        func timeCount(time: String) {
            self.audioCountabel.text = time
        }
        
        func timeReset(time: String) {
            self.audioCountabel.text = time
        }
        
        @objc func trackAudio() {
            let normalizedTime = Float(self.audioPlayer.currentTime * 100.0 / self.audioPlayer.duration)
            self.playerSlider.value = normalizedTime
        }
        
        func startRecordTimer() {
            self.audioTimer.startTimer()
        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            self.playerStatus = PayerStatus.isIdle
            self.audioTimer.reset()
            self.showPlayIcon()
        }
        
        func showPlayIcon(){
            DispatchQueue.main.async {
                let playImage = UIImage(named: "play")
                playImage?.maskWithColor(color: UIColor.gamvesColor)
                self.playPauseButton.setImage(playImage, for: UIControlState.normal)
            }
        }
        
        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
            print(error.debugDescription)
        }
        
        internal func audioPlayerBeginInterruption(_ player: AVAudioPlayer){
            print(player.debugDescription)
        }
        
        func sliderValueDidChange(sender: AnyObject) {
            
        }
        
        func stopSpinner() {
            self.progressAudio.stopAnimating()
        }
        
    }

    protocol TimerDelegate {
        func timeCount(time: String)
        func timeReset(time: String)
    }

    class ChatTimer: NSObject {
        
        weak var timer : Timer?
        var startTime: Double = 0
        var time: Double = 0
        
        var timerIsOn = false
        
        var delegate:TimerDelegate!
        
        func startTimer(){
            
            if !self.timerIsOn && self.timer == nil {
                self.startTime = Date().timeIntervalSinceReferenceDate
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,      selector: #selector(timerRunning), userInfo: nil, repeats: true)
                self.timerIsOn = true
            }
        }
        
        func pause(){
            self.timer?.invalidate()
            self.timerIsOn = false
        }
        
        func reset() {
            if self.timer != nil {
                self.timer?.invalidate()
                self.delegate.timeReset(time: "00:00")
                self.timer = nil
                timerIsOn = false
            }
        }
        
        func timerRunning() {
            
            time = Date().timeIntervalSinceReferenceDate - startTime
            
            let minutes = UInt8(time / 60.0)
            time -= (TimeInterval(minutes) * 60)
            
            let seconds = UInt8(time)
            time -= TimeInterval(seconds)
            
            let strMinutes = String(format: "%02d", minutes)
            let strSeconds = String(format: "%02d", seconds)
            
            let timeCount = "\(strMinutes):\(strSeconds)"
            
            self.delegate.timeCount(time: timeCount)
            
        }
        
    }

