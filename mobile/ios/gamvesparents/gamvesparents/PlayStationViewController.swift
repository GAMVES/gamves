//
//  PlayStationViewController.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-07-20.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//


import UIKit
import RSKImageCropper

class PlayStationViewController: UIViewController
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
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center        
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

    let buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)                        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gambesDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()

    lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)                 
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gambesDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5
        button.isEnabled = false
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

        self.view.backgroundColor = UIColor.gamvesColor

        self.view.addSubview(topView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: topView)        
        
        self.view.addSubview(photoContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: photoContainerView)

        self.view.addSubview(messageLabel)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: messageLabel)

        self.view.addSubview(userTextField)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: userTextField)        

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

        self.view.addConstraintsWithFormat("V:|[v0(200)][v1(200)][v2(100)]-20-[v3(60)]-20-[v4(60)]-30-[v5]|", views: 
            topView,
            photoContainerView,
            messageLabel,
            userTextField,
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

        self.buttonsView.addConstraintsWithFormat("H:|-10-[v0(100)]-10-[v1]-10-|", views: skipButton, saveButton)      

        var metricsTitle = [String:Int]()
        let topTitle = padding / 2

        metricsTitle["topTitle"]             =  topTitle

        topView.addSubview(titleLabel)        
        topView.addConstraintsWithFormat("H:|[v0]|", views: titleLabel)
        topView.addConstraintsWithFormat("V:|-topTitle-[v0(80)]|", views: titleLabel, metrics: metricsTitle)

        self.setScreenByType()   

		/*
        self.topView.backgroundColor 				= UIColor.orange  
        self.titleLabel.backgroundColor 			= UIColor.green  
        self.photoContainerView.backgroundColor 	= UIColor.cyan  
        self.pictureImageView.backgroundColor 		= UIColor.brown 
        self.messageLabel.backgroundColor 			= UIColor.yellow
        self.saveButton.backgroundColor 			= UIColor.red 
        self.bottomView.backgroundColor 			= UIColor.blue       
        */
       
    }

    func setScreenByType() {

        var title = String()
        var message = String()
        var buttonTitle = String()
        var imageName = String()
        
        title = "Add user name"
        message = "Provide your son/daughter PlayStation username. Will help Gamves to be more connected"
        buttonTitle = "  Select child Image"
        imageName = "son_photo"
        

        self.titleLabel.text = title
        self.pictureImageView.image = UIImage(named: "playstation")
        self.messageLabel.text = message

        self.saveButton.setTitle("SAVE  USERNAME", for: .normal)
        self.skipButton.setTitle("SKIP", for: .normal)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }

    func handleSave() {

        if userTextField.isEmpty {

            self.showAlert("Empty field", "Please provide a valid Play Station user name", completionHandler: { (gamvesUser) in

                print("")

            })
        
        } else {

            let consoles: PFObject = PFObject(className: "Consoles")

            let son_userId = Global.defaults.string(forKey: "\(self.puserId)_son_userId")                                            

            consoles["type"] = 1            
            consoles["userId"] = son_userId
            consoles["username"] = userTextField.text            
            consoles.saveInBackground { (resutl, error) in
                
                if error == nil {

                    self.showAlert("Username saved", "Please provide a valid Play Station user name", completionHandler: { (gamvesUser) in

                        print("")

                        self.navigationController?.popViewController(animated: true)

                    })                    
                }
            }
        }        
    }

    func handleSkip() {

        self.showAlert("Skip username", "You will be able to provide your username later", completionHandler: { (gamvesUser) in

            print("")

        }) 

    }

    func showAlert(title:String, message:String, completionHandler : @escaping (_ resutl:Bool) -> ()) {

        let message = message

        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in          
            
            
            completionHandler(resutl)

        }))
        
        self.present(alert, animated: true)

    }


           

            self.navigationController?.popToRootViewController(animated: true)
            self.homeController?.clearNewVideo()
            






            











   

}

