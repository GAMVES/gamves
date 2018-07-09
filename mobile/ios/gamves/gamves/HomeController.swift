///
//  ViewController.swift
//  youtube
//
//  Created by Jose Vigil on 12/12/17.
//

import UIKit
import Parse
import PopupDialog


class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    var popup:PopupDialog! = nil
    
    let homeCellId          = "homeCellId"
    let feedCellId          = "feedCellId"
    let notificationCellId  = "notificationCellId"
    let profileCellId       = "profileCellId"
    
    //let titles = ["Home", "Trending", "Community", "Profile"]
    let titles = ["Home", "Activity", "Notifications", "Profile"]
    
    var cellFree:FeedCell!
    var cellHome:HomeCell!
    var notificationCell:NotificationCell!
    var profileHome:ProfileCell!
    
    var locationManager : CLLocationManager = CLLocationManager()
    
    var didFindLocation = Bool()


    lazy var chatLauncher: ChatViewController = {
        let launcher = ChatViewController()
        launcher.homeController = self
        return launcher
    }()

    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()

    lazy var newGroupNameViewController: NewGroupNameViewController = {
        let groupName = NewGroupNameViewController()
        groupName.homeController = self
        return groupName
    }()

    lazy var selectContactViewController: SelectContactViewController = {
        let selector = SelectContactViewController()
        selector.homeController = self
        return selector
    }()

     lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.homeController = self
        return mb
    }()

    lazy var newVideoController: NewVideoController = {
        let newvideo = NewVideoController()
        newvideo.homeController = self
        return newvideo
    }()
    
    lazy var newFanpageController: NewFanpageController = {
        let newFanpage = NewFanpageController()
        newFanpage.homeController = self
        return newFanpage
    }()


    lazy var profileController: ProfileController = {
        let profile = ProfileController()
        profile.homeController = self
        return profile
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.green

        navigationController?.navigationBar.isTranslucent = false
        
        locationManager.delegate = self
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
            didFindLocation = false
        }
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = "  Home"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel
        
        setupCollectionView()
        setupMenuBar()
        setupNavBarButtons()
        
        //Global.buildPopup(viewController:self, title: "Hola", message: "Este es un mensaje")

        NotificationCenter.default.addObserver(self, selector: #selector(openChatFromUser), name: NSNotification.Name(rawValue: Global.notificationOpenChatFromUser), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(showProfileController), name: NSNotification.Name(rawValue: Global.notificationKeyShowProfile), object: nil)        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("")
        
        //self.view.setNeedsLayout()
        
        //self.collectionView?.reloadData()
        
    }

    func openChatFromUser(_ notification: NSNotification) {

        //let userDataDict:[String: GamvesUser] = ["gamvesUser": self.gamvesUser, "chatId": chatId] 

        if let user = notification.userInfo?["gamvesUser"] as? GamvesUser {    

            if let chatId = notification.userInfo?["chatId"] as? Int {
            
                self.openChat(room: user.name, chatId: chatId, users: [user])

            }
        }
        
    }


    override func viewDidLayoutSubviews() {
        //print("did")
    }
    
    func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(HomeCell.self, forCellWithReuseIdentifier: homeCellId)
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: feedCellId)
        collectionView?.register(NotificationCell.self, forCellWithReuseIdentifier: notificationCellId)
        collectionView?.register(ProfileCell.self, forCellWithReuseIdentifier: profileCellId)
    
        collectionView?.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)
        
        collectionView?.isPagingEnabled = true
        
        //collectionView?.alwaysBounceVertical = false
    }
    
    func setupNavBarButtons() {
 
        let searchImage = UIImage(named: "search_icon")?.withRenderingMode(.alwaysOriginal)

        let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))
        
        let moreButton = UIBarButtonItem(image: UIImage(named: "nav_more_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        
        navigationItem.rightBarButtonItems = [moreButton, searchBarButtonItem]
    }
    
    
    func handleMore() {
        //show menu
        settingsLauncher.showSettings()
    }
    
    func showControllerForSetting(_ setting: Setting) {
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func openSearch(params:[String : Any]) {
        let media = MediaController()
        media.delegate = params["targer"] as! MediaDelegate
        media.isImageMultiSelection = params["isImageMultiSelection"] as! Bool
        media.setType(type: params["type"] as! MediaType)
        media.termToSearch = params["termToSearch"] as! String
        media.searchType = params["searchType"] as! SearchType
        media.searchSize = params["searchSize"] as! SearchSize
        navigationController?.pushViewController(media, animated: true)
    } 

    func showProfileController(_ notification: NSNotification) {
        profileController.modalPresentationStyle = .overCurrentContext
        navigationController?.navigationBar.tintColor = UIColor.white        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]        
        navigationController?.pushViewController(profileController, animated: true)
    }

    func getHomeCell() -> HomeCell 
    {
        let identifier: String       
        identifier = homeCellId
        
        let indexPath = IndexPath(item: 0, section: 0)
        
        let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        cellHome = cell as! HomeCell
        
        return cellHome
    }
    
    func handleSearch() {
        scrollToMenuIndex(2)
    }
    
    func scrollToMenuIndex(_ menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
        setTitleForIndex(menuIndex)
        self.reloadFeed(index: menuIndex)
    }
    
    func switchToMenuIndex(index: Int) {

        self.scrollToMenuIndex(index)

        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        self.setTitleForIndex(Int(index))
       self.reloadFeed(index: Int(index))
    }

    fileprivate func setTitleForIndex(_ index: Int) {
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = "  \(titles[index])"
        }

    }  
   
    
    fileprivate func setupMenuBar() {
        
        //navigationController?.hidesBarsOnSwipe = true
        
        /*let redView = UIView()
         redView.backgroundColor = UIColor.gamvesBlackColor // .rgb(230, green: 32, blue: 31)
         view.addSubview(redView)
         view.addConstraintsWithFormat("H:|[v0]|", views: redView)
         view.addConstraintsWithFormat("V:[v0(50)]", views: redView)*/

        view.addSubview(menuBar)
        view.addConstraintsWithFormat("H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat("V:[v0(50)]", views: menuBar)
        
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 4
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        self.setTitleForIndex(Int(index))
        self.reloadFeed(index: Int(index))
    }
    
    func reloadFeed(index : Int) {
        if cellFree != nil && index == 1 {
            cellFree.reloadCollectionView()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier: String
        if indexPath.item == 0
        {
            identifier = homeCellId
        } else if indexPath.item == 1
        {
            identifier = feedCellId
        } else if indexPath.item == 2
        {
            identifier = notificationCellId
        } else
        {
            identifier = profileCellId
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if indexPath.item == 0 {
            
            cellHome = cell as! HomeCell
            cellHome.homeController = self
            
        } else if indexPath.item == 1 {
            
            cellFree = cell as! FeedCell
            cellFree.homeController = self
            
        }  else if indexPath.item == 2 {
            
            notificationCell = cell as! NotificationCell
            notificationCell.homeController = self
            
        } else if indexPath.item == 3 {
            
            profileHome = cell as! ProfileCell
            profileHome.homeController = self
            profileHome.setProfileType(type: ProfileSaveType.profile)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
    
    
    
    func openChat(room: String, chatId:Int, users:[GamvesUser]) {
        
        self.chatLauncher.modalPresentationStyle = .overCurrentContext
        self.chatLauncher.chatId = chatId
        self.chatLauncher.gamvesUsers = users
        self.chatLauncher.delegateFeed = cellFree
        self.chatLauncher.room = room
        chatLauncher.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(self.chatLauncher, animated: true)
    } 
    
    
    func selectContact(group: Bool) {
        selectContactViewController.isGroup = group
        selectContactViewController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(selectContactViewController, animated: true)
    }  
    
    
    func addNewVideo() {        
        newVideoController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(newVideoController, animated: true)
    }
    
    func addNewFanpage(edit:Bool) {
        if edit {
            newFanpageController.isEdit = true
        } else {
            newFanpageController.isEdit = false
        }
        newFanpageController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(newFanpageController, animated: true)
    }
    
    func clearNewFanpage() {
        self.newFanpageController = NewFanpageController()
        newFanpageController.homeController = self
    }
    
    func clearNewVideo() {
        self.newVideoController = NewVideoController()
        newVideoController.homeController = self
    }
    
    func selectGroupName(users: [GamvesUser]) {
        self.newGroupNameViewController.view.backgroundColor = UIColor.white
        self.newGroupNameViewController.gamvesUsers = users
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.pushViewController(newGroupNameViewController, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first
        {
            if !didFindLocation
            {
                didFindLocation = true
                
                print(location.coordinate)
                
                var lat = Double(location.coordinate.latitude)
                var lng = Double(location.coordinate.longitude)                
                
                self.getLastLocation(completionHandler: { ( point:PFGeoPoint, has:Bool ) -> () in
                    
                    var newLocation = Bool()
                    
                    if has
                    {
                        
                        let current = PFGeoPoint(latitude: lat, longitude: lng)
                        let distance = current.distanceInKilometers(to: point as! PFGeoPoint)
                    
                        if distance > 0.2
                        {
                            newLocation = true
                        }
                    
                    } else
                    {
                        newLocation = true
                    }
                    
                    if newLocation
                    {
                        let userLocation = PFObject(className: "Location")
                    
                        if let userId = PFUser.current()?.objectId
                        {
                            userLocation["userId"] = userId
                        }
                    
                        let geoPoint = PFGeoPoint(latitude: lat, longitude: lng)
                        userLocation["geolocation"] = geoPoint
                    
                        userLocation.saveInBackground(block: { (resutl, error) in
                    
                            if error != nil
                            {
                                print(error)
                            } else
                            {
                                print(resutl)
                            }
                    
                        })
                    }
                })
            }
        }
    }
    
    
    func getLastLocation(completionHandler : @escaping (_ point:PFGeoPoint, _ has:Bool) -> ()?)
    {
        let locationQuery = PFQuery(className:"Location")
        
        if let userId = PFUser.current()?.objectId
        {
            locationQuery.whereKey("userId", equalTo: userId)
        }
        locationQuery.order(byDescending: "createdAt")
        
        locationQuery.getFirstObjectInBackground { (location, error) in
            
            var point = PFGeoPoint()
            
            if error != nil
            {
                print("error: \(error)")
            }
            
            if location != nil
            {
                point = location?["geolocation"] as! PFGeoPoint
                
                completionHandler(point, true)
                
            } else
            {                
                completionHandler(point, false)

            }
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp()
    {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to deliver pizza we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }

        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }


    func setCurrentPage(current: Int, direction: Int, data: GamvesFanpage) {

        let homeCell = getHomeCell()
        
        homeCell.setCurrentPage(current: current, direction: direction, data: data)
        
    }
    
}






