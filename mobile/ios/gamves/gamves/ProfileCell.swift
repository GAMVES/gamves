

//
//  ProfileCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/10/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class ProfileCell: BaseCell, UIScrollViewDelegate {
    
    var metricsHome = [String:Int]()

    var userStatistics = [UserStatistics]()
    
    let registerViewContent: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    let dataView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white
        return v
    }()
    
    // SON VIEW
    
    let registerRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.blue
        return view
    }()
    
    let leftregisterRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var sonProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let rightregisterRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let sonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.backgroundColor = UIColor.white
        return label
    }()   

    

    let footerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.red
        return v
    }()

    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var cellId = String()
    
    var registerOnline = Bool()

    var youRegisterChatId = Int()
    var youSpouseChatId = Int()
    var groupChatId = Int()
   
    
    override func setupViews() {
        super.setupViews()
        
        let width = self.frame.width
        let paddingRegister = (width - 80)/2
        let metricsRegisterView = ["paddingRegister": paddingRegister]
        
        print(metricsRegisterView)

        self.addSubview(self.registerViewContent)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.registerViewContent)
        
        self.addSubview(self.lineView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
 
        self.addSubview(self.dataView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.dataView)
        
        self.addConstraintsWithFormat("V:|[v0(250)][v1(2)][v2]|", views: 
            self.registerViewContent, 
            self.lineView, 
            self.dataView, 
            metrics: metricsRegisterView)
        
        // SON VIEW  

        //registerViewContent.backgroundColor = UIColor.red       
        
        self.registerViewContent.addSubview(self.registerRowView)
        self.registerViewContent.addConstraintsWithFormat("H:|[v0]|", views: self.registerRowView)
        self.registerViewContent.addConstraintsWithFormat("V:|-10-[v0(paddingRegister)]|", views: self.registerRowView,
            metrics: metricsRegisterView)

        //registerViewContent.backgroundColor = UIColor.blue 
        
        self.registerRowView.addSubview(self.leftregisterRowView)
        self.registerRowView.addSubview(self.sonProfileImageView)
        self.registerRowView.addSubview(self.rightregisterRowView)
        
        self.registerRowView.addConstraintsWithFormat("V:|[v0]|", views: self.leftregisterRowView)
        self.registerRowView.addConstraintsWithFormat("V:|[v0]|", views: self.sonProfileImageView)
        self.registerRowView.addConstraintsWithFormat("V:|[v0]|", views: self.rightregisterRowView)    
        
        
        self.registerRowView.addConstraintsWithFormat("H:|[v0(paddingRegister)][v1(80)][v2(paddingRegister)]|", views: 
            self.leftregisterRowView, 
            self.sonProfileImageView, 
            self.rightregisterRowView, 
            metrics: metricsRegisterView)
       
        let userId = PFUser.current()?.objectId
        print(userId)
        
        if let sonImage:UIImage = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.avatar {
            self.sonProfileImageView.image = sonImage
            Global.setRoundedImage(image: sonProfileImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.white)
        }
        
        var metricsVerBudge = [String:Int]()

        let topPadding = 40
        let midPadding =  topPadding / 2
        let smallPadding =  midPadding / 2
        let photoSize:Int = (Int(width) / 4)
        let padding = photoSize / 4      

        self.metricsHome["topPadding"]      = topPadding
        self.metricsHome["midPadding"]      = midPadding
        self.metricsHome["smallPadding"]    = smallPadding
        self.metricsHome["photoSize"]       = photoSize
        self.metricsHome["padding"]         = padding

        metricsVerBudge["verPadding"] = photoSize - 25   

        self.registerViewContent.addSubview(self.sonLabel)
        self.registerViewContent.addConstraintsWithFormat("H:|[v0]|", views: self.sonLabel)

        let name = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.name
        self.sonLabel.text = "Clemente"
        self.sonLabel.textAlignment = NSTextAlignment.center


    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
                
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }

    
  
}








