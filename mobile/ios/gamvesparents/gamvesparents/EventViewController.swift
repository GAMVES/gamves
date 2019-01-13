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
    

    var puserId = String()

    override func viewDidLoad() {
        super.viewDidLoad()   

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }             

        if !UserDefaults.standard.isHasPhoneAndImage() {  

            
        }
        

    }

     


}
