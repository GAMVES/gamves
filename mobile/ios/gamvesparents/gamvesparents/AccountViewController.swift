//
//  AccountViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 24/01/2018.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit
import Parse

class AccountViewController: UIViewController {
    
    var homeViewController:HomeViewController?
    
    var tabBarViewController:TabBarViewController?

    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gamvesBackgoundColor
        return view
    }()

     var backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill //.scaleFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let photosContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()

     var yourLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()

      let lineView: UIView = {
         let v = UIView()
         v.translatesAutoresizingMaskIntoConstraints = false
         v.backgroundColor = UIColor.gray
         return v
    }()

    let componentsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.headerView)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.componentsView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.headerView)  
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)  
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.componentsView)  


        let height:Int = Int(view.frame.size.height)
        let componentsHeight = height - 221   

        var metricsComponents = [String:Int]()

        metricsComponents["componentsHeight"] = componentsHeight

        self.view.addConstraintsWithFormat(
            "V:|[v0(220)][v1(1)][v2(componentsHeight)]|", views:
            self.headerView,
            self.lineView,
            self.componentsView,
            metrics: metricsComponents)

        NotificationCenter.default.addObserver(self, selector: #selector(onFamilyLoaded), name: NSNotification.Name(rawValue: Global.notificationKeyFamilyLoaded), object: nil)

    }


    func onFamilyLoaded() {
        //self.getTimeCount()
        self.loadYourProfileInfo()
    }


     func loadYourProfileInfo() {
        
        let queryUser = PFQuery(className:"Profile")
        
        queryUser.whereKey("userId", equalTo: PFUser.current()?.objectId)
        
        queryUser.getFirstObjectInBackground { (profile, error) in
            
            if error == nil {
                
                if let prPF:PFObject = profile {
                
                    if prPF["pictureBackground"] != nil {
                        
                        let backImage = prPF["pictureBackground"] as! PFFile
                    
                        backImage.getDataInBackground { (imageData, error) in
                            
                            if error == nil {
                                
                                if let imageData = imageData {
                                    
                                    let image = UIImage(data:imageData)
                                    
                                    self.backImageView.image = image
                                
                                }
                            }
                        }
                    }
                }
            }
        }
    }





    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()     
    }
    
    

}
