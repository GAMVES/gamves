//
//  FinishRegistrationViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 07/01/2019.
//  Copyright © 2019 Gamves Parents. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class FinishRegistrationViewController: UIViewController,
ProfileImagesPickerProtocol {

    var you:PFUser!

    var puserId = String()
    
    var yourPhotoImageView:UIImageView!
    var yourPhotoImage:UIImage!
    var yourPhotoImageSmall:UIImage!

    var yourType:PFObject!
    var yourTypeId = Int()
    
    var phoneNumber = String()

    var eventViewController:EventViewController!

    var imagePickerViewController = ImagePickerViewController()
    var activityIndicatorView:NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.you = PFUser.current()

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }

        self.yourTypeId = PFUser.current()?["user_type"] as! Int

        imagePickerViewController.setType(type: ProfileImagesTypes.You)
        
        //print(FinishRegistrationViewController)

        imagePickerViewController.profileImagesPickerProtocol = self       
        
        self.navigationController?.pushViewController(imagePickerViewController, animated: true)   
    }  

    func saveYou(phone:String) {

        if (!phone.isEmpty) {

            self.phoneNumber = phone  

            self.saveYou(completionHandler: { ( resutl ) -> () in
                                
                print("YOU SAVED")
                                
                if resutl {
                    
                    let title = "Congratulations Registration Completed!"
                    var message = "\n\nThanks very much for registering to Gamves. Enjoy the educative videos and add your family! \n\n"                                                            
                    
                    let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                        
                        self.activityIndicatorView?.stopAnimating()
                        self.navigationController?.popViewController(animated: true)                        

                        UserDefaults.standard.setHasPhoneAndImage(value: true)

                        self.hideShowTabBar(status:false)                        
                        
                    }))
                    
                    self.present(alert, animated: true) 

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
        
        self.yourPhotoImageView.image   = croppedImage
        self.yourPhotoImage             = croppedImage
        self.yourPhotoImageSmall        = smallImage
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
        
        //I add the level of all sons
        let levleId = Global.gamvesFamily.sonsUsers[0].levelId as String
        
        for sons in Global.gamvesFamily.sonsUsers {
            let levelId = sons.levelId
            let levelObj = Global.levels[levelId]?.levelObj
            levelRel.add(levelObj!)
        }

        self.you["phone"]  = self.phoneNumber
        
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
