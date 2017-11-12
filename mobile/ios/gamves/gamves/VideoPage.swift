//
//  VideoPage.swift
//  gamves
//
//  Created by Jose Vigil on 7/18/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class VideoPage: UIViewController {

    var name: UILabel!


    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red //UIColor(white: 0, alpha: 1)
        return view
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.addSubview(self.controlsContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.controlsContainerView)
        self.view.addConstraintsWithFormat("V:|[v0(100)]|", views: self.controlsContainerView)
       
        name = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        
        name.center = CGPoint(x:160, y:240)
        
        name.textColor = UIColor.black
        
        name.textAlignment = .center
        
        name.sizeToFit()
        
        name.text = "Video"
        
        view.addSubview(name)      
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
