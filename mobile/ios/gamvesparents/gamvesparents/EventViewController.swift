//
//  EventViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 25/12/2018.
//  Copyright © 2018 Gamves Parents. All rights reserved.
//

import UIKit
import Parse

class EventViewController: UIViewController {
    
    var tabBarViewController:TabBarViewController?

    var finishRegistrationViewController:FinishRegistrationViewController!   

    var puserId = String()

    override func viewDidLoad() {
        super.viewDidLoad()   

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }     
        
        if !Global.isKeyPresentInUserDefaults(key: "\(self.puserId)_profile_completed") {  

            openFinishRegistration()

        }
        

    }

    func openFinishRegistration() {
        
        finishRegistrationViewController = FinishRegistrationViewController()
        finishRegistrationViewController.eventViewController = self
        finishRegistrationViewController.tabBarController?.tabBar.isHidden = true                
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.pushViewController(finishRegistrationViewController, animated: true, completion: { (reult) in
            
            self.finishRegistrationViewController.hideShowTabBar(status:true)
        })        
        
    }  


}
