//
//  ImagesCollectionViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/25/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: BaseCell {
    
    let imageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()

    override func setupViews()
    {
        self.addSubview(self.imageView) 
        self.addSubview(self.nameLabel)        

        self.addConstraintsWithFormat("H:|[v0]|", views: self.imageView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.nameLabel)

        self.addConstraintsWithFormat("V:|[v0][v1]|", views: self.imageView, self.nameLabel)
        

    }
    
}
