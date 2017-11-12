//
//  FanpageViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 8/31/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: BaseCell {  
  
    
    let thumbnailImageView: CustomImageView = {
        let imageView = CustomImageView()
        //imageView.image = UIImage(named: "taylor_swift_blank_space")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let userProfileImageView: CustomImageView = {
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
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        //textView.text = "TaylorSwiftVEVO • 1,604,684,607 views • 2 years ago"
        textView.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
        textView.textColor = UIColor.lightGray
        return textView
    }()
    
    var titleLabelHeightConstraint: NSLayoutConstraint?
    
    override func setupViews() 
    {
        
        addSubview(thumbnailImageView) 
        addSubview(descriptionTextView)   
        addSubview(separatorView)
        
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: thumbnailImageView)
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: descriptionTextView)
        addConstraintsWithFormat("H:|[v0]|", views: separatorView)      
        
        //vertical constraints
        addConstraintsWithFormat("V:|-16-[v0]-8-[v1(44)]-36-[v2(1)]|", 
            views: thumbnailImageView, descriptionTextView, separatorView)        

        self.separatorView.backgroundColor = UIColor.lightGray
        
    }

    
}
