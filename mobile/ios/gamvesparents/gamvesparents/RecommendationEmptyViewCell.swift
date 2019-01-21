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
        imageView.tintColor = UIColor.black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

	let messageLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.gamvesColor
        label.textAlignment = .right        
        return label
    }()
    

     override func setupViews() {             

        //- Thumbnail view
        
        self.addSubview(self.iportanImageView)
        self.addSubview(self.messageLabel)        
        
        self.addConstraintsWithFormat("V:|-5-[v0(40)]-5-|", views: self.iportanImageView)
        self.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.messageLabel)

        self.addConstraintsWithFormat("H:|-40-[v0(40)]-40-[v1]|", views: self.iportanImageView, self.messageLabel)

    }
}
