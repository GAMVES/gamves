//
//  ContactCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/15/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class ContactCell: BaseCell {
    
    var checked = Bool()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            statusLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }
    
    var contact: GamvesUser?
    {
        
        didSet
        {
            nameLabel.text = contact?.name
            
            if let profileImage = contact?.avatar
            {
                profileImageView.image = profileImage
            }
    
            statusLabel.text = contact?.status
            
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        //label.text = "Mark Zuckerberg"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        //label.text = "Your friend's message and something else..."
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    var checkLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    
    override func setupViews() {
        
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        checkLabel =  Global.createCircularLabel(text: "✓", size: 30, fontSize: 24.0, borderWidth: 3.0, color: UIColor.cyberChildrenColor)
        addSubview(checkLabel)
        
        setupContainerView()
        
        addConstraintsWithFormat("H:|-12-[v0(68)]", views: profileImageView)
        addConstraintsWithFormat("V:[v0(68)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat("H:|-82-[v0]|", views: dividerLineView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)
        
        addConstraintsWithFormat("H:|-60-[v0(30)]", views: checkLabel)
        addConstraintsWithFormat("V:|-60-[v0(30)]", views: checkLabel)
    
    }
    
    fileprivate func setupContainerView() {
        let containerView = UIView()
        
        addSubview(containerView)
        
        addConstraintsWithFormat("H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat("V:[v0(50)]", views: containerView)
        
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(statusLabel)
        
        containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: nameLabel)
        
        containerView.addConstraintsWithFormat("V:|[v0][v1(24)]|", views: nameLabel, statusLabel)
        
        containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: statusLabel)
        
    }
   
    
}

