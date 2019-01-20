//
//  LoginViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 11/2/17.
//

import UIKit
import Parse
import DownPicker
import BEMCheckBox
import NVActivityIndicatorView
import ParseLiveQuery

class LoginViewController: UIViewController, 
ImagesPickerProtocol {

    let userClient: Client = ParseLiveQuery.Client(server: Global.localWs) // .lremoteWs)

    private var userSubscription: Subscription<PFObject>!

    var verifiedQuery:PFQuery<PFObject>!

    var tabBarViewController:TabBarViewController?
    
    var okLogin = Bool()
    
    var isRegistered = Bool()

    var activityIndicatorView:NVActivityIndicatorView?

   var schoolsArray: NSMutableArray = []
   var schoolShort = String()

   let parents: NSMutableArray = ["Father", "Mother"]  
    
    let explainLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please provide your fullname, emall and password for your new account"
        label.textColor = UIColor.white
        //label.font = UIFont.boldSystemFont(ofSize: 15)
        label.font = UIFont(name: label.font.fontName, size: 13)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 3
        return label
    }()
    
    let backView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.gamvesColor
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    let registerLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.text = "Please ask your parents for registration credentials and come back. They should register first in order to give you access."
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 5
        return label
    }()

    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full name"
        tf.text = "Jose Vigil"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.tag = 0
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.text = "josemanuelvigil@gmail.com"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.tag = 1
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.text = "JoseVigil2016"
        tf.tag = 2
        return tf
    }()

    //var checkBoxView: CheckBoxView!

    let userTypeSeparatorView: UIView = {
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

    //var checkBoxView: CheckBoxView!

    let schoolTypeSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()    
    
    var userTypeDownPicker: DownPicker!
    let userTypeTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false                
        //tf.backgroundColor = UIColor.red
        tf.tag = -1
        return tf
    }()

    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Register", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()

    var isMessage = Bool()
    var isError = Bool()    
    var message = String()
    var containerViewHeight = CGFloat()
    
    var containerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    var sonSchoolTextFieldHeightAnchor: NSLayoutConstraint?
    var userTypeTextFieldHeightAnchor: NSLayoutConstraint?
    var registerLabelHeightAnchor: NSLayoutConstraint?
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mTop:CGFloat        = 30
    let expHeight:CGFloat   = 50
    let scHeight:CGFloat    = 36
    let icHeight:CGFloat    = 160
    let icHeightLogin:CGFloat    = 160
    let cbHeight:CGFloat    = 70
    let lrbHeight:CGFloat   = 60
    
    var metricsDict:[String:Any]!
    
    // Image Picker        

    var imagePickerViewController = ImagePickerViewController()

    var you:PFUser!
    var puserId = String()
    
    var yourPhotoImageView:UIImageView!
    var yourPhotoImage:UIImage!
    var yourPhotoImageSmall:UIImage!

    var yourType:PFObject!
    var yourTypeId = Int()    
    var phoneNumber = String()
    //var eventViewController:EventViewController!

    var navigationPickerController:UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }
        
        self.view.backgroundColor = UIColor.gamvesColor
        
        self.view.addSubview(self.backView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.backView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.backView)
        
        self.backView.backgroundColor = UIColor.gamvesColor
        
        self.backView.addSubview(explainLabel)
        self.backView.addSubview(loginRegisterSegmentedControl)
        self.backView.addSubview(containerView)
        self.backView.addSubview(registerLabel)
        self.backView.addSubview(loginRegisterButton)
        self.backView.addSubview(bottomView)
        
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -24).isActive = true
        
        containerViewHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: icHeight)
        containerViewHeightAnchor?.isActive = true
        
        self.metricsDict = [String:Any]()
        
        self.metricsDict["mTop" ] = mTop
        self.metricsDict["expHeight" ] = expHeight
        self.metricsDict["scHeight" ] = scHeight
        self.metricsDict["icHeight" ] = icHeight
        self.metricsDict["lrbHeight" ] = lrbHeight

        backView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.explainLabel)
        backView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.loginRegisterSegmentedControl)
        
        backView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.loginRegisterButton)
        backView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)
        
        self.backView.addConstraintsWithFormat(
            "V:|-mTop-[v0(expHeight)]-10-[v1(scHeight)]-10-[v2(icHeight)]-10-[v3(lrbHeight)][v4]|", 
            views: self.explainLabel, 
            self.loginRegisterSegmentedControl, 
            self.containerView,
            self.loginRegisterButton, 
            self.bottomView,
            metrics: metricsDict)
        
        containerView.addSubview(nameTextField)
        containerView.addSubview(nameSeparatorView)
        containerView.addSubview(emailTextField)
        containerView.addSubview(emailSeparatorView)        
        containerView.addSubview(passwordTextField)        
        containerView.addSubview(userTypeSeparatorView)
        containerView.addSubview(userTypeTextField)

        containerView.addSubview(schoolTypeSeparatorView)
        containerView.addSubview(sonSchoolTextField)
        
        //Name
        nameTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        
        //Name Separator
        nameSeparatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Email
        emailTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        
        //Email Separator
        emailSeparatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Password
        passwordTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        passwordTextFieldHeightAnchor?.isActive = true  

        //need x, y, width, height constraints
        userTypeSeparatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        userTypeSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        userTypeSeparatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        userTypeSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
      
        //need x, y, width, height constraints
        userTypeTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        userTypeTextField.topAnchor.constraint(equalTo: userTypeSeparatorView.bottomAnchor).isActive = true        
        userTypeTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        userTypeTextFieldHeightAnchor = userTypeTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        userTypeTextFieldHeightAnchor?.isActive = true

         //need x, y, width, height constraints
        schoolTypeSeparatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        schoolTypeSeparatorView.topAnchor.constraint(equalTo: userTypeTextField.bottomAnchor).isActive = true
        schoolTypeSeparatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        schoolTypeSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        schoolTypeSeparatorView.isHidden = true      

        //School
        sonSchoolTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        sonSchoolTextField.topAnchor.constraint(equalTo: schoolTypeSeparatorView.bottomAnchor).isActive = true                    
        sonSchoolTextFieldHeightAnchor = sonSchoolTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        sonSchoolTextFieldHeightAnchor?.isActive = true  
        sonSchoolTextField.isHidden = true          
        
        self.userTypeDownPicker = DownPicker(textField: self.userTypeTextField, withData: self.parents as! [Any])
        
        self.userTypeTextFieldHeightAnchor = self.userTypeTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/4)
        
        userTypeDownPicker.setPlaceholder("Tap to choose relationship...")                 
        
        //Register Message
        registerLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        registerLabel.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        registerLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        registerLabel.backgroundColor = UIColor.gambesDarkColor
        registerLabel.frame.size.width = registerLabel.intrinsicContentSize.width - 40
        registerLabel.textAlignment = .center
        registerLabel.isHidden = true
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        self.prepTextFields(inView: [self.nameTextField, self.emailTextField, self.passwordTextField])
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)//, x: 0, y: 0, width: 80.0, height: 80.0)
        
        //let deadlineTime = DispatchTime.now() + 2
        //DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        //    self.firstTFBecomeFirstResponder(view: self.view)
        //}
        
        if self.isRegistered {
            self.loginRegisterSegmentedControl.selectedSegmentIndex = 0
            self.handleLoginRegisterChange()
        } 
        
        Global.loadSchools(completionHandler: { ( user, schoolsArray ) -> () in
            
            self.schoolsArray = schoolsArray
            
            self.sonSchoolDownPicker = DownPicker(textField: self.sonSchoolTextField, withData:self.schoolsArray as! [Any])
            self.sonSchoolDownPicker.setPlaceholder("Tap to choose school...")
            self.sonSchoolDownPicker.addTarget(self, action: #selector(self.handleSchoolPickerChange), for: .valueChanged)

        })      

        self.checkVerified()

    }

    @objc func handleSchoolPickerChange() {        

        let sKeys = Array(Global.schools.keys)
        
        for s in sKeys {

            let schoolId = Global.schools[s]!.objectId

            if self.sonSchoolTextField.text! == Global.schools[schoolId]?.schoolName {

                self.schoolShort = Global.schools[schoolId]!.short

                print(self.schoolShort)
            }            
        }                       
    }


    func initializeChatSubscription() {

        if let userId = PFUser.current()?.objectId {
            
            print(userId)
        
            self.verifiedQuery = PFQuery(className: "UserVerified").whereKey("userId", equalTo: userId)

            self.userSubscription = userClient.subscribe(self.verifiedQuery).handle(Event.updated) { _, verifiedPF in
                
                print(verifiedPF.objectId)

                let vuserId = verifiedPF["userId"] as! String
                    
                if vuserId == userId {

                    let verified = verifiedPF["emailVerified"] as! Bool

                    if verified {

                        DispatchQueue.main.async {
                        
                            self.loginRegisterButton.setTitle("Mail verified! Continue", for: UIControlState())
                            self.loginRegisterButton.isEnabled = true
                            //self.loginRegisterButton.alpha = 1
                        }
                    }
                }               
            }
        }
    }


    func checkVerified() {

        if let userId = PFUser.current()?.objectId {
        
            let queryUserVerified = PFQuery(className: "UserVerified")                               

                queryUserVerified.whereKey("userId", equalTo: userId)

                queryUserVerified.getFirstObjectInBackground(block: { (userVerified, error) in
                    
                    if error == nil {
                        
                        if userVerified?["emailVerified"] != nil {
                        
                            if userVerified?["emailVerified"] as! Bool  == true {
                                
                                self.loginRegisterButton.setTitle("Mail verified! Continue", for: UIControlState())
                                self.loginRegisterButton.isEnabled = true
                                
                            } else {
                                
                                
                            }
                            
                        } else {
                            
                            
                        }

                    } else {
                        print(error)
                    }
                })               
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        //logoImageView.isHidden = true
    }
    
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        //logoImageView.isHidden = false
    }
    
    @objc func handleLoginRegisterChange()
    {
        
        if Reachability.isConnectedToNetwork() == true
        {
            if (!isMessage)
            {
                
                let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
                loginRegisterButton.setTitle(title, for: UIControlState())
                
                if (loginRegisterSegmentedControl.selectedSegmentIndex == 0) {
                    
                    self.showLoginFields()
                    
                } else if (loginRegisterSegmentedControl.selectedSegmentIndex == 1) {                    
                    
                    self.switchToIndex()           
                    
                }
                
                registerLabelHeightAnchor?.isActive = false
                registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
                registerLabelHeightAnchor?.isActive = true
                registerLabel.isHidden = true


                print(self.userTypeTextField.isHidden)
                
            } else {
                
                //self.showLoginFields()
                self.hideShowMessage(bol:true)
                self.isMessage = false
            }
            
        } else {
            
            let title = "Check connection"
            let message = "You are not connected to the Internet, please connect and try again"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
            
            print("Internet connection FAILED")
        }

    }

    func switchToIndex() {

        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = false
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        emailTextField.isHidden = false
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        passwordTextFieldHeightAnchor?.isActive = true
        passwordTextField.isHidden = false        

        sonSchoolTextFieldHeightAnchor?.isActive = false  
        sonSchoolTextFieldHeightAnchor = sonSchoolTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        sonSchoolTextFieldHeightAnchor?.isActive = true
        sonSchoolTextField.isHidden = true  

        self.isRegistered = false        
                    
    }
    
    func showLoginFields() 
    {
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = true
        
        //need x, y, width, height constraints
        schoolTypeSeparatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        schoolTypeSeparatorView.topAnchor.constraint(equalTo: userTypeTextField.bottomAnchor).isActive = true
        schoolTypeSeparatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        schoolTypeSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        schoolTypeSeparatorView.isHidden = false
        
        //School
        sonSchoolTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        sonSchoolTextField.topAnchor.constraint(equalTo: schoolTypeSeparatorView.bottomAnchor).isActive = true
        sonSchoolTextFieldHeightAnchor = sonSchoolTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/4)
        sonSchoolTextFieldHeightAnchor?.isActive = true
        sonSchoolTextField.isHidden = false
        
        self.isRegistered = true
        
    }
    
    @objc func handleLoginRegister()
    {
        if !okLogin
        {        
           
            // THIS BLOCK IS A MESS

             //if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {

                if (self.isError) {

                    if self.loginRegisterButton.titleLabel?.text == "Try again" {                                               

                        self.isMessage = false

                        self.handleLoginRegisterChange()

                        self.clearFields()

                        self.userTypeTextField.isHidden = false

                        if self.loginRegisterSegmentedControl.selectedSegmentIndex == 1 {                          

                            self.nameTextField.becomeFirstResponder() 

                        } else {

                            self.emailTextField.becomeFirstResponder()   
                        }

                        self.handleLoginRegisterChange()                     
                      
                    } else  {

                        self.handleLogin()        
                    }  

                    self.isError = false    

                } else {

                    if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {

                         self.handleLogin()          

                    } else if loginRegisterSegmentedControl.selectedSegmentIndex == 1 {

                        self.handleRegister()

                    }                   

                }

            //} else {
                    
                //self.handleRegister()
            
            //}

            

            
        } else {
            
            /*self.checkVerified(completionHandler: { ( verified ) -> () in

                if verified {
                    
                    self.handleLogin()
                    
                    self.okLogin = false

                } else {

                    self.message="Please verify your email and then Continue."

                    self.registerLabel.text = self.message
                }
            })*/
            
            self.handleLogin()
            
            self.okLogin = false
            
        }
    }

    func clearFields() {

        self.nameTextField.text = ""
        self.nameTextField.placeholder = "Full name"
     
        self.emailTextField.text = ""
        self.emailTextField.placeholder = "Email"

        self.passwordTextField.text = ""
        self.passwordTextField.placeholder = "Password"

        self.userTypeTextField.text = ""                
        self.userTypeTextField.placeholder = "Tap to choose relationship..."  

        self.sonSchoolTextField.text = ""           
        self.sonSchoolDownPicker.setPlaceholder("Tap to choose school...")               
    }

    
    func handleRegister()
    {
        
        if !checkForErrors()
        {

            self.activityIndicatorView?.startAnimating()

            var email = self.emailTextField.text
            let name = self.nameTextField.text
            var password = self.passwordTextField.text
            let relationship = self.userTypeTextField.text
            
            // Defining the user object
            let user = PFUser()
            user.username = email
            user.password = password
            user.email = email
            user["name"] = name
            user["isRegister"] = true

            let full_name = name?.components(separatedBy: " ")

            user["firstName"] = full_name?[0]
            user["lastName"] = full_name?[1]
            
            //let userTypeRel:PFRelation = user.relation(forKey: "userType")
            
            var type = Int()            
            
            if relationship == "Father" {
                type = Global.REGISTER_FATHER
            } else if relationship == "Mother" {
                type = Global.REGISTER_MOTHER
            }
            
            user["user_type"] = type
        
            user.signUpInBackground {
                (success, error) -> Void in
                
                if let error = error as NSError?
                {
                    
                    let errorString = error.userInfo["error"] as? NSString
                    
                    // In case something went                   		wrong...
                    self.message = errorString as! String

                    //self.okLogin = false

                    self.showMessage(title: "Try again", message: self.message)            

                    self.activityIndicatorView?.stopAnimating()
                    
                } else {
                    
                    // Everything went ok
                    //user["userType"] = type
                    
                    self.activityIndicatorView?.stopAnimating()
                    
                    self.message = "An email has been sent to your inbox. Please confirm, once then press the Continue."

                    self.loginRegisterSegmentedControl.isUserInteractionEnabled = false
                    
                    self.okLogin = true
                    self.isRegistered = false
                    
                    self.loginRegisterButton.setTitle("Verify mail befor continuing", for: UIControlState())
                    
                    self.loginRegisterButton.isEnabled = false
                    
                    //self.loginRegisterButton.alpha = 0.30

                    if let userId = PFUser.current()?.objectId
                    {
                        self.puserId = userId
                    }                  
                    
                    Global.defaults.set(email, forKey: "\(self.puserId)_your_email")
                    Global.defaults.set(password, forKey: "\(self.puserId)_your_password")

                    self.initializeChatSubscription()
                    
                    Global.defaults.synchronize()
                    
                    Global.registerInstallationAndRole(completionHandlerRole: { ( resutl ) -> () in
                        
                        if resutl {

                             self.saveNewProfile(completionHandler: { (profile) in
                                
                                let relation:PFRelation = user.relation(forKey: "userType")
                                
                                print(type)
                                
                                let userType = (Global.userTypes[type]?.userTypeObj)!
                                
                                relation.add(userType)
                                
                                let profileRel:PFRelation = user.relation(forKey: "profile")
                                profileRel.add(profile)
                                
                                user.saveInBackground(block: { (resutl, error) in
                                    
                                    if error == nil {                                         
                                        
                                        PFUser.logOut()
                                        
                                    } else {
                                        print(error)
                                    }
                                    
                                })
                                
                             })
                        }
                    })
                }
                
                self.isMessage = true
                self.handleLoginRegisterChange()
            }
        }
    }
    
    func saveNewProfile(completionHandler : @escaping (_ profile:PFObject) -> ())
    {
        
        let profilePF: PFObject = PFObject(className: "Profile")
        
        let backImage = UIImage(named: "universe")
        
        var backimagePF = PFFileObject(name: "background.png", data: UIImageJPEGRepresentation(backImage!, 1.0)!)
        profilePF.setObject(backimagePF, forKey: "pictureBackground")
        
        if let userId = PFUser.current()?.objectId {
            profilePF["userId"] = userId
        }
        
        profilePF["backgroundColor"] = [228, 239, 245]
        
        profilePF.saveInBackground { (resutl, error) in
            
            if error == nil {
                
                 completionHandler(profilePF)
            }
            
        }
        
    }
    
    func handleLogin() {


        //self.dismiss(animated: true, completion: nil)
        //self.tabBarViewController?.selectedIndex = 0 //Home 
     
        self.activityIndicatorView?.startAnimating()   
        
        let email = self.emailTextField.text        
        let password = self.passwordTextField.text
        let userType = self.userTypeTextField.text
        let school = self.sonSchoolTextField.text

        
        print("________________")
        print(email)
        print(password)
        print(userType)
        print(school)
        print("________________")
        
        if (email?.isEmpty)! {
            self.showMessage(title: "Try again", message: "Error, email is empty. Please provide your email and try again.")            
            return
        } 

        if !Global.isMailValid(email: email!) {
            self.showMessage(title: "Try again", message: "Error, email is not valid. Please check your email format and try again.")            
            return
        }      
        
        if (password?.isEmpty)! {
            self.showMessage(title: "Try again", message: "Error, password is empty. Please provide your passowrd and try again.")            
            return
        }

        if (userType?.isEmpty)! {
            self.showMessage(title: "Try again", message: "Error, relation is empty. Please select a relation and try again.")            
            return
        }

        if (loginRegisterSegmentedControl.selectedSegmentIndex == 0) {

            if (school?.isEmpty)! {
                self.showMessage(title: "Try again", message: "Error, school is empty. Please select a relation and try again.")            
                return
            }

        }
        
        // Defining the user object
        PFUser.logInWithUsername(inBackground: email!, password: password!, block: {(user, error) -> Void in
            
            if let error = error as NSError?
            {
                
                if let errorString = error.userInfo["error"] as? NSString {

                    self.showMessage(title: "Try again", message: "Error \(errorString) Please try again.")   
                    return               
                }                
                
            } else {    

                var isVerified = Bool()            
                
                if user?["emailVerified"] != nil {
                
                    let emailVerified = user?["emailVerified"]
                    
                    if emailVerified as! Bool == true {

                        isVerified = true
                        
                        UserDefaults.standard.setIsLoggedIn(value: true)
                        
                        if self.isRegistered {
                            
                            Global.getFamilyData(completionHandler: { ( result:Bool ) -> () in

                                var sonUser:GamvesUser = Global.gamvesFamily.sonsUsers[0]

                                    var son_type = sonUser.typeNumber

                                    var son_school = Global.gamvesFamily.school.schoolName

                                    if (self.loginRegisterSegmentedControl.selectedSegmentIndex == 0) {                                    

                                        var selectedType = Int()
                                        var type = Int()

                                        if userType == "Father" {

                                            // 0 = Father
                                            selectedType = 0

                                        } else if userType == "Mother" { 

                                            // 1 = Mother
                                            selectedType = 1
                                        }

                                        if son_type == 0 || son_type == 1 {

                                            type = 0
                                        }                                        

                                        if selectedType != type && school != son_school {

                                            self.showMessage(title: "Try again", message: "Error, the information you provided is wrong. Please try again.")            
                                            return
                                        }

                                    }
                                
                                Global.loaLevels(completionHandler: { ( result:Bool ) -> () in                              
                                    
                                    UserDefaults.standard.setIsLoggedIn(value: true)
                                    UserDefaults.standard.setIsRegistered(value: true)
                                    
                                    ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in })

                                    if let userId = PFUser.current()?.objectId {
                                        self.puserId = userId
                                    }

                                    let pid = "\(self.puserId)_profile_completed"

                                    print(pid)
                                    
                                    //FAMILY
                                    
                                    Global.defaults.set(true, forKey: pid)
                                    Global.defaults.set(true, forKey: "\(self.puserId)_family_exist")
                                    Global.defaults.set(true, forKey: "\(self.puserId)_son_exist")
                                    
                                    let your_family_name = Global.gamvesFamily.familyName
                                    Global.defaults.set(your_family_name, forKey: "\(self.puserId)_your_family_name")
                                    
                                    //YOU

                                    let email = Global.gamvesFamily.youUser.email
                                    Global.defaults.set(email, forKey: "\(self.puserId)_your_email")
                                    
                                    let password = Global.gamvesFamily.youUser.email
                                    Global.defaults.set(password, forKey: "\(self.puserId)_your_password")
                                    
                                    let your_username = Global.gamvesFamily.youUser.userName
                                    Global.defaults.set(your_username, forKey: "\(self.puserId)_your_username")
                                    
                                    let youImage:UIImage = Global.gamvesFamily.youUser.avatar
                                    
                                    Global.storeImgeLocally(imagePath: Global.youImageName, imageToStore: youImage)
                                    
                                    let youImageLow = youImage.lowestQualityJPEGNSData as Data
                                    var youSmallImage = UIImage(data: youImageLow)
                                    
                                    Global.storeImgeLocally(imagePath: Global.youImageNameSmall, imageToStore: youSmallImage!)
                                    
                                    //SPOUSE
                                    
                                    let spouse_username = Global.gamvesFamily.spouseUser.userName
                                    Global.defaults.set(spouse_username, forKey: "\(self.puserId)_your_username")
                                    
                                    let spouse_email = Global.gamvesFamily.spouseUser.email
                                    Global.defaults.set(spouse_email, forKey: "\(self.puserId)_spouse_email")
                                  
                                    let spouseImage:UIImage = Global.gamvesFamily.spouseUser.avatar
                                    
                                    Global.storeImgeLocally(imagePath: Global.spouseImageName, imageToStore: spouseImage)
                                    
                                    let spouseImageLow = spouseImage.lowestQualityJPEGNSData as Data
                                    var spouseSmallImage = UIImage(data: spouseImageLow)
                                    
                                    Global.storeImgeLocally(imagePath: Global.spouseImageNameSmall, imageToStore: spouseSmallImage!)
                                    
                                    //SON                            
                                    
                                    let son_name = sonUser.name
                                    Global.defaults.set(son_name, forKey: "\(self.puserId)_son_name")
                                    
                                    let son_username = sonUser.userName
                                    Global.defaults.set(son_username, forKey: "\(self.puserId)_son_username")                                    
                                    
                                    Global.defaults.set(son_type, forKey: "\(self.puserId)_son_type")                                    
                                    
                                    Global.defaults.set(son_school, forKey: "\(self.puserId)_son_school")
                                    
                                    print(self.puserId)
                                    
                                    if let son_userId = sonUser.userObj.objectId {
                                        print(son_userId)
                                        Global.defaults.set(son_userId, forKey: "\(self.puserId)_son_userId")
                                        Global.defaults.set(son_userId, forKey: "\(self.puserId)_son_object_id")
                                    }
                                    
                                    let sonImage:UIImage = Global.gamvesFamily.sonsUsers[0].avatar
                                    
                                    Global.storeImgeLocally(imagePath: Global.sonImageName, imageToStore: sonImage)
                                    
                                    let sonImageLow = sonImage.lowestQualityJPEGNSData as Data
                                    var sonSmallImage = UIImage(data: sonImageLow)
                                    
                                    Global.storeImgeLocally(imagePath: Global.sonImageNameSmall, imageToStore: sonSmallImage!)                                                                

                                    //Refreshing all data on views
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: self)                                    
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyLoadFamilyDataGromGlobal), object: self)
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyLoadDataAfterLogin), object: self)
                                    
                                    Global.familyDataGromGlobal = true
                                    
                                    self.activityIndicatorView?.stopAnimating()

                                    UserDefaults.standard.setIsRegistered(value: true)
                                    self.dismiss(animated: true, completion: nil)
                                    self.tabBarViewController?.selectedIndex = 0 //Home                                      

                                })
                                
                            })
                            
                        } else {

                            if let userId = PFUser.current()?.objectId {
                                self.puserId = userId
                            }

                            Global.defaults.set(true, forKey: "\(self.puserId)_registrant_completed")
                                                  
                            self.activityIndicatorView?.stopAnimating()
                            
                            self.tabBarViewController?.selectedIndex = 0 

                            self.imagePickerViewController = ImagePickerViewController()
                            self.imagePickerViewController.imagesPickerProtocol = self
                            self.you = PFUser.current()

                            if let userId = PFUser.current()?.objectId {
                                self.puserId = userId
                            }

                            self.yourTypeId = PFUser.current()?["user_type"] as! Int                                                  

                            self.imagePickerViewController.setType(type: ProfileImagesTypes.You)

                            self.navigationPickerController = UINavigationController(rootViewController: self.imagePickerViewController)

                            self.dismiss(animated:true)                       

                            let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
                            appDelegate.window?.rootViewController = self.navigationPickerController

                            Global.loadAdminUser()
                            Global.loadConfigData()
                                                        
                        }
                    } 
                } 

                if !isVerified {

                    let message = "Your account has been created but you have not verified your email. Please check your email, verify and try again."
                        
                    self.showMessage(title: "Try again", message: message)                         

                    PFUser.logOut()
                    return
                }
            }
        })
    }

   

    func showMessage(title: String, message: String) {

        self.message = message 

        self.isMessage = true

        self.loginRegisterButton.setTitle(title, for: UIControlState())

        self.handleLoginRegisterChange()

        //self.emailTextField.becomeFirstResponder()    

        self.activityIndicatorView?.stopAnimating()      

        self.isError = true

    }
    
    func hideShowMessage(bol:Bool)
    {
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
        emailTextFieldHeightAnchor?.isActive = true
        emailTextField.isHidden = bol
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
        passwordTextFieldHeightAnchor?.isActive = true
        passwordTextField.isHidden = bol

        userTypeTextFieldHeightAnchor?.isActive = false
        userTypeTextFieldHeightAnchor = userTypeTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0)
        userTypeTextFieldHeightAnchor?.isActive = true
        userTypeTextField.isHidden = bol
        
        registerLabelHeightAnchor?.isActive = false
        registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1)
        registerLabelHeightAnchor?.isActive = true
        registerLabel.isHidden = !bol
        registerLabel.text = message
    }
    
    func checkForErrors() -> Bool
    {
        var errors = false
        let title = "Validation error"
        var message = ""

        if (self.nameTextField.text?.isEmpty)! {

            errors = true
            message += "Complete name is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.nameTextField)
            
        }
        else if (emailTextField.text?.isEmpty)!
        {
            errors = true
            message += "Email is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.emailTextField)
            
            self.emailTextField.becomeFirstResponder()
        }
        else if !Global.isValidEmail(test: self.emailTextField.text!)
        {
            errors = true
            message += "Invalid Email Address"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.emailTextField)
            
        }
        else if (self.passwordTextField.text?.isEmpty)!
        {
            errors = true
            message += "Password is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.passwordTextField)
            
        }
        else if (self.passwordTextField.text?.characters.count)! < 8
        {
            errors = true
            message += "Password must be at least 8 characters"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.passwordTextField)
        
        }
        else if (userTypeTextField.text?.isEmpty)!
        {
            errors = true
            message += "Tap to choose a relationship..."
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.userTypeTextField)
            
            self.emailTextField.becomeFirstResponder()
        }
        
        return errors
    }
    
    func handleSelectProfileImageView() {   

    }


    // Image Picker

     func saveYouImageAndPhone(phone:String) {

        if (!phone.isEmpty) {

            self.activityIndicatorView?.startAnimating()

            self.phoneNumber = phone  

            self.saveYou(completionHandler: { ( resutl ) -> () in
                                
                print("YOU SAVED")
                                
                if resutl {

                    self.activityIndicatorView?.stopAnimating()
                    
                    let title = "Congratulations Registration Completed!"
                    var message = "\n\nThanks very much for registering to Gamves. Enjoy the educative videos and add your family! \n\n"                                                            
                    
                    let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                                                                     
                        //self.navigationController?.popViewController(animated: true)                        

                        UserDefaults.standard.setHasPhoneAndImage(value: true)

                        //self.dismiss(animated:true)                       

                        let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
                        self.tabBarViewController?.selectedIndex = 0
                        appDelegate.window?.rootViewController = self.tabBarViewController                     

                        self.hideShowTabBar(status:true)                        
                        
                    }))
                    
                    self.navigationPickerController.present(alert, animated: true) 

                }

            })


        } else {


            let title = "Phone number is empty"
            var message = "\n\nPlease fill in your phone number and try agaiin! \n\n"                                                            
            
            let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in             

                self.imagePickerViewController.phoneTextField.becomeFirstResponder()
                
            }))
            
            self.present(alert, animated: true) 

        }

    }   
    
    func didpickImage(type: ProfileImagesTypes, smallImage: UIImage, croppedImage: UIImage) {
        
        self.yourPhotoImageView = UIImageView()
        self.yourPhotoImageView.image   = croppedImage
        
        self.yourPhotoImage = UIImage()
        self.yourPhotoImage = croppedImage

        self.yourPhotoImageSmall = UIImage()
        self.yourPhotoImageSmall = smallImage
        self.makeRounded(imageView:self.yourPhotoImageView)
    }    

    func hideShowTabBar(status: Bool)
    {
        self.tabBarController?.tabBar.isHidden = status
        
        if status
        {
            navigationController?.navigationBar.tintColor = UIColor.white
        } 
    }
    

    func saveYou(completionHandler : @escaping (_ resutl:Bool) -> ())
    {   

        self.you = PFUser.current()
        
        let your_email = Global.defaults.string(forKey: "\(self.puserId)_your_email")
        let your_password = Global.defaults.string(forKey: "\(self.puserId)_your_password")
        
        var reusername = self.you["firstName"] as! String
        reusername = reusername.lowercased()
        
        //self.you["email"] = your_email
        //self.you.email = your_email
        
        let yourimage = PFFileObject(name: reusername, data: UIImageJPEGRepresentation(self.yourPhotoImage, 1.0)!)
        self.you.setObject(yourimage!, forKey: "picture")
        
        let yourImgName = "\(reusername)_small"              
        
        print("--------------")
        print(yourImgName)
        print("--------------")

        let yourimageSmall = PFFileObject(name: yourImgName, data: UIImageJPEGRepresentation(self.yourPhotoImageSmall, 1.0)!)
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

        self.you["phone"]  = self.phoneNumber
        
        self.you.saveInBackground(block: { (resutl, error) in
            
            if error != nil
            {
                print(error)
                completionHandler(false)
            } else
            {
                
                Global.addUserToDictionary(user: self.you as! PFUser, isFamily: true, completionHandler: { ( gamvesUser ) -> () in                                    
                    
                    var youAdmin = [GamvesUser]()
            
                    youAdmin.append(gamvesUser)
                    youAdmin.append(Global.adminUser)

                    let youAdminChatId = Global.getRandomInt()
                    
                    ChatMethods.addNewFeedAppendgroup(gamvesUsers: youAdmin, chatId: youAdminChatId, type: 2, completionHandlerGroup: { ( resutl:Bool ) -> () in
                        
                        print("done youAdmin")
                        print(resutl)
                        
                        if (resutl != nil) {

                            let params = [
                            "role" : self.schoolShort,
                            "userId" : self.puserId,                  
                            ] as [String : Any]

                            print(params)
                        
                            PFCloud.callFunction(inBackground: "AddUserToRole", withParameters: params) { (result, error) in
                            
                                ChatFeedMethods.queryFeed(chatId: nil, completionHandlerChatId: { ( chatId:Int ) -> () in

                                    completionHandler(true)

                                })
                            }    
                        }                        
                    })                    
                })
            }
        })        
    }


    func makeRounded(imageView:UIImageView)
    {
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2            
        imageView.clipsToBounds = true         
        imageView.layer.borderColor = UIColor.gamvesBlackColor.cgColor
        imageView.layer.borderWidth = 3
    } 
    
}
