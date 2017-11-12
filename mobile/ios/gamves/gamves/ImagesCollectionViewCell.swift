//
//  ImagesCollectionViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/25/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class ImagesCollectionViewCell: BaseCell {
    
    let imageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override func setupViews()
    {
        addSubview(self.imageView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.imageView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.imageView)
    }
    
}
