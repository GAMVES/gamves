//
//  FriendApprovalCell.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-07-12.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit
import QuartzCore

class FriendApprovalCell: BaseCell {
    
    var checked = Bool()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            statusLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }

    let containerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.cyan
        return view
    }() 
    
    let typeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyan   
        return view
    }()

    let typeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill        
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let typeLabel: UILabel = {
        let label = UILabel()        
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.layer.cornerRadius = 10
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = UIColor.white        
        return label
    }()    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        return view
    }()
    
    
    var nameLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()        
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var checkLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override func setupViews() {
        
        self.addSubview(self.profileImageView)
        self.addSubview(self.dividerLineView)
        
        self.setupContainerView()
        
        self.addConstraintsWithFormat("H:|-12-[v0(68)]", views: self.profileImageView)
        self.addConstraintsWithFormat("V:[v0(68)]", views: self.profileImageView)
        
        self.addConstraint(NSLayoutConstraint(item: self.profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.dividerLineView)
        self.addConstraintsWithFormat("V:[v0(0.3)]|", views: self.dividerLineView)
        
    }
    
    func setCheckLabel(color:UIColor, symbol:String) {
        
        self.checkLabel =  Global.createCircularLabel(text: symbol, size: 30, fontSize: 24.0, borderWidth: 3.0, color:color ) //UIColor.gamvesColor)
        self.addSubview(self.checkLabel)
        
        self.addConstraintsWithFormat("H:|-50-[v0(30)]", views: self.checkLabel)
        self.addConstraintsWithFormat("V:|-60-[v0(30)]", views: self.checkLabel)
        
    }
    
    fileprivate func setupContainerView() {      
        
        self.addSubview(self.containerView)
        self.addSubview(self.typeView)        
        
        self.addConstraintsWithFormat("H:|-90-[v0][v1(80)]-10-|", views: self.containerView, self.typeView)
        
        self.addConstraintsWithFormat("V:[v0(50)]", views: self.containerView)
        self.addConstraintsWithFormat("V:[v0(100)]", views: self.typeView)
        
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.typeView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        self.containerView.addSubview(self.nameLabel)
        self.containerView.addSubview(self.statusLabel)
        
        self.containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: self.nameLabel)
        self.containerView.addConstraintsWithFormat("V:|[v0]-10-[v1(24)]|", views: self.nameLabel, self.statusLabel)
        self.containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: self.statusLabel)    

        self.typeView.addSubview(self.typeIcon)
        self.typeView.addSubview(self.typeLabel)
        
        self.typeView.addConstraintsWithFormat("H:|[v0]|", views: self.typeIcon)
        self.typeView.addConstraintsWithFormat("H:|[v0]|", views: self.typeLabel)    
        self.typeView.addConstraintsWithFormat("V:|[v0]-10-[v1]|", views: self.typeIcon, self.typeLabel)       
     
        
    }
    
}
