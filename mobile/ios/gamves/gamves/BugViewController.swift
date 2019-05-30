//
//  ReportBugViewController.swift
//  gamves
//
//  Created by Jose Vigil on 18/11/2018.
//  Copyright © 2018 Gamves. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import Parse
import NVActivityIndicatorView

class BugViewController: UIViewController {

    var homeController: HomeController?

    var isEdit = false

    var keyBoardOpened = Bool()
    
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
        //imageView.view.addTarget(self, action: #selector(showImage), for: .touchUpInside)    
        imageView.tag = 0           
        return imageView
    }() 

    let textView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        //view.backgroundColor = UIColor.cyan
        return view
    }()

    let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Title"
        tf.translatesAutoresizingMaskIntoConstraints = false  
        tf.backgroundColor = UIColor.white 
        tf.font = UIFont.boldSystemFont(ofSize: 20)                  
        return tf
    }()   

    let descTextView: UITextView = {
        let tf = UITextView()
        tf.placeholder = "Describe the bug, explain with "
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
        //view.backgroundColor = UIColor.cyan
        return view
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system) 
        var image = UIImage(named: "save")
        image = Global.resizeImage(image: image!, targetSize: CGSize(width:30, height:30))      
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gambesDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        var image = UIImage(named: "close_white")
        image = Global.resizeImage(image: image!, targetSize: CGSize(width:30, height:30))
        button.setImage(image, for: .normal)                 
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gambesDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()

    let listView: UIView = {
        let view = UIView()       
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        var image = UIImage(named: "list")
        image = Global.resizeImage(image: image!, targetSize: CGSize(width:30, height:30))
        button.setImage(image, for: .normal)                 
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gambesDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(showList), for: .touchUpInside)
        return button
    }()

    let bottomView: UIView = {
        let view = UIView()       
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()    

    var activityView: NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()         

        let buttonIcon = UIImage(named: "arrow_back_white")        
        let leftBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButton(sender:)))
        leftBarButton.image = buttonIcon        
        self.navigationItem.leftBarButtonItem = leftBarButton   

        //self.navigationItem.title = "Account"

        //self.view.backgroundColor = UIColor.gamvesColor
        
        self.view.addSubview(photoContainerView)
        self.view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: photoContainerView)        
        
        self.view.addSubview(buttonsView)
        self.view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: buttonsView)
        
        self.view.addSubview(bottomView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: bottomView)

        //self.view.addSubview(listView)
        //self.view.addConstraintsWithFormat("H:|[v0]|", views: listView)
       
        self.view.addConstraintsWithFormat("V:|-20-[v0(200)]-10-[v1(60)][v2]|", views:             
            photoContainerView,
            buttonsView,
            //listView,
            bottomView)

        self.photoContainerView.addSubview(self.pictureImageView)
        self.photoContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.pictureImageView)        

        self.photoContainerView.addSubview(self.textView)               
        self.photoContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.textView)  

        self.photoContainerView.addConstraintsWithFormat("H:|[v0(150)][v1]|", views: 
            self.pictureImageView,
            self.textView)           

        self.textView.addSubview(self.titleTextField)
        self.textView.addConstraintsWithFormat("H:|[v0]|", views: self.titleTextField)
        
        self.textView.addSubview(self.descTextView)
        self.textView.addConstraintsWithFormat("H:|[v0]|", views: self.descTextView)      

        self.textView.addConstraintsWithFormat("V:|[v0(50)]-5-[v1]|", views:
            self.titleTextField,
            self.descTextView)      

        self.buttonsView.addSubview(saveButton)
        self.buttonsView.addConstraintsWithFormat("V:|[v0]|", views: saveButton)      
        self.buttonsView.addConstraintsWithFormat("H:|[v0]|", views: saveButton)      

        //self.buttonsView.addSubview(cancelButton)
        //self.buttonsView.addConstraintsWithFormat("V:|[v0]|", views: cancelButton)      

        //self.buttonsView.addConstraintsWithFormat("H:|-10-[v0]-10-[v1(60)]|", views: 
        //    self.saveButton,
        //    self.cancelButton)  

        self.view.addSubview(cancelButton)
        self.view.addConstraintsWithFormat("V:|-10-[v0(50)]|", views: cancelButton)      
        self.view.addConstraintsWithFormat("H:|-10-[v0(50)]|", views: cancelButton)      

        //self.listView.addSubview(listButton)
        //self.listView.addConstraintsWithFormat("H:|-20-[v0]-10-|", views: listButton) 
        //self.listView.addConstraintsWithFormat("V:|[v0]|", views: listButton)  

        self.saveButton.setTitle("  SAVE", for: .normal)
        //self.listButton.setTitle("  YOUR BUG LIST", for: .normal)        

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        let tapImage:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showImage))
        
        pictureImageView.isUserInteractionEnabled = true
        pictureImageView.addGestureRecognizer(tapImage)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                           name: Notification.Name.UIKeyboardWillShow, object: nil)

        self.saveButton.isEnabled = false

        self.activityView = Global.setActivityIndicator(container: self.view, type: Int(NVActivityIndicatorType.ballSpinFadeLoader.hashValue), color: UIColor.gray)

      }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !isEdit {

            self.titleTextField.text = ""
            self.descTextView.text = ""
        }
    }

    @objc func dismissKeyboard() {
       self.view.endEditing(true)

       if self.descTextView.text.count > 0 {
            self.saveButton.isEnabled = true        
       }

    }

    @objc func backButton(sender: UIBarButtonItem) {        
        self.isEdit = false
        self.navigationController?.popViewController(animated: true)
    }

    @objc func showList() {
        
        self.homeController?.showBugList()

    }        

    @objc func handleCancel() {        

        //let letterImageGenerator = LetterImageGenerator()

        let nAImage = LetterImageGenerator.imageWith(name: "NO IMAGE ONLY DESCRIPTION")

        self.pictureImageView.image = nAImage

    }

    @objc func showImage() {

        if self.keyBoardOpened {

            self.view.endEditing(true)

            self.keyBoardOpened = false

        } else {

            var images = [SKPhoto]()   

            let image = SKPhoto.photoWithImage(pictureImageView.image!)
            image.caption = "SCREENSHOT"

            images.append(image)      
            
            let browser = SKPhotoBrowser(photos: images)
            present(browser, animated: true, completion: {})
        }
        
    }


    @objc func handleKeyboardShow(notification: Notification) {        

        self.keyBoardOpened = true

    }

    @objc func handleSave() {
                    
        self.activityView.startAnimating()     

        let bug: PFObject = PFObject(className: "Bugs")                
        
        bug["posterId"] = PFUser.current()?.objectId
        bug["title"] = self.titleTextField.text
        bug["description"] = self.descTextView.text
        bug["approved"] = 1        

        let thumbnail = PFFileObject(name: "bug", data: UIImageJPEGRepresentation(self.pictureImageView.image!, 1.0)!)
    
        bug.setObject(thumbnail!, forKey: "screenshot")             

        bug.saveInBackground { (resutl, error) in
            
            if error == nil {             
                

                self.activityView.startAnimating()     
                
                let title = "Bug reported!"
                let message = "The bug has been reported, please wait appoval. Thanks for submitting!"
                
                let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                    
                    self.isEdit = false
                    self.navigationController?.popToRootViewController(animated: true)                    
                    
                }))
                
                self.present(alert, animated: true)
            }
        }

        /*let title = "Log Out"
        let message = "Are you sure you want to log out?"
        
        var alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes log me out", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            
            PFUser.logOutInBackground { (error) in
            
                NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyLogOut), object: self)
                
            }
            
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alertAction: UIAlertAction!) in
            
               alert.dismiss(animated: true, completion: nil)
    
            
        }))
        
        // show the alert            
        self.appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)



        */

    }

    class LetterImageGenerator: NSObject {
      class func imageWith(name: String?) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = UIColor.gambesDarkColor
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        var initials = ""
        if let initialsArray = name?.components(separatedBy: " ") {
          if let firstWord = initialsArray.first {
            if let firstLetter = firstWord.characters.first {
              initials += String(firstLetter).capitalized
            }
          }
          if initialsArray.count > 1, let lastWord = initialsArray.last {
            if let lastLetter = lastWord.characters.first {
              initials += String(lastLetter).capitalized
            }
          }
        } else {
          return nil
        }
        nameLabel.text = initials
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
          nameLabel.layer.render(in: currentContext)
          let nameImage = UIGraphicsGetImageFromCurrentImageContext()
          return nameImage
        }
        return nil
      }
    }



}
