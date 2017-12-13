

//
//  ProfileCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/10/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse

class ProfileCell: BaseCell, UIScrollViewDelegate {
    
    let sonViewContent: UIView = {
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
    
    let parentsScrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.cyan
        return v
    }()
    
    // SON VIEW
    
    let sonRowImage: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let leftSonRowImage: UIView = {
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

    let rightSonRowImage: UIView = {
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

    ///////////////////////////

    lazy var yourPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "your_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()

    lazy var sonPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))
        imageView.isUserInteractionEnabled = true        
        imageView.tag = 1
        return imageView
    }()   

    lazy var spousePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spouse_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 2           
        return imageView
    }()

    lazy var familyPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "family_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 3           
        return imageView
    }()
   
    
    override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.sonViewContent)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.sonViewContent)
        
        self.addSubview(self.lineView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
 
        self.addSubview(self.parentsScrollView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.parentsScrollView)
        
        self.addConstraintsWithFormat("V:|[v0(200)][v1(2)][v2]|", views: self.sonViewContent, self.lineView, self.parentsScrollView)
        
        // SON VIEW
        
        self.sonViewContent.addSubview(self.sonRowImage)
        self.sonViewContent.addConstraintsWithFormat("H:|[v0]|", views: self.sonRowImage)
        
        self.sonRowImage.addSubview(self.leftSonRowImage)
        self.sonRowImage.addSubview(self.sonProfileImageView)
        self.sonRowImage.addSubview(self.rightSonRowImage)
        
        self.sonRowImage.addConstraintsWithFormat("V:|[v0]|", views: self.leftSonRowImage)
        self.sonRowImage.addConstraintsWithFormat("V:|[v0]|", views: self.sonProfileImageView)
        self.sonRowImage.addConstraintsWithFormat("V:|[v0]|", views: self.rightSonRowImage)
        
        let width = self.frame.width
        let paddingSon = (width - 100)/2
        let metricsSonView = ["paddingSon": paddingSon]
        
        self.sonRowImage.addConstraintsWithFormat("H:|[v0(paddingSon)][v1(100)][v2(paddingSon)]|", views: self.leftSonRowImage, self.sonProfileImageView, self.rightSonRowImage, metrics: metricsSonView)
        
        let userId = PFUser.current()?.objectId
        
        if let sonImage:UIImage = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.avatar
        {
            self.sonProfileImageView.image = sonImage
            Global.setRoundedImage(image: sonProfileImageView, cornerRadius: 50, boderWidth: 2, boderColor: UIColor.white)
        }
        
        self.sonViewContent.addSubview(self.sonLabel)
        self.sonViewContent.addConstraintsWithFormat("H:|[v0]|", views: self.sonLabel)
        
        self.sonViewContent.addConstraintsWithFormat("V:|-30-[v0(100)][v1(30)]-40-|", views: self.sonRowImage, self.sonLabel)
        
        let name = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.name
        self.sonLabel.text = name
        self.sonLabel.textAlignment = NSTextAlignment.center

    }
    
    override func layoutSubviews() {
        
    }
    
    
}








