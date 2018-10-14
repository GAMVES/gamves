//
//  PlayStationViewController.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-07-20.
//

import UIKit
import RSKImageCropper
import Parse

class FortniteViewController: UIViewController
{

    let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center    
        label.numberOfLines = 2    
        return label
    }()

     let photoContainerView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

     lazy var pictureImageView: UIImageView = {
        let imageView = UIImageView()        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    let userTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "User name"
        tf.translatesAutoresizingMaskIntoConstraints = false  
        tf.backgroundColor = UIColor.white 
        tf.font = UIFont.boldSystemFont(ofSize: 20)     
        tf.tag = 0
        return tf
    }()

    let passTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false  
        tf.backgroundColor = UIColor.white 
        tf.font = UIFont.boldSystemFont(ofSize: 20)  
        tf.isSecureTextEntry = true
        tf.tag = 0
        return tf
    }()

    let buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system) 
        let image = UIImage(named: "save")        
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gamvesFortniteDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "close_white")        
        button.setImage(image, for: .normal)                 
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gamvesFortniteDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()

    let bottomView: UIView = {
        let view = UIView()       
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    let imagePicker = UIImagePickerController()

    var smallImage = UIImage()

    var croppedImage = UIImage()

    var puserId = String()   

    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonIcon = UIImage(named: "arrow_back_white")        
        let leftBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButton(sender:)))
        leftBarButton.image = buttonIcon        
        self.navigationItem.leftBarButtonItem = leftBarButton   

        self.navigationItem.title = "Account"

        self.navigationController?.navigationBar.barTintColor = UIColor.gamvesFortniteColor
        
        self.view.backgroundColor = UIColor.gamvesFortniteColor

        self.view.addSubview(topView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: topView)        
        
        self.view.addSubview(photoContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: photoContainerView)

        self.view.addSubview(messageLabel)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: messageLabel)

        self.view.addSubview(userTextField)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: userTextField)  
        
        self.view.addSubview(passTextField)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: passTextField)                

        self.view.addSubview(buttonsView)
        self.view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: buttonsView)
        
        self.view.addSubview(bottomView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: bottomView)

        var metricsPicker = [String:Int]()

        let width:Int = Int(self.view.frame.size.width)
        let height:Int = Int(self.view.frame.size.height)
        let photoSize = width / 3
        
        let padding = (height - (photoSize + 300)) / 2

        metricsPicker["photoSize"] = photoSize
        metricsPicker["padding"]   = padding

        self.view.addConstraintsWithFormat("V:|[v0(150)][v1(150)][v2(100)]-20-[v3(60)]-20-[v4(60)]-40-[v5(60)]-30-[v6]|", views: 
            topView,
            photoContainerView,
            messageLabel,
            userTextField,
            passTextField,
            buttonsView,
            bottomView,
            metrics: metricsPicker)

        self.photoContainerView.addSubview(self.pictureImageView)
        self.photoContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.pictureImageView)
        self.photoContainerView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.pictureImageView, metrics: metricsPicker)                     

        self.buttonsView.addSubview(saveButton)
        self.buttonsView.addSubview(cancelButton)

        self.buttonsView.addConstraintsWithFormat("V:|[v0]|", views: saveButton)      
        self.buttonsView.addConstraintsWithFormat("V:|[v0]|", views: cancelButton)      

        self.buttonsView.addConstraintsWithFormat("H:|-20-[v0]-10-[v1(150)]-20-|", views: saveButton, cancelButton)      

        var metricsTitle = [String:Int]()
        let topTitle = padding / 2

        metricsTitle["topTitle"] = topTitle - 30

        self.topView.addSubview(self.titleLabel)        
        self.topView.addConstraintsWithFormat("H:|-40-[v0]-40-|", views: self.titleLabel)
        self.topView.addConstraintsWithFormat("V:|-topTitle-[v0(100)]|", views: self.titleLabel, metrics: metricsTitle)

        self.setScreenByType()   

        if let userId = PFUser.current()?.objectId {
            self.puserId = userId
        }	
    }

    @objc func backButton(sender: UIBarButtonItem) {

        self.hideShowTabBar(hidden:false)

        self.navigationController?.popViewController(animated: true)

    }

    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParentViewController {

            self.navigationController?.navigationBar.barTintColor = UIColor.gamvesColor
            
        }
    }

    func setScreenByType() {

        var title = String()
        var message = String()
        var buttonTitle = String()
        var imageName = String()
        
        title = "Fortnite" //"Registration completed. Please add Fortnite user name and password"
        message = "Provide your son/daughter Fortnite username and password"
        buttonTitle = "  Select child Image"
        imageName = "son_photo"
        

        self.titleLabel.text = title
        self.pictureImageView.image = UIImage(named: "fortnite")
        self.messageLabel.text = message

        self.saveButton.setTitle("    SAVE", for: .normal)
        self.cancelButton.setTitle(" CANCEL", for: .normal)
    }  
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }

    @objc func handleSave() {

        if ( (userTextField.text?.isEmpty)! || (passTextField.text?.isEmpty)! ) {

            self.showAlert(title: "Empty field", message: "Please provide username and password", completionHandler: { (gamvesUser) in

                print("")
            })
        
        } else {

            self.checkUserExist(completionHandler: { ( result ) -> () in

                if result { 

                    var son_userId = String()
                            
                    if var userId = PFUser.current()?.objectId {                
                        son_userId = Global.defaults.string(forKey: "\(userId)_son_userId")!                                     
                    }
                    
                    var vendors:PFObject!

                    let vendorQuery = PFQuery(className:"Vendors")   
                    vendorQuery.whereKey("userId", equalTo:son_userId)                         
                    vendorQuery.whereKey("type", equalTo:1)                         
                    vendorQuery.getFirstObjectInBackground(block: { (vendorPF, error) in

                        if error != nil
                        {
                            vendors = PFObject(className: "Vendors")                                         
                            vendors["userId"] = son_userId  
                            vendors["type"] = 1   
                            vendors["name"] = "Fortnite"                                           

                        } else {
                        
                            vendors = vendorPF
                        }   

                        vendors["username"] = self.userTextField.text
                        vendors["password"] = self.passTextField.text 

                        vendors.saveInBackground { (resutl, error) in
                        
                            if error == nil {
                                
                                 let otherQuery = PFQuery(className:"OtherAccounts")   
                                 otherQuery.whereKey("userId", equalTo:son_userId)                         
                                 otherQuery.getFirstObjectInBackground(block: { (otherAccountsPF, error) in
                                
                                    if error != nil
                                    {

                                        var otherAccounts: PFObject = PFObject(className: "OtherAccounts") 

                                        otherAccounts["userId"] = son_userId  

                                        let vendorsRelation: PFRelation = otherAccounts.relation(forKey: "vendors")
                                        vendorsRelation.add(vendors)                                   

                                        otherAccounts.saveInBackground(block: { (resutl, error) in
                                          
                                            self.showSavedAlert()
                                            
                                        })
                                    } else {
                                        
                                        self.showSavedAlert()
                                    }
                                })                                              
                            }
                        }
                    })                    

                } else {

                    self.showAlert(title: "Invalid username or password", message: "The username or password do not exist or they are not correct. Please try again", completionHandler: { (gamvesUser) in
                        
                        self.userTextField.text = ""
                        self.passTextField.text = ""

                    })

                }
            })
        }
    }



    func showSavedAlert() {

        self.showAlert(title: "Fornite credentials saved", message: "Your Fortnite account has been stored correctly", completionHandler: { (gamvesUser) in                                                               

            self.popController()

        })
    }

    func checkUserExist(completionHandler : @escaping (_ resutl:Bool) -> ()) {

        // Sam API here        
        var result = Bool()
        result = true

        completionHandler(result)
    }


    @objc func handleCancel() {

        self.showAlert(title: "Cancel Fortnite credentials", message: "You will be able to provide your username later", completionHandler: { (gamvesUser) in            

            self.self.popController()
            
       })
    }

    func showAlert(title:String, message:String, completionHandler : @escaping (_ resutl:Bool) -> ()) {

        let message = message

        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in          
                        
            completionHandler(true)

        }))
        
        self.present(alert, animated: true)

    }   

    func popController() {

        UINavigationBar.appearance().barTintColor = UIColor.gamvesColor

        //if self.isRegistering {
                                
            //let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            //self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)                                   

        //} else {

            self.navigationController?.popViewController(animated: true)
        //}

    }

    //Move this to Global
    func hideShowTabBar(hidden: Bool)
    {
        self.tabBarController?.tabBar.isHidden = hidden
        
        if hidden
        {
            navigationController?.navigationBar.tintColor = UIColor.white
        } 
    }

}

