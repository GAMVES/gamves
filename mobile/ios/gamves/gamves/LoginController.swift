//
//  LoginController.swift
//  gameofchats
//
//  Created by Brian Voong on 6/24/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class LoginController: UIViewController {
    
    var activityView: NVActivityIndicatorView!
    
    let messageRegister = "Please ask your parents for registration credentials and come back. They should register first in order to give you access."

     let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor        
        return v
    }()  

    let loginBackgroundView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
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
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Login", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let userTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "User name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.tag = 0
        tf.text = "josemanuelvigil@gmail.com"
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gambesDarkColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.tag = 1
        tf.text = "JoseVigil2016"
        return tf
    }()

    let registerLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.text =
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping        
        label.numberOfLines = 5
        return label
    }()
    
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectlogoImageView)))        
        imageView.isUserInteractionEnabled = true        
        return imageView
    }()
    
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gamvesColor
        
        navigationController?.navigationBar.isTranslucent = false
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = "  Login"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel

        self.view.addSubview(self.scrollView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.scrollView)        

        self.scrollView.addSubview(self.loginBackgroundView)

        let width = self.view.frame.width
        let height = self.view.frame.height

        let sizeDict = ["width":width, "height":height]

        self.scrollView.addConstraintsWithFormat("H:|[v0(width)]|", views: self.loginBackgroundView, metrics: sizeDict)
        self.scrollView.addConstraintsWithFormat("V:|[v0(height)]|", views: self.loginBackgroundView, metrics: sizeDict)
        
        //self.loginBackgroundView.backgroundColor = UIColor.gamvesColor
        
        self.loginBackgroundView.addSubview(inputsContainerView)
        self.loginBackgroundView.addSubview(loginRegisterButton)
        self.loginBackgroundView.addSubview(logoImageView)        
        self.loginBackgroundView.addSubview(loginRegisterSegmentedControl)
        
        self.setupInputsContainerView()
        self.setupLoginRegisterButton()
        self.setuplogoImageView()        
        self.setupLoginRegisterSegmentedControl()
        
        self.activityView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.lineSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)
        
        self.view.addSubview(activityView)
        
        self.prepTextFields(inView: self.view)

    }
    
    func handleLoginRegisterChange()
    {
        
        self.view.endEditing(true)
        
        let title = self.loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        self.loginRegisterButton.setTitle(title, for: UIControlState())
        
        // change height of inputContainerView, but how???
        self.inputsContainerViewHeightAnchor?.constant = self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 100
        
        self.userTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 1
        self.passwordTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 1
        self.nameSeparatorView.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 1
        self.loginRegisterButton.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 1
        
        self.registerLabel.text = messageRegister
        
        self.registerLabel.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        self.loginRegisterButton.tag = 0
        
    }
    
    func handleLoginRegister()
    {
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0
        {
            
            handleLogin()
            
        } else {
            //handleRegister()
        }
    }
    
    func handleLogin()
    {
        
        if self.loginRegisterButton.tag == 0
        {
            
            self.activityView.startAnimating()
            
            guard let user = userTextField.text, let password = passwordTextField.text else {
                print("Form is not valid")
                return
            }
            
            
            if user.isEmpty
            {
                return
            }
            
            
            if password.isEmpty
            {
                return
            }
            
            print(user)
            print(password)
            
            // Defining the user object
            PFUser.logInWithUsername(inBackground: user, password: password, block: {(user, error) -> Void in
                
                if let error = error as NSError? {
                    
                    let errorString = error.userInfo["error"] as? NSString
                    print(errorString)
                    
                    self.showLoginError(error: errorString as! String)

                    self.activityView.stopAnimating()
                    
                    
                } else
                {
                    
                    // Still need to check if the email has been verified
                    /*if user?["emailVerified"] != nil
                     {
                     
                     let emailVerified = user?["emailVerified"];
                     
                     if emailVerified as! Bool == true
                     {
                     } else {
                     // The email has not been verified, so logout the user
                     PFUser.logOut()
                     }
                     
                     } else {
                     
                     let layout = UICollectionViewFlowLayout()
                     layout.scrollDirection = .vertical
                     
                     self.window?.rootViewController = UINavigationController(rootViewController: HomeController(collectionViewLayout: layout))
                     
                     }*/
                    
                    
                    //Check fisrt login
                    
                    if Global.isKeyPresentInUserDefaults(key:"first_run")
                    {
                        
                        Global.getFamilyData(completionHandler: { ( result:Bool ) -> () in })
                        
                        Global.defaults.set(true, forKey: "first_run")
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyLoggedin), object: self)
                    
                    
                    // Adds an admin role to the users.
                    
                    Global.registerInstallationAndRole()
                    
                    let layout = UICollectionViewFlowLayout()
                    layout.scrollDirection = .vertical
                    
                    //let homeViewController = HomeController(collectionViewLayout: layout)
                    
                    self.activityView.stopAnimating()
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window!.rootViewController = UINavigationController(rootViewController: HomeController(collectionViewLayout: layout))
                    
                    
                    
                    
                }
            })
            
        } else if self.loginRegisterButton.tag == 1
        {
            self.handleLoginRegisterChange()
            
            //let deadlineTime = DispatchTime.now() + 1
            //DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            //    self.firstTFBecomeFirstResponder(view: self.view)
            //}
        }
    }
    
    func showLoginError(error: String)
    {
        
        let title = "Try again"
        
        self.loginRegisterButton.setTitle(title, for: UIControlState())
        
        self.inputsContainerViewHeightAnchor?.constant = self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 100
        
        self.registerLabel.text = error
        
        self.userTextField.text = ""
        self.passwordTextField.text = ""
        
        self.userTextField.isHidden = true
        self.passwordTextField.isHidden = true
        self.nameSeparatorView.isHidden = true
        
        self.registerLabel.isHidden = false
        
        self.loginRegisterButton.tag = 1
    }

     override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //let deadlineTime = DispatchTime.now() + 2
        //DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        //    self.firstTFBecomeFirstResponder(view: self.view)
        //}
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func submitForm() {
        super.submitForm()
        // actually submit the form
        print ("Submit")
        
        self.handleLoginRegister()
        
    }

    override func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let editTextPosition = textField.frame.maxY + 100
        
        print(editTextPosition)
        
        self.scrollView.setContentOffset(CGPoint(x:0, y:editTextPosition), animated: true)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }

    func setupLoginRegisterSegmentedControl() {
        //need x, y, width, height constraints
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: self.loginBackgroundView.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setuplogoImageView() {
        //need x, y, width, height constraints
        logoImageView.centerXAnchor.constraint(equalTo: self.loginBackgroundView.centerXAnchor).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: 40).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var userTextFieldHeightAnchor: NSLayoutConstraint?
    
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    var registerLabelHeightAnchor: NSLayoutConstraint?    
    
    func setupInputsContainerView() 
    {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: self.loginBackgroundView.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: self.loginBackgroundView.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: self.loginBackgroundView.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 100)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(userTextField)
        inputsContainerView.addSubview(nameSeparatorView)        
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(registerLabel)     

        registerLabel.backgroundColor = UIColor.gambesDarkColor
        registerLabel.frame.size.width = registerLabel.intrinsicContentSize.width - 40        
        registerLabel.textAlignment = .center
        registerLabel.isHidden = true        
                
        //need x, y, width, height constraints
        userTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        userTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        userTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userTextFieldHeightAnchor = userTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
        userTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: userTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
                
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: userTextField.bottomAnchor).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
        passwordTextFieldHeightAnchor?.isActive = true

        //need x, y, width, height constraints
        registerLabel.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 0).isActive = true
        registerLabel.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true        
        registerLabel.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerLabelHeightAnchor = registerLabel.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor)        
        registerLabelHeightAnchor?.isActive = true

    }
    
    func setupLoginRegisterButton() 
    {
        //need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: self.loginBackgroundView.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}









