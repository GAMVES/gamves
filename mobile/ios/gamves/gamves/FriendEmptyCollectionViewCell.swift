//
//  FriendEmptyCollectionViewCell.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-07-16.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit

class FriendEmptyCollectionViewCell: BaseCell {

	 var messageLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()


    override func setupViews() {

    	self.addSubview(self.messageLabel)     
        self.addConstraintsWithFormat("H:|[v0]|", views: self.messageLabel)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.messageLabel)

    }      
    
    
}
