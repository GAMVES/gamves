     //
//  ProfileViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 9/26/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import Foundation
import UIKit
import DownPicker
import Parse
import SwiftValidator
import NVActivityIndicatorView
import RSKImageCropper
import TaskQueue

class ProfileViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    RSKImageCropViewControllerDelegate  
{
  
    var imageCropVC = RSKImageCropViewController()

    var tabBarViewController:TabBarViewController?
    
    var types = Dictionary<Int, PFObject>()
    
    var adminRole:PFRole!
   
    var son:PFUser!
    var you:PFUser!
    var spouse:PFUser!

    var sonType:PFObject!
    var sonTypeId = Int()

    var yourType:PFObject!
    var yourTypeId = Int()

    var spouseType:PFObject!
    var spouseTypeId = Int()

    let validator = Validator()

    let imagePicker = UIImagePickerController()
    var selectedImageView = UIImageView()

    var metricsProfile = [String:Int]()

    var yourPhotoImage:UIImage!
    var sonPhotoImage:UIImage!
    var spousePhotoImage:UIImage!
    var familyPhotoImage:UIImage!

    var yourPhotoImageSmall:UIImage!
    var sonPhotoImageSmall:UIImage!
    var spousePhotoImageSmall:UIImage!
    var familyPhotoImageSmall:UIImage!

    let schoolsArray: NSMutableArray = []

    var familyChatId = Int() 
    var sonChatId = Int() 
    var spouseChatId = Int() 
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()

    let photosContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    lazy var yourPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "your_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()

