//
//  SuggestionCell.swift
//  gamves
//
//  Created by Jose Vigil on 12/29/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class SearchGridImageCell: UITableViewCell {
    
    var imageView_1: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var imageView_2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let imageView_3: UIImageView = {
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
        
        self.addSubview(imageView_1)
        self.addSubview(imageView_2)
        self.addSubview(imageView_3)
    
        let imageWidth = self.frame.width / 3
        
        let imageMetrics = ["iw":imageWidth]
        
        self.addConstraintsWithFormat("H:[v0(iw)][v1(iw)][v2(iw)]", views:
            self.imageView_1,
            self.imageView_2,
            self.imageView_3,
            metrics: imageMetrics)
        
        self.addConstraintsWithFormat("V:[v0(iw)]", views: imageView_1, metrics: imageMetrics)
        self.addConstraintsWithFormat("V:[v0(iw)]", views: imageView_2, metrics: imageMetrics)
        self.addConstraintsWithFormat("V:[v0(iw)]", views: imageView_3, metrics: imageMetrics)
    
    }
    
}
