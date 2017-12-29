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
        
        let imageWidth = self.frame.width
        
        let imageMetrics = ["iw":imageWidth, "ih":120]
        
        self.addConstraintsWithFormat("H:[v0(iw)]", views: thumbnailImageView, metrics:imageMetrics )
        self.addConstraintsWithFormat("V:[v0(ih)]", views: thumbnailImageView, metrics:imageMetrics)
    }
    
}
