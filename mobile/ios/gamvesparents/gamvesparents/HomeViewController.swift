//
//  HomeViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 9/26/17.
//

import UIKit
import Foundation
import Parse
import NVActivityIndicatorView
import MapKit
import ParseLiveQuery


class HomeViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout    
{

    var userStatistics = [UserStatistics]()

	var metricsHome = [String:Int]()
    
    var tabBarViewController:TabBarViewController?
    
    private var sonSubscription: Subscription<PFObject>!
    
    let liveQueryClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .remoteWs)
    
    private var approvalSubscription: Subscription<PFObject>!
    private var friendApprovalSubscription: Subscription<PFObject>!        

    private var approvalSubscriptionUpdate: Subscription<PFObject>!
    private var friendApprovalSubscriptionUpdate: Subscription<PFObject>!    
    

    let liveQueryClientApproval: Client = ParseLiveQuery.Client(server: Global.localWs)

    let liveQueryClientFriendApproval: Client = ParseLiveQuery.Client(server: Global.localWs)

    var youSonChatId = Int()
    var youSpouseChatId = Int()
    var groupChatId = Int()

    var friendApprovalViewController: FriendApprovalViewController = {
        let friend = FriendApprovalViewController()
        return friend
    }()
    
    var approvalViewController: ApprovalViewController = {
        let selector = ApprovalViewController()
        return selector
    }()
    
    var historyViewControlle: HistoryViewController = {
        let selector = HistoryViewController()
        return selector
    }()
    
    var activityViewControlle: ActivityViewController = {
        let selector = ActivityViewController()
        return selector
    }()

    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red //.gamvesBackgoundColor
        return view
    }()
    
    let lineView: UIView = {
         let v = UIView()
         v.translatesAutoresizingMaskIntoConstraints = false
         v.backgroundColor = UIColor.gray
         return v
    }()

    var backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill //.scaleFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let photosContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true        
        return view
    }()
    
    let homeBackgroundView: UIView = {
        let view = UIView()
        return view
    }()
	
    lazy var sonPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSonPhotoImageView)))
        imageView.isUserInteractionEnabled = true        
        imageView.tag = 1
        return imageView
    }()   

    var checkLabelSon: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var sonLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.gamvesBlackColor
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()   

    let dataLeftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let dataView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    let dataRightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    lazy var locationViewController: LocationViewController = {
        let location = LocationViewController()
        return location
    }()


    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var cellId = String()
    
    var sonOnline = Bool()

    var _status     = UserStatistics()
    var _location   = UserStatistics()
    var _friends    = UserStatistics()
    var _approval   = UserStatistics()
    var _activity   = UserStatistics()
    var _history    = UserStatistics()

    var photoCornerRadius = Int()
    
    var countWeekTime = TimeInterval()
    
    func initilizeObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(familyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)
        
        if Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_family_exist") {

            NotificationCenter.default.addObserver(self, selector: #selector(chatFeedLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyChatFeed), object: nil)
        }
        
    }

    var locations = [LocationGamves]()

    var puserId = String()

    var friendCount = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }

        tabBarController?.tabBar.isHidden = false
        
        self.cellId = "homeCellId"  
        
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.dataView)
        self.view.addSubview(self.bottomView)        
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.headerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.dataView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)        
        
        let width:Int = Int(view.frame.size.width)
        let height:Int = Int(view.frame.size.height)        
        
        let photoSize = width / 3
        let padding = (width - photoSize) / 2
        self.photoCornerRadius = photoSize / 2        

        let tabBarHeight = self.tabBarController!.tabBar.frame.size.height

        self.metricsHome["photoSize"]       = photoSize
        self.metricsHome["padding"]         = padding
        self.metricsHome["tabBarHeight"]    = Int(tabBarHeight)
                
        self.view.addConstraintsWithFormat(
            "V:|-60-[v0(160)][v1(1)][v2][v3(tabBarHeight)]|", views:
            self.headerView,
            self.lineView,
            self.dataView,
            self.bottomView, 
            metrics: metricsHome)         
        
        self.headerView.addSubview(self.backImageView)
        self.headerView.addSubview(self.photosContainerView)
        self.headerView.addSubview(self.sonLabel)
        
        self.headerView.addConstraintsWithFormat("H:|[v0]|", views: self.backImageView)
        self.headerView.addConstraintsWithFormat("H:|[v0]|", views: self.photosContainerView)
        self.headerView.addConstraintsWithFormat("H:|[v0]|", views: self.sonLabel) 

        self.headerView.addConstraintsWithFormat("V:|[v0(70)]|", views: self.backImageView)
        
        self.headerView.addConstraintsWithFormat(
            "V:|-20-[v0(photoSize)][v1]|", views:
            self.photosContainerView,
            self.sonLabel,
            metrics: self.metricsHome)
        
        self.checkLabelSon =  Global.createCircularLabel(text: "2", size: 25, fontSize: 18.0, borderWidth: 0.0, color: UIColor.gamvesColor)
        
        self.photosContainerView.addSubview(self.sonPhotoImageView)
        self.photosContainerView.addSubview(self.checkLabelSon)
        
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.sonPhotoImageView)
        
        var metricsVerBudge = [String:Int]()
        
        metricsVerBudge["verPadding"] = photoSize - 25
        
        self.photosContainerView.addConstraintsWithFormat("V:|-verPadding-[v0(25)]", views: self.checkLabelSon, metrics: metricsVerBudge)
        
        self.photosContainerView.addConstraintsWithFormat(
            "H:|-padding-[v0(photoSize)]-padding-|", views:
            self.sonPhotoImageView,
            metrics: metricsHome)
        
        var metricsHorBudge = [String:Int]()
        
        let paddingBudge = (padding + photoSize) - 25
        
        metricsHorBudge["sonPadding"]      = paddingBudge
        metricsHorBudge["spousePadding"]   = (paddingBudge * 2) + 25
        metricsHorBudge["groupPadding"]    = (paddingBudge * 3) + 50
        
        self.photosContainerView.addConstraintsWithFormat("H:|-sonPadding-[v0(25)]", views: self.checkLabelSon, metrics: metricsHorBudge)
     
        self.dataView.addSubview(self.dataLeftView)
        self.dataView.addSubview(self.collectionView)        
        self.dataView.addSubview(self.dataRightView)

        self.dataView.addConstraintsWithFormat("V:|-7-[v0]|", views: self.collectionView)
        self.dataView.addConstraintsWithFormat("V:|-7-[v0]|", views: self.dataLeftView)
        self.dataView.addConstraintsWithFormat("V:|-7-[v0]|", views: self.dataRightView)

        self.dataView.addConstraintsWithFormat("H:|[v0(20)][v1][v2(20)]|", views: 
            self.dataLeftView, 
            self.collectionView, 
            self.dataRightView)
       
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)//, x: 0, y: 0, width: 80.0, height: 80.0)
        
        self.collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)

        self.collectionView.backgroundColor = UIColor.gamvesLightLightBlueColor
        self.dataView.backgroundColor = UIColor.gamvesLightLightBlueColor
        self.dataLeftView.backgroundColor = UIColor.gamvesLightLightBlueColor
        self.dataRightView.backgroundColor = UIColor.gamvesLightLightBlueColor
        self.headerView.backgroundColor = UIColor.gamvesGamvesLightColor
        
        self.activityIndicatorView?.startAnimating()
        
        self.checkLabelSon.isHidden = true
        
        self.renderSon()

        self.loadStatistics()
        
    }   

    var _status_time = String()

    var _friends_data = "04:50 hs"
    var _friends_desc = "Friends"

    var _approval_approval = String()
    var _friend_approval = Bool()

    var _location_data = String()
    
    func loadStatistics() {

    	self.userStatistics = [UserStatistics]()
    
        _status.desc = "Offline"
        _status.icon = UIImage(named: "status_offline")!
        _status.second_icon = UIImage(named: "time")!
        _status.id = 0
        _status.data = _status_time
        self.userStatistics.append(_status)
    
        _location.desc = "Location"
        _location.data = _location_data 
        _location.id = 1
        _location.icon = UIImage(named: "map")!
        _location.second_icon = UIImage(named: "location")!
        self.userStatistics.append(_location)
    
        _friends.desc = _friends_desc 
        _friends.data = _friends_data
        _friends.id = 2
        _friends.icon = UIImage(named: "friend")!
        _friends.second_icon = UIImage(named: "add_friend")!
        _friends.updated = self._friend_approval
        self.userStatistics.append(_friends)

        _approval.desc = "Approvals"
        _approval.id = 3
        _approval.icon = UIImage(named: "check_circle")!
        _approval.data = self._approval_approval
        _approval.second_icon = UIImage(named: "sand_watch")!
        self.userStatistics.append(_approval)
    
        _activity.desc = "Activity"
        _activity.id = 4
        _activity.icon = UIImage(named: "view_activity")!        
        self.userStatistics.append(_activity)
    
        _history.desc = "History"
        _history.id = 5
        _history.icon = UIImage(named: "history")!
        self.userStatistics.append(_history)
    
    }
    
 
    func loadSonProfileInfo() {
        
        let queryUser = PFQuery(className:"Profile")
        
        queryUser.whereKey("userId", equalTo: Global.gamvesFamily.sonsUsers[0].userId)
        
        queryUser.getFirstObjectInBackground { (profile, error) in
            
            if error == nil {
                
                if let prPF:PFObject = profile {
                
                    if prPF["pictureBackground"] != nil {
                        
                        let backImage = prPF["pictureBackground"] as! PFFileObject
                    
                        backImage.getDataInBackground { (imageData, error) in
                            
                            if error == nil {
                                
                                if let imageData = imageData {
                                    
                                    let image = UIImage(data:imageData)
                                    
                                    self.backImageView.image = image
                                
                                }
                            }
                        }
                    }
                }
            }
        }
    }   
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false     
    }

    func hideShowTabBar(status: Bool)
    {
        self.tabBarController?.tabBar.isHidden = status
        
        if status
        {
            navigationController?.navigationBar.tintColor = UIColor.white
        } 
    }
  
    func getTimeCount() {

        let userId:String = Global.gamvesFamily.sonsUsers[0].userId

        //-
        // Get last time online

        let queryLastSeen = PFQuery(className:"TimeOnline")               
        queryLastSeen.whereKey("userId", equalTo: userId)        
        queryLastSeen.order(byDescending: "createdAt")        
        queryLastSeen.limit = 1
        queryLastSeen.findObjectsInBackground { (times, error) in

            if error == nil {

                for time in times! {
                    
                    let last = time.createdAt as! Date

                    self._status_time = last.elapsedTime

                    self.loadUserStatus()
            
                    DispatchQueue.main.async {
                    
                        self.collectionView.reloadData()
                        
                    }  

                }
            }
        }

        //-
        // Count elapsed time last week
        
        /*let queryTimeCount = PFQuery(className:"TimeOnline")         
        queryTimeCount.whereKey("userId", equalTo: userId)        
        queryTimeCount.order(byDescending: "createdAt")

        if let initWeek = Date().startOfWeek {
            
            let minute:TimeInterval = 60.0
            let hour:TimeInterval = 60.0 * minute
            let day:TimeInterval = 24 * hour
            let week:TimeInterval = 7 * day
            
            let endweek = Date(timeInterval: week, since: initWeek)
            
            queryTimeCount.whereKey("createdAt", greaterThanOrEqualTo: initWeek)
            queryTimeCount.whereKey("updatedAt", lessThanOrEqualTo: endweek)
            
        }
    
        queryTimeCount.findObjectsInBackground { (times, error) in
            
            if error == nil {
                
                for time in times! {
                    
                    let timeStarted = time["timeStarted"] as! Date
                    
                    if time["timeEnded"] != nil {
                        
                        let timeEnded = time["timeEnded"] as! Date
                        
                        print(timeStarted)
                        print(timeEnded)
                        
                        let interval = timeEnded.timeIntervalSince(timeStarted)
                        
                        self.countWeekTime = self.countWeekTime + interval
                    }                    
                }
                
                let stringInterval = self.stringFromTimeInterval(interval: self.countWeekTime)
                
                let timecounted = "\(stringInterval) hs" 

                if self.userStatistics.count == 0 {

                    self.loadStatistics()
                    
                }                               
                
                //self.userStatistics[0].data = timecounted

                self._status_time = timecounted

                self.loadUserStatus()
            
                DispatchQueue.main.async {
                
                    self.collectionView.reloadData()
                    
                }               
                
            }
        }*/
    }


    func getLocation(){

        let queryLocation = PFQuery(className:"Location")
        
        let sonId = Global.gamvesFamily.sonsUsers[0].userId 
        
        queryLocation.whereKey("userId", equalTo: sonId)
        queryLocation.order(byDescending: "createdAt")
        queryLocation.limit = 10

        queryLocation.findObjectsInBackground {
            (locationPF, error) -> Void in

            if error == nil {

                if let locations = locationPF {

                    var count = 0
                    
                    for location in locations {
                        
                        var locGamves = LocationGamves()
                        
                        locGamves.geopoint = location["geolocation"] as! PFGeoPoint

                        if count == 0 {                           

                            let myLocation = Global.locationPF.location()                        

                            let distanceInMeters = myLocation.distance(from: myLocation)
                        
                            self._location_data = "\(distanceInMeters) meters"

                             DispatchQueue.main.async {
                        
                                self.collectionView.reloadData()

                                self.loadUserStatus()
                            
                            } 

                        }

                        // Extended formatted_address reverse geocode data
                        
                        locGamves.address = location["address"] as! String
                        
                        locGamves.city = location["city"] as! String
                        
                        locGamves.state = location["state"] as! String
                        
                        locGamves.country = location["country"] as! String
                        
                        self.locations.append(locGamves)
                        
                        count = count + 1
                    }
                }                
            }
        }
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func generateDates(startDate :Date?, addbyUnit:Calendar.Component, value : Int) -> [Date] {
        
        var dates = [Date]()
        var date = startDate!
        let endDate = Calendar.current.date(byAdding: addbyUnit, value: value, to: date)!
        while date < endDate {
            date = Calendar.current.date(byAdding: addbyUnit, value: 1, to: date)!
            dates.append(date)
        }
        return dates
    }

    
    @objc func chatFeedLoaded()
    {
        let sonRegisterChatId:Int = Global.gamvesFamily.sonRegisterChatId
        if ChatFeedMethods.chatFeeds[sonRegisterChatId]! != nil
        {
            let sonBadge = ChatFeedMethods.chatFeeds[sonRegisterChatId]?.badgeNumber
            
            if sonBadge! > 0
            {
                self.checkLabelSon.isHidden = false
                
                let sob = "\(sonBadge!)"
                
                self.checkLabelSon.text = sob
            }            
        }
    }
    
    
    @objc func familyLoaded() {
        
        let familyId = Global.gamvesFamily.objectId
        
        Global.getApprovasByFamilyId(familyId: familyId, completionHandler: { ( count ) -> () in                      
		
            self._approval_approval = "Pendings:  \(count)"

            self.loadStatistics()
            
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
            }
            
        })
        

        self.getFriends(familyId: familyId)               
        
        self.renderSon()
        
        self.initializeOnlineSubcritpion()
        
        self.getTimeCount()

        self.getLocation()

        self.loadUserStatus()
        
        self.loadSonProfileInfo()

    }    


    func getFriends(familyId: String) {

        let userId = Global.gamvesFamily.sonsUsers[0].userId

        Global.getFriendsAmount(posterId: userId, completionHandler: { ( countFriends ) -> () in

            self.friendCount = countFriends

            Global.getFriendsApprovasByFamilyId(familyId: familyId, completionHandler: { ( invites, invited, updated ) -> () in
                
                self.updateFriendView(invites: invites, invited: invited, updated: updated)
                
            })
        })
    }
    
    func renderSon() {
        
        print(self.puserId)
        
        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }
        
        if self.isKeyPresentInUserDefaults(key: "\(self.puserId)_son_userId") {        
            
            if self.isKeyPresentInUserDefaults(key: "\(self.puserId)_son_object_id")
            {
                
                DispatchQueue.main.async {
                    
                    let sonId = Global.defaults.object(forKey: "\(self.puserId)_son_object_id") as! String
                    
                    if Global.userDictionary[sonId] != nil
                    {
                        self.sonLabel.text = Global.userDictionary[sonId]?.firstName
                        
                        self.sonPhotoImageView.image = Global.userDictionary[sonId]?.avatar
                        
                        Global.setRoundedImage(image: self.sonPhotoImageView, cornerRadius: self.photoCornerRadius, boderWidth: 5, boderColor: UIColor.gamvesGamvesLightColor)
                    }
                    
                    self.activityIndicatorView?.stopAnimating()
                }
            }            
        }
    }
    
   
    func isKeyPresentInUserDefaults(key: String) -> Bool
    {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    
    func generateGroupImage() -> UIImage
    {
        let LeftImage = self.sonPhotoImageView.image        
        
        let size = CGSize(width: LeftImage!.size.width, height: LeftImage!.size.height)        
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        LeftImage?.draw(in: CGRect(x: 0, y: 0, width:size.width, height: size.height))                
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()
        
        return newImage
    }

    @objc func handleSonPhotoImageView(sender: UITapGestureRecognizer)
    {
        
        let sonRegisterChatId:Int = Global.gamvesFamily.sonRegisterChatId
    
        if ChatFeedMethods.chatFeeds[sonRegisterChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[sonRegisterChatId]!
            
            var users = [GamvesUser]()
            users.append(Global.gamvesFamily.sonsUsers[0])
            users.append(Global.gamvesFamily.youUser)

            self.chatViewController.chatId = sonRegisterChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!            
            self.chatViewController.view.backgroundColor = UIColor.white
           
            navigationController?.pushViewController(self.chatViewController, animated: true)
    
        }                
    }

    @objc func handleSpousePhotoImageView(sender: UITapGestureRecognizer)
    {
        
        let spouseRegisterChatId:Int = Global.gamvesFamily.spouseRegisterChatId
        
        if ChatFeedMethods.chatFeeds[spouseRegisterChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[spouseRegisterChatId]!
            
            var users = [GamvesUser]()
            users.append(Global.gamvesFamily.spouseUser)
            users.append(Global.gamvesFamily.youUser)
            
            self.chatViewController.chatId = spouseRegisterChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            //self.chatViewController.isStandAlone = true
            self.chatViewController.view.backgroundColor = UIColor.white
            
            navigationController?.pushViewController(self.chatViewController, animated: true)
            
        }
    	
    }

    @objc func handleGroupPhotoImageView(sender: UITapGestureRecognizer)
    {
        let familyChatId:Int = Global.gamvesFamily.familyChatId
        
        if ChatFeedMethods.chatFeeds[familyChatId]! != nil
        {
            let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[familyChatId]!
            
            var users = [GamvesUser]()
            users.append(Global.gamvesFamily.sonsUsers[0])
            users.append(Global.gamvesFamily.spouseUser)
            users.append(Global.gamvesFamily.youUser)
            
            self.chatViewController.chatId = familyChatId
            self.chatViewController.gamvesUsers = users
            self.chatViewController.room = chatfeed.room!
            //self.chatViewController.isStandAlone = true
            self.chatViewController.view.backgroundColor = UIColor.white
            
            navigationController?.pushViewController(self.chatViewController, animated: true)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    ////collectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userStatistics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeCollectionViewCell
        

        let id = indexPath.item
        
        var stats = self.userStatistics[id]
        
        cell.descLabel.text = stats.desc        
        cell.dataLabel.text = stats.data
        
        print(stats.desc)
        print(stats.updated)
        print(id)
        
        if id == 0
        {
            if self.sonOnline
            {
                stats.icon = UIImage(named: "status_online")!
                cell.descLabel.text = "Online"               

            } else {
               
                stats.icon = UIImage(named: "status_offline")!
                cell.descLabel.text = "Offline"                
                cell.dataLabel.text = stats.data

            }         
            
        } 
        
        if stats.updated {
            
            stats.icon = UIImage(named: "check_circle_white")!
            
            cell.descLabel.textColor = UIColor.white
            cell.dataLabel.textColor = UIColor.white                      
        
            cell.backView.backgroundColor = UIColor.gamvesColor            
            
            cell.layer.cornerRadius = 10            
        }      
        
   
        cell.iconImageView.image = stats.icon
        
        //if id < 3 {
            
            print(stats.desc)

            cell.secondIconImageView.image = stats.second_icon

            cell.secondIconImageView.alpha = 0.4

        //}       
        
        //if id > 0
        //{
            cell.iconImageView.alpha = 0.4
        //}
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {    
        
        if indexPath.row == 0 { //Online
            
        } else if indexPath.row == 1 { //Location

            self.locationViewController.locations = self.locations
            navigationController?.pushViewController(self.locationViewController, animated: true) 
            tabBarController?.tabBar.isHidden = true         
        
        } else if indexPath.row == 2 { //Friends

            friendApprovalViewController.homeViewController = self
            friendApprovalViewController.view.backgroundColor = UIColor.white
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            navigationController?.pushViewController(friendApprovalViewController, animated: true)
            tabBarController?.tabBar.isHidden = true            
            
            
        } else if indexPath.row == 3 { //Approval

            approvalViewController.homeViewController = self
            approvalViewController.view.backgroundColor = UIColor.white
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            navigationController?.pushViewController(approvalViewController, animated: true)
            tabBarController?.tabBar.isHidden = true
            
        } else if indexPath.row == 4 { //Activity
            
            activityViewControlle.homeViewController = self
            activityViewControlle.view.backgroundColor = UIColor.white
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            navigationController?.pushViewController(activityViewControlle, animated: true)
            tabBarController?.tabBar.isHidden = true
        
        } else if indexPath.row == 5 { //History
            
            historyViewControlle.homeViewController = self
            historyViewControlle.view.backgroundColor = UIColor.white
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            navigationController?.pushViewController(historyViewControlle, animated: true)
            tabBarController?.tabBar.isHidden = true
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let userStatistic = userStatistics[indexPath.row]

        /*if let description = userStatistic.description {
            
            let size = CGSize(width:250, height:1000)
            
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width:self.frame.width, height:estimatedFrame.height + 20)
        }*/
        
        return CGSize(width:self.collectionView.frame.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
   
    
    func initializeOnlineSubcritpion()
    {
        
        if Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_son_object_id") {
        
            let sonId = Global.defaults.object(forKey: "\(self.puserId)_son_object_id") as! String

            if Global.userDictionary[sonId] != nil
            {
                let userId = Global.userDictionary[sonId]?.userId
                
                let onlineQuery = PFQuery(className: "UserStatus").whereKey("userId", equalTo: userId)
                
                self.sonSubscription = liveQueryClient.subscribe(onlineQuery).handle(Event.updated) { _, onlineMessage in
                    
                    self.changeSingleUserStatus(onlineMessage:onlineMessage)
                    
                }
                
                self.loadUserStatus()           
            }
            
            if Global.gamvesFamily != nil
            {
                
                let familyId = Global.gamvesFamily.objectId
                
                var approvalQuery = PFQuery(className: "Approvals").whereKey("familyId", equalTo: familyId)
                
                self.approvalSubscription = liveQueryClientApproval.subscribe(approvalQuery).handle(Event.created) { _, approvals in
                    
                    Global.getApprovasByFamilyId(familyId: familyId, completionHandler: { ( count ) -> () in        

                        self.updateApproval(count: count)

                    })
                }

                 self.approvalSubscriptionUpdate = liveQueryClientApproval.subscribe(approvalQuery).handle(Event.updated) { _, approvals in
                    
                    Global.getApprovasByFamilyId(familyId: familyId, completionHandler: { ( count ) -> () in         

                        self.updateApproval(count: count)               
                   
                    })
                }
                
                var friendsApprovalQuery = PFQuery(className: "FriendsApproval").whereKey("familyId", equalTo: familyId)                               
                
                self.friendApprovalSubscription = liveQueryClientFriendApproval.subscribe(friendsApprovalQuery).handle(Event.created) { _, approvals in
                    
                    Global.getFriendsApprovasByFamilyId(familyId: familyId, completionHandler: { ( invites, invited, updated ) -> () in                             

                        self.updateFriendView(invites: invites, invited: invited, updated: updated)
                        
                    })
                }

                self.friendApprovalSubscriptionUpdate = liveQueryClientFriendApproval.subscribe(friendsApprovalQuery).handle(Event.updated) { _, approvals in
                    
                    Global.getFriendsApprovasByFamilyId(familyId: familyId, completionHandler: { ( invites, invited, updated ) -> () in                             

                        self.updateFriendView(invites: invites, invited: invited, updated: updated)
                        
                    })
                }
                
            }
        }
    }

    func updateApproval(count : Int) { 

        self._approval_approval = "Pendings:  \(count)"

        self.loadStatistics()

         DispatchQueue.main.async {
    
            self.collectionView.reloadData()
            
        }
    } 
    
    func updateFriendView(invites: Int, invited: Int, updated: Bool) {

        NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyFriendApprovalLoaded), object: self)
        
        self._friend_approval = updated
        
        self._friends_desc = "Friends   \(self.friendCount)"
        
        let friendData = "Invites:   \(invites)   \(invited)"
        
        self._friends_data = friendData
        
        self.loadStatistics()
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
            
        }
        
    }


    func loadUserStatus() {

       
        if Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_son_object_id") {

            let queryOnline = PFQuery(className:"UserStatus")

            let sonId = Global.defaults.object(forKey: "\(self.puserId)_son_object_id") as! String

            let userId = Global.userDictionary[sonId]?.userId

            queryOnline.whereKey("userId", equalTo: userId)

            queryOnline.getFirstObjectInBackground { (usersOnline, error) in
        
                if error != nil
                {
                    print("error")

                    self.sonOnline = false
                    
                } else {

                    
                    self.changeSingleUserStatus(onlineMessage:usersOnline!)
                    
                }
            }    

        }

    }  
  
    func changeSingleUserStatus(onlineMessage:PFObject)
    {
        let status = onlineMessage["status"] as! Int
        
        if status == 2 {
            
            self.sonOnline = true

             DispatchQueue.main.async {
                        
                self.collectionView.reloadData()
                
            }

            
        } else if status == 1 {
            
            self.sonOnline = false
            
            if self.userStatistics.count > 0  {

                if let lastSeen = onlineMessage.updatedAt {

                    self.userStatistics[0].data = "\(lastSeen)"

                     DispatchQueue.main.async {
                        
                        self.collectionView.reloadData()
                        
                    }
                }
            }
        }         
    }
    
}