    lazy var sonPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))        
        imageView.isUserInteractionEnabled = true        
        imageView.tag = 1
        return imageView
    }()   

    lazy var spousePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spouse_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 2           
        return imageView
    }()

    lazy var familyPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "family_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 3           
        return imageView
    }()

    lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Son or daughter", "Family"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleSegmentedChange), for: .valueChanged)
        return sc
    }()

    ////////////////////////////    
    //// SON AND DAUGHTER //////
    ////////////////////////////

    let sonNameContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

     let sonNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Clemente Vigil"
        tf.tag = 0
        return tf
    }()

    let sonNameSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let sonUserTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "User name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Clemente"
        tf.tag = 1
        return tf
    }()

    let sonUserSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    let sonPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.isSecureTextEntry = true
        tf.text = "clemente"
        tf.tag = 2
        return tf
    }()

    ///////////////////////////

     let sonSchoolContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    var sonUserTypeDownPicker: DownPicker!
    let sonUserTypeTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false        
        return tf
    }()


    let sonUserTypeSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()  

    var sonSchoolDownPicker: DownPicker!
    let sonSchoolTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false        
        return tf
    }()

    let sonSchoolSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var sonGradeDownPicker: DownPicker!
    let sonGradeTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false        
        return tf
    }()

    ////////////////////////////    
    //// FAMILY INFORMATION ////
    ////////////////////////////


     let yourNameContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

     let yourNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Jose Vigil"
        tf.tag = 0
        return tf
    }()

    let yourNameSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let yourUserTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your user name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Jose"
        tf.tag = 1
        return tf
    }()  

    let yourUserSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()  

    let yourFamilyTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Family name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Familia Vigil"
        tf.tag = 2
        return tf
    }()

    ////////////
    // SPOUSE //
    ////////////

    let spouseContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()   

    let spouseNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Spouse name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "Leda Olano"
        tf.tag = 3
        return tf
    }()

    let spouseNameSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let spouseEmailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Spouse email"
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "ledaolano@gmail.com"
        tf.tag = 4
        return tf
    }()  

    let spouseEmailSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let spousePasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Spouse password"
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "LedaOlano"
        tf.isSecureTextEntry = true
        tf.tag = 5
        return tf
    }()


    //////////////    
    //// SAVE ////
    //////////////
    
    var activityIndicatorView:NVActivityIndicatorView?

    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Save son or doughter", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)        
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)       
        button.layer.cornerRadius = 5 
        return button
    }()

    let bottomView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var sonImageName = "sonImage"
    var familyImageName = "familyImage"

    var sonNameContainerViewHeightAnchor: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()        
        
        NotificationCenter.default.addObserver(self, selector: #selector(familyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(levelsLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyLevelsLoaded), object: nil)
        
        self.loadAdminRole()
        
        self.you = PFUser.current()

        self.imagePicker.delegate = self
        
        self.view.addSubview(self.scrollView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView)   
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.scrollView)          

        let attr = NSDictionary(object: UIFont(name: "Arial", size: 16.0)!, forKey: NSFontAttributeName as NSCopying)
        self.segmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)

        self.scrollView.addSubview(self.photosContainerView)
        self.scrollView.addSubview(self.segmentedControl)

        self.scrollView.addSubview(self.sonNameContainerView)
        self.scrollView.addSubview(self.sonSchoolContainerView)         

        self.scrollView.addSubview(self.saveButton)   
        self.scrollView.addSubview(self.bottomView)             

        self.photosContainerView.addSubview(self.sonPhotoImageView)
        self.photosContainerView.addSubview(self.familyPhotoImageView) 

        self.photosContainerView.addSubview(self.yourPhotoImageView)
        self.photosContainerView.addSubview(self.spousePhotoImageView)
        
        self.sonNameContainerView.addSubview(self.sonNameTextField)
        self.sonNameContainerView.addSubview(self.sonNameSeparatorView)
        self.sonNameContainerView.addSubview(self.sonUserTextField)                
        self.sonNameContainerView.addSubview(self.sonUserSeparatorView)  
        self.sonNameContainerView.addSubview(self.sonPasswordTextField)            

        let sons: NSMutableArray = ["Son", "Daughter"]
        self.sonUserTypeDownPicker = DownPicker(textField: sonUserTypeTextField, withData:sons as! [Any])
        sonUserTypeDownPicker.setPlaceholder("Tap to choose relationship...")  

        self.sonSchoolContainerView.addSubview(self.sonUserTypeTextField)
        self.sonSchoolContainerView.addSubview(self.sonUserTypeSeparatorView)   
        self.sonSchoolContainerView.addSubview(self.sonSchoolTextField)
        self.sonSchoolContainerView.addSubview(self.sonSchoolSeparatorView)        
        self.sonSchoolContainerView.addSubview(self.sonGradeTextField)

        //let schools: NSMutableArray = ["St Paul's", "St Hilda's"]
        
        self.scrollView.addSubview(self.yourNameContainerView)
        self.scrollView.addSubview(self.spouseContainerView) 

        self.yourNameContainerView.addSubview(self.yourNameTextField)
        self.yourNameContainerView.addSubview(self.yourNameSeparatorView)
        self.yourNameContainerView.addSubview(self.yourUserTextField)                
        self.yourNameContainerView.addSubview(self.yourUserSeparatorView)  
        self.yourNameContainerView.addSubview(self.yourFamilyTextField)  

        self.spouseContainerView.addSubview(self.spouseNameTextField)
        self.spouseContainerView.addSubview(self.spouseNameSeparatorView)   
        self.spouseContainerView.addSubview(self.spouseEmailTextField)
        self.spouseContainerView.addSubview(self.spouseEmailSeparatorView)        
        self.spouseContainerView.addSubview(self.spousePasswordTextField)

        self.view.backgroundColor = UIColor.gamvesColor

        let width:Int = Int(view.frame.size.width)
        let height:Int = Int(view.frame.size.height)

        let photoSize = width / 3
        let padding = photoSize / 3  
        let topPadding = 40 

        let photoContainerHeight = 120        
        let photoEditTextHeight = photoContainerHeight / 3  

        let schoolContainerHeight = 120
        let schoolEditTextHeight = schoolContainerHeight / 3

        let saveButtonHeight = 50

        let topHeight = padding + photoSize + photoContainerHeight
        
        metricsProfile["photoSize"]             =  photoSize
        metricsProfile["padding"]               = padding
        metricsProfile["topPadding"]            = topPadding
        metricsProfile["photoContainerHeight"]  = photoContainerHeight
        metricsProfile["photoEditTextHeight"]   = photoEditTextHeight
        metricsProfile["schoolContainerHeight"] = schoolContainerHeight
        metricsProfile["schoolEditTextHeight"]  = schoolEditTextHeight
        metricsProfile["saveButtonHeight"]      = saveButtonHeight 

        self.boyConstraints()
        
        self.prepTextFields(inView: [self.sonNameContainerView])

        self.segmentedControl.setEnabled(false, forSegmentAt: 1)
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)
       
        self.familyChatId    = Global.getRandomInt()
        self.sonChatId       = Global.getRandomInt()
        self.spouseChatId    = Global.getRandomInt()
        
        if !Global.isKeyPresentInUserDefaults(key: "profile_completed") {
            
            tabBarController?.tabBar.isHidden = true
            
            if Global.isKeyPresentInUserDefaults(key: "son_name") {
            
                self.loadSonDataIfFamilyDontExist()
            }
        }
        
        Global.loaLevels()
        
    }
    
    
    func levelsLoaded() {
        
        self.loadSchools(completionHandler: { ( user ) -> () in
            
            self.sonSchoolDownPicker = DownPicker(textField: self.sonSchoolTextField, withData:self.schoolsArray as! [Any])
            self.sonSchoolDownPicker.setPlaceholder("Tap to choose school...")
        })
        
        let grades: NSMutableArray = [] //["5 - Fig", "5 - Chestnut"]
        
        for level in Global.levels {
            grades.add(level.fullDesc)
        }
        
        print(grades)
        
        self.sonGradeDownPicker = DownPicker(textField: self.sonGradeTextField, withData:grades as! [Any])
        sonGradeDownPicker.setPlaceholder("Tap to choose grade...")
        
    }
    
    func familyLoaded() {
        
        if Global.isKeyPresentInUserDefaults(key: "profile_completed")
        {
            let profile_completed = Global.defaults.bool(forKey: "profile_completed")
            
            if profile_completed
            {
                self.hideShowTabBar(status:false)
                self.loadFamilyData()
                self.segmentedControl.setEnabled(true, forSegmentAt: 1)
            }
            
        } else
        {
            self.hideShowTabBar(status:true)
        }
    }
    
    func loadFamilyData()
    {
        DispatchQueue.main.async() {
            
            self.yourPhotoImageView.image     = Global.gamvesFamily.youUser.avatar
            self.makeRounded(imageView:self.yourPhotoImageView)
            
            self.sonPhotoImageView.image      = Global.gamvesFamily.sonsUsers[0].avatar
            self.makeRounded(imageView:self.sonPhotoImageView)
            
            self.spousePhotoImageView.image   = Global.gamvesFamily.spouseUser.avatar
            self.makeRounded(imageView:self.spousePhotoImageView)
            
            self.familyPhotoImageView.image   = Global.gamvesFamily.familyImage
            self.makeRounded(imageView:self.familyPhotoImageView)

            self.sonNameTextField.text = Global.gamvesFamily.sonsUsers[0].name
            self.sonUserTextField.text = Global.gamvesFamily.sonsUsers[0].userName
            
            self.yourNameTextField.text = Global.gamvesFamily.youUser.name
            self.yourUserTextField.text = Global.gamvesFamily.youUser.userName
            
            self.yourFamilyTextField.text = Global.gamvesFamily.familyName
            
            self.spouseNameTextField.text = Global.gamvesFamily.spouseUser.name
            self.spouseEmailTextField.text = Global.gamvesFamily.spouseUser.email
            
            let type = Global.gamvesFamily.sonsUsers[0].typeNumber

            var typeDesc = String()
            
            if type == 2
            {
                typeDesc = "Son"
            } else if type == 3
            {
                typeDesc = "Daughter"
            }
            self.sonUserTypeTextField.text = typeDesc            
            
            self.sonSchoolTextField.text = Global.gamvesFamily.school          
            
            self.sonGradeTextField.text = Global.gamvesFamily.sonsUsers[0].levelDescription
            
            print(Global.gamvesFamily.youUser.typeNumber)
            
            self.yourTypeId = Global.gamvesFamily.youUser.typeNumber

        }
    }

    func scrollViewGoTop() {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: false)
    }
    
    func hideShowTabBar(status: Bool)
    {
        tabBarController?.tabBar.isHidden = status
        
        if status
        {
            navigationController?.navigationBar.tintColor = UIColor.white
        } 
    }

    func loadAdminRole() {
        
        let roleQuery = PFRole.query()
        
        roleQuery?.whereKey("name", equalTo: "admin")
        
        roleQuery?.getFirstObjectInBackground(block: { (role, error) in
            
            print(error)
            
            if error == nil
            {
                self.adminRole = role as! PFRole
            
            }
        })

    }

    func loadSchools(completionHandler : @escaping (_ user:Bool) -> ()) {
        
        let querySchool = PFQuery(className:"Schools")
        
        querySchool.findObjectsInBackground(block: { (schools, error) in
            
            if error == nil
            {
                if let schools = schools
                {
                    var countSchools = schools.count
                    var count = 0
                    
                    for school in schools
                    {
                        let schoolDesc = school["name"] as! String
                        self.schoolsArray.add(schoolDesc)
                        
                        if count == (countSchools - 1)
                        {
                            completionHandler(true)
                        }
                        count = count + 1
                    }
                }
            }
        })
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let editTextPosition = textField.frame.maxY
        
        print(editTextPosition)
        
        self.scrollView.setContentOffset(CGPoint(x:0, y:editTextPosition), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }


    func boyConstraints() {
        
         print(metricsProfile)       

        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.photosContainerView)  
        self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.segmentedControl) 

        self.photosContainerView.addConstraintsWithFormat(
            "H:|-padding-[v0(photoSize)]-padding-[v1(photoSize)]-padding-|", views: 
            self.sonPhotoImageView, 
            self.familyPhotoImageView, 
            metrics: metricsProfile)

        //self.photosContainerView.addConstraintsWithFormat(
        //    "H:|-photoSize-[v0(photoSize)]-photoSize-|", views: 
        //    self.sonPhotoImageView, metrics: metricsProfile)

        self.sonPhotoImageView.isHidden    = false
        self.familyPhotoImageView.isHidden    = false

        self.yourPhotoImageView.isHidden    = true
        self.spousePhotoImageView.isHidden  = true
        
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.sonPhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.familyPhotoImageView)

        self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.sonNameContainerView)
        self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.sonSchoolContainerView)

        self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.saveButton) 
        self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.bottomView)                 

        self.scrollView.addConstraintsWithFormat(
            "V:|-topPadding-[v0(photoSize)]-topPadding-[v1(40)]-20-[v2(photoContainerHeight)]-20-[v3(schoolContainerHeight)]-30-[v4(saveButtonHeight)][v5(50)]|", views: 
            self.photosContainerView, 
            self.segmentedControl, 
            self.sonNameContainerView, 
            self.sonSchoolContainerView, 
            self.saveButton, 
            self.bottomView,
            metrics: metricsProfile)
        
        print(metricsProfile)

        self.sonNameContainerView.addConstraintsWithFormat("H:|-10-[v0]-5-|", views: self.sonNameTextField)
        self.sonNameContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.sonNameSeparatorView)        
        self.sonNameContainerView.addConstraintsWithFormat("H:|-10-[v0]-5-|", views: self.sonUserTextField)
        self.sonNameContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.sonUserSeparatorView)       
        self.sonNameContainerView.addConstraintsWithFormat("H:|-10-[v0]-5-|", views: self.sonPasswordTextField)         

        self.sonNameContainerView.addConstraintsWithFormat(
            "V:|[v0(photoEditTextHeight)][v1(2)][v2(photoEditTextHeight)][v3(2)][v4(photoEditTextHeight)]|", 
            views: 
            self.sonNameTextField, 
            self.sonNameSeparatorView, 
            self.sonUserTextField,
            self.sonUserSeparatorView,            
            self.sonPasswordTextField,
            metrics: metricsProfile)       

        self.sonSchoolContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.sonUserTypeTextField)
        self.sonSchoolContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.sonUserTypeSeparatorView)        
        self.sonSchoolContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.sonSchoolTextField)
        self.sonSchoolContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.sonSchoolSeparatorView)    
        self.sonSchoolContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.sonGradeTextField)    

        self.sonSchoolContainerView.addConstraintsWithFormat(
            "V:|[v0(schoolEditTextHeight)][v1(2)][v2(schoolEditTextHeight)][v3(2)][v4(schoolEditTextHeight)]|", 
            views: 
            self.sonUserTypeTextField, 
            self.sonUserTypeSeparatorView, 
            self.sonSchoolTextField,          
            self.sonSchoolSeparatorView,          
            self.sonGradeTextField,          
            metrics: metricsProfile)
    }

    func familyConstraints() {
        
        self.sonPhotoImageView.isHidden       = true
        self.familyPhotoImageView.isHidden    = true

        self.yourPhotoImageView.isHidden    = false
        self.spousePhotoImageView.isHidden  = false

        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.yourPhotoImageView)
        self.photosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.spousePhotoImageView)

        self.photosContainerView.addConstraintsWithFormat(
            "H:|-padding-[v0(photoSize)]-padding-[v1(photoSize)]-padding-|", views: 
            self.yourPhotoImageView, 
            self.spousePhotoImageView, 
            metrics: metricsProfile)

        self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.yourNameContainerView)
        self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.spouseContainerView) 

        self.scrollView.addConstraintsWithFormat(
            "V:|-topPadding-[v0(photoSize)]-topPadding-[v1(40)]-20-[v2(photoContainerHeight)]-20-[v3(schoolContainerHeight)]-20-[v4(saveButtonHeight)][v5(50)]|", views: 
            self.photosContainerView, 
            self.segmentedControl, 
            self.yourNameContainerView, 
            self.spouseContainerView, 
            self.saveButton, 
            self.bottomView,
            metrics: metricsProfile)        

        self.yourNameContainerView.addConstraintsWithFormat("H:|-10-[v0]-5-|", views: self.yourNameTextField)
        self.yourNameContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.yourNameSeparatorView)        
        self.yourNameContainerView.addConstraintsWithFormat("H:|-10-[v0]-5-|", views: self.yourUserTextField)
        self.yourNameContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.yourUserSeparatorView)       
        self.yourNameContainerView.addConstraintsWithFormat("H:|-10-[v0]-5-|", views: self.yourFamilyTextField)            

        self.yourNameContainerView.addConstraintsWithFormat(
            "V:|[v0(photoEditTextHeight)][v1(2)][v2(photoEditTextHeight)][v3(2)][v4(photoEditTextHeight)]|", 
            views: 
            self.yourNameTextField, 
            self.yourNameSeparatorView, 
            self.yourUserTextField,
            self.yourUserSeparatorView,            
            self.yourFamilyTextField,
            metrics: metricsProfile)       

        self.spouseContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.spouseNameTextField)
        self.spouseContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.spouseNameSeparatorView)        
        self.spouseContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.spouseEmailTextField)
        self.spouseContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.spouseEmailSeparatorView)    
        self.spouseContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.spousePasswordTextField)    

        self.spouseContainerView.addConstraintsWithFormat(
            "V:|[v0(schoolEditTextHeight)][v1(2)][v2(schoolEditTextHeight)][v3(2)][v4(schoolEditTextHeight)]|", 
            views: 
            self.spouseNameTextField, 
            self.spouseNameSeparatorView, 
            self.spouseEmailTextField,          
            self.spouseEmailSeparatorView,          
            self.spousePasswordTextField,          
            metrics: metricsProfile)
    }

    func handleSegmentedChange() {
        
        if self.segmentedControl.selectedSegmentIndex == 0
        {
            self.prepTextFields(inView: [self.sonNameContainerView])

            self.sonNameContainerView.isHidden = false
            self.sonSchoolContainerView.isHidden = false

            self.boyConstraints()     

            self.yourNameContainerView.isHidden = true
            self.spouseContainerView.isHidden = true

            self.saveButton.setTitle("Save son or doughter", for: UIControlState())

        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            
            self.prepTextFields(inView: [self.yourNameContainerView,self.spouseContainerView])

            self.sonNameContainerView.isHidden = true
            self.sonSchoolContainerView.isHidden = true

            self.familyConstraints()

            self.yourNameContainerView.isHidden = false
            self.spouseContainerView.isHidden = false

            self.saveButton.setTitle("Save family", for: UIControlState())
            
        }    
    }


    func loadSonDataIfFamilyDontExist() {
        
        let family_exist = Global.defaults.bool(forKey: "family_exist")
        let son_exist = Global.defaults.bool(forKey: "son_exist")
        
        Global.defaults.synchronize()

        if son_exist && !family_exist
        {

            self.activityIndicatorView?.startAnimating()

            let queryUser = PFUser.query()
            
            let son_object_id = Global.defaults.string(forKey: "son_object_id")

            queryUser?.whereKey("objectId", equalTo: son_object_id)          
            
            queryUser?.findObjectsInBackground { (users, error) in
                
                if error != nil
                {
                    print("error")
                } else {
                    
                    if let users = users
                    {
                        let userAmount = users.count
                        for user in users {
                            
                            self.son = user as! PFUser
                           
                            self.sonPhotoImage = self.loadImageFromDisc(imageName: self.sonImageName)
                            self.sonPhotoImageView.image = self.sonPhotoImage
                            self.makeRounded(imageView:self.sonPhotoImageView)
                            
                            self.familyPhotoImage = self.loadImageFromDisc(imageName: self.familyImageName)
                            self.familyPhotoImageView.image = self.familyPhotoImage
                            self.makeRounded(imageView:self.familyPhotoImageView)
                            
                            self.sonNameTextField.text = user["Name"] as! String

                            self.sonUserTextField.text = user["username"] as! String
                            
                            self.sonTypeId = user["userType"] as! Int
                            
                            let sonUserType = user["userType"] as! Int
                            
                            var sType = String()
                            
                            if sonUserType == 2 {
                                sType = "Son"
                            } else if sonUserType == 3 {
                                sType = "Daughter"
                            }
                            
                            self.sonUserTypeTextField.text = sType
                            
                            if Global.isKeyPresentInUserDefaults(key: "son_school") {
                            
                                let son_school = Global.defaults.string(forKey: "son_school")
                            
                                self.sonSchoolTextField.text = son_school
                            }
                            
                            let levelRel:PFRelation = user.relation(forKey: "level")
                            
                            let queryLevel:PFQuery = levelRel.query()
                            
                            queryLevel.findObjectsInBackground(block: { (levelObjects, error) in
                                
                                
                                if error != nil
                                {
                                    print("error")
                                    
                                } else {
                                    
                                    for levels in levelObjects!
                                    {
                                        
                                        let grade = levels["grade"] as! Int
                                        let description = levels["description"] as! String
                                        
                                        self.sonGradeTextField.text = "\(grade) - \(description)"
                                        
                                        self.activityIndicatorView?.stopAnimating()
                                        
                                        self.segmentedControl.selectedSegmentIndex = 1
                                        self.segmentedControl.setEnabled(true, forSegmentAt: 1)
                                        self.handleSegmentedChange()
            
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    } 
    
    func storeImgeLocally(imagePath: String, imageToStore:UIImage) {
        
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imagePath).png"
        
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        do {
            try? UIImagePNGRepresentation(imageToStore)?.write(to: imageUrl)
        } catch {
            
        }
    }

    
    func loadImageFromDisc(imageName: String) -> UIImage {
        
        var imageLoaded = UIImage()
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        if FileManager.default.fileExists(atPath: imagePath),
            let imageData: Data = try? Data(contentsOf: imageUrl),
            let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
            
            imageLoaded = image
        }
        return imageLoaded
    }

    func handleSave()
    {
        
        self.activityIndicatorView?.startAnimating()

        if self.segmentedControl.selectedSegmentIndex == 0
        {              

            if !checkForSonErrors()
            {
                Global.defaults.set(self.sonNameTextField.text!, forKey: "son_name")
                Global.defaults.set(self.sonUserTextField.text!, forKey: "son_username")
                Global.defaults.set(self.sonPasswordTextField.text!, forKey: "son_password")

                Global.defaults.set(self.sonUserTypeTextField.text!, forKey: "son_type")
                Global.defaults.set(self.sonSchoolTextField.text!, forKey: "son_school")
                Global.defaults.set(self.sonGradeTextField.text!, forKey: "son_grade")

                Global.defaults.synchronize()

                self.saveSon(completionHandler: { ( result ) -> () in
                    

                    if result
                    {
                        self.activityIndicatorView?.stopAnimating()
                        self.segmentedControl.setEnabled(true, forSegmentAt: 1)
                        self.segmentedControl.selectedSegmentIndex = 1
                        self.handleSegmentedChange()
                        self.scrollViewGoTop()

                    }

                })
                
            } else 
            {
                 self.activityIndicatorView?.stopAnimating()
            }

        } else if self.segmentedControl.selectedSegmentIndex == 1
        {
       
            if !checkForFamilyErrors()
            {
                
                Global.defaults.set(self.yourUserTextField.text!, forKey: "your_username")
                Global.defaults.set(self.yourFamilyTextField.text!, forKey: "your_family_name")

                Global.defaults.set(self.spouseNameTextField.text!, forKey: "spouse_username")
                Global.defaults.set(self.spouseEmailTextField.text!, forKey: "spouse_email")
                Global.defaults.set(self.spousePasswordTextField.text!, forKey: "spouse_password")
                
                Global.defaults.synchronize()

                self.saveSpouse(completionHandler: { ( resutl ) -> () in

                    if resutl
                    {                        

                        DispatchQueue.main.async()
                        {
                            self.saveFamilyImagesToServer(completionHandlerFamilySave: { ( resutl ) -> () in

                                self.activityIndicatorView?.stopAnimating() 

                                self.hideShowTabBar(status:false)   
                                self.tabBarViewController?.selectedIndex = 0

                                Global.defaults.set(true, forKey: "profile_completed")
                                
                                NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: self)
                                
                                ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in })

                            })
                        }          
                    
                    } else 
                    {
                        print("error")    
                    }
                })

            }  else 
            {
                 self.activityIndicatorView?.stopAnimating()
            }
        }
   }
    
    
    func logOutLogIn(username:String, password: String, completionHandler : @escaping (_ user:PFUser) -> ())
    {
        
        
        PFUser.logOutInBackground { (error) in
        
            
            if error == nil {
                
                // Defining the user object
                PFUser.logInWithUsername(inBackground: username, password: password, block: {(user, error) -> Void in
                    
                    if let error = error as NSError?
                    {
                        print(error)
                        
                    } else
                    {
                        print(user?.username)
                        completionHandler(user!)
                    }
                })
                
            } else {
                print(error)
            }
        }
    }

   

   func checkForSonErrors() -> Bool
    {
        var errors = false
        let title = "Error"
        var message = ""

        if self.sonPhotoImage == nil
        {
            errors = true
            message += "Son image is empty please add a picture with the + button"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)

        } else if self.familyPhotoImage == nil
        { 
            errors = true
            message += "Family image is empty please add a picture with the + button"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)

        } else if (self.sonNameTextField.text?.isEmpty)!
        {
            errors = true
            message += "Son name is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.sonNameTextField)
            
        } else if (self.sonUserTextField.text?.isEmpty)!
        {
            errors = true
            message += "Son user name is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.sonUserTextField)
            
        } else if (self.sonPasswordTextField.text?.isEmpty)!
        {
            errors = true
            message += "Password is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.sonPasswordTextField)
            
        }
        else if (self.sonPasswordTextField.text?.characters.count)! < 8
        {
            errors = true
            message += "Password must be at least 8 characters"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.sonPasswordTextField)
        }
        else if (self.sonUserTypeTextField.text?.isEmpty)!
        {
            errors = true
            message += "Type is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.sonUserTypeTextField)
            
        }
        else if (self.sonSchoolTextField.text?.isEmpty)!
        {
            errors = true
            message += "School is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.sonSchoolTextField)
            
        }
        else if (self.sonGradeTextField.text?.isEmpty)!
        {
            errors = true
            message += "Son grades is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.sonGradeTextField)
            
        }
        return errors
    }

    func checkForFamilyErrors() -> Bool
    {
        var errors = false
        let title = "Error"
        var message = ""

        if self.yourPhotoImage == nil
        {
            errors = true
            message += "Your image is empty please add a picture with the + button"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)

        } else if (self.yourNameTextField.text?.isEmpty)!
        {
            errors = true
            message += "Your name is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.yourNameTextField)
            
        } else if (self.yourUserTextField.text?.isEmpty)!
        {
            errors = true
            message += "Your user name is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.yourUserTextField)
            
        } else if (self.yourFamilyTextField.text?.isEmpty)!
        {
            errors = true
            message += "The family name is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.yourFamilyTextField)
            
        }

        var hasSpouse = Bool()

        if (!(self.spouseNameTextField.text?.isEmpty)!)
        {
            hasSpouse = true
        }


        if hasSpouse
        {

            if self.spousePhotoImage == nil
            {
                errors = true
                message += "Your spouse image is empty please add a picture with the + button"
                Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)

            } else if (spouseEmailTextField.text?.isEmpty)!
            {
                errors = true
                message += "Email is empty"
                Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.spouseEmailTextField)
                
                self.spouseEmailTextField.becomeFirstResponder()
            }
            else if !Global.isValidEmail(test: self.spouseEmailTextField.text!)
            {
                errors = true
                message += "Invalid Email Address"
                Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.spouseEmailTextField)
                
            } else if (self.spousePasswordTextField.text?.isEmpty)!
            {
                errors = true
                message += "Spouse password is empty"
                Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.spousePasswordTextField)
                
            }
            else if (self.spousePasswordTextField.text?.characters.count)! < 8
            {
                errors = true
                message += "Spouse password must be at least 8 characters"
                Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.spousePasswordTextField)
            }

        }

        return errors
        
    }


   func saveSon(completionHandler : @escaping (_ resutl:Bool) -> ())
   {

        let son_name = Global.defaults.string(forKey: "son_name")
        let son_user_name = Global.defaults.string(forKey: "son_username")
        let son_password = Global.defaults.string(forKey: "son_password")
    
        let full_name = son_name?.components(separatedBy: " ")

        self.son = PFUser()
        self.son["Name"]  = son_name
        self.son.username = son_user_name
        self.son.password = son_password
        self.son["firstName"] = full_name?[0]
        self.son["lastName"] = full_name?[1]
        self.son["isRegister"] = false
    
        let son_type = Global.defaults.string(forKey: "son_type")
        if son_type == "Son"
        {
            self.son["userType"] = 2
            
        } else if son_type == "Daughter"
        {
            self.son["userType"] = 3
        }   

        let levelRel:PFRelation = self.son.relation(forKey: "level")
        var son_grade:String = Global.defaults.string(forKey: "son_grade") as! String
    
        print(son_grade)
    
        for lv in Global.levels {
            
            if lv.fullDesc == son_grade {
        
                levelRel.add(lv.levelObj!)
            }
        }
    
        self.storeImgeLocally(imagePath: self.sonImageName, imageToStore: self.sonPhotoImage)
    
        self.storeImgeLocally(imagePath: self.familyImageName, imageToStore: self.familyPhotoImage)
    
        self.son.signUpInBackground {
            (success, error) -> Void in

            if let error = error as NSError? {
                
                let errorString = error.userInfo["error"] as? NSString
                completionHandler(false)

            } else {
                
                Global.defaults.set(true, forKey: "son_exist")
                Global.defaults.set(self.son.objectId, forKey: "son_object_id")
                Global.defaults.synchronize()

                //PERMISSIONS
                let acl = PFACL(user: self.son!)
                 
                acl.setWriteAccess(true, for: self.adminRole)
                acl.setReadAccess(true, for: self.adminRole)
                 
                self.adminRole.users.add(self.son!)
                 
                self.adminRole.saveInBackground(block: { (resutl, error) in
                 
                     print("")
                     
                     if error != nil
                     {
                        completionHandler(false)
                     } else {
                        completionHandler(true)
                     }
                 })
            }
        }
   }
    

   func saveSpouse(completionHandler : @escaping (_ resutl:Bool) -> ())
   {            

        let spouse_username = Global.defaults.string(forKey: "spouse_username")
        let spouse_password = Global.defaults.string(forKey: "spouse_password")
        let spouse_email = Global.defaults.string(forKey: "spouse_email")
    
        let spouseUser = PFUser()
        spouseUser["Name"]  = spouse_username
        spouseUser.email = spouse_email
        spouseUser.username = spouse_email
        spouseUser.password = spouse_password

        let full_name = spouse_username?.components(separatedBy: " ")

        spouseUser["firstName"] = full_name?[0]
        spouseUser["lastName"] = full_name?[1]
    
        if self.yourTypeId == 5 //"Father"
        {
            spouseUser["userType"] = 1
            
        } else if self.yourTypeId == 0 //"Mother"
        {
            spouseUser["userType"] = 5
        } 

        spouseUser["isRegister"] = false
    
        let levelRel:PFRelation = spouseUser.relation(forKey: "level")
        var son_grade:String = Global.defaults.string(forKey: "son_grade") as! String
    
        print(son_grade)
    
        for lv in Global.levels {
            
            if lv.fullDesc == son_grade {
                
                levelRel.add(lv.levelObj!)
                
            }
        }

        spouseUser.signUpInBackground {
            (success, error) -> Void in

            if let error = error as NSError? {
                
                let errorString = error.userInfo["error"] as? NSString
                
                print(errorString)
                
                completionHandler(false)

            } else {
                
                self.spouse = spouseUser
                
                Global.defaults.set(self.spouse.objectId, forKey: "spouse_object_id")
                
                Global.defaults.synchronize()
                
                //PERMISSIONS 
                
                let acl = PFACL(user: self.spouse!)
                
                acl.setWriteAccess(true, for: self.adminRole)
                acl.setReadAccess(true, for: self.adminRole)
                
                self.adminRole.users.add(self.spouse!)
                
                self.adminRole.saveInBackground(block: { (resutl, error) in
                    
                    print("")
                    
                    if error != nil
                    {
                        completionHandler(false)
                    } else {
                        completionHandler(true)
                    }
                    
                })
                
            }
        }
    }   
  

    func saveFamilyImagesToServer(completionHandlerFamilySave : @escaping (_ resutl:Bool) -> ())
    {
        
        self.saveYou(completionHandler: { ( resutl ) -> () in

            print("YOU SAVED")

            if resutl
            {
                self.saveFamily(completionHandler: { ( resutl ) -> () in

                    print("FAMILY SAVED")
                    
                    Global.defaults.setHasProfileInfo(value: true)

                    var queue = TaskQueue()

                    var gYou = GamvesParseUser()
                    var gSpouse = GamvesParseUser()
                    var gSon = GamvesParseUser()

                    if Global.userDictionary[self.you.objectId!] != nil {
                        Global.userDictionary[self.you.objectId!]?.gamvesUser = self.you                        
                        gYou = Global.userDictionary[self.you.objectId!]!                        
                    }


                    if self.yourPhotoImage != nil {
                        
                        ///SAVE SON
                        
                        if self.sonPhotoImage != nil
                        {
                            
                            queue.tasks +=~ { resutl, next in
                                
                                self.saveUserImages(id: 1, completionHandler: { ( resutl ) -> () in
                                    
                                    if resutl
                                    {
                                        
                                        Global.addUserToDictionary(user: self.son as! PFUser, isFamily: true, completionHandler: { ( sonGamvesUser ) -> () in
                                            
                                            
                                            if sonGamvesUser != nil
                                            {
                                                
                                                sonGamvesUser.gamvesUser = self.son
                                                
                                                gSon = sonGamvesUser
                                                
                                                var youSon = [GamvesParseUser]()
                                                
                                                youSon.append(gYou)
                                                youSon.append(gSon)
                                                
                                                ChatMethods.addNewFeedAppendgroup(gamvesUsers: youSon, chatId: self.sonChatId, completionHandler: { ( result ) -> () in
                                                    
                                                    print("done youSon")
                                                    
                                                    if (resutl != nil) {
                                                        next(nil)
                                                    }
                                                })
                                            }
                                        })
                                    }
                                })
                            }
                        }
                        
                        //SAVE SPOUSE
                        
                        if self.spousePhotoImage != nil {
                            
                            queue.tasks +=~ { resutl, next in
                                
                                
                                self.saveUserImages(id: 2, completionHandler: { ( resutl ) -> () in
                                    
                                    if resutl
                                    {

                                        Global.addUserToDictionary(user: self.spouse as! PFUser, isFamily: true, completionHandler: { ( spouseGamvesUser ) -> () in


                                            if spouseGamvesUser != nil
                                            {
                                                
                                                spouseGamvesUser.gamvesUser = self.spouse
                                                
                                                gSpouse = spouseGamvesUser
                                                
                                                var youSpouse = [GamvesParseUser]()

                                                youSpouse.append(gYou)
                                                youSpouse.append(gSpouse)

                                                ChatMethods.addNewFeedAppendgroup(gamvesUsers: youSpouse, chatId: self.spouseChatId, completionHandler: { ( result ) -> () in

                                                    print("done youSpouse")

                                                    if (resutl != nil)
                                                    {                                               
                                                        next(nil)
                                                    }

                                                })
                                            }
                                        })
                                    }
                                })
                            }
                        }

                        //SAVE FAMILY
                        
                        queue.tasks +=~ {
                            
                            print("FINISH")
                            
                            let your_email = Global.defaults.string(forKey: "your_email")
                            let your_password = Global.defaults.string(forKey: "your_password")
                            
                            self.logOutLogIn(username: your_email!, password: your_password!, completionHandler: { ( user ) -> () in
                                
                                
                                print("BACK AGAIN LOGIN AS: \(PFUser.current()?.username)")

                                    var youSpouseSon = [GamvesParseUser]()                                  
                                   
                                    youSpouseSon.append(gYou)
                                    youSpouseSon.append(gSpouse)
                                    youSpouseSon.append(gSon)

                                    ChatMethods.addNewFeedAppendgroup(gamvesUsers: youSpouseSon, chatId: self.familyChatId, completionHandler: { ( result ) -> () in

                                        print("done youSpouseSon")

                                        if (resutl != nil)
                                        {                                                                                                                                                                                    
                                         
                                            completionHandlerFamilySave(true)
                                        }

                                    })
                            })
                        }
                        queue.run()
                    }

                })
            }
        })
    }

    func saveYou(completionHandler : @escaping (_ resutl:Bool) -> ())
    {
        
        let your_email = Global.defaults.string(forKey: "your_email")
        let your_password = Global.defaults.string(forKey: "your_password")
                        
        self.logOutLogIn(username: your_email!, password: your_password!, completionHandler: { ( user ) -> () in
            
            print(user.username)
            
            self.you = user                   
            
            var reusername = self.you["firstName"] as! String
            reusername = reusername.lowercased()

            let yourimage = PFFile(name: reusername, data: UIImageJPEGRepresentation(self.yourPhotoImage, 1.0)!)
            user.setObject(yourimage!, forKey: "picture")
            
            let yourImgName = "\(reusername)_small"
            
            print("--------------")
            print(yourImgName)
            print("--------------")
            
            let yourimageSmall = PFFile(name: yourImgName, data: UIImageJPEGRepresentation(self.yourPhotoImageSmall, 1.0)!)
            self.you.setObject(yourimageSmall!, forKey: "pictureSmall")

            let levelRel:PFRelation = self.you.relation(forKey: "level")
            var son_grade:String = Global.defaults.string(forKey: "son_grade") as! String
        
            for lv in Global.levels {
                
                if lv.fullDesc == son_grade {
                    
                    levelRel.add(lv.levelObj!)
                    
                }
            }
            
            self.you.saveInBackground(block: { (resutl, error) in
                
                if error != nil
                {
                    print(error)
                    completionHandler(false)
                } else
                {

                    Global.addUserToDictionary(user: self.you as! PFUser, isFamily: true, completionHandler: { ( gamvesUser ) -> () in

                        completionHandler(true)

                    })
                }
            })
        })
    }

    func saveFamily(completionHandler : @escaping (_ resutl:Bool) -> ())
    {
        let your_family_name = Global.defaults.string(forKey: "your_family_name")
        
        var family = PFObject(className: "Family")
        family.setObject(your_family_name, forKey: "description")
        
        let userRel:PFRelation = family.relation(forKey: "members")
        
        print("*************")
        print(self.spouse.username)
        print(self.son.username)
        print(self.you.username)
        print("*************")
        
        userRel.add(self.spouse!)
        userRel.add(self.son!)
        userRel.add(self.you!)

        family["familyChatId"]  = self.familyChatId
        family["sonChatId"]     = self.sonChatId
        family["spouseChatId"]  = self.spouseChatId

        let imageFamily = self.familyPhotoImage

        let pfimage = PFFile(name: "family", data: UIImageJPEGRepresentation(imageFamily!, 1.0)!)
        family.setObject(pfimage!, forKey: "picture")

        let imageFamilySmall = self.familyPhotoImageSmall

        let pfimageSmall = PFFile(name: "familySmall", data: UIImageJPEGRepresentation(imageFamilySmall!, 1.0)!)
        family.setObject(pfimageSmall!, forKey: "pictureSmall")
        
        family.saveInBackground { (success, error) in
            
            print(success)
            print(error)
            
            if error != nil
            {
                print(error)
                completionHandler(false)
            }
            else
            {

                Global.gamvesFamily.familyName = your_family_name!
               
                Global.gamvesFamily.sonChatId = self.sonChatId
                Global.gamvesFamily.spouseChatId = self.spouseChatId
                Global.gamvesFamily.familyChatId = self.familyChatId

                Global.gamvesFamily.familyImage = self.familyPhotoImageSmall
                
                Global.defaults.set(true, forKey: "family_exist")
                completionHandler(true)             
               
            }
        }   
    }  
    
    

    
    func saveUserImages(id: Int, completionHandler : @escaping (_ resutl:Bool) -> ())
    {
        
        var _user = PFUser()
        var image = UIImage()
        var imageSmall = UIImage()
        
        var username = String()
        var password = String()
        
        switch id
        {
            
            case 0:
                
                _user = self.you
                
                image = self.yourPhotoImage
                imageSmall = self.yourPhotoImageSmall
                
                username = Global.defaults.string(forKey: "your_email")!
                password = Global.defaults.string(forKey: "your_password")!
                
                break
                
             case 1:
                
                _user = self.son
                
                image = self.sonPhotoImage
                imageSmall = self.sonPhotoImageSmall
                
                username = Global.defaults.string(forKey: "son_username")!
                password = Global.defaults.string(forKey: "son_password")!
                
                break
                
            case 2:
                
                _user = self.spouse
                
                image = self.spousePhotoImage
                imageSmall = self.spousePhotoImageSmall
                
                username = Global.defaults.string(forKey: "spouse_email")!
                password = Global.defaults.string(forKey: "spouse_password")!
                
                break
                
            default:
                break
        }
        
        var name = _user["firstName"] as! String
        name = name.lowercased()
        
        let pfimage = PFFile(name: name, data: UIImageJPEGRepresentation(image, 1.0)!)
        _user.setObject(pfimage!, forKey: "picture")
        
        let usernamesmall = "\(name)_small"
        
        let pfimagesmall = PFFile(name: usernamesmall, data: UIImageJPEGRepresentation(imageSmall, 1.0)!)
        _user.setObject(pfimagesmall!, forKey: "pictureSmall")
        
        self.logOutLogIn(username: username, password: password, completionHandler: { ( user ) -> () in
            
            print(_user.username)
            
            _user.saveInBackground { (resutl, error) in
                
                if error != nil
                {
                    
                    print(error)
                    
                    completionHandler(false)
                }
                else {
                    
                    print(resutl)
                    
                    completionHandler(true)
                    
                }
            }
            
        })  
        
        
    } 

   
    func handlePhotoImageView(sender: UITapGestureRecognizer)
    {
        
        self.selectedImageView = (sender.view as? UIImageView)!
     
        let ac = UIAlertController(title: "Select Input", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        ac.addAction(cancelAction)
         
        ac.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
             
        }))
         
        ac.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
             
        }))        
         
        let popover = ac.popoverPresentationController        
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any
         
        present(ac, animated: true, completion: nil)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage 
        {           

            imageCropVC = RSKImageCropViewController(image: image)
            imageCropVC.delegate = self
            navigationController?.pushViewController(imageCropVC, animated: true)  
        }

        picker.dismiss(animated: true, completion: nil);
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
         let imageLow = croppedImage.lowestQualityJPEGNSData as Data
         var smallImage = UIImage(data: imageLow)
        
        self.selectedImageView.image = croppedImage

        if self.selectedImageView.tag == 0 
        {             
            self.yourPhotoImageView.image   = croppedImage
            self.yourPhotoImage             = croppedImage
            self.yourPhotoImageSmall        = smallImage
            self.makeRounded(imageView:self.yourPhotoImageView)

        } else if selectedImageView.tag == 1
        {
            self.sonPhotoImageView.image    = croppedImage
            self.sonPhotoImage              = croppedImage
            self.sonPhotoImageSmall         = smallImage
            self.makeRounded(imageView:self.sonPhotoImageView)                

        } else if selectedImageView.tag == 2
        {
            self.spousePhotoImageView.image    = croppedImage
            self.spousePhotoImage              = croppedImage
            self.spousePhotoImageSmall         = smallImage
            self.makeRounded(imageView:self.spousePhotoImageView)                
        
        } else if selectedImageView.tag == 3
        {
            self.familyPhotoImageView.image    = croppedImage
            self.familyPhotoImage              = croppedImage
            self.familyPhotoImageSmall         = smallImage
            self.makeRounded(imageView:self.familyPhotoImageView)                
        }
        
        navigationController?.popViewController(animated: true)
        
    
    }

    
    func makeRounded(imageView:UIImageView)
    {
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2            
        imageView.clipsToBounds = true         
        imageView.layer.borderColor = UIColor.gamvesBlackColor.cgColor
        imageView.layer.borderWidth = 3
    }  
   
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let y: CGFloat = UIDevice.current.orientation.isLandscape ? -100 : -50
            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    
    }

    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }    

}
