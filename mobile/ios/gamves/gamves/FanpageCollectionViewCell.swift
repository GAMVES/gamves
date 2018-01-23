//
//  FanpageViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 8/31/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class FanpageCollectionViewCell: BaseCell {
    
       
    let thumbnailImageView: CustomImageView = {
        let imageView = CustomImageView()
        //imageView.image = UIImage(named: "taylor_swift_blank_space")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let detailView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.cyan
        return view
    }()
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        //imageView.image = UIImage(named: "taylor_swift_profile")
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    let centerlView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.cyan
        return view
    }()
    
    let createdByLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "created by"
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = UIColor.gray
        return label
    }()
    
    let authorImageView: CustomImageView = {
        let imageView = CustomImageView()
        //imageView.image = UIImage(named: "taylor_swift_profile")
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        return view
    }()
    
    var titleLabelHeightConstraint: NSLayoutConstraint?
    var createdByViewHeightConstraint: NSLayoutConstraint?
    
    var isLineHidden = Bool()

    override func setupViews() 
    {
        addSubview(thumbnailImageView)
        addSubview(detailView)
        addSubview(separatorView)
        
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: thumbnailImageView)
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: detailView)
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: separatorView)
        
        addConstraintsWithFormat("V:|-16-[v0]-8-[v1(44)]-8-[v2(1)]|", views: thumbnailImageView, detailView, separatorView)
        
        detailView.addSubview(userProfileImageView)
        detailView.addSubview(titleLabel)
        detailView.addSubview(centerlView)
        detailView.addSubview(createdByLabel)
        detailView.addSubview(authorImageView)
        
        detailView.addConstraintsWithFormat("V:|[v0]|", views: userProfileImageView)
        detailView.addConstraintsWithFormat("V:|[v0]|", views: titleLabel)
        detailView.addConstraintsWithFormat("V:|[v0]|", views: centerlView)
        detailView.addConstraintsWithFormat("V:|[v0]-30-|", views: createdByLabel)
        detailView.addConstraintsWithFormat("V:|[v0]|", views: authorImageView)
        
        addConstraintsWithFormat("H:|[v0(44)]-8-[v1(200)][v2][v3(50)][v4(44)]|", views:
            userProfileImageView,
            titleLabel,
            centerlView,
            createdByLabel,
            authorImageView)

        self.separatorView.backgroundColor = UIColor.gray
        
    }
    
    override func layoutSubviews() {
        
        if isLineHidden {
            
            self.separatorView.isHidden = true
            
        }
        
    }

    
}
