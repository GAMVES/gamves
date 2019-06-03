//
//  NoConnectionViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 03/01/2019.
//  Copyright © 2019 Gamves Parents. All rights reserved.
//

import UIKit

class NoConnectionViewController: UIViewController {

    var seconds = 6

    let gamvesImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "icon")
        imageView.image = image
        imageView.contentMode = .scaleAspectFill        
        imageView.layer.masksToBounds = true
        return imageView
    }()


    let messageLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 10        
        return label
    }()

    let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white        
        label.font = UIFont.boldSystemFont(ofSize: 80)
        label.textAlignment = .center
        label.backgroundColor = UIColor.cyberChildrenDarkColor              
        return label
    }()

    let bottomView: UIView = {
        let view = UIView()        
        return view
    }()


    var timer = Timer() 

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.messageLabel)
        self.view.addSubview(self.gamvesImageView)
        self.view.addSubview(self.countLabel)
        self.view.addSubview(self.bottomView)
        
        self.messageLabel.text = "There is no internet connection, the application will close. Check the conn∫ection and try again."

        let width = self.view.frame.width
        let height = self.view.frame.height 

        let p = (width - 100) / 2
        let lp = (width - 200) / 2               

        let noMetrics = [
            "p":p, 
            "lp":lp           
        ]        

        self.view.addConstraintsWithFormat("H:|-p-[v0(90)]-p-|", views: 
            self.gamvesImageView,
            metrics: noMetrics)

        self.view.addConstraintsWithFormat("H:|-lp-[v0(190)]-lp-|", views: 
            self.messageLabel,
            metrics: noMetrics)

        self.view.addConstraintsWithFormat("H:|-p-[v0(100)]-p-|", views: 
            self.countLabel,
            metrics: noMetrics)          

        self.view.addConstraintsWithFormat("V:|-50-[v0(90)]-50-[v1(200)][v2(100)][v3]|", views: 
            self.gamvesImageView,
            self.messageLabel,
            self.countLabel,
            self.bottomView,
            metrics: noMetrics)     
        
        self.view.backgroundColor = UIColor.cyberChildrenColor

        self.runTimer()

    }

    func runTimer() { 
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }


    @objc func updateTimer() {
        seconds = seconds - 1       
        self.countLabel.text = "\(seconds)"
        if (seconds == 0) {
            exit(0);
        } 
    }
}
