//


//  ProfileViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 9/26/17.
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
    RSKImageCropViewControllerDelegate,
    ProfileImagesPickerProtocol  
{

    var accountViewController:AccountViewController!
  
    var imageCropVC = RSKImageCropViewController()

    var tabBarViewController:TabBarViewController?
    
    var types = Dictionary<Int, PFObject>()
    
    var adminRole:PFRole!
   
    var son:PFUser!
    var you:PFUser!
    var spouse:PFUser!
    
    var youGamves = GamvesUser()
    var sonGamves = GamvesUser()
    var spouseGamves = GamvesUser()
    
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

    var schoolsArray: NSMutableArray = []
 
    var familyChatId            = Int()
    var sonRegisterChatId       = Int()
    var spouseRegisterChatId    = Int()
    var sonSpouseChatId         = Int()
    var youAdminChatId          = Int()
    var sonAdminChatId          = Int()
    var spouseAdminChatId       = Int()
    
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
        tf.tag = 1
        return tf
    }()

    let sonUserSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var birthDate = String()

    let sonPassBirthContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true        
        return view
    }()  

    let sonUserVerticalSeparatorView: UIView = {
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
        tf.tag = 2
        return tf
    }()

    let sonBirthdayTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Birthday"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.addTarget(self, action: #selector(showDatePicker), for: UIControlEvents.touchDown)        
        tf.tag = 2
        return tf
    }()

    let datePicker = UIDatePicker()

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
        //tf.text = "LedaOlano"
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
    
    var sonNameContainerViewHeightAnchor: NSLayoutConstraint?
    
    var sonSaving = Bool()

    var puserId = String()

    var photoEditTextHeight = Int()
    
    override func viewDidLoad() {        
        super.viewDidLoad() 
       
        let buttonIcon = UIImage(named: "arrow_back_white")        
        let leftBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButton(sender:)))
        leftBarButton.image = buttonIcon        
        self.navigationItem.leftBarButtonItem = leftBarButton   

        self.navigationItem.title = "Profile"
        
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
        self.sonNameContainerView.addSubview(self.sonPassBirthContainerView) 

        self.sonPassBirthContainerView.addSubview(self.sonPasswordTextField)   
        self.sonPassBirthContainerView.addSubview(self.sonUserVerticalSeparatorView)   
        self.sonPassBirthContainerView.addSubview(self.sonBirthdayTextField)            

        let sons: NSMutableArray = ["Son", "Daughter"]
        self.sonUserTypeDownPicker = DownPicker(textField: sonUserTypeTextField, withData:sons as! [Any])
        sonUserTypeDownPicker.setPlaceholder("Tap to choose relationship...")  

        self.sonSchoolContainerView.addSubview(self.sonUserTypeTextField)
        self.sonSchoolContainerView.addSubview(self.sonUserTypeSeparatorView)   
        self.sonSchoolContainerView.addSubview(self.sonSchoolTextField)
        self.sonSchoolContainerView.addSubview(self.sonSchoolSeparatorView)        
        self.sonSchoolContainerView.addSubview(self.sonGradeTextField)        
        
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
        photoEditTextHeight = photoContainerHeight / 3  

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

        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)//, x: 0, y: 0, width: 80.0, height: 80.0)
       
        self.familyChatId           = Global.getRandomInt()
        self.sonRegisterChatId      = Global.getRandomInt()
        self.spouseRegisterChatId   = Global.getRandomInt()
        self.sonSpouseChatId        = Global.getRandomInt()

        self.youAdminChatId        = Global.getRandomInt()
        self.sonAdminChatId        = Global.getRandomInt()
        self.spouseAdminChatId        = Global.getRandomInt()        
        
        if PFUser.current() != nil {
            self.son = PFUser.current()
        }   

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }

        if !Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_profile_completed") {  
        
            NotificationCenter.default.addObserver(self, selector: #selector(self.familyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.levelsLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyLevelsLoaded), object: nil)                   
            
        }
        
        if Global.familyLoaded {
            self.familyLoaded()            
        }
        
        if Global.levelsLoaded {
            self.levelsLoaded()
        }
        
        if Global.familyDataGromGlobal {
            self.loadFamilyDataGromGlobal()
       }

        self.boyConstraints()

    }

    func backButton(sender: UIBarButtonItem) {

        self.hideShowTabBar(hidden:false)

        self.navigationController?.popViewController(animated: true)
    }

    func showDatePicker(){
       
        datePicker.datePickerMode = .date       
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
       
        //let doneButton = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.bordered, target: self, action: "donedatePicker")
        //let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        //let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.bordered, target: self, action: "cancelDatePicker")
        //toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)        
        //self.sonBirthdayTextField.inputAccessoryView = toolbar         

        self.sonBirthdayTextField.inputView = datePicker

    }

    func donedatePicker(){
    
       let formatter = DateFormatter()
       formatter.dateFormat = "dd/MM/yyyy"
       
       self.sonBirthdayTextField.text = formatter.string(from: datePicker.date)

       let dateFormatterParse = DateFormatter()
       dateFormatterParse.dateFormat = "yyyy-MM-dd" //"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
       self.birthDate = dateFormatterParse.string(from: datePicker.date)
    
       self.view.endEditing(true) 
   }

    func cancelDatePicker(){
   
        self.view.endEditing(true)          
    }

    
    func didpickImage(type:ProfileImagesTypes, smallImage:UIImage, croppedImage:UIImage)  {
     
        var id = Int()

        switch type {
            
            case .Son: 
                    id = 1
                break
            
            case .Family:
                    id = 3                
                break

            case .You:
                    id = 0               
                break

             case .Spouse:               
                    id = 2
                break    
            
            default: break
            
        }

        self.applyImageById(id:id, croppedImage: croppedImage, smallImage: smallImage)

    }
    
    func levelsLoaded() {
        
        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }

        if !Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_profile_completed") {
            
            self.tabBarController?.tabBar.isHidden = true
            
            if Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_son_userId") {
                
                self.loadSonSpouseDataIfFamilyDontExist()
                
                self.segmentedControl.setEnabled(true, forSegmentAt: 1)
                
            } else {
                
                self.segmentedControl.setEnabled(false, forSegmentAt: 1)
            }
            
        } else {
            
            self.yourTypeId = PFUser.current()?["iDUserType"] as! Int
            
            DispatchQueue.main.async() {
                self.makeRounded(imageView:self.yourPhotoImageView)
                self.makeRounded(imageView:self.sonPhotoImageView)
                self.makeRounded(imageView:self.spousePhotoImageView)
                self.makeRounded(imageView:self.familyPhotoImageView)
            }
            
            self.segmentedControl.setEnabled(true, forSegmentAt: 1)

            print(self.yourTypeId)


            if self.yourTypeId == Global.REGISTER_FATHER || self.yourTypeId == Global.REGISTER_MOTHER {

                self.spousePasswordTextField.isEnabled = false
                self.spouseNameTextField.isEnabled = false
                self.spouseEmailTextField.isEnabled = false

            } 

            self.boyConstraints()               
            
        }
        
        Global.loadSchools(completionHandler: { ( user, schoolsArray ) -> () in

            self.schoolsArray = schoolsArray
            
            self.sonSchoolDownPicker = DownPicker(textField: self.sonSchoolTextField, withData:self.schoolsArray as! [Any])
            self.sonSchoolDownPicker.setPlaceholder("Tap to choose school...")
            self.sonSchoolDownPicker.addTarget(self, action: #selector(self.handleSchoolPickerChange), for: .valueChanged)
        })     

        //Populate empty so loaded when school selected
        let grades: NSMutableArray = [] 
        self.setGrades(grades: grades)
        self.sonGradeDownPicker.setPlaceholder("Tap to choose grade...") 
        
        self.you = PFUser.current()
        self.setGrades(grades: grades)
    }

    func setGrades(grades: NSMutableArray) {

        print(grades)
        
        self.sonGradeDownPicker = DownPicker(textField: self.sonGradeTextField, withData:grades as! [Any])            
    }

    func handleSchoolPickerChange() {

        self.sonGradeTextField.text = ""

        let grades: NSMutableArray = [] 
        
        let lkeys = Array(Global.levels.keys)
        
        for l in lkeys {

            let schoolId = Global.levels[l]?.schoolId

            if self.sonSchoolTextField.text! == Global.schools[schoolId!]?.schoolName {

                grades.add(Global.levels[l]?.fullDesc)
            }
            
        }        
        
        self.setGrades(grades: grades)
    }
    
    func familyLoaded() {

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }
        
        if Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_profile_completed")
        {
            let profile_completed = Global.defaults.bool(forKey: "\(self.puserId)_profile_completed")
            
            if profile_completed
            {
                self.hideShowTabBar(hidden:false)
                self.loadFamilyDataGromGlobal()
                self.segmentedControl.setEnabled(true, forSegmentAt: 1)
            }
            
        } else
        {

            self.hideShowTabBar(hidden:true)
            
        }
    }
    
    func loadFamilyDataGromGlobal()
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
            let spousemeail = Global.gamvesFamily.spouseUser.email
            
            print(spousemeail)
            
            self.spouseEmailTextField.text = spousemeail
            
            let type = Global.gamvesFamily.sonsUsers[0].typeNumber
            
            var typeDesc:String = Global.getTypeDescById(id: type)
            
            self.sonUserTypeTextField.text = typeDesc
            
            let school = Global.gamvesFamily.schoolName
            
            self.sonSchoolTextField.text = school
            
            self.sonGradeTextField.text = Global.gamvesFamily.sonsUsers[0].levelDescription
            
            self.yourTypeId = PFUser.current()?["iDUserType"] as! Int //Global.gamvesFamily.youUser.typeNumber
          
        }
    }


    func scrollViewGoTop() {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: false)
    }
    
    func hideShowTabBar(hidden: Bool)
    {
        self.tabBarController?.tabBar.isHidden = hidden
        
        if hidden
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let editTextPosition = textField.frame.maxY
        
        print(editTextPosition)
        
        self.scrollView.setContentOffset(CGPoint(x:0, y:editTextPosition), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)

        if textField == self.sonNameTextField {

            let son_name = self.sonNameTextField.text

            let trimmedName = son_name?.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
            
            self.sonUserTextField.text = trimmedName?.lowercased()
        }
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

        self.sonPhotoImageView.isHidden    = false
        self.familyPhotoImageView.isHidden = false

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
        self.sonNameContainerView.addConstraintsWithFormat("H:|-10-[v0]-5-|", views: self.sonPassBirthContainerView)         

        self.sonNameContainerView.addConstraintsWithFormat(
            "V:|[v0(photoEditTextHeight)][v1(2)][v2(photoEditTextHeight)][v3(2)][v4]|", 
            views: 
            self.sonNameTextField, 
            self.sonNameSeparatorView, 
            self.sonUserTextField,
            self.sonUserSeparatorView,            
            self.sonPassBirthContainerView,
            metrics: metricsProfile)     

        let width = self.view.frame.width
        let moduleWidth = Int((width / 2) + 40)
        let moduleheight = photoEditTextHeight - 5
        let moduleMetrics = ["moduleWidth":moduleWidth, "moduleheight":moduleheight]

        self.sonPassBirthContainerView.addConstraintsWithFormat("V:|[v0(moduleheight)]|", views: self.sonPasswordTextField, metrics: moduleMetrics)
        self.sonPassBirthContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.sonUserVerticalSeparatorView, metrics: moduleMetrics)
        self.sonPassBirthContainerView.addConstraintsWithFormat("V:|[v0(moduleheight)]|", views: self.sonBirthdayTextField, metrics: moduleMetrics)
        
        self.sonPassBirthContainerView.addConstraintsWithFormat("H:|[v0(moduleWidth)]-2-[v1(2)]-10-[v2]|", views: 
            self.sonPasswordTextField, 
            self.sonUserVerticalSeparatorView,
            self.sonBirthdayTextField,
            metrics: moduleMetrics)

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

        ///////
        
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

        self.segmentedControl.selectedSegmentIndex = 0
        self.handleSegmentedChange()
    }

   
    @objc func handleSegmentedChange() {
        
        if self.segmentedControl.selectedSegmentIndex == 0
        {
            self.prepTextFields(inView: [self.sonNameContainerView])
           
            self.sonNameContainerView.isHidden = false
            self.sonSchoolContainerView.isHidden = false

            self.yourNameContainerView.isHidden = true
            self.spouseContainerView.isHidden = true    

            self.sonPhotoImageView.isHidden       = false
            self.familyPhotoImageView.isHidden    = false

            self.yourPhotoImageView.isHidden    = true
            self.spousePhotoImageView.isHidden  = true            

            self.saveButton.setTitle("Save son or doughter", for: UIControlState())

        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            
            self.prepTextFields(inView: [self.yourNameContainerView,self.spouseContainerView])

            self.sonNameContainerView.isHidden = true
            self.sonSchoolContainerView.isHidden = true

            self.yourNameContainerView.isHidden = false
            self.spouseContainerView.isHidden = false    

            self.sonPhotoImageView.isHidden       = true
            self.familyPhotoImageView.isHidden    = true

            self.yourPhotoImageView.isHidden    = false
            self.spousePhotoImageView.isHidden  = false                        
            
            self.saveButton.setTitle("Save family", for: UIControlState())
            
        }    
    }


    func loadSonSpouseDataIfFamilyDontExist() {

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }
        
        let son_userId = Global.defaults.string(forKey: "\(self.puserId)_son_userId")
        
        let querySon = PFQuery(className:"_User")
        querySon.whereKey("objectId", equalTo: son_userId)
        
        querySon.getFirstObjectInBackground(block: { (userSon, error) in
            
            if error == nil {
                
                Global.addUserToDictionary(user: userSon as! PFUser, isFamily: true, completionHandler: { (gamvesUser) in
                    
                    self.sonGamves = gamvesUser
                    
                })
            }
        })

        
        let family_exist = Global.defaults.bool(forKey: "\(self.puserId)_family_exist")
        let son_exist = Global.defaults.bool(forKey: "\(self.puserId)_son_exist")
        
        Global.defaults.synchronize()

        if son_exist && !family_exist
        {

            self.activityIndicatorView?.startAnimating()

            let queryUser = PFUser.query()
            
            let son_object_id = Global.defaults.string(forKey: "\(self.puserId)_son_object_id")

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
                           
                            self.sonPhotoImage = self.loadImageFromDisc(imageName: Global.sonImageName)
                            self.sonPhotoImageView.image = self.sonPhotoImage
                            self.makeRounded(imageView:self.sonPhotoImageView)
                            
                            self.sonPhotoImageSmall = self.loadImageFromDisc(imageName: Global.sonImageNameSmall)
                            
                            self.familyPhotoImage = self.loadImageFromDisc(imageName: Global.familyImageName)
                            self.familyPhotoImageView.image = self.familyPhotoImage
                            self.makeRounded(imageView:self.familyPhotoImageView)
                            
                            self.familyPhotoImage = self.loadImageFromDisc(imageName: Global.familyImageName)
                            self.familyPhotoImageSmall = self.loadImageFromDisc(imageName: Global.familyImageNameSmall)
                            
                            self.sonNameTextField.text = user["Name"] as! String
                            self.sonUserTextField.text = user["username"] as! String                            
                            
                            self.sonTypeId = user["iDUserType"] as! Int
                            let sonUserType = user["iDUserType"] as! Int
                            
                            var sType = String()
                            
                            if sonUserType == Global.SON {
                                sType = "Son"
                            } else if sonUserType == Global.DAUGHTER {
                                sType = "Daughter"
                            }
                            
                            self.sonUserTypeTextField.text = sType
                            
                            if Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_son_school") {
                            
                                let son_school = Global.defaults.string(forKey: "\(self.puserId)_son_school")
                                self.sonSchoolTextField.text = son_school
                            }
                            
                            // level Id
                            
                            let levelRel:PFRelation = user.relation(forKey: "level")
                            
                            let queryLevel:PFQuery = levelRel.query()
                            queryLevel.findObjectsInBackground(block: { (levelObjects, error) in
                                
                                if error != nil {
                                    print("error")
                                } else {
                                    
                                    for levels in levelObjects! {
                                        
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

    @objc func handleSave(sender: UIButton)
    {
        DispatchQueue.main.async() {
            self.activityIndicatorView?.startAnimating()
        }
        
        sender.isUserInteractionEnabled = false

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }

        if self.segmentedControl.selectedSegmentIndex == 0 {
            
            self.yourTypeId = PFUser.current()?["iDUserType"] as! Int

            let name = PFUser.current()?["Name"] as! String
        
            self.yourNameTextField.text = name        

            let trimmedName = name.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
            
            self.yourUserTextField.text = trimmedName.lowercased()

            if !checkForSonErrors() {
                
                Global.defaults.set(self.sonNameTextField.text!, forKey: "\(self.puserId)_son_name")
                Global.defaults.set(self.sonUserTextField.text!, forKey: "\(self.puserId)_son_username")
                Global.defaults.set(self.sonPasswordTextField.text!, forKey: "\(self.puserId)_son_password")
                Global.defaults.set(self.sonBirthdayTextField.text!, forKey: "\(self.puserId)_son_birthday")

                Global.defaults.set(self.sonUserTypeTextField.text!, forKey: "\(self.puserId)_son_type")
                Global.defaults.set(self.sonSchoolTextField.text!, forKey: "\(self.puserId)_son_school")
                Global.defaults.set(self.sonGradeTextField.text!, forKey: "\(self.puserId)_son_grade")

                Global.defaults.synchronize()
                
                if !self.sonSaving {

                    self.saveSon(completionHandler: { ( result ) -> () in
                        
                        if result {
                            
                            self.activityIndicatorView?.stopAnimating()
                            self.segmentedControl.setEnabled(true, forSegmentAt: 1)
                            self.segmentedControl.selectedSegmentIndex = 1
                            self.handleSegmentedChange()
                            self.scrollViewGoTop()
                            
                            self.sonSaving = false

                            sender.isUserInteractionEnabled = true

                            //aca

                            DispatchQueue.main.async() {

                                Global.loadConfigData()

                                self.hideShowTabBar(hidden: true)

                                self.accountViewController.showImagePicker(type: ProfileImagesTypes.You)

                            }

                        }
                    })
                }
                
            } else {
                 self.activityIndicatorView?.stopAnimating()
            }

        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            
            self.you = PFUser.current()
       
            if !checkForFamilyErrors() {
                
                Global.defaults.set(self.yourUserTextField.text!, forKey: "\(self.puserId)_your_username")
                Global.defaults.set(self.yourFamilyTextField.text!, forKey: "\(self.puserId)_your_family_name")

                Global.defaults.set(self.spouseNameTextField.text!, forKey: "\(self.puserId)_spouse_username")
                Global.defaults.set(self.spouseEmailTextField.text!, forKey: "\(self.puserId)_spouse_email")
                Global.defaults.set(self.spousePasswordTextField.text!, forKey: "\(self.puserId)_spouse_password")
                
                Global.defaults.synchronize()

                self.saveSpouse(completionHandler: { ( resutl ) -> () in

                    if resutl {
                        
                        print("SPOUSE SAVED")
                        
                        DispatchQueue.main.async() {
                    
                            self.saveYou(completionHandler: { ( resutl ) -> () in
                                
                                print("YOU SAVED")
                                
                                if resutl {
                                    
                                    self.saveFamily(completionHandler: { ( resutl ) -> () in
                                        
                                        if resutl {
                                            
                                            self.createChatGroups(completionHandlerChatGroups: { ( resutl ) -> () in
                                                
                                                if resutl {
                                                
                                                    print("GROUPS CREATED")
                                                    
                                                    self.hideShowTabBar(hidden:true)

                                                    self.tabBarViewController?.selectedIndex = 0
                                                    
                                                    //Global.defaults.set(true, forKey: "\(self.puserId)_profile_completed")  
                                                    
                                                    Global.getFamilyData(completionHandler: { ( result:Bool ) -> () in
                                                        
                                                        ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in                                                 
                                                            
                                                            // REGISTRATION COMPLETED

                                                            Global.defaults.set(false, forKey: "\(self.puserId)_fortnite_completed") 
                                                            Global.defaults.set(false, forKey: "\(self.puserId)_fortnite_skipped")

                                                            let title = "Congratulations Registration Completed!"
                                                            var message = "\n\nThanks very much for registering to Gamves. You can share the app with your family! \n\n"
                                                            
                                                            //message = message + "Fortnite users\n\n" 

                                                            //message = message +  "Before you start using Gamves please provide one las optional information about Fortnite, otherwise you can complete it later."
                                                            
                                                            let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
                                                            
                                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                                                                
                                                                self.activityIndicatorView?.stopAnimating()
                                                                self.navigationController?.popViewController(animated: true)

                                                                self.hideShowTabBar(hidden:false)
                                                                
                                                            }))

                                                            /*alert.addAction(UIAlertAction(title: "Fornite", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in                                                                                                                                      
                                                                
                                                                let fortniteViewController = FortniteViewController()
                                                                fortniteViewController.isRegistering = true
                                                                self.navigationController?.pushViewController(fortniteViewController, animated: true)
                                                                
                                                            }))*/
                                                            
                                                            self.present(alert, animated: true)                                                     
                                                            
                                                        })                                                        
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
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
    

    func checkForSonErrors() -> Bool {
        
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
            
        } else if (self.sonPasswordTextField.text?.characters.count)! < 8
        {
            errors = true
            message += "Password must be at least 8 characters"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.sonPasswordTextField)

        } else if (self.sonBirthdayTextField.text?.isEmpty)!
        {
            errors = true
            message += "Birthday is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.sonBirthdayTextField)
            
        } else if (self.sonUserTypeTextField.text?.isEmpty)!
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
        
        if errors {

            DispatchQueue.main.async() {
                self.activityIndicatorView?.stopAnimating()
            }
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

        if (!(self.spouseNameTextField.text?.isEmpty)!) {
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

        if errors {
            DispatchQueue.main.async() {
                self.activityIndicatorView?.stopAnimating()
            }
        }

        return errors
        
    }
    
    func saveSon(completionHandler : @escaping (_ resutl:Bool) -> ()) {
        
        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }
        
        let son_name        = Global.defaults.string(forKey: "\(self.puserId)_son_name")
        let son_user_name   = Global.defaults.string(forKey: "\(self.puserId)_son_username")
        let son_password    = Global.defaults.string(forKey: "\(self.puserId)_son_password")
        //let son_birthday  = Global.defaults.string(forKey: "\(self.puserId)_son_birthday")
        let son_type        = Global.defaults.string(forKey: "\(self.puserId)_son_type")
        
        var type = Int()
        if son_type == "Son" {
            type = Global.SON
        } else if son_type == "Daughter" {
            type = Global.DAUGHTER
        }
        let userTypeObj:PFObject = (Global.userTypes[type]?.userTypeObj)!
    
        var son_grade:String = Global.defaults.string(forKey: "\(self.puserId)_son_grade") as! String
        
        var levelObj:PFObject!
        let lkeys = Array(Global.levels.keys)
        for l in lkeys {
            let level = Global.levels[l]
            if level?.fullDesc == son_grade {
                levelObj = (level?.levelObj)!
                
                if let levelObjId = levelObj.objectId {
                
                    PFPush.subscribeToChannel(inBackground: levelObjId)
                }
            }
        }
        
        Global.storeImgeLocally(imagePath: Global.sonImageName, imageToStore: self.sonPhotoImage)
        Global.storeImgeLocally(imagePath: Global.sonImageNameSmall, imageToStore: self.sonPhotoImageSmall)
        
        Global.storeImgeLocally(imagePath: Global.familyImageName, imageToStore: self.familyPhotoImage)
        Global.storeImgeLocally(imagePath: Global.familyImageNameSmall, imageToStore: self.familyPhotoImageSmall)
        
        let dataPhotoImage = self.sonPhotoImage.highQualityJPEGNSData
        let dataPhotoImageSmall = self.sonPhotoImageSmall.highQualityJPEGNSData
        
        let imageUniverse = UIImage(named: "universe")
        let dataPhotoUniverse = imageUniverse?.highQualityJPEGNSData
        
        let full_name = son_name?.components(separatedBy: " ")
        let firstName = full_name?[0]
        let lastName = full_name?[1]
        
        var short = String()

        let skeys = Array(Global.schools.keys)
        for s in skeys {
            let school = Global.schools[s]
            if self.sonSchoolTextField.text == school?.schoolName {
                Global.gamvesFamily.school = school!
                short = (school?.short)!
            }
        }
        
        let schoolId:String! = Global.gamvesFamily.school.objectId
        
        let sonParams = [
            "user_name" : son_user_name?.lowercased(),
            "user_password" : son_password,
            "user_birthday" : self.birthDate,
            "firstName" : firstName,
            "lastName" : lastName,
            "iDUserType" : type,
            "levelObj": levelObj.objectId,
            "userTypeObj": userTypeObj.objectId,
            "short": short,
            "dataPhotoImage": dataPhotoImage,
            "dataPhotoImageSmall": dataPhotoImageSmall,
            "dataPhotoBackground": dataPhotoUniverse
            ] as [String : Any]
        
        print(sonParams)
        
        PFCloud.callFunction(inBackground: "createGamvesUser", withParameters: sonParams) { (result, error) in
         
            if error == nil {
                
                print(result)
                
                self.son = result as! PFUser
                
                Global.defaults.set(self.son.objectId, forKey: "\(self.puserId)_son_userId")
                
                Global.addUserToDictionary(user: self.son as! PFUser, isFamily: true, completionHandler: { (gamvesUser) in
                    
                    self.sonGamves = gamvesUser
                    
                    Global.defaults.set(true, forKey: "\(self.puserId)_son_exist")
                    
                    if let sonObjectId = self.son.objectId {
                        
                        print(sonObjectId)
                        Global.defaults.set(sonObjectId, forKey: "\(self.puserId)_son_object_id")
                        Global.defaults.synchronize()
                    }
                    
                    completionHandler(true)
                })
                
            } else {
                
                 print(error)
                 completionHandler(false)
            }
        }
    }
    
    func saveSpouse(completionHandler : @escaping (_ resutl:Bool) -> ()) {
        
        let spouse_username = Global.defaults.string(forKey: "\(self.puserId)_spouse_username")
        let spouse_password = Global.defaults.string(forKey: "\(self.puserId)_spouse_password")
        let spouse_email = Global.defaults.string(forKey: "\(self.puserId)_spouse_email")
        
        let full_name = spouse_username?.components(separatedBy: " ")
        let firstName = full_name?[0]
        let lastName = full_name?[1]
        
        var type = Int()
        print(self.yourTypeId)


        if self.yourTypeId == Global.REGISTER_FATHER { //"Father" {
        
            type = Global.SPOUSE_MOTHER
            print(type)

        } else if self.yourTypeId == Global.REGISTER_MOTHER { //"Mother" {

            type = Global.SPOUSE_FATHER
            print(type)            
                
        } 


        let userTypeObj:PFObject = (Global.userTypes[type]?.userTypeObj)!
        
        //I add the level of all sons
        var levelObj:PFObject!
        
        let levleId = self.sonGamves.levelId
        
        for sons in Global.gamvesFamily.sonsUsers {
            let levelId = sons.levelId
            levelObj = Global.levels[levelId]?.levelObj
        }
        
        Global.storeImgeLocally(imagePath: Global.spouseImageName, imageToStore: self.spousePhotoImage)
        Global.storeImgeLocally(imagePath: Global.spouseImageNameSmall, imageToStore: self.spousePhotoImageSmall)
        
        let dataPhotoImage = self.spousePhotoImage.highQualityJPEGNSData
        let dataPhotoImageSmall = self.spousePhotoImageSmall.highQualityJPEGNSData
        
        let imageUniverse = UIImage(named: "universe")
        let dataPhotoUniverse = imageUniverse?.highQualityJPEGNSData
        
        let momParams = [
            "user_name" : spouse_email,
            "user_password" : spouse_password,
            "user_email" : spouse_email,
            "firstName" : firstName,
            "lastName" : lastName,
            "iDUserType" : type,
            "levelObj": levelObj.objectId,
            "userTypeObj": userTypeObj.objectId,
            "dataPhotoImage": dataPhotoImage,
            "dataPhotoImageSmall": dataPhotoImageSmall,
            "dataPhotoBackground": dataPhotoUniverse
            ] as [String : Any]

            print(momParams)
        
        PFCloud.callFunction(inBackground: "createGamvesUser", withParameters: momParams) { (result, error) in
            
            if error == nil {
                
                print(result)
                
                self.spouse = result as! PFUser
                
                Global.addUserToDictionary(user: self.spouse as! PFUser, isFamily: true, completionHandler: { (gamvesUser) in
                    
                    print(self.spouse["Name"])
                    
                    self.spouseGamves = gamvesUser
                    
                    Global.defaults.set(true, forKey: "spouse_exist")
                    Global.defaults.set(self.spouse.objectId, forKey: "spouse_object_id")
                    
                    Global.defaults.synchronize()

                    
                    completionHandler(true)
                })
                
            } else {
                
                var nsError:NSError = error as! NSError
                
                let errorCode = nsError.code
                
                switch errorCode {
                case 209:
                    print("invalid session token")
                    break
                default:
                    break
                }
                
                print(errorCode)
                
                completionHandler(false)
            }
            
        }
        
    }

  
    func saveYou(completionHandler : @escaping (_ resutl:Bool) -> ())
    {	
        
        let your_email = Global.defaults.string(forKey: "\(self.puserId)_your_email")
        let your_password = Global.defaults.string(forKey: "\(self.puserId)_your_password")
        
        var reusername = self.you["firstName"] as! String
        reusername = reusername.lowercased()
        
        //self.you["email"] = your_email
        //self.you.email = your_email
        
        let yourimage = PFFile(name: reusername, data: UIImageJPEGRepresentation(self.yourPhotoImage, 1.0)!)
        self.you.setObject(yourimage!, forKey: "picture")
        
        let yourImgName = "\(reusername)_small"
        
        print("--------------")
        print(yourImgName)
        print("--------------")
        
        let yourimageSmall = PFFile(name: yourImgName, data: UIImageJPEGRepresentation(self.yourPhotoImageSmall, 1.0)!)
        self.you.setObject(yourimageSmall!, forKey: "pictureSmall")
        
        let profileRelation = self.you.relation(forKey: "profile")
        let profileQuery = profileRelation.query()
        profileQuery.getFirstObjectInBackground { (profilePF, error) in
            
            if error == nil {
                
                var relation = String()
                
                if self.yourTypeId == Global.REGISTER_FATHER {
                    relation = "father"
                } else if self.yourTypeId == Global.SPOUSE_MOTHER {
                    relation = "mother"
                }
                
                let son_name = Global.defaults.string(forKey: "\(self.puserId)_son_name")
                
                profilePF?["bio"] = "\(son_name) \(relation)"
                
                profilePF?.saveEventually()
                
            }
        }
        
    
        let levelRel:PFRelation = self.you.relation(forKey: "level")
        
        //I add the level of all sons
        let levleId = Global.gamvesFamily.sonsUsers[0].levelId as String
        
        for sons in Global.gamvesFamily.sonsUsers {
            let levelId = sons.levelId
            let levelObj = Global.levels[levelId]?.levelObj
            levelRel.add(levelObj!)
        }
        
        self.you.saveInBackground(block: { (resutl, error) in
            
            if error != nil
            {
                print(error)
                completionHandler(false)
            } else
            {
                
                Global.addUserToDictionary(user: self.you as! PFUser, isFamily: true, completionHandler: { ( gamvesUser ) -> () in
                    
                    self.youGamves = gamvesUser
                    
                    completionHandler(true)
                    
                })
            }
        })
        
    }

    func saveFamily(completionHandler : @escaping (_ resutl:Bool) -> ())
    {
        var your_family_name = Global.defaults.string(forKey: "\(self.puserId)_your_family_name")
        
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
        family["sonRegisterChatId"]  = self.sonRegisterChatId
        family["spouseRegisterChatId"]  = self.spouseRegisterChatId
        family["sonSpouseChatId"]  = self.sonSpouseChatId
        
        let imageFamily = self.loadImageFromDisc(imageName: Global.familyImageName)

        let pfimage = PFFile(name: "family", data: UIImageJPEGRepresentation(imageFamily, 1.0)!)
        family.setObject(pfimage!, forKey: "picture")

        let imageFamilySmall = self.loadImageFromDisc(imageName: Global.familyImageNameSmall)
        
        let pfimageSmall = PFFile(name: "familySmall", data: UIImageJPEGRepresentation(imageFamilySmall, 1.0)!)
        family.setObject(pfimageSmall!, forKey: "pictureSmall")

        let skeys = Array(Global.schools.keys)
        for s in skeys {
            let school = Global.schools[s]
            if self.sonSchoolTextField.text == school?.schoolName {
                let schoolRelation = family.relation(forKey: "school")
                schoolRelation.add((school?.schoolOBj)!)
            }
        }    
        
        var son_grade:String = Global.defaults.string(forKey: "\(self.puserId)_son_grade") as! String
        
        print(son_grade)
        
        let levelRel:PFRelation = family.relation(forKey: "level")
        
        let lkeys = Array(Global.levels.keys)
        
        for i in lkeys {
            
            let level = Global.levels[i]
            
            if level?.fullDesc == son_grade {
                
                levelRel.add((level?.levelObj!)!)
            }
        }

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

                print(your_family_name)
                
                Global.gamvesFamily.familyName = your_family_name!
               
                Global.gamvesFamily.sonRegisterChatId = self.sonRegisterChatId
                Global.gamvesFamily.spouseRegisterChatId = self.spouseRegisterChatId
                Global.gamvesFamily.familyChatId = self.familyChatId

                Global.gamvesFamily.familyImage = self.familyPhotoImageSmall
                
                Global.defaults.set(true, forKey: "\(self.puserId)_family_exist")  

                completionHandler(true)  
                
            }                 
        }   
    }   
    
    func createChatGroups(completionHandlerChatGroups : @escaping (_ resutl:Bool) -> ())
    {
        print("FAMILY SAVED")
        
        Global.defaults.setHasProfileInfo(value: true)
        
        var queue = TaskQueue()        
        ///SAVE SON
        
        queue.tasks +=~ { resutl, next in
            
            var youSon = [GamvesUser]()
            
            youSon.append(self.youGamves)
            youSon.append(self.sonGamves)
            
            ChatMethods.addNewFeedAppendgroup(gamvesUsers: youSon, chatId: self.sonRegisterChatId, type: 1, completionHandlerGroup: { ( resutl:Bool ) -> () in
                
                print("done youSon")
                print(resutl)
                if resutl {
                    next(nil)
                }
            })
            
        }
        
        //SAVE SPOUSE
        
        queue.tasks +=~ { resutl, next in
            
            var youSpouse = [GamvesUser]()
            
            youSpouse.append(self.youGamves)
            youSpouse.append(self.spouseGamves)
            
            ChatMethods.addNewFeedAppendgroup(gamvesUsers: youSpouse, chatId: self.spouseRegisterChatId, type: 1, completionHandlerGroup: { ( resutl:Bool ) -> () in
                
                print("done youSpouse")
                print(resutl)
                if (resutl != nil) {
                    next(nil)
                }
                
            })
        }

        
        //SAVE SPOUSE SON
        
        queue.tasks +=~ { resutl, next in
            
            var sonSpouse = [GamvesUser]()
            
            sonSpouse.append(self.sonGamves)
            sonSpouse.append(self.spouseGamves)
            
            ChatMethods.addNewFeedAppendgroup(gamvesUsers: sonSpouse, chatId: self.sonSpouseChatId, type: 1, completionHandlerGroup: { ( resutl:Bool ) -> () in
                
                print("done sonSpouse")
                print(resutl)
                if (resutl != nil) {
                    next(nil)
                }
                
            })
        }

        
        //SAVE FAMILY
        
        queue.tasks +=~ { resutl, next in
            
            var youSpouseSon = [GamvesUser]()
            
            youSpouseSon.append(self.youGamves)
            youSpouseSon.append(self.spouseGamves)
            youSpouseSon.append(self.sonGamves)
            
            ChatMethods.addNewFeedAppendgroup(gamvesUsers: youSpouseSon, chatId: self.familyChatId, type: 1, completionHandlerGroup: { ( resutl:Bool ) -> () in
                
                print("done youSpouseSon")
                print(resutl)
                if (resutl != nil) {
                    next(nil)
                }
                
            })
            
        }

        //SAVE YOU ADMIN
        
        queue.tasks +=~ { resutl, next in
            
            var youAdmin = [GamvesUser]()
            
            youAdmin.append(self.youGamves)
            youAdmin.append(Global.adminUser)
            
            ChatMethods.addNewFeedAppendgroup(gamvesUsers: youAdmin, chatId: self.youAdminChatId, type: 2, completionHandlerGroup: { ( resutl:Bool ) -> () in
                
                print("done youAdmin")
                print(resutl)
                if (resutl != nil) {
                    next(nil)
                }
                
            })
        }

        //SAVE SON ADMIN
        
        queue.tasks +=~ { resutl, next in
            
            var sonAdmin = [GamvesUser]()
            
            sonAdmin.append(self.sonGamves)
            sonAdmin.append(Global.adminUser)
            
            ChatMethods.addNewFeedAppendgroup(gamvesUsers: sonAdmin, chatId: self.sonAdminChatId, type: 2, completionHandlerGroup: { ( resutl:Bool ) -> () in
                
                print("done sonAdmin")
                print(resutl)
                if (resutl != nil) {
                    next(nil)
                }
                
            })
        }

        //SAVE SPOSE ADMIN
        
        queue.tasks +=~ { resutl, next in          
            
            var spouseAdmin = [GamvesUser]()
            
            spouseAdmin.append(self.spouseGamves)
            spouseAdmin.append(Global.adminUser)
            
            ChatMethods.addNewFeedAppendgroup(gamvesUsers: spouseAdmin, chatId: self.spouseAdminChatId, type: 2, completionHandlerGroup: { ( resutl:Bool ) -> () in
                
                print("done spouseAdmin")
                print(resutl)
                if (resutl != nil) {
                    next(nil)
                }               
                
            })
        }

        //Remove User
        
        queue.tasks +=~ {

            print("FINISH")                     

            let userVerifiedQuery = PFQuery(className:"UserVerified")  
            let contained = [self.youGamves.userId, self.sonGamves.userId, self.spouseGamves.userId] 
            userVerifiedQuery.whereKey("userId", containedIn: contained)      
            userVerifiedQuery.findObjectsInBackground { (userVerifiedsPF, error) in
            
                if error == nil
                {
                    for userVerified in userVerifiedsPF! {
                        do {
                           try userVerified.delete()
                        } catch {
                            print("error deleting")
                        }
                    }
                    print("done deleting userVerified")
                    completionHandlerChatGroups(true)
                }
            }
        }
        queue.run()

    }
   
    @objc func handlePhotoImageView(sender: UITapGestureRecognizer)
    {
        
        self.selectedImageView = (sender.view as? UIImageView)!
     
        let actionSheet = UIAlertController(title: "Select Input", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheet.addAction(cancelAction)
         
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
             
        }))
         
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
             
        }))        
         
        let popover = actionSheet.popoverPresentationController        
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any

        // iPad spport
        if Global.device.lowercased().range(of:"ipad") != nil {
            
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = self.view.frame

        }
         
        present(actionSheet, animated: true, completion: nil)

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

        self.applyImageById(id:self.selectedImageView.tag, croppedImage: croppedImage, smallImage: smallImage!)
        
        navigationController?.popViewController(animated: true)
    }

    func applyImageById(id:Int, croppedImage:UIImage, smallImage:UIImage) {

        if id == 0 
        {             
            self.yourPhotoImageView.image   = croppedImage
            self.yourPhotoImage             = croppedImage
            self.yourPhotoImageSmall        = smallImage
            self.makeRounded(imageView:self.yourPhotoImageView)

        } else if id == 1
        {
            self.sonPhotoImageView.image    = croppedImage
            self.sonPhotoImage              = croppedImage
            self.sonPhotoImageSmall         = smallImage
            self.makeRounded(imageView:self.sonPhotoImageView)                

        } else if id == 2
        {
            self.spousePhotoImageView.image    = croppedImage
            self.spousePhotoImage              = croppedImage
            self.spousePhotoImageSmall         = smallImage
            self.makeRounded(imageView:self.spousePhotoImageView)                
        
        } else if id == 3
        {
            self.familyPhotoImageView.image    = croppedImage
            self.familyPhotoImage              = croppedImage
            self.familyPhotoImageSmall         = smallImage
            self.makeRounded(imageView:self.familyPhotoImageView)                
        }

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
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    @objc func keyboardShow() {
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
