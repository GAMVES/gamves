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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let rowView: UIView = {
        let view = UIView()       
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()        
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }() 

     let labelsView: UIView = {
        let view = UIView()       
        view.backgroundColor = UIColor.white
        return view
    }()   

    let videoName: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    let videoDatePublish: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()      
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false        
        textView.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
        textView.textColor = UIColor.lightGray
        return textView
    }()

    let separatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var titleLabelHeightConstraint: NSLayoutConstraint?
    
    override func setupViews() 
    {      

        addSubview(thumbnailImageView) 
        addSubview(rowView) 
        addSubview(separatorView)
        
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: thumbnailImageView)    
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: rowView)    
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: separatorView)      
         
        addConstraintsWithFormat("V:|-16-[v0]-8-[v1(50)]-10-[v2(1)]|", 
            views: thumbnailImageView, rowView, separatorView)
        
        rowView.addSubview(userProfileImageView) 
        rowView.addSubview(labelsView)
        
        rowView.addConstraintsWithFormat("H:|[v0(50)]|", views: userProfileImageView)
        rowView.addConstraintsWithFormat("V:|[v0(50)]|", views: userProfileImageView)

        rowView.addConstraintsWithFormat("H:|-50-[v0]|", views: labelsView)
        rowView.addConstraintsWithFormat("V:|[v0(50)]|", views: labelsView)

        labelsView.addSubview(videoName) 
        labelsView.addSubview(videoDatePublish) 

        labelsView.addConstraintsWithFormat("H:|-10-[v0]|", views: videoName)
        labelsView.addConstraintsWithFormat("V:|[v0(25)]|", views: videoName)

        labelsView.addConstraintsWithFormat("H:|-10-[v0]|", views: videoDatePublish)
        labelsView.addConstraintsWithFormat("V:|-25-[v0(25)]|", views: videoDatePublish)        

        self.separatorView.backgroundColor = UIColor.lightGray
        
    }
    
}
