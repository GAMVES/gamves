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
        //button.isEnabled = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()

    lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "skip")        
        button.setImage(image, for: .normal)                 
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gamvesFortniteDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5
        //button.isEnabled = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
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

    override func viewDidLoad() {
        super.viewDidLoad()

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

        metricsPicker["photoSize"]             =  photoSize
        metricsPicker["padding"]               =  padding

        self.view.addConstraintsWithFormat("V:|[v0(150)][v1(150)][v2(100)]-20-[v3(60)]-20-[v4(60)]-40-[v5(60)]-30-[v6]|", views: 
            topView,
            photoContainerView,
            messageLabel,
            userTextField,
            passTextField,
            buttonsView,
            bottomView,
            metrics: metricsPicker)

        photoContainerView.addSubview(pictureImageView)
        photoContainerView.addConstraintsWithFormat("V:|[v0]|", views: pictureImageView)
        photoContainerView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: pictureImageView, metrics: metricsPicker)                     

        self.buttonsView.addSubview(saveButton)
        self.buttonsView.addSubview(skipButton)

        self.buttonsView.addConstraintsWithFormat("V:|[v0]|", views: saveButton)      
        self.buttonsView.addConstraintsWithFormat("V:|[v0]|", views: skipButton)      

        self.buttonsView.addConstraintsWithFormat("H:|-30-[v0]-30-[v1(100)]-30-|", views: saveButton, skipButton)      

        var metricsTitle = [String:Int]()
        let topTitle = padding / 2

        metricsTitle["topTitle"]             =  topTitle

        topView.addSubview(titleLabel)        
        topView.addConstraintsWithFormat("H:|-40-[v0]-40-|", views: titleLabel)
        topView.addConstraintsWithFormat("V:|-topTitle-[v0(100)]|", views: titleLabel, metrics: metricsTitle)

        self.setScreenByType()   	
    }

    func setScreenByType() {

        var title = String()
        var message = String()
        var buttonTitle = String()
        var imageName = String()
        
        title = "Add Fortnite user name and password"
        message = "Provide your son/daughter Fortnite username and password. With Gamves he/she will be able to win gifts for the game"
        buttonTitle = "  Select child Image"
        imageName = "son_photo"
        

        self.titleLabel.text = title
        self.pictureImageView.image = UIImage(named: "fortnite")
        self.messageLabel.text = message

        self.saveButton.setTitle("   SAVE", for: .normal)
        self.skipButton.setTitle("   SKIP", for: .normal)
    }   
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }

    func handleSave() {

        if ( (userTextField.text?.isEmpty)! || (passTextField.text?.isEmpty)! ) {

            self.showAlert(title: "Empty field", message: "Please provide username and password", completionHandler: { (gamvesUser) in

                print("")

            })
        
        } else {


            self.checkUserExist(completionHandler: { ( result ) -> () in


                if result {

                    let vendors: PFObject = PFObject(className: "Vendors")

                    if let userId = PFUser.current()?.objectId
                    {                
                        let son_userId = Global.defaults.string(forKey: "\(userId)_son_userId")                                            
                        vendors["userId"] = son_userId
                    }

                    vendors["type"] = 1                        
                    vendors["username"] = self.userTextField.text
                    vendors["password"] = self.passTextField.text

                    vendors.saveInBackground { (resutl, error) in
                        
                        if error == nil {

                            self.showAlert(title: "Username saved", message: "Please provide a valid Play Station user name", completionHandler: { (gamvesUser) in

                                print("")

                                //self.navigationController?.popViewController(animated: true)

                                UINavigationBar.appearance().barTintColor = UIColor.gamvesColor
                                
                                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)

                            })                    
                        }
                    }

                } else {

                    self.showAlert(title: "Invalid username or password", message: "The username or password do not exist or they are not correct. Please try again", completionHandler: { (gamvesUser) in
                        
                        self.userTextField.text = ""
                        self.passTextField.text = ""

                    })

                }
            })
        }
    }

    func checkUserExist(completionHandler : @escaping (_ resutl:Bool) -> ()) {

        // Sam API here
        
        var result = Bool()
        result = true

        completionHandler(result)
    }


    func handleSkip() {

        self.showAlert(title: "Skip username", message: "You will be able to provide your username later", completionHandler: { (gamvesUser) in

            print("")

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

}

