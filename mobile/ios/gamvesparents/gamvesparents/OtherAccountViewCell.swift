//
//  OtherAccountViewCell.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-09-04.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit

class OtherAccountViewCell: BaseCell {
    
    var vendorImageView: UIImageView = {
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
        
        contentView.addSubview(vendorImageView)
        contentView.addSubview(nameLabel)
        
        contentView.addConstraintsWithFormat("H:|-10-[v0(80)]-10-|", views: vendorImageView)
        contentView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: nameLabel)
        
        //vertical constraints
        contentView.addConstraintsWithFormat("V:|-10-[v0(80)][v1]|", views: vendorImageView, nameLabel)
        
    }
    
}
