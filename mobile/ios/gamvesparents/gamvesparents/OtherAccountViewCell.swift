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
        profileImageView.contentMode = .scaleAspectFill 
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor.red
        return profileImageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()                
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .left                        
        label.numberOfLines = 2
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        self.addSubview(vendorImageView)
        self.addSubview(nameLabel)           
        
        self.addConstraintsWithFormat("H:|-20-[v0(80)]-20-[v1]|", views: self.vendorImageView, self.nameLabel)

        self.addConstraintsWithFormat("V:|-10-[v0(80)]-10-|", views: self.vendorImageView)
        self.addConstraintsWithFormat("V:|-10-[v0(80)]-10-|", views: self.nameLabel)
        
    }
    
}