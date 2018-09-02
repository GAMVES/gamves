//
//  FriendsTableViewCell.swift
//  gamves
//
//  Created by XCodeClub on 2018-07-09.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()

    let containerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark Zuckerberg"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Your friend's message and something else..."
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var checkLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupViews()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    func setupViews() { 

        self.backgroundColor = UIColor.white
        
        self.addSubview(profileImageView)
        self.addSubview(dividerLineView)

        self.addConstraintsWithFormat("H:|-12-[v0(68)]", views: profileImageView)
        self.addConstraintsWithFormat("V:[v0(68)]", views: profileImageView)
        
        self.addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        self.addConstraintsWithFormat("H:|-82-[v0]|", views: dividerLineView)
        self.addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)
        
        self.checkLabel =  Global.createCircularLabel(text: "✓", size: 30, fontSize: 24.0, borderWidth: 3.0, color: UIColor.gamvesColor)
        self.addSubview(checkLabel)           

        self.addSubview(containerView)
        
        self.addConstraintsWithFormat("H:|-90-[v0]|", views: containerView)
        self.addConstraintsWithFormat("V:[v0(50)]", views: containerView)
        
        self.addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        self.containerView.addSubview(nameLabel)
        self.containerView.addSubview(statusLabel)
        
        self.containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: nameLabel)
        
        self.containerView.addConstraintsWithFormat("V:|[v0][v1(24)]|", views: nameLabel, statusLabel)
        
        self.containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: statusLabel)       
        
        
        self.addConstraintsWithFormat("H:|-60-[v0(30)]", views: checkLabel)
        self.addConstraintsWithFormat("V:|-60-[v0(30)]", views: checkLabel)
        
    }   
    

}
