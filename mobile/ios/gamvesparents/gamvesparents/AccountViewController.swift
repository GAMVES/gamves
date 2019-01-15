//
//  AccountViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 24/01/2018.
//

import UIKit
import Parse
import Floaty

class AccountViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout {

    var imagePickerViewController = ImagePickerViewController()
    
    var profileViewController:ProfileViewController!
    var otherAccountsViewController:OtherAccountsViewController!
    var tutorialVideoViewController:TutorialVideoViewController!
    
    var homeViewController:HomeViewController?
    
    var tabBarViewController:TabBarViewController?

    var accountButton = [AccountButton]()  

    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gamvesBackgoundColor
        return view
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

     var yourLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center        
        label.textColor = UIColor.gamvesBlackColor
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()

      let lineView: UIView = {
         let v = UIView()
         v.translatesAutoresizingMaskIntoConstraints = false
         v.backgroundColor = UIColor.gray
         return v
    }()

    let buttonLeftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    let buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    let buttonRightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    lazy var yourPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleyourPhotoImageView)))
        imageView.isUserInteractionEnabled = true        
        imageView.tag = 1
        return imageView
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
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.accountViewController = self
        return launcher
    }()

    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var photoCornerRadius = Int()

    var cellId = String()

    var _profile = AccountButton()
    var _family = AccountButton()
    var _account = AccountButton()
    var _tutorial = AccountButton()
    
   func initilizeObservers() {
    
        NotificationCenter.default.addObserver(self, selector: #selector(familyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(yourAccountInfoLoaded), name: NSNotification.Name(rawValue: Global.notificationYourAccountInfoLoaded), object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.levelsLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyLevelsLoaded), object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadFamilyDataGromGlobal), name: NSNotification.Name(rawValue: Global.notificationKeyLoadFamilyDataGromGlobal), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.loadYourDataGromGlobal), name: NSNotification.Name(rawValue: Global.notificationKeyChatFeed), object: nil)
        
    }

    var puserId = String()   

    var floaty = Floaty(size: 80)

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }

        self.cellId = "accountCellId"     

        self.view.addSubview(self.headerView)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.buttonsView)
        self.view.addSubview(self.bottomView)        
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.headerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)  
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.buttonsView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)  

        let height:Int = Int(view.frame.size.height)
        let width:Int = Int(view.frame.size.width)

        let tabBarHeight = self.tabBarController!.tabBar.frame.size.height

        var metricsProfile = [String:Int]()
        metricsProfile["tabBarHeight"] = Int(tabBarHeight)

        self.view.addConstraintsWithFormat(
            "V:|-60-[v0(160)][v1(1)][v2][v3(tabBarHeight)]|", views:
            self.headerView,
            self.lineView,
            self.buttonsView,
            self.bottomView, 
            metrics: metricsProfile)            

        self.headerView.addSubview(self.backImageView)
        self.headerView.addSubview(self.photosContainerView)
        self.headerView.addSubview(self.yourLabel)

        self.headerView.addConstraintsWithFormat("H:|[v0]|", views: self.backImageView)
        self.headerView.addConstraintsWithFormat("V:|[v0(75)]|", views: self.backImageView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.photosContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.yourLabel)

        var metricsHeader = [String:Int]()
        let photoSize = width / 3
        let padding = (width - photoSize) / 2

        metricsHeader["photoSize"] = photoSize
        metricsHeader["padding"] = padding

        self.headerView.addConstraintsWithFormat(
            "V:|-20-[v0(photoSize)][v1]|", views:
            self.photosContainerView,
            self.yourLabel,
            metrics: metricsHeader)
        
        self.photosContainerView.addSubview(self.yourPhotoImageView)
        
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.yourPhotoImageView)
        
        var metricsVerBudge = [String:Int]()
        
        metricsVerBudge["verPadding"] = photoSize - 25     
        
        self.photosContainerView.addConstraintsWithFormat(
            "H:|-padding-[v0(photoSize)]-padding-|", views:
            self.yourPhotoImageView,
            metrics: metricsHeader)
        
        self.photoCornerRadius = photoSize / 2

        Global.setRoundedImage(image: self.yourPhotoImageView, cornerRadius: self.photoCornerRadius, boderWidth: 5, boderColor: UIColor.gamvesGamvesLightColor)              
       
        self.collectionView.register(AccountCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)        
        

        if Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_family_exist") {

            _profile.desc = "Profile"
            _profile.icon = UIImage(named: "identity")!
            _profile.id = 0
            self.accountButton.append(_profile)

            _account.desc = "Other Accounts"
            _account.icon = UIImage(named: "account")!
            _account.id = 2
            self.accountButton.append(_account)

        } else {

            _family.desc = "Family"
            _family.icon = UIImage(named: "family_chat")!
            _family.id = 1
            self.accountButton.append(_family)
        }

        _tutorial.desc = "Tutorials"
        _tutorial.icon = UIImage(named: "video")!
        _tutorial.id = 3
        self.accountButton.append(_tutorial)

        self.buttonsView.addSubview(self.buttonLeftView)
        self.buttonsView.addSubview(self.collectionView)        
        self.buttonsView.addSubview(self.buttonRightView)

        self.buttonsView.addConstraintsWithFormat("V:|-20-[v0]|", views: self.collectionView)
        self.buttonsView.addConstraintsWithFormat("V:|-20-[v0]|", views: self.buttonLeftView)
        self.buttonsView.addConstraintsWithFormat("V:|-20-[v0]|", views: self.buttonRightView)

        self.buttonsView.addConstraintsWithFormat("H:|[v0(20)][v1][v2(20)]|", views: 
            self.buttonLeftView, 
            self.collectionView, 
            self.buttonRightView)
        
        /*if !Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_son_userId") {
        
            if !Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_profile_completed") {
                
                self.openProfile()                
                self.loadYourProfileInfo()
            }
        }*/
        
        self.buttonsView.backgroundColor = UIColor.gamvesLightLightBlueColor
        self.buttonLeftView.backgroundColor = UIColor.gamvesLightLightBlueColor
        self.collectionView.backgroundColor = UIColor.gamvesLightLightBlueColor
        self.buttonRightView.backgroundColor = UIColor.gamvesLightLightBlueColor        
        self.headerView.backgroundColor = UIColor.gamvesGamvesLightColor


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
        itemNewGroup.title = "ADD FAMILY"
        itemNewGroup.handler = { item in
            
            
        }

        /*let itemSelectGroup = FloatyItem()
        var groupContactImage = UIImage(named: "account")
        groupContactImage = groupContactImage?.maskWithColor(color: UIColor.white)
        itemSelectGroup.icon = groupContactImage
        itemSelectGroup.buttonColor = UIColor.gamvesColor
        itemSelectGroup.titleLabelPosition = .left
        itemSelectGroup.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemSelectGroup.title = "SELECT CONTACT"
        itemSelectGroup.handler = { item in
            
            self.selectContact(group: false)
        }*/
        
        self.floaty.addItem(item: itemNewGroup)  
        //self.floaty.addItem(item: itemSelectGroup)               
        self.view.addSubview(self.floaty)


    }    

     func showControllerForSetting(_ setting: Setting) {

        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)


    }

    override func viewWillAppear(_ animated: Bool) {
        self.setupNavBarButtons()   
     
    }

    func setTabbBarIndex(id: Int) {

        self.tabBarViewController?.selectedIndex = id
    }

    func showImagePicker(type:ProfileImagesTypes) {

        self.hideShowTabBar(status: true)
        
        imagePickerViewController.setType(type: type)
        
        print(profileViewController)

        imagePickerViewController.imagesPickerProtocol = profileViewController
        
        self.navigationController?.pushViewController(imagePickerViewController, animated: true)        
      
    }

    func hideShowTabBar(status: Bool)
    {
        self.tabBarController?.tabBar.isHidden = status
        
        if status
        {
            navigationController?.navigationBar.tintColor = UIColor.white
        } 
    }


    func setupNavBarButtons() {
 
        //let searchImage = UIImage(named: "search_icon")?.withRenderingMode(.alwaysOriginal)

        //let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))
        
        let moreButton = UIBarButtonItem(image: UIImage(named: "nav_more_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        
        navigationItem.rightBarButtonItems = [moreButton] //, searchBarButtonItem]
    }

    @objc func handleMore() {
        //show menu
        settingsLauncher.showSettings()
    }
    
    func handleSearch() {
        
    }
    
    @objc func familyLoaded() {
        //self.yourPhotoImageView.image = Global.gamvesFamily.youUser.avatar
        //self.yourLabel.text = Global.gamvesFamily.youUser.name
        self.loadYourProfileInfo()
    }
    
    @objc func yourAccountInfoLoaded() {
        
    }
    
    @objc func levelsLoaded() {
        
    }
    
    @objc func loadFamilyDataGromGlobal() {
        
    }


    @objc func loadYourDataGromGlobal() {

        self.loadYourProfileInfo()
        
    }
    

    func loadYourProfileInfo() {
        
        let queryUser = PFQuery(className:"Profile")

        if let userId = PFUser.current()?.objectId {

            let yourGamvesUser = Global.userDictionary[userId] as! GamvesUser

            self.yourPhotoImageView.image = yourGamvesUser.avatar

            self.yourLabel.text = yourGamvesUser.name
        
            queryUser.whereKey("userId", equalTo: userId)
            
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

                                        Global.yourAccountBackImage = image!
                                    
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AccountCollectionViewCell
        
        let id = indexPath.row        
        var accountButon = self.accountButton[id]
        cell.descLabel.text = accountButon.desc        
        cell.iconImageView.image = accountButon.icon

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.accountButton.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = indexPath.item

        let button = self.accountButton[index]
        
        switch (button.id) {
            
            case 0: //Profile
                
                self.openProfile()
                
                break
            
            case 1: //Payments
                
                break
            
            case 2: //Accounts
                
                self.openAccounts()

                break
            
            case 3: //Tutorials

                self.openTutorials()
                
                break
            
            default: break
            
        }
        
    }
    
    func openProfile() {
        
        profileViewController = ProfileViewController()
        profileViewController.accountViewController = self
        profileViewController.tabBarController?.tabBar.isHidden = true                
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(profileViewController, animated: true, completion: { (reult) in
            
            self.profileViewController.hideShowTabBar(hidden:true)
        })        
        
    }

    func openAccounts() {
        
        otherAccountsViewController = OtherAccountsViewController()
        otherAccountsViewController.tabBarController?.tabBar.isHidden = true                
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(otherAccountsViewController, animated: true)
        
    }

    func openTutorials() {
        
        tutorialVideoViewController = TutorialVideoViewController()
        tutorialVideoViewController.tabBarController?.tabBar.isHidden = true                
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(tutorialVideoViewController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        let size = CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
        
        return size
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()     
    }
    
    

}
