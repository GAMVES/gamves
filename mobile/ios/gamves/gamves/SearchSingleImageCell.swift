//
//  SearchImageCell.swift
//  gamves
//
//  Created by Jose Vigil on 12/29/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class SearchSingleImageCell: UITableViewCell {
    
    
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }

    func setupViews()
    {
    
        self.addSubview(thumbnailImageView)
        
        self.addConstraintsWithFormat("H:[v0]", views: thumbnailImageView)
        self.addConstraintsWithFormat("V:[v0]", views: thumbnailImageView)
    }
    
   
    
}
