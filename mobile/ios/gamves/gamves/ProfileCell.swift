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

public enum SelectedColorTarget {
    case dataView
    case collectionView
    case fontColor
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

    var colorTarget:SelectedColorTarget!
    
    var profileUser:GamvesUser!

    var imageCropVC = RSKImageCropViewController()

    var homeController: HomeController?
    
    var profileSaveType:ProfileSaveType!

    var metricsHome = [String:Int]()

    var userStatistics = [UserStatistics]()

    var videosGamves  = [GamvesVideo]()
    let cellVideoCollectionId = "cellVideoCollectionId"  

    // Status and Friends

    // Online Status

    var onlineImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "status_online")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // Friendsvie

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

    var friendsButton:UIButton! //nulled button       

    //- Profile

    let profileView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()  
    
    // SON VIEW
    
    let sonView: UIView = {
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
    
    let leftsonView: UIView = {
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
    
    let rightsonView: UIView = {
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
        return v
    }()

    //Joined

    let joinedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right        
        return label
    }()

    //SchoolView   

    let schoolView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false        
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
        return v
    }()

    // gradePlsView

    let gradeUserView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false               
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

    //- Points

    let pointsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false             
        return v
    }()   

    let pointsLabelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray        
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "points"        
        label.textAlignment = .center        
        return label
    }() 

    let pointsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray        
        label.font = UIFont.systemFont(ofSize: 35)
        label.text = "0"        
        label.textAlignment = .center        
        return label
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
        return v
    }()
    
    // DATA VIEW
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)        
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    //- Footer

    var footerView:UIView!            

    var saveDesc:String  = "Save Profile"
    var colorDesc:String = "Choose Color"
    var chatDesc:String = "Chat"
    var closeDesc:String = "Close"
    
    lazy var saveProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
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

    //- Edit buttons overlay 

    let editOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false              
        return view
    }()

    //- Color popup view 

    let colorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false               
        v.layer.cornerRadius = 15
        v.backgroundColor = UIColor.black       
        return v
    }()   

    lazy var colorCloseButton: UIButton = {
        let button = UIButton(type: .system)
        var image = UIImage(named: "cancel")
        //image = image?.maskWithColor(color: UIColor.white)
        image = Global.resizeImage(image: image!, targetSize: CGSize(width:50, height:50))
        button.setImage(image, for: .normal)        
        button.translatesAutoresizingMaskIntoConstraints = false        
        button.addTarget(self, action: #selector(handleHideColor), for: .touchUpInside)
        //button.backgroundColor = UIColor.cyan
        return button
    }()
    
    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var cellId = String()   
    
    var colorPickerViewController:ColorPickerViewController!

    var editProfile = Bool()
    var editCreated = Bool()
    var colorCreated = Bool()
    
    var editBackImageView:UIView!
    var editAvatarImageView:UIView!
    var editColorView:UIView!
    var editBioView:UIView!
    var editColorCollView:UIView!
    var editFontView:UIView!

     let backgroundEdit: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false                     
        return v
    }()   
    
    var initialSetting = InitialSetting()
    
    var profilePF:PFObject!       

    var selectedImage:SelectedImage!    

    var selectedBackImage = UIImage()

    var floaty = Floaty(size: 80)      

    var leftOnline = CGFloat()

    var sonOnline = Bool()

    var showColors = Bool()

    var editColorButton:UIButton!
    var editColorCollButton:UIButton!
    var editFontButton:UIButton!
    
    override func setupViews() {
        super.setupViews()  

        self.profileUser = Global.profileUser

        let userId = Global.profileUser.userId        

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
        
        self.addConstraintsWithFormat("V:|[v0(240)][v1(1)][v2][v3(1)]|", views: //[v4(70)]
            self.profileView, 
            self.lineView, 
            self.dataView,
            self.lineFooterView)//,
            //self.footerView)        
        
        // SON VIEW         

        self.profileView.addSubview(self.backImageView)
        self.profileView.addSubview(self.sonView)
        self.profileView.addSubview(self.sonLabel)
        self.profileView.addSubview(self.bioLabel)  

        self.profileView.addConstraintsWithFormat("H:|[v0]|", views: self.backImageView)
        self.profileView.addConstraintsWithFormat("V:|[v0(100)]|", views:self.backImageView)        
        
        self.profileView.addConstraintsWithFormat("H:|[v0]|", views: self.sonView)
        self.profileView.addConstraintsWithFormat("H:|-30-[v0(250)]|", views: self.sonLabel)
        self.profileView.addConstraintsWithFormat("H:|-30-[v0(250)]|", views: self.bioLabel)

        self.profileView.addConstraintsWithFormat("V:|-20-[v0(150)][v1(40)][v2]-10-|", views:
            self.sonView,
            self.sonLabel,
            self.bioLabel,
            metrics: metricsRegisterView)   

        // Right Box -> InfoView

        let widthModule = self.frame.width / 3        
        let module = widthModule + ( widthModule / 2 )
        let infoMetrics = [ "widthModule" : module ]

        self.profileView.addSubview(self.infoView)  
        self.profileView.addConstraintsWithFormat("H:|-widthModule-[v0]|", views: self.infoView, metrics: infoMetrics) 
        self.profileView.addConstraintsWithFormat("V:|-100-[v0]|", views: self.infoView)            

        // Friends               

        self.leftOnline = width - 160

        self.profileView.addSubview(self.friendsView)                    

        let leftSpace = leftOnline + 60     
        let mestricsLeft = ["leftSpace":leftSpace] 

        self.profileView.addConstraintsWithFormat("H:|-leftSpace-[v0(80)]|", views: self.friendsView, metrics:mestricsLeft)
        self.profileView.addConstraintsWithFormat("V:|-20-[v0(40)]|", views:self.friendsView)               

        self.friendsView.addSubview(self.friendImageView)  
        self.friendsView.addSubview(self.friendsLabel)  

        self.friendsLabel.text = "\(Global.friendsAmount)"

        self.friendsView.addConstraintsWithFormat("V:|-5-[v0(30)]-5-|", views: self.friendImageView)
        self.friendsView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.friendsLabel)
        self.friendsView.addConstraintsWithFormat("H:|-15-[v0(30)]-5-[v1]|", views: 
            self.friendImageView, 
            self.friendsLabel)
      
        self.friendsView.isUserInteractionEnabled = true
        self.friendsView.alpha = 0.5        

        //Infoview
       
        self.infoView.addSubview(self.joinedLabel)  
        self.infoView.addSubview(self.schoolView)  
        self.infoView.addSubview(self.gradeUserPlsView)

        self.infoView.addConstraintsWithFormat("H:|[v0]-20-|", views: self.joinedLabel)
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
        self.gradeUserPlsView.addSubview(self.pointsView)

        self.gradeUserPlsView.addConstraintsWithFormat("V:|[v0]|", views: self.gradeUserView)
        self.gradeUserPlsView.addConstraintsWithFormat("V:|[v0]|", views: self.pointsView)

        self.gradeUserPlsView.addConstraintsWithFormat("H:|[v0][v1(50)]|", views: 
            self.gradeUserView, 
            self.pointsView)

        //plsIconImageView

        self.pointsView.addSubview(self.pointsLabel)
        self.pointsView.addSubview(self.pointsLabelLabel)

        self.pointsView.addConstraintsWithFormat("H:|[v0]|", views: self.pointsLabelLabel)
        self.pointsView.addConstraintsWithFormat("H:|[v0]|", views: self.pointsLabel)

        self.pointsView.addConstraintsWithFormat("V:|[v0(20)][v1]|", views: self.pointsLabelLabel, self.pointsLabel)       

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
        
        self.gradeUserView.addConstraintsWithFormat("H:|[v0(20)]-5-[v1]|", views: 
            self.pstStatusImageView, 
            self.plsUsernameLabel)      

        let dateFormatter = DateFormatter()  
        let joined = dateFormatter.dateFormat = "MM/dd/yy"
        let date = profileUser.userObj.createdAt! as Date

        self.joinedLabel.text = "since:  \(dateFormatter.string(from: date))"
        self.schoolLabel.text = profileUser.school.schoolName
        self.gradeLabel.text = "  \(profileUser.level.fullDesc)"
        self.schoolIconImageView.image = profileUser.school.icon
        
        if self.profileUser.consoles.count > 0 {

            self.plsUsernameLabel.text = profileUser.consoles[0].username

        } else {

            self.pstStatusImageView.isHidden = true
            self.plsUsernameLabel.isHidden = true

        }

        self.profileView.addConstraintsWithFormat("H:|-30-[v0(250)]|", views: self.sonLabel)
        self.profileView.addConstraintsWithFormat("H:|-30-[v0(250)]|", views: self.bioLabel)               
        
        //FLOATY      

        self.floaty.paddingY = 20
        self.floaty.paddingX = 20                    
        self.floaty.itemSpace = 30
        self.floaty.hasShadow = true
        self.floaty.shadowColor = UIColor.black
        self.floaty.buttonColor = UIColor.gamvesFucsiaColor
        var addImage = UIImage(named: "add_symbol")
        addImage = addImage?.maskWithColor(color: UIColor.white)
        addImage = Global.resizeImage(image: addImage!, targetSize: CGSize(width:40, height:40))
        self.floaty.buttonImage = addImage
        self.floaty.sizeToFit()

        //floaty.verticalDirection = .down        
        
        let itemEditProfile = FloatyItem()
        var editImage = UIImage(named: "edit")
        editImage = editImage?.maskWithColor(color: UIColor.white)
        itemEditProfile.icon = editImage
        itemEditProfile.buttonColor = UIColor.gamvesFucsiaColor
        itemEditProfile.titleLabelPosition = .left
        itemEditProfile.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemEditProfile.title = "EDIT PROFILE"
        itemEditProfile.handler = { item in
            self.handleEditProfile()
            
            self.editOverlayView.isHidden = false
            self.footerView.isHidden = false

            self.floaty.isHidden = true
        }

        let itemEditFanpage = FloatyItem()
        var fanImage = UIImage(named: "page")
        fanImage = fanImage?.maskWithColor(color: UIColor.white)
        itemEditFanpage.icon = fanImage
        itemEditFanpage.buttonColor = UIColor.gamvesFucsiaColor
        itemEditFanpage.titleLabelPosition = .left
        itemEditFanpage.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemEditFanpage.title = "EDIT YOUR FANPAGE"
        itemEditFanpage.handler = { item in
            self.handleEditFanpage()
        }

        self.floaty.addItem(item: itemEditProfile)       
        self.floaty.addItem(item: itemEditFanpage)       
        self.addSubview(floaty)        
        
        self.profileView.bringSubview(toFront: self.sonView)
                        
        let name = profileUser.name
        self.sonLabel.text = name
        //self.sonLabel.textAlignment = NSTextAlignment.center
        
        self.sonView.addSubview(self.leftsonView)
        self.sonView.addSubview(self.sonProfileImageView)
        self.sonView.addSubview(self.rightsonView)
        
        self.sonView.addConstraintsWithFormat("V:|[v0]|", views: self.leftsonView)
        self.sonView.addConstraintsWithFormat("V:|[v0]|", views: self.sonProfileImageView)
        self.sonView.addConstraintsWithFormat("V:|[v0]|", views: self.rightsonView)            
        
        self.sonView.addConstraintsWithFormat("H:|[v0(30)][v1(150)][v2]|", views: 
            self.leftsonView, 
            self.sonProfileImageView, 
            self.rightsonView, 
            metrics: metricsRegisterView)        

        //- DataView

        self.dataView.addSubview(self.collectionView)
        self.dataView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.collectionView) 
        self.dataView.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)     

        self.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: self.cellVideoCollectionId)       

        self.collectionView.backgroundColor = UIColor.white       

        self.addSubview(self.labelEmptyMessage)
        self.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: self.labelEmptyMessage)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.labelEmptyMessage)

        self.labelEmptyMessage.isHidden = true      

        //Popup colors        

        let hm  = (self.frame.height - 110) //+ 120
        let hc  = self.frame.width  - 80        

        let metricsModule = ["hm":hm]     

        self.addSubview(self.colorView)
        self.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.colorView)
        self.addConstraintsWithFormat("V:|-hm-[v0(90)]-10-|", views: self.colorView, metrics: metricsModule)
        
        let offset = CGSize(width:100, height:100)
        self.colorView.dropShadow(color: UIColor.black, opacity: 0.5, offSet: offset, radius: 10.0, scale: true)

        self.colorPickerViewController = ColorPickerViewController()          
        colorPickerViewController.colorPickerView.delegate = self
        self.colorView.addSubview(self.colorPickerViewController)

        self.colorView.addConstraintsWithFormat("H:|-10-[v0]-80-|", views: self.colorPickerViewController)
        self.colorView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.colorPickerViewController)

        let lb = self.frame.width - 90

        let metricsButton = ["lb":lb] 

        self.colorView.addSubview(self.colorCloseButton)
        self.colorView.addConstraintsWithFormat("H:|-lb-[v0(60)]|", views: self.colorCloseButton, metrics: metricsButton)
        self.colorView.addConstraintsWithFormat("V:|-20-[v0(60)]-20-|", views: self.colorCloseButton)

        //-- Overlay

        self.addSubview(self.editOverlayView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.editOverlayView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.editOverlayView)       

        self.editOverlayView.isHidden = true
        self.colorView.isHidden = true

    }
    
    override func layoutSubviews() {

        if self.footerView == nil {

            let w = self.frame.width 
            let h = self.frame.height

            let topPadding = h - 70
            let metrisFooter = ["topPadding":topPadding]

            //- Footer 

            self.footerView = UIView()
            self.footerView.translatesAutoresizingMaskIntoConstraints = false
            self.footerView.backgroundColor = UIColor.gamvesColor

            self.addSubview(self.footerView)
            self.addConstraintsWithFormat("H:|[v0]|", views: self.footerView)        
            self.addConstraintsWithFormat("V:|-topPadding-[v0]|", views: self.footerView, metrics: metrisFooter)   

            self.footerView.addSubview(self.footerLabel)    
            self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.footerLabel)
            self.footerView.addConstraintsWithFormat("H:|-10-[v0]-100-|", views: self.footerLabel)

            self.footerLabel.isHidden = true   
            
            let splitFooter = (w - 60) / 2 
            
            let metricsFooterView = ["sf": splitFooter]   

            self.footerView.addSubview(self.saveProfileButton)
            self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.saveProfileButton)
            self.saveProfileButton.isHidden = true
            
            self.footerView.addSubview(self.cancelProfileButton)
            self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.cancelProfileButton)
            self.cancelProfileButton.isHidden = true
            
            self.footerView.addConstraintsWithFormat("H:|-20-[v0(sf)]-20-[v1(sf)]-20-|", views: self.saveProfileButton, self.cancelProfileButton, metrics: metricsFooterView)    

            self.footerView.isHidden = true   
            
        }

        if self.friendsView.frame.width > 0 {

            if self.friendsButton == nil {

                self.friendsButton = UIButton(type: .system)                
                self.friendsButton.addTarget(self, action: #selector(self.showFriends), for: .touchUpInside)  

                let x = self.friendsView.frame.maxX - 80
                let y = self.friendsView.frame.maxY - 40
                let width = self.friendsView.frame.width
                let height = self.friendsView.frame.height                            

                self.addSubview(self.friendsButton)

                let mestrics = ["x":x, "y":y, "width":width, "height":height] 

                self.addConstraintsWithFormat("H:|-x-[v0(width)]|", views: self.friendsButton, metrics:mestrics)                
                self.addConstraintsWithFormat("V:|-y-[v0(height)]|", views:self.friendsButton, metrics:mestrics)                               

            }            
        }       
    }

    func hideNotEditable(status: Bool) {

        self.friendsView.isHidden   = status
        self.infoView.isHidden      = status
        self.collectionView.isHidden      = status

    }

    func showFriends() {       

        self.homeController?.showFriends()
    }

    func setType(type:ProfileSaveType){
        
        self.profileSaveType = type
        
        if self.profileSaveType == ProfileSaveType.publicProfile {

            self.userOnline()
            
            self.profileView.addSubview(self.onlineImageView)
            let mestricsLeftOnline = ["leftOnline":self.leftOnline] 

            self.profileView.addConstraintsWithFormat("H:|-leftOnline-[v0(40)]|", views: self.onlineImageView, metrics:mestricsLeftOnline)
            self.profileView.addConstraintsWithFormat("V:|-20-[v0(40)]|", views:self.onlineImageView)  
        }
    }   
  

    func userOnline() {

        let userId = Global.profileUser.userId 

        let queryOnline = PFQuery(className:"UserStatus")
        queryOnline.whereKey("userId", equalTo: userId)
        queryOnline.getFirstObjectInBackground { (usersOnline, error) in 
            
            if error != nil
            {
                print("error")

                self.onlineImageView.image = UIImage(named: "status_offline")

            } else {
                
                self.changeSingleUserStatus(onlineMessage:usersOnline!)
                
            }
        }
    }

    func changeSingleUserStatus(onlineMessage:PFObject)
    {
        let status = onlineMessage["status"] as! Int
        
        if status == 2 {
            
            self.sonOnline = true

             DispatchQueue.main.async {
                        
                self.onlineImageView.image = UIImage(named: "status_online")
                
            }

            
        } else if status == 1 {
            
            self.sonOnline = false
            
            if self.userStatistics.count > 0  {

                if let lastSeen = onlineMessage.updatedAt {

                    self.userStatistics[0].data = "\(lastSeen)"

                     DispatchQueue.main.async {
                        
                        self.onlineImageView.image = UIImage(named: "status_online")
                        
                    }
                }
            }
        }         
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

        userId = self.profileUser.userId    
        
        queryUser.whereKey("userId", equalTo: userId)
        
        queryUser.getFirstObjectInBackground { (profile, error) in
            
            if error == nil {
                
                if let prPF:PFObject = profile {
                    
                    self.profilePF = prPF
                    
                    if self.profilePF["pictureBackground"] != nil {
                
                        let backImage = self.profilePF["pictureBackground"] as! PFFile
                        
                        let colorArray:[CGFloat] = self.profilePF["backgroundColor"] as! [CGFloat]
                        let backgroundColor = UIColor.rgb(colorArray[0], green: colorArray[1], blue: colorArray[2])
                        
                        self.initialSetting.backColor = backgroundColor
                        self.profileView.backgroundColor = backgroundColor
                        
                        let bio = self.profilePF["bio"] as! String
                        
                        self.bioLabel.text = bio

                        if self.profilePF["fontColor"] != nil {

                            let fontColorArray:[CGFloat] = self.profilePF["fontColor"] as! [CGFloat]
                            let fontColorColor = UIColor.rgb(fontColorArray[0], green: fontColorArray[1], blue: fontColorArray[2])                        
                            self.setFontcolor(color:fontColorColor)
                            self.initialSetting.fontColor = fontColorColor
                        }

                        if self.profilePF["collectionColor"] != nil {

                            let collColorArray:[CGFloat] = self.profilePF["collectionColor"] as! [CGFloat]
                            let collColorColor = UIColor.rgb(collColorArray[0], green: collColorArray[1], blue: collColorArray[2])                                                                       
                            
                            self.dataView.backgroundColor = collColorColor  
                            self.collectionView.backgroundColor = collColorColor                       
                            self.initialSetting.collectionColor = collColorColor
                        }
                        
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

        userId = self.profileUser.userId

        /*if self.gamvesUser == nil {

            userId = (PFUser.current()?.objectId)!

        } else {

            userId = self.gamvesUser.userId
        }*/
        

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

        self.backgroundColor = UIColor(white: 1, alpha: 0.5)

        if self.profileSaveType == ProfileSaveType.chat {

            var chatId = Int()
            
            if self.profileUser.chatId > 0
            {
                chatId = self.profileUser.chatId
            } else
            {
                chatId = Global.getRandomInt()
            }         

            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)           

            let userDataDict:[String: AnyObject] = ["gamvesUser": self.profileUser, "chatId": chatId as AnyObject] 

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Global.notificationOpenChatFromUser), object: nil, userInfo: userDataDict)  
        
        } else if !self.editCreated {
        
            DispatchQueue.main.async {                  

                //self.hideNotEditable(status:true)    

               self.backgroundEdit.translatesAutoresizingMaskIntoConstraints = false
               self.backgroundEdit.backgroundColor = UIColor.black
               self.backgroundEdit.alpha = 0.5
                
                self.editOverlayView.addSubview(self.backgroundEdit)
                self.editOverlayView.addConstraintsWithFormat("V:|[v0]|", views: self.backgroundEdit)
                self.editOverlayView.addConstraintsWithFormat("H:|[v0]|", views: self.backgroundEdit)

                self.editOverlayView.isHidden = false

                self.editProfile = true
                let w = self.frame.width
                let h = self.frame.height               
                
                //-- Bottom single button
                
                self.saveProfileButton.isHidden = false
                self.cancelProfileButton.isHidden = false

                //self.editProfileButton.isHidden = true
                //self.editFanpageButton.isHidden = true
                
                //-- Background

                let halfWidth = (w/2) + 10               
                
                self.editBackImageView = UIView(frame: CGRect(x:halfWidth, y:30, width:100, height:100))
                
                var editBackImageButton = UIButton(type: UIButtonType.system)
                editBackImageButton = UIButton(frame: CGRect(x:0, y:0, width:40, height:40))
                var imageBack = UIImage(named: "camera_black")                
                imageBack = Global.resizeImage(image: imageBack!, targetSize: CGSize(width:40, height:40))                
                imageBack = imageBack?.maskWithColor(color: UIColor.gamvesBackgoundColor)           
                
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
                self.editOverlayView.addSubview(self.editBackImageView)
                
                //-- Avatar               
                
                self.editAvatarImageView = UIView(frame: CGRect(x:85, y:80, width:100, height:100))
                
                var editAvatarButton = UIButton(type: .system)
                
                editAvatarButton = UIButton(frame: CGRect(x:0, y:0, width:40, height:40))
                var imageAvatar = UIImage(named: "camera_black")
                imageAvatar = Global.resizeImage(image: imageAvatar!, targetSize: CGSize(width:40, height:40))                
                imageAvatar = imageBack?.maskWithColor(color: UIColor.gamvesBackgoundColor)          
                
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
                self.editOverlayView.addSubview(self.editAvatarImageView)
                
                //-- Color

                let xColor = w - 80
                
                self.editColorView = UIView(frame: CGRect(x:xColor, y:105, width:100, height:100))
                
                self.editColorButton = UIButton(type: UIButtonType.system)
                self.editColorButton = UIButton(frame: CGRect(x:0, y:0, width:40, height:40))
                var imageColor = UIImage(named: "color")
                imageColor = Global.resizeImage(image: imageColor!, targetSize: CGSize(width:40, height:40))                
                imageColor = imageColor?.maskWithColor(color: UIColor.gamvesBackgoundColor)          
                
                self.editColorButton.setImage(imageColor, for: .normal)
                self.editColorButton.addTarget(self, action: #selector(self.handleChangeColor), for: .touchUpInside)
                self.editColorButton.isUserInteractionEnabled = true
                
                let haloColor = PulsingHaloLayer()
                haloColor.position.x = self.editColorButton.center.x
                haloColor.position.y = self.editColorButton.center.y
                haloColor.haloLayerNumber = 5
                haloColor.backgroundColor = UIColor.lightGray.cgColor
                haloColor.radius = 40
                haloColor.start()
                self.editColorView.layer.addSublayer(haloColor)

                self.editColorView.addSubview(self.editColorButton)
                self.editOverlayView.addSubview(self.editColorView)
                
                //-- Bio                
                
                self.editBioView = UIView(frame: CGRect(x:70, y:200, width:40, height:40))
        
                var editBioButton = UIButton(type: UIButtonType.system)
                editBioButton = UIButton(frame: CGRect(x:0, y:0, width:40, height:40))
                var imageBio = UIImage(named: "edit")
                imageBio = Global.resizeImage(image: imageBio!, targetSize: CGSize(width:40, height:40))                
                imageBio = imageBio?.maskWithColor(color: UIColor.gamvesBackgoundColor)                

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
                self.editOverlayView.addSubview(self.editBioView)

                //-- Color Font               
                
                self.editFontView = UIView(frame: CGRect(x:halfWidth, y:130, width:40, height:40))
        
                self.editFontButton = UIButton(type: UIButtonType.system)
                self.editFontButton = UIButton(frame: CGRect(x:0, y:0, width:40, height:40))
                var imageFont = UIImage(named: "color")
                imageFont = Global.resizeImage(image: imageFont!, targetSize: CGSize(width:40, height:40))                
                imageFont = imageFont?.maskWithColor(color: UIColor.gamvesBackgoundColor)                

                self.editFontButton.setImage(imageFont, for: .normal)
                self.editFontButton.addTarget(self, action: #selector(self.handleChangeColor), for: .touchUpInside)
                self.editFontButton.isUserInteractionEnabled = true
                
                let haloFont = PulsingHaloLayer()
                haloFont.position.x = self.editFontButton.center.x
                haloFont.position.y = self.editFontButton.center.y
                haloFont.haloLayerNumber = 5
                haloFont.backgroundColor = UIColor.lightGray.cgColor
                haloFont.radius = 40
                haloFont.start()    
                self.editFontView.layer.addSublayer(haloFont)

                self.editFontView.addSubview(self.editFontButton)
                self.editOverlayView.addSubview(self.editFontView)

                //-- CollectionColor

                let xColl = ( w / 2 ) - 30
                let yColl = ( h / 2 ) + 50

                self.editColorCollView = UIView(frame: CGRect(x:xColl, y:yColl, width:100, height:100))
                
                self.editColorCollButton = UIButton(type: UIButtonType.system)
                self.editColorCollButton = UIButton(frame: CGRect(x:0, y:0, width:40, height:40))
                var imageColorColl = UIImage(named: "color")
                imageColorColl = Global.resizeImage(image: imageColorColl!, targetSize: CGSize(width:40, height:40))                
                imageColorColl = imageColorColl?.maskWithColor(color: UIColor.gamvesBackgoundColor)          

                self.editColorCollButton.setImage(imageColorColl, for: .normal)                
                self.editColorCollButton.addTarget(self, action: #selector(self.handleChangeColor), for: .touchUpInside)
                self.editColorCollButton.isUserInteractionEnabled = true
                
                let haloColorColl = PulsingHaloLayer()
                haloColorColl.position.x = self.editColorCollButton.center.x
                haloColorColl.position.y = self.editColorCollButton.center.y
                haloColorColl.haloLayerNumber = 5
                haloColorColl.backgroundColor = UIColor.lightGray.cgColor
                haloColorColl.radius = 40
                haloColorColl.start()
                self.editColorCollView.layer.addSublayer(haloColorColl)

                self.editColorCollView.addSubview(self.editColorCollButton)
                self.editOverlayView.addSubview(self.editColorCollView)                                               
                
                self.editCreated = true                
            }
        }
    }

    func hideNonEditable(status:Bool) {
        self.friendsView.isHidden       = status
        self.friendsButton.isHidden     = status
        self.collectionView.isHidden    = status
    }

    func handleEditFanpage() {
        
        if self.profileSaveType == ProfileSaveType.chat {            

            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)           

        } else {

            self.homeController?.addNewFanpage(edit:true)
        }                  
    }


    
    func handleSaveProfile() {

        if self.profileSaveType == ProfileSaveType.profile {

            self.activityIndicatorView?.startAnimating()
            
            let backImage:UIImage = self.selectedBackImage
            let backImagePF = PFFile(name: "background.png", data: UIImageJPEGRepresentation(backImage, 1.0)!)            
            self.profilePF["pictureBackground"] = backImagePF            
            self.profilePF["bio"] = self.bioLabel.text

            let backColor:UIColor = self.profileView.backgroundColor!
            if let rgbBack:[CGFloat] = backColor.rgb() {
    
                self.profilePF["backgroundColor"] = rgbBack             
            } 

            let fontColor:UIColor = self.sonLabel.textColor
            if let rgbFont:[CGFloat] = fontColor.rgb() {                   

                self.profilePF["fontColor"] = rgbFont             
            }

            let colllColor:UIColor = self.dataView.backgroundColor!
            if let rgbColl:[CGFloat] = colllColor.rgb() {                   

                self.profilePF["collectionColor"] = rgbColl             
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

        self.footerView.isHidden = true
        
        self.floaty.isHidden = false

        self.profileView.backgroundColor = self.initialSetting.backColor
        
        if self.profileSaveType == ProfileSaveType.profile {
            
            self.newKenBurnsImageView(image: self.initialSetting.backImage)
            self.sonProfileImageView.image = self.initialSetting.avatarImage
            self.setSonProfileImageView()
            
            self.bioLabel.text = self.initialSetting.bio

            self.setFontcolor(color: self.initialSetting.fontColor)

            self.dataView.backgroundColor = self.initialSetting.collectionColor
            self.collectionView.backgroundColor = self.initialSetting.collectionColor
         
            self.videosGamves = [GamvesVideo]()
            self.videosGamves = self.initialSetting.videos
            
            self.enableDisableButtonToNormal()
            
        } else if self.profileSaveType == ProfileSaveType.color {
         
            self.clearColorButton()            
        }    
    }

    func enableDisableButtonToNormal() {

        self.footerView.isHidden            = true
        self.floaty.isHidden                = false

        self.saveProfileButton.isHidden     = true
        self.cancelProfileButton.isHidden   = true
        
        self.editBackImageView.isHidden     = true
        self.editAvatarImageView.isHidden   = true
        self.editColorView.isHidden         = true
        self.editBioView.isHidden           = true
        self.editColorCollView.isHidden     = true
        self.editFontView.isHidden          = true

        self.backgroundEdit.isHidden        = true 

        self.editCreated                    = false
    }
    
    func clearColorButton() {        
        self.colorPickerViewController.isHidden = true
        self.saveProfileButton.setTitle(self.saveDesc, for: .normal)
        self.profileSaveType = ProfileSaveType.profile        
    } 

    func handleHideColor() {

        self.colorView.isHidden = true
        self.footerView.isHidden = false   
        self.editOverlayView.isHidden = false

        /*UIView.animate(withDuration: 0.5, animations: { 
            self.colorView.frame.origin.y += 120
        }, completion: { (completedAnimation) in
            print("")                    
        })*/
    }   

    func handleChangeColor(sender : UIButton) {

        if sender == self.editColorButton {

            self.colorTarget = SelectedColorTarget.dataView
        
        } else if sender == self.editColorCollButton {

            self.colorTarget = SelectedColorTarget.collectionView

        } else if sender == self.editFontButton {

            self.colorTarget = SelectedColorTarget.fontColor
        }

        self.friendsView.isUserInteractionEnabled = false
        self.dataView.isUserInteractionEnabled = false

        self.colorView.isHidden = false

        self.footerView.isHidden = true

        self.editOverlayView.isHidden = true

        /*UIView.animate(withDuration: 0.5, animations: { 
            self.colorView.frame.origin.y -= 120
        }, completion: { (completedAnimation) in                   
            print("")                    
        })*/
        
    }
    
    func handleChangeBackgoundImage(sender : UIButton) {        
        self.selectedImage = SelectedImage.background        
        let media = MediaController()
        media.isImageMultiSelection = false
        media.delegate = self
        media.setType(type: MediaType.selectImage)
        media.searchType = SearchType.isSingleImage
        media.searchSize = SearchSize.imageSmall
        self.homeController?.navigationController?.pushViewController(media, animated: true)        
    }    
   
    
    func handleChangeAvatarImage(sender : UIButton) {        

        self.selectedImage = SelectedImage.avatar
       let media = MediaController()
        media.isImageMultiSelection = false
        media.delegate = self        
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

        let color = colorPickerView.colors[indexPath.item] as UIColor
 
        if self.colorTarget == SelectedColorTarget.collectionView {

            self.dataView.backgroundColor = color
            self.collectionView.backgroundColor = color

        } else if self.colorTarget == SelectedColorTarget.dataView {

            self.profileView.backgroundColor = color        
            self.sonProfileImageView.borderColor = color

        } else if self.colorTarget == SelectedColorTarget.fontColor {
            
            self.setFontcolor(color: color)

        }        
    }

    func setFontcolor(color: UIColor) {

        self.sonLabel.textColor       = color
        self.bioLabel.textColor       = color
        self.joinedLabel.textColor    = color
        self.schoolLabel.textColor    = color
        self.gradeLabel.textColor     = color
        self.plsUsernameLabel.textColor = color
        self.pointsLabelLabel.textColor = color
        self.pointsLabel.textColor    = color

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

    func getProfileVideos() {
        
        self.activityIndicatorView?.startAnimating()
        
        let queryvideos = PFQuery(className:"Videos")
        if let userId = PFUser.current()?.objectId {            
            queryvideos.whereKey("posterId", equalTo: userId)    
        }
        
        queryvideos.whereKey("approved", equalTo: true)
        queryvideos.findObjectsInBackground(block: { (videoObjects, error) in
            
            if error != nil {
                print("error")                
            } else {
                
                let countVideosLoaded = Int()
                
                var countVideos = videoObjects?.count
                var count = 0
                
                print(countVideos)
                
                if countVideos! > 0 {

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
                                    
                                    //print("***********")
                                    //print("countVideos: \(countVideos!)")
                                    //print("countVideosLoaded: \(countVideosLoaded)")
                                    
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
        
        return size 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing = CGFloat()        
        spacing = 0       
        return spacing
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
    var fontColor:UIColor!
    var collectionColor:UIColor!
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
        
        self.cornerRadius = 15
        self.backgroundColor = UIColor.white             
        
        //colorPickerView.delegate = self
        self.colorPickerView.layoutDelegate = self
        self.colorPickerView.style = .circle
        self.colorPickerView.selectionStyle = .check
        self.colorPickerView.isSelectedColorTappable = false
        self.colorPickerView.preselectedIndex = colorPickerView.colors.indices.first        
        
        self.addSubview(self.backgroundView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.backgroundView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.backgroundView)
        
        self.backgroundView.addSubview(self.colorPickerView)
        self.backgroundView.addConstraintsWithFormat("H:|[v0]|", views: self.colorPickerView)
        self.backgroundView.addConstraintsWithFormat("V:|[v0]|", views: self.colorPickerView)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}








