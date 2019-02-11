//
//  RecommendationEmptyViewCell.swift
//  gamvesparents
//
//  Created by Jose Vigil on 21/01/2019.
//  Copyright © 2019 Gamves Parents. All rights reserved.
//

import UIKit

class RecommendationEmptyViewCell: BaseCell {

	let iportanImageView: CustomImageView = {
        let imageView = CustomImageView()
        var image  = UIImage(named: "notification_important")?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = UIColor.gray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

	let messageLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.gray
        label.numberOfLines = 2
        label.textAlignment = .left        
        return label
    }()
    

     override func setupViews() {                     
        
        self.addSubview(self.iportanImageView)
        self.addSubview(self.messageLabel)        
        
        self.addConstraintsWithFormat("V:|-20-[v0(40)]-5-|", views: self.iportanImageView)
        self.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.messageLabel)

        self.addConstraintsWithFormat("H:|-30-[v0(40)]-20-[v1]-30-|", views: self.iportanImageView, self.messageLabel)

    }
}
