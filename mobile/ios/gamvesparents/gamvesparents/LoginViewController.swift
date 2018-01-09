//
//  LoginViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 11/2/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import Parse
import DownPicker
import BEMCheckBox
import NVActivityIndicatorView

class LoginViewController: UIViewController
{

    var okLogin = Bool()

    var activityIndicatorView:NVActivityIndicatorView?
    
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
    
    let loginBackgroundView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.gamvesColor
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let inputsContainerView: UIView = {
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

    var userTypeDownPicker: DownPicker!
  
    let userTypeTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false        
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
    var message = String()
    var inputsContainerViewHeight = CGFloat()
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
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
    let cbHeight:CGFloat    = 70
    let lrbHeight:CGFloat   = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gamvesColor
        
        self.view.addSubview(self.loginBackgroundView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.loginBackgroundView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.loginBackgroundView)
        
        self.loginBackgroundView.backgroundColor = UIColor.gamvesColor
        
        //let checkFrame = CGRect(x: 0, y: 0, width: 0, height: cbHeight)
        //checkBoxView = CheckBoxView(frame: checkFrame)
        //checkBoxView.backgroundColor = UIColor.blue

        self.loginBackgroundView.addSubview(explainLabel)
        self.loginBackgroundView.addSubview(loginRegisterSegmentedControl)
        self.loginBackgroundView.addSubview(inputsContainerView)
        self.loginBackgroundView.addSubview(registerLabel)
        //self.loginBackgroundView.addSubview(checkBoxView)
        self.loginBackgroundView.addSubview(loginRegisterButton)
        self.loginBackgroundView.addSubview(bottomView)


        
        inputsContainerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -24).isActive = true
        
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: icHeight)
        inputsContainerViewHeightAnchor?.isActive = true
        
        //inputsContainerView.backgroundColor = UIColor.blue
        
        let metricsDict = [
            "mTop"      :  mTop,
            "expHeight" : expHeight,
            "scHeight"  : scHeight,
            "icHeight"  : icHeight,
            //"cbHeight"  : cbHeight,
            "lrbHeight" : lrbHeight ]

        loginBackgroundView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.explainLabel)
        loginBackgroundView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.loginRegisterSegmentedControl)
        loginBackgroundView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.loginRegisterButton)
        loginBackgroundView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)
        
        self.loginBackgroundView.addConstraintsWithFormat(
            "V:|-mTop-[v0(expHeight)]-10-[v1(scHeight)]-10-[v2(icHeight)]-10-[v3(lrbHeight)][v4]|", 
            views: self.explainLabel, 
            self.loginRegisterSegmentedControl, 
            self.inputsContainerView, 
            //self.checkBoxView, 
            self.loginRegisterButton, 
            self.bottomView,
            metrics: metricsDict)
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(userTypeSeparatorView)
        inputsContainerView.addSubview(userTypeTextField)  
       
        
        //Name
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true        
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        
        //Name Separator
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Email
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        
        //Email Separator
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Password
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        passwordTextFieldHeightAnchor?.isActive = true  

        //need x, y, width, height constraints
        userTypeSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        userTypeSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        userTypeSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userTypeSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
      
        //need x, y, width, height constraints
        userTypeTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        userTypeTextField.topAnchor.constraint(equalTo: userTypeSeparatorView.bottomAnchor).isActive = true        
        userTypeTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userTypeTextFieldHeightAnchor = userTypeTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        userTypeTextFieldHeightAnchor?.isActive = true
  
        let parents: NSMutableArray = ["Father", "Mother"]
        self.userTypeDownPicker = DownPicker(textField: userTypeTextField, withData:parents as! [Any])
        userTypeTextFieldHeightAnchor = userTypeTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/4)
        userTypeDownPicker.setPlaceholder("Tap to choose relationship...")          
        
        //Register Message
        registerLabel.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 0).isActive = true
        registerLabel.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        registerLabel.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor)
        registerLabel.backgroundColor = UIColor.gambesDarkColor
        registerLabel.frame.size.width = registerLabel.intrinsicContentSize.width - 40
        registerLabel.textAlignment = .center
        registerLabel.isHidden = true
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        self.prepTextFields(inView: self.view)
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)
        
        //let deadlineTime = DispatchTime.now() + 2
        //DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        //    self.firstTFBecomeFirstResponder(view: self.view)
        //}
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyBoardWillShow(notification: NSNotification) {
        //logoImageView.isHidden = true
    }
    
    
    func keyBoardWillHide(notification: NSNotification) {
        //logoImageView.isHidden = false
    }
    
    func handleLoginRegisterChange()
    {
        
        if Reachability.isConnectedToNetwork() == true
        {
            if (!isMessage)
            {
                
                let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
                loginRegisterButton.setTitle(title, for: UIControlState())
                
                if (loginRegisterSegmentedControl.selectedSegmentIndex == 0)
                {
                    
                    inputsContainerViewHeight = (inputsContainerViewHeightAnchor?.constant)!
                    
                    print(inputsContainerViewHeight)
                    
                    inputsContainerViewHeightAnchor?.constant = 80
                    
                    self.hideName()
                    
                    emailTextFieldHeightAnchor?.isActive = false
                    emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
                    emailTextFieldHeightAnchor?.isActive = true
                    emailTextField.isHidden = false
                    
                    passwordTextFieldHeightAnchor?.isActive = false
                    passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
                    passwordTextFieldHeightAnchor?.isActive = true
                    passwordTextField.isHidden = false
                    
                    //userTypeTextField.isHidden = true

                    
                } else if (loginRegisterSegmentedControl.selectedSegmentIndex == 1)
                {
                    inputsContainerViewHeightAnchor?.constant = inputsContainerViewHeight
                    
                    nameTextFieldHeightAnchor?.isActive = false
                    nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
                    nameTextFieldHeightAnchor?.isActive = true
                    nameTextField.isHidden = false
                    
                    emailTextFieldHeightAnchor?.isActive = false
                    emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
                    emailTextFieldHeightAnchor?.isActive = true
                    emailTextField.isHidden = false
                    
                    passwordTextFieldHeightAnchor?.isActive = false
                    passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
                    passwordTextFieldHeightAnchor?.isActive = true
                    passwordTextField.isHidden = false
                    
                }
                
                registerLabelHeightAnchor?.isActive = false
                registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
                registerLabelHeightAnchor?.isActive = true
                registerLabel.isHidden = true
                
            } else
            {
                
                self.hideName()
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
    
    func handleLoginRegister()
    {
        if !okLogin
        {
            
            if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
                handleLogin()
            } else {
                handleRegister()
            }
            
        } else
        {
            
            self.loginRegisterSegmentedControl.selectedSegmentIndex = 0
            self.handleLoginRegisterChange()
            
            self.okLogin=false
            
        }
    }
    
    func handleRegister()
    {
        
        if !checkForErrors()
        {

            self.activityIndicatorView?.startAnimating()

            var email = emailTextField.text
            let name = nameTextField.text
            var password = passwordTextField.text
            let relationship = userTypeTextField.text
            
            // Defining the user object
            let user = PFUser()
            user.username = email
            user.password = password
            user.email = email
            user["Name"] = name
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
            
            user["iDUserType"] = type
        
            user.signUpInBackground {
                (success, error) -> Void in
                
                if let error = error as NSError?
                {
                    
                    let errorString = error.userInfo["error"] as? NSString
                    // In case something went wrong...
                    self.message = errorString as! String

                    self.activityIndicatorView?.stopAnimating()
                    
                } else {
                    
                    // Everything went ok
                    //user["userType"] = type
                    
                    self.activityIndicatorView?.stopAnimating()
                    
                    self.message="An email has been sent to your inbox. Please confirm, once then press the Login."
                    
                    self.okLogin = true
                    self.loginRegisterButton.setTitle("Ok", for: UIControlState())
                    
                    Global.defaults.set(email, forKey: "your_email")
                    Global.defaults.set(password, forKey: "your_password")
                    
                    Global.defaults.synchronize()
                    
                    Global.registerInstallationAndRole(completionHandlerRole: { ( resutl ) -> () in
                        
                        if resutl {

                             self.saveNewProfile(completionHandler: { (profile) in
                                
                                let relation:PFRelation = user.relation(forKey: "userType")
                                relation.add((Global.userTypes[type]?.userTypeObj)!)
                                
                                let profileRel:PFRelation = user.relation(forKey: "profile")
                                profileRel.add(profile)
                                
                                user.saveInBackground(block: { (resutl, error) in
                                    
                                    if error == nil
                                    {
                                        
                                        PFUser.logOut()
                                        
                                    } else
                                    {
                                        print(error)
                                    }
                                    
                                })
                                
                             })
                        }
                    })
                }
                
                self.isMessage=true
                self.handleLoginRegisterChange()
            }
        }
    }
    
    func saveNewProfile(completionHandler : @escaping (_ profile:PFObject) -> ())
    {
        
        let profilePF: PFObject = PFObject(className: "Profile")
        
        let backImage = UIImage(named: "universe")
        
        var backimagePF = PFFile(name: "background.png", data: UIImageJPEGRepresentation(backImage!, 1.0)!)
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
     
        self.activityIndicatorView?.startAnimating()   
        
        let email = emailTextField.text        
        let password = passwordTextField.text
        
        print("________________")
        print(email)
        print(password)
        print("________________")
        
        if (email?.isEmpty)!
        {
            return
        }       
        
        if (password?.isEmpty)!
        {
            return
        }
        
        // Defining the user object
        PFUser.logInWithUsername(inBackground: email!, password: password!, block: {(user, error) -> Void in
            
            if let error = error as NSError?
            {
                
                let errorString = error.userInfo["error"] as? NSString
                // Something went wrong
                self.message="Error \(errorString), please try again."
                self.isMessage=true
                self.handleLoginRegisterChange()
                
            }
            else {
                
                let emailVerified = user?["emailVerified"]
                
                if emailVerified as! Bool == true
                {
                    self.activityIndicatorView?.stopAnimating()   
                    
                    UserDefaults.standard.setIsLoggedIn(value: true)
                    
                    self.dismiss(animated: true, completion: nil)
                }
                else
                {
                    PFUser.logOut()
                }
            }
        })
    }

    
    func hideShowMessage(bol:Bool)
    {
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
        emailTextFieldHeightAnchor?.isActive = true
        emailTextField.isHidden = bol
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
        passwordTextFieldHeightAnchor?.isActive = true
        passwordTextField.isHidden = bol

        userTypeTextFieldHeightAnchor?.isActive = false
        userTypeTextFieldHeightAnchor = userTypeTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
        userTypeTextFieldHeightAnchor?.isActive = true
        userTypeTextField.isHidden = bol
        
        registerLabelHeightAnchor?.isActive = false
        registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1)
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
    

    func hideName()
    {
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = true
    }
    
    func handleSelectProfileImageView()
    {
        
    }
    
}
