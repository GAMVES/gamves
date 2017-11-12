//
//  GroupUserCollectionViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/22/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class GroupUserCollectionViewCell: BaseCell
{
    
    var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill //.scaleFill
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor.red
        return profileImageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        //label.text = "Setting"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        //label.backgroundColor = UIColor.cyan
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        
        contentView.addConstraintsWithFormat("H:|-10-[v0(80)]-10-|", views: profileImageView)
        contentView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: nameLabel)
        
        //vertical constraints
        contentView.addConstraintsWithFormat("V:|-10-[v0(80)][v1]|", views: profileImageView, nameLabel)
        
    }        
    
}
