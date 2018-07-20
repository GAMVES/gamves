

//
//  ProfileCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/10/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import IGColorPicker
import PulsingHalo
import KenBurns
import RSKImageCropper
import Floaty

public enum ProfileSaveType {
    case profile
    case color
    case chat
    case publicProfile
}

public enum SelectedImage {
        case avatar
    case background
}


class ProfileCell: BaseCell,
    UICollectionViewDataSource,
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout, 
    UIScrollViewDelegate,
    ColorPickerViewDelegate,
    MediaDelegate,
    RSKImageCropViewControllerDelegate   
{
    var gamvesUser:GamvesUser!

    var imageCropVC = RSKImageCropViewController()

    var homeController: HomeController?
    
    var profileSaveType:ProfileSaveType!

    var metricsHome = [String:Int]()

    var userStatistics = [UserStatistics]()

    var videosGamves  = [GamvesVideo]()
    let cellVideoCollectionId = "cellVideoCollectionId"   


    // Onliine

    var onlineImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "status_online")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // Friends

    let friendsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesBackgoundColor
        v.layer.cornerRadius = 20
        return v
    }() 

    var friendImageView: CustomImageView = {
        let imageView = CustomImageView()
        let image = UIImage(named: "group")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let friendsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left        
        return label
    }()



    let profileView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let registerViewContent: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()  
    
    // SON VIEW
    
    let registerpstView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    }()

    var backImageView: KenBurnsImageView = {
        let imageView = KenBurnsImageView()
        imageView.contentMode = .scaleAspectFill 
        imageView.clipsToBounds = true             
        return imageView
    }()
    
    let leftregisterpstView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    }()
    
    var sonProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let rightregisterpstView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    }()
    
    let sonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textAlignment = .left        
        return label
    }()

    let bioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray        
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left        
        return label
    }()
    
    // INFO -> Contains right box: since, school, grade, pls and school iso.

    let infoView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesBackgoundColor
        return v
    }()

    //Joined

    let joinedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right        
        return label
    }()

    //SchoolView   

    let schoolView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesBackgoundColor
        return v
    }()    

    var schoolIconImageView: CustomImageView = {
        let imageView = CustomImageView()        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let schoolLabel: UILabel =   { 
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center        
        return label
    }()  

    // gradeUserPlsView

    let gradeUserPlsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesBackgoundColor
        return v
    }()

    // gradePlsView

    let gradeUserView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesBackgoundColor
        return v
    }()

    // gradeLabel   

    let gradeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left        
        return label
    }()

    // pstView

    let pstUserView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false        
        return v
    }()


    var pstStatusImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "status_offline")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let plsUsernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left        
        return label
    }()

    let pstIconView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false        
        return v
    }()

    var plsIconImageView: CustomImageView = {
        let imageView = CustomImageView()    
        let image = UIImage(named: "pls_icon")
        imageView.tintColor = UIColor.gray
        imageView.image = image    
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()   

    // DATA
    
    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        return view
    }()

    let lineFooterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    let dataView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.white
        return v
    }()
    
    // DATA VIEW
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    let footerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesBackgoundColor
        return v
    }()

    var saveDesc:String  = "Save Profile"
    var colorDesc:String = "Choose Color"
    var chatDesc:String = "Chat"
    var closeDesc:String = "Close"
    
    lazy var saveProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        //button.setTitle(colorDesc, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSaveProfile), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var cancelProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Cancel", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleCancelProfile), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()

    var labelEmptyMessage: UILabel = {
        let label = UILabel()
        label.text = "There are no videos yet loaded for your profile"        
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.gray
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()


    let footerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Edit your public profile and fanpage using the + button. Customize to your wish!"
        label.textColor = UIColor.gray        
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left        
        return label
    }()

    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var cellId = String()
    
    var colorPickerView: ColorPickerView!
    var colorPickerViewController:ColorPickerViewController!

    var editProfile = Bool()
    var editCreated = Bool()
    var colorCreated = Bool()
    
    var editBackImageView:UIView!
    var editAvatarImageView:UIView!
    var editColorView:UIView!
    var editBioView:UIView!
    
    var initialSetting = InitialSetting()
    
    var profilePF:PFObject!       

    var selectedImage:SelectedImage!    

    var selectedBackImage = UIImage()

    var floaty = Floaty(size: 80)
    
    override func setupViews() {
        super.setupViews()      

        let userId = PFUser.current()?.objectId
        let user = Global.gamvesFamily.getFamilyUserById(userId: userId!) as! GamvesUser

        self.saveProfileButton.setTitle(saveDesc, for: .normal)
        
        self.getProfileVideos()
        
        let width = self.frame.width
        let paddingRegister = (width - 150)/2  
        
        let metricsRegisterView = ["paddingRegister": paddingRegister]
        
        self.addSubview(self.profileView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.profileView)
        
        self.addSubview(self.lineView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
 
        self.addSubview(self.dataView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.dataView)

        self.addSubview(self.lineFooterView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.lineFooterView)

        self.addSubview(self.footerView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.footerView)        
        
        self.addConstraintsWithFormat("V:|[v0(240)][v1(1)][v2][v3(1)][v4(70)]|", views:
            self.profileView, 
            self.lineView, 
            self.dataView,
            self.lineFooterView,
            self.footerView)        
        
        // SON VIEW         

        self.profileView.addSubview(self.backImageView)
        self.profileView.addSubview(self.registerpstView)
        self.profileView.addSubview(self.sonLabel)
        self.profileView.addSubview(self.bioLabel)
        
        //Status
        self.profileView.addSubview(self.onlineImageView)
        self.profileView.addSubview(self.friendsView)       


        self.profileView.addConstraintsWithFormat("H:|[v0]|", views: self.backImageView)
        self.profileView.addConstraintsWithFormat("V:|[v0(100)]|", views:self.backImageView)        
        
        self.profileView.addConstraintsWithFormat("H:|[v0]|", views: self.registerpstView)
        self.profileView.addConstraintsWithFormat("H:|-30-[v0(250)]|", views: self.sonLabel)
        self.profileView.addConstraintsWithFormat("H:|-30-[v0(250)]|", views: self.bioLabel)

        self.profileView.addConstraintsWithFormat("V:|-20-[v0(150)][v1(40)][v2]-10-|", views:
            self.registerpstView,
            self.sonLabel,
            self.bioLabel,
            metrics: metricsRegisterView)   

        // Right Box -> InfoView

        let widthModule = self.frame.width / 3        
        let m = widthModule + ( widthModule / 2 )
        let infoMetrics = [ "widthModule" : m ]

        self.profileView.addSubview(self.infoView)  
        self.profileView.addConstraintsWithFormat("H:|-widthModule-[v0]|", views: self.infoView, metrics: infoMetrics) 
        self.profileView.addConstraintsWithFormat("V:|-100-[v0]|", views: self.infoView)    

       let leftOnline = width - 160
       let mestricsLeftOnline = ["leftOnline":leftOnline] 

        self.profileView.addConstraintsWithFormat("H:|-leftOnline-[v0(40)]|", views: self.onlineImageView, metrics:mestricsLeftOnline)
        self.profileView.addConstraintsWithFormat("V:|-20-[v0(40)]|", views:self.onlineImageView)       

        let leftSpace = leftOnline + 60     
        let mestricsLeft = ["leftSpace":leftSpace] 

        self.profileView.addConstraintsWithFormat("H:|-leftSpace-[v0(80)]|", views: self.friendsView, metrics:mestricsLeft)
        self.profileView.addConstraintsWithFormat("V:|-20-[v0(40)]|", views:self.friendsView)       

        //Friends

        self.friendsView.addSubview(self.friendImageView)  
        self.friendsView.addSubview(self.friendsLabel)  

        self.friendsLabel.text = "\(Global.friendsAmount)"

        self.friendsView.addConstraintsWithFormat("V:|-5-[v0(30)]-5-|", views: self.friendImageView)
        self.friendsView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.friendsLabel)
        self.friendsView.addConstraintsWithFormat("H:|-15-[v0(30)]-5-[v1]|", views: 
            self.friendImageView, 
            self.friendsLabel)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (showFriends))
        self.friendsView.addGestureRecognizer(gesture)
        self.friendsView.alpha = 0.5

        //Infoview

        //self.joinedLabel.backgroundColor    = UIColor.green
        //self.schoolView.backgroundColor     = UIColor.brown
        //self.gradeUserPlsView.backgroundColor     = UIColor.cyan        
        
        self.infoView.addSubview(self.joinedLabel)  
        self.infoView.addSubview(self.schoolView)  
        self.infoView.addSubview(self.gradeUserPlsView)

        self.infoView.addConstraintsWithFormat("H:|[v0]|", views: self.joinedLabel)
        self.infoView.addConstraintsWithFormat("H:|[v0]|", views: self.schoolView) 
        self.infoView.addConstraintsWithFormat("H:|[v0]|", views: self.gradeUserPlsView) 

        self.infoView.addConstraintsWithFormat("V:|[v0(25)][v1(50)][v2]|", views: 
            self.joinedLabel,
            self.schoolView,
            self.gradeUserPlsView)

        //Schoolview

        self.schoolView.addSubview(self.schoolIconImageView)
        self.schoolView.addSubview(self.schoolLabel)

        self.schoolView.addConstraintsWithFormat("V:|-5-[v0(40)]-5-|", views: self.schoolIconImageView)
        self.schoolView.addConstraintsWithFormat("V:|[v0]|", views: self.schoolLabel)

        self.schoolView.addConstraintsWithFormat("H:|-5-[v0(40)][v1]|", views: 
            self.schoolIconImageView, 
            self.schoolLabel)

        // gradePlsView

        self.gradeUserPlsView.addSubview(self.gradeUserView)
        self.gradeUserPlsView.addSubview(self.pstIconView)

        self.gradeUserPlsView.addConstraintsWithFormat("V:|[v0]|", views: self.gradeUserView)
        self.gradeUserPlsView.addConstraintsWithFormat("V:|-10-[v0]|", views: self.pstIconView)

        self.gradeUserPlsView.addConstraintsWithFormat("H:|[v0][v1(50)]-10-|", views: 
            self.gradeUserView, 
            self.pstIconView)

        //plsIconImageView

        self.pstIconView.addSubview(self.plsIconImageView)
        self.pstIconView.addConstraintsWithFormat("V:|[v0(50)]|", views: self.plsIconImageView)
        self.pstIconView.addConstraintsWithFormat("H:|[v0(50)]|", views: self.plsIconImageView)     

        self.plsIconImageView.alpha = 0.4   

        // gradeUserView

        self.gradeLabel
        self.plsUsernameLabel

        self.gradeUserView.addSubview(self.gradeLabel)
        self.gradeUserView.addSubview(self.pstUserView)

        self.gradeUserView.addConstraintsWithFormat("H:|[v0]|", views: self.gradeLabel)
        self.gradeUserView.addConstraintsWithFormat("H:|[v0]|", views: self.pstUserView)
        
        self.gradeUserView.addConstraintsWithFormat("V:|[v0(25)][v1]|", views: 
            self.gradeLabel, 
            self.pstUserView)

        // pstUserView

        self.pstUserView.addSubview(self.pstStatusImageView)
        self.pstUserView.addSubview(self.plsUsernameLabel)

        self.gradeUserView.addConstraintsWithFormat("V:|[v0(20)]-10-|", views: self.pstStatusImageView)
        self.gradeUserView.addConstraintsWithFormat("V:|[v0]-10-|", views: self.plsUsernameLabel)
        
        self.gradeUserView.addConstraintsWithFormat("H:|-10-[v0(20)]-10-[v1]|", views: 
            self.pstStatusImageView, 
            self.plsUsernameLabel)      

        let dateFormatter = DateFormatter()  
        let joined = dateFormatter.dateFormat = "MM/dd/yy"
        let date = user.userObj.createdAt! as Date

        self.joinedLabel.text = "since:  \(dateFormatter.string(from: date))"
        self.schoolLabel.text = user.school.schoolName
        self.gradeLabel.text = "  \(user.level.fullDesc)"
        self.schoolIconImageView.image = user.school.icon
        self.plsUsernameLabel.text = user.consoles[0].username

        self.profileView.addConstraintsWithFormat("H:|-30-[v0(250)]|", views: self.sonLabel)
        self.profileView.addConstraintsWithFormat("H:|-30-[v0(250)]|", views: self.bioLabel)               
        
        //FLOATY      

        self.floaty.paddingY = 35
        self.floaty.paddingX = 20                    
        self.floaty.itemSpace = 30
        self.floaty.shadowRadius = 20
        self.floaty.buttonColor = UIColor.gamvesYellowColor
        self.floaty.sizeToFit()

        //floaty.verticalDirection = .down        
        
        let itemEditProfile = FloatyItem()
        itemEditProfile.icon = UIImage(named: "edit")                
        itemEditProfile.buttonColor = UIColor.white
        itemEditProfile.titleLabelPosition = .left
        itemEditProfile.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemEditProfile.title = "EDIT PROFILE"
        itemEditProfile.handler = { item in
            
            self.handleEditProfile()
            self.floaty.isHidden = true

        }

        let itemEditFanpage = FloatyItem()
        itemEditFanpage.icon = UIImage(named: "page")                
        itemEditFanpage.buttonColor = UIColor.white
        itemEditFanpage.titleLabelPosition = .left
        itemEditFanpage.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemEditFanpage.title = "EDIT FANPAGE"
        itemEditFanpage.handler = { item in
            
            self.handleEditFanpage()            

        }

        self.floaty.addItem(item: itemEditProfile)       
        self.floaty.addItem(item: itemEditFanpage)       
        self.addSubview(floaty)        
        
        self.profileView.bringSubview(toFront: self.registerpstView)
                        
        let name = user.name
        self.sonLabel.text = name
        //self.sonLabel.textAlignment = NSTextAlignment.center
        
        self.registerpstView.addSubview(self.leftregisterpstView)
        self.registerpstView.addSubview(self.sonProfileImageView)
        self.registerpstView.addSubview(self.rightregisterpstView)
        
        self.registerpstView.addConstraintsWithFormat("V:|[v0]|", views: self.leftregisterpstView)
        self.registerpstView.addConstraintsWithFormat("V:|[v0]|", views: self.sonProfileImageView)
        self.registerpstView.addConstraintsWithFormat("V:|[v0]|", views: self.rightregisterpstView)            
        
        self.registerpstView.addConstraintsWithFormat("H:|[v0(30)][v1(150)][v2]|", views: 
            self.leftregisterpstView, 
            self.sonProfileImageView, 
            self.rightregisterpstView, 
            metrics: metricsRegisterView)                 

        self.footerView.addSubview(self.footerLabel)    
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.footerLabel)
        self.footerView.addConstraintsWithFormat("H:|-10-[v0]-100-|", views: self.footerLabel)   
        
        let splitFooter = (width - 60)/2
        
        let metricsFooterView = ["sf": splitFooter]   

        self.footerView.addSubview(self.saveProfileButton)
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.saveProfileButton)
        self.saveProfileButton.isHidden = true
        
        self.footerView.addSubview(self.cancelProfileButton)
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.cancelProfileButton)
        self.cancelProfileButton.isHidden = true
        
        self.footerView.addConstraintsWithFormat("H:|-20-[v0(sf)]-20-[v1(sf)]-20-|", views: self.saveProfileButton, self.cancelProfileButton, metrics: metricsFooterView)    

        self.dataView.addSubview(self.collectionView)
        self.dataView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.collectionView) 
        self.dataView.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)     

        self.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: self.cellVideoCollectionId)       

        self.collectionView.backgroundColor = UIColor.white
        
        self.profileSaveType = ProfileSaveType.profile    

        self.addSubview(self.labelEmptyMessage)
        self.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: self.labelEmptyMessage)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.labelEmptyMessage)

        self.labelEmptyMessage.isHidden = true          
       
    }
    
    /*if id == 0
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
    
    }*/
    
    func showFriends() {

        print("show friends")
    }
    

    func setProfileType(type: ProfileSaveType) {

        self.profileSaveType = type

        if type == ProfileSaveType.chat {

            //self.editProfileButton.setTitle(chatDesc, for: .normal)
            //self.editFanpageButton.setTitle(closeDesc, for: .normal)

        }

        self.loadProfileInfo()
    }
        
    
    func loadProfileInfo() {
        
        let queryUser = PFQuery(className:"Profile")

        var userId = String()

        if self.gamvesUser == nil {

            userId = (PFUser.current()?.objectId)!

        } else {

            userId = self.gamvesUser.userId
        }
        
        queryUser.whereKey("userId", equalTo: userId)
        
        queryUser.getFirstObjectInBackground { (profile, error) in
            
            if error == nil {
                
                if let prPF:PFObject = profile {
                    
                    self.profilePF = prPF
                    
                    if self.profilePF["pictureBackground"] != nil {
                
                        let backImage = self.profilePF["pictureBackground"] as! PFFile
                        
                        let colorArray:[CGFloat] = self.profilePF["backgroundColor"] as! [CGFloat]
                        
                        let bio = self.profilePF["bio"] as! String
                        
                        self.bioLabel.text = bio
                        
                        let backgroundColor = UIColor.rgb(colorArray[0], green: colorArray[1], blue: colorArray[2])
                        
                        self.initialSetting.backColor = backgroundColor
                        self.profileView.backgroundColor = backgroundColor
                        
                        backImage.getDataInBackground { (imageData, error) in
                            
                            if error == nil {
                                
                                if let imageData = imageData
                                {
                                    let image = UIImage(data:imageData)
                                    
                                    self.newKenBurnsImageView(image: image!)
                                    
                                    self.initialSetting.backImage = image

                                    self.selectedBackImage = image!

                                    self.initialSetting.bio = self.bioLabel.text!

                                    self.setSonProfileImageView()
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func showEmptyMessage() {

        self.activityIndicatorView?.stopAnimating()
        self.labelEmptyMessage.isHidden = false

    }

    func setSonProfileImageView() {
        
        var userId = String()

        if self.gamvesUser == nil {

            userId = (PFUser.current()?.objectId)!

        } else {

            userId = self.gamvesUser.userId
        }
        

        //if let sonImage:UIImage = Global.gamvesFamily.getFamilyUserById(userId: userId)?.avatar {

        if let sonImage:UIImage = Global.userDictionary[userId]?.avatar {        

            self.sonProfileImageView.image = sonImage
            
            Global.setRoundedImage(image: sonProfileImageView, cornerRadius: 75, boderWidth: 5, boderColor: UIColor.gamvesBackgoundColor)
            
            self.sonProfileImageView.layer.shadowColor = UIColor.black.cgColor
            self.sonProfileImageView.layer.shadowOpacity = 1
            self.sonProfileImageView.layer.shadowOffset = CGSize.zero
            self.sonProfileImageView.layer.shadowRadius = 10
        }
        
    }
    
    func newKenBurnsImageView(image: UIImage) {
        self.backImageView.setImage(image)
        self.backImageView.zoomIntensity = 1.5
        self.backImageView.setDuration(min: 5, max: 13)
        self.backImageView.startAnimating()
    }

    func handleEditProfile() {


        if self.profileSaveType == ProfileSaveType.chat {

            var chatId = Int()
            
            if self.gamvesUser.chatId > 0
            {
                chatId = self.gamvesUser.chatId
            } else
            {
                chatId = Global.getRandomInt()
            }         

            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)           

            let userDataDict:[String: AnyObject] = ["gamvesUser": self.gamvesUser, "chatId": chatId as AnyObject] 

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Global.notificationOpenChatFromUser), object: nil, userInfo: userDataDict)      

            //NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyReloadPageFanpage), object: self)
        
        } else if !self.editCreated {
        
            DispatchQueue.main.async {
                
                self.editProfile = true
                let w = self.frame.width
                
                //-- Bottom single button
                
                self.saveProfileButton.isHidden = false
                self.cancelProfileButton.isHidden = false

                //self.editProfileButton.isHidden = true
                //self.editFanpageButton.isHidden = true
                
                //-- Background
                
                self.editBackImageView = UIView(frame: CGRect(x:30, y:30, width:50, height:50))
                
                var editBackImageButton = UIButton(type: UIButtonType.system)
                editBackImageButton = UIButton(frame: CGRect(x:0, y:0, width:50, height:50))
                let imageBack = UIImage(named: "camera_black")
                imageBack?.maskWithColor(color: UIColor.gamvesBackgoundColor)
                editBackImageButton.setImage(imageBack, for: .normal)
                editBackImageButton.isUserInteractionEnabled = true
                editBackImageButton.addTarget(self, action: #selector(self.handleChangeBackgoundImage), for: .touchUpInside)
                
                let haloBack = PulsingHaloLayer()
                haloBack.position.x = editBackImageButton.center.x
                haloBack.position.y = editBackImageButton.center.y
                haloBack.haloLayerNumber = 5
                haloBack.backgroundColor = UIColor.gamvesBackgoundColor.cgColor
                haloBack.radius = 40
                haloBack.start()
                
                self.editBackImageView.layer.addSublayer(haloBack)
                self.editBackImageView.addSubview(editBackImageButton)
                self.profileView.addSubview(self.editBackImageView)
                
                //-- Avatar
                
                let halfWidth = w/2 - 25
                
                self.editAvatarImageView = UIView(frame: CGRect(x:halfWidth, y:25, width:50, height:50))
                
                var editAvatarButton = UIButton(type: UIButtonType.system)
                editAvatarButton = UIButton(frame: CGRect(x:0, y:0, width:50, height:50))
                let imageAvatar = UIImage(named: "camera_black")
                editAvatarButton.setImage(imageAvatar, for: .normal)
                editAvatarButton.addTarget(self, action: #selector(self.handleChangeAvatarImage), for: .touchUpInside)
                editAvatarButton.isUserInteractionEnabled = true
                
                let haloAvatar = PulsingHaloLayer()
                haloAvatar.position.x = editAvatarButton.center.x
                haloAvatar.position.y = editAvatarButton.center.y
                haloAvatar.haloLayerNumber = 5
                haloAvatar.backgroundColor = UIColor.gamvesBackgoundColor.cgColor
                haloAvatar.radius = 40
                haloAvatar.start()
                
                self.editAvatarImageView.layer.addSublayer(haloAvatar)
                self.editAvatarImageView.addSubview(editAvatarButton)
                self.registerpstView.addSubview(self.editAvatarImageView)
                
                //-- Color
                
                self.editColorView = UIView(frame: CGRect(x:30, y:60, width:50, height:50))
                
                var editColorButton = UIButton(type: UIButtonType.system)
                editColorButton = UIButton(frame: CGRect(x:0, y:0, width:50, height:50))
                let imageColor = UIImage(named: "color")
                imageColor?.maskWithColor(color: UIColor.lightGray)
                editColorButton.setImage(imageColor, for: .normal)
                editColorButton.addTarget(self, action: #selector(self.handleChangeColor), for: .touchUpInside)
                editColorButton.isUserInteractionEnabled = true
                
                let haloColor = PulsingHaloLayer()
                haloColor.position.x = editColorButton.center.x
                haloColor.position.y = editColorButton.center.y
                haloColor.haloLayerNumber = 5
                haloColor.backgroundColor = UIColor.lightGray.cgColor
                haloColor.radius = 40
                haloColor.start()

                self.editColorView.layer.addSublayer(haloColor)
                self.editColorView.addSubview(editColorButton)
                self.registerpstView.addSubview(self.editColorView)
                
                //-- Bio
                
                let bX = w - 70
                
                self.editBioView = UIView(frame: CGRect(x:bX, y:60, width:50, height:50))
        
                var editBioButton = UIButton(type: UIButtonType.system)
                editBioButton = UIButton(frame: CGRect(x:0, y:0, width:50, height:50))
                let imageBio = UIImage(named: "edit")
                imageBio?.maskWithColor(color: UIColor.lightGray)
                editBioButton.setImage(imageBio, for: .normal)
                editBioButton.addTarget(self, action: #selector(self.handleChangeBio), for: .touchUpInside)
                editBioButton.isUserInteractionEnabled = true
                
                let haloBio = PulsingHaloLayer()
                haloBio.position.x = editBioButton.center.x
                haloBio.position.y = editBioButton.center.y
                haloBio.haloLayerNumber = 5
                haloBio.backgroundColor = UIColor.lightGray.cgColor
                haloBio.radius = 40
                haloBio.start()
                
                self.editBioView.layer.addSublayer(haloBio)
                self.editBioView.addSubview(editBioButton)
                self.registerpstView.addSubview(self.editBioView)
            
                self.collectionView.reloadData()
                
                self.editCreated = true
            }
        }
    }


     func handleEditFanpage() {
        
        //Call branch add code here

        if self.profileSaveType == ProfileSaveType.chat {            

            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)           

        } else {

            self.homeController?.addNewFanpage(edit:true)

        }          
        
    }
    
    func handleSaveProfile() {
        
        //NOT WORKING

        if self.profileSaveType == ProfileSaveType.profile {

            self.activityIndicatorView?.startAnimating()
            
            let backImage:UIImage = self.selectedBackImage

            let backImagePF = PFFile(name: "background.png", data: UIImageJPEGRepresentation(backImage, 1.0)!)
            
            self.profilePF["pictureBackground"] = backImagePF
            
            self.profilePF["bio"] = self.bioLabel.text

            let backColor:UIColor = self.profileView.backgroundColor!

            if let rgb:[CGFloat] = backColor.rgb() {
    
                print(rgb)

                self.profilePF["backgroundColor"] = rgb             
            } 
            
            self.profilePF.saveInBackground(block: { (profile, error) in                
                
                if error == nil {

                    let sonUser:PFUser = PFUser.current()!

                    let userId = PFUser.current()?.objectId
                    
                    let firstName = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.name
                    
                    let sonImagePF = PFFile(name: "\(firstName)picture.png", data: UIImageJPEGRepresentation(self.sonProfileImageView.image!, 1.0)!)
                    sonUser.setObject(sonImagePF!, forKey: "picture")

                    let sonImageLow = self.sonProfileImageView.image?.lowestQualityJPEGNSData as! Data
                    var sonSmallImage = UIImage(data: sonImageLow)

                    let sonImageSmallPF = PFFile(name: "\(firstName)pictureSmall.png", data: UIImageJPEGRepresentation(sonSmallImage!, 1.0)!)

                    sonUser.setObject(sonImageSmallPF!, forKey: "pictureSmall")               
                    
                    sonUser.saveInBackground(block: { (user, error) in
                        
                        self.showApprovalMessage()
                        
                    })
                }
            })
            
        } else if self.profileSaveType == ProfileSaveType.color {
            
            //Close color window change button to original label
            
            self.clearColorButton()
            
        } else if self.profileSaveType == ProfileSaveType.chat {

                //Open Chant

        }
    }
    
    func showApprovalMessage() {        
                                    
        var message = String()               
        
        let title = "Profile update!"
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            
            self.activityIndicatorView?.stopAnimating() 

            self.enableDisableButtonToNormal()           
            
        }))
        
        self.homeController?.present(alert, animated: true)
    }

    func handleCancelProfile() {
        
        self.profileView.backgroundColor = self.initialSetting.backColor
        
        if self.profileSaveType == ProfileSaveType.profile {
            
            self.newKenBurnsImageView(image: self.initialSetting.backImage)
            self.sonProfileImageView.image = self.initialSetting.avatarImage
            self.setSonProfileImageView()
            
            self.bioLabel.text = self.initialSetting.bio
         
            self.videosGamves = [GamvesVideo]()
            self.videosGamves = self.initialSetting.videos
            
            self.enableDisableButtonToNormal()

            
        } else if self.profileSaveType == ProfileSaveType.color {
         
            self.clearColorButton()
            
        }
    
    }

    func enableDisableButtonToNormal() {

        self.saveProfileButton.isHidden = true
        self.cancelProfileButton.isHidden = true

        //self.editProfileButton.isHidden = false
        //self.editFanpageButton.isHidden = false
        
        self.editBackImageView.isHidden = true
        self.editAvatarImageView.isHidden = true
        self.editColorView.isHidden = true
        self.editBioView.isHidden = true

        self.editCreated = false

    }

    
    func clearColorButton() {
        
        self.colorPickerViewController.isHidden = true
        self.saveProfileButton.setTitle(self.saveDesc, for: .normal)
        self.profileSaveType = ProfileSaveType.profile
        
    }   
   

    func handleChangeColor(sender : UIButton) {
        
        if !self.colorCreated {
    
            let colorFrame = self.dataView.frame
            
            self.colorPickerViewController = ColorPickerViewController(frame: colorFrame)
            colorPickerViewController.cornerRadius = 20
            
            colorPickerViewController.colorPickerView.delegate = self
            
            self.addSubview(colorPickerViewController)
            
            self.colorCreated = true
            
        }  else {
            
            self.colorPickerViewController.isHidden = false
        
        }
        
        self.saveProfileButton.setTitle(self.colorDesc, for: .normal)
        
        self.profileSaveType = ProfileSaveType.color
        
    }
    
    func handleChangeBackgoundImage(sender : UIButton) {        
        //Media Controller Here
        self.selectedImage = SelectedImage.background        
        let media = MediaController()
        media.isImageMultiSelection = false
        media.delegate = self
        //media.termToSearch = self.nameTextField.text!
        media.setType(type: MediaType.selectImage)
        media.searchType = SearchType.isSingleImage
        media.searchSize = SearchSize.imageSmall
        self.homeController?.navigationController?.pushViewController(media, animated: true)        
    }    
   
    
    func handleChangeAvatarImage(sender : UIButton) {
        
        //Media Controller Here

        self.selectedImage = SelectedImage.avatar

       let media = MediaController()
        media.isImageMultiSelection = false
        media.delegate = self
        //media.termToSearch = self.nameTextField.text!
        media.setType(type: MediaType.selectImage)
        media.searchType = SearchType.isSingleImage
        media.searchSize = SearchSize.imageSmall
        self.homeController?.navigationController?.pushViewController(media, animated: true)

    }

    func didPickImage(_ image: UIImage) {

        if self.selectedImage == SelectedImage.avatar {
        
            imageCropVC = RSKImageCropViewController(image: image)
            imageCropVC.delegate = self
            self.homeController?.navigationController?.pushViewController(imageCropVC, animated: true)            

        } else if self.selectedImage == SelectedImage.avatar {


            self.backImageView.setImage(image)
        }

    }

    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.homeController?.navigationController?.popViewController(animated: true)
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
    
    //func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
         let imageLow = croppedImage.lowestQualityJPEGNSData as Data
         var smallImage = UIImage(data: imageLow)
        
        self.sonProfileImageView.image = croppedImage
        self.makeRounded(imageView:self.sonProfileImageView)     
        
        self.homeController?.navigationController?.popViewController(animated: true)
    }

    func makeRounded(imageView:UIImageView)
    {
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2            
        imageView.clipsToBounds = true         
        imageView.layer.borderColor = UIColor.gamvesBlackColor.cgColor
        imageView.layer.borderWidth = 3
    }     

    
    func handleChangeBio(sender : UIButton) {
        
        var alertController = UIAlertController(title: "Slogan ", message: "Enter your slogan", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let bio = alertController.textFields?[0].text
            
            self.bioLabel.text = bio
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
    
        alertController.addTextField { (textField) in
            textField.placeholder = "New slogan here"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
 
        self.profileView.backgroundColor = colorPickerView.colors[indexPath.item]
        
        self.sonProfileImageView.borderColor = colorPickerView.colors[indexPath.item]
        
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }

    func getProfileVideos()
    {
        
        self.activityIndicatorView?.startAnimating()
        
        let queryvideos = PFQuery(className:"Videos")      

        if let userId = PFUser.current()?.objectId {

            print(userId)
            
            queryvideos.whereKey("posterId", equalTo: userId)    
        }
        
        queryvideos.whereKey("approved", equalTo: true)

        queryvideos.findObjectsInBackground(block: { (videoObjects, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                let countVideosLoaded = Int()
                
                var countVideos = videoObjects?.count
                var count = 0
                
                print(countVideos)
                
                if countVideos! > 0
                {
                    if let videoArray = videoObjects
                    {
                        for qvideoinfo in videoArray
                        {
                            
                            let video = GamvesVideo()
                            
                            var videothum = qvideoinfo["thumbnail"] as! PFFile
                            
                            video.title                     = qvideoinfo["title"] as! String
                            video.description               = qvideoinfo["description"] as! String
                            video.thumbnail                 = videothum
                            video.categoryName              = qvideoinfo["categoryName"] as! String
                            video.videoId                   = qvideoinfo["videoId"] as! Int
                            video.s3_source                 = qvideoinfo["s3_source"] as! String
                            video.ytb_thumbnail_source      = qvideoinfo["ytb_thumbnail_source"] as! String
                            video.ytb_videoId               = qvideoinfo["ytb_videoId"] as! String
                            
                            let dateStr = qvideoinfo["ytb_upload_date"] as! String
                            let dateDouble = Double(dateStr)
                            let date = NSDate(timeIntervalSince1970: dateDouble!)
                            
                            video.ytb_upload_date           = date as Date
                            video.ytb_view_count            = qvideoinfo["ytb_view_count"] as! Int
                            video.ytb_tags                  = qvideoinfo["ytb_tags"] as! [String]
                            
                            let durStr = qvideoinfo["ytb_upload_date"] as! String
                            let durDouble = Double(durStr)
                            video.ytb_duration              = durDouble!
                            
                            video.ytb_categories            = qvideoinfo["ytb_categories"] as! [String]
                            //video.ytb_like_count            = qvideoinfo["ytb_like_count"] as! Int
                            video.order                     = qvideoinfo["order"] as! Int
                            video.fanpageId                 = qvideoinfo["fanpageId"] as! Int
                            
                            video.posterId                  = qvideoinfo["posterId"] as! String
                            
                            print(video.posterId)                            
                                                        
                            video.posterName                = qvideoinfo["poster_name"] as! String
                            
                            video.published                 = qvideoinfo.createdAt! as Date
                            
                            video.videoObj = qvideoinfo
                            
                            video.checked                   = qvideoinfo["public"] as! Bool
                            
                            videothum.getDataInBackground(block: { (data, error) in
                                
                                if error == nil{
                                    
                                    video.image = UIImage(data: data!)!
                                    
                                    self.videosGamves.append(video)
                                    
                                    print("***********")
                                    print("countVideos: \(countVideos!)")
                                    print("countVideosLoaded: \(countVideosLoaded)")
                                    
                                    if ( (countVideos!-1) == count)
                                    {
                                        self.initialSetting.videos = self.videosGamves
                                        
                                        self.activityIndicatorView?.stopAnimating()
                                        self.collectionView.reloadData()
                                    }
                                    count = count + 1
                                }
                            })
                        }
                    }

                } else {

                    self.showEmptyMessage()
                }
                
            }
        })
    } 


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        count = self.videosGamves.count      
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
             
        let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: cellVideoCollectionId, for: indexPath) as! VideoCollectionViewCell
        
        cellVideo.thumbnailImageView.image = videosGamves[indexPath.row].image
        
        let posterId = videosGamves[indexPath.row].posterId
        
        if posterId == Global.gamves_official_id {
            
            cellVideo.userProfileImageView.image = UIImage(named:"gamves_icons_white")
            
        } else if let imagePoster = Global.userDictionary[posterId] {
            
            cellVideo.userProfileImageView.image = imagePoster.avatar
        }
        
        if self.editProfile {
        
            if videosGamves[indexPath.row].checked {
                
                cellVideo.checkView.isHidden = false
            
            } else {
                
                cellVideo.checkView.isHidden = true
            }
            
        } else {
            
            cellVideo.checkView.isHidden = true
        }
        
        cellVideo.videoName.text = videosGamves[indexPath.row].title
        
        let published = String(describing: videosGamves[indexPath.row].published)
        
        let shortDate = published.components(separatedBy: " at ")
        
        cellVideo.videoDatePublish.text = shortDate[0] 
        
        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize()      
       
        let height = (self.frame.width - 16 - 16) * 9 / 16
           
        size = CGSize(width: self.frame.width, height: height + 16 + 88)
        
        
        return size //CGSize(width: view.frame.width, height: height + 16 + 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing = CGFloat()        
        spacing = 0       
        return spacing
        
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
        if !self.editProfile || self.profileSaveType == ProfileSaveType.chat {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)

            let videoLauncher = VideoLauncher()
            
            let video = videosGamves[indexPath.row]
        
            videoLauncher.showVideoPlayer(videoGamves: video)
            
        } else {
            
            
            let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: cellVideoCollectionId, for: indexPath) as! VideoCollectionViewCell
            
            if videosGamves[indexPath.row].checked {
            
                videosGamves[indexPath.row].checked = false
                
            } else {
                
                videosGamves[indexPath.row].checked = true
            }
            
            self.collectionView.reloadData()
            
        }
    }
}

class InitialSetting {
    var backColor:UIColor!
    var backImage:UIImage!
    var avatarImage:UIImage!
    var bio = String()
    var videos = [GamvesVideo]()
}


class ColorPickerViewController: UIView, ColorPickerViewDelegateFlowLayout {
    
    let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gamvesBackgoundColor
        return view
    }()
    
    let colorPickerView: ColorPickerView = {
        let view = ColorPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
       
        // Setup colorPickerView
        //colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.style = .circle
        colorPickerView.selectionStyle = .check
        colorPickerView.isSelectedColorTappable = false
        colorPickerView.preselectedIndex = colorPickerView.colors.indices.first
        
        self.addSubview(self.backgroundView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.backgroundView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.backgroundView)
        
        self.backgroundView.addSubview(self.colorPickerView)
        self.backgroundView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.colorPickerView)
        self.backgroundView.addConstraintsWithFormat("V:|[v0]|", views: self.colorPickerView)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}








