//
//  FanpageViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 8/31/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import PulsingHalo

class WelcomeCollectionViewCell: BaseCell {
    
    var checked = Bool()
  
    let thumbnailImageView: CustomImageView = {
        let imageView = CustomImageView()        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let rowView: UIView = {
        let view = UIView()              
        return view
    }()    

    let labelsView: UIView = {
        let view = UIView()               
        return view
    }()   

    let welcomeTitleLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()

    let welcomeDescLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 2
        return label
    }()         
    

    let separatorView: UIView = {
        let view = UIView()                
        return view
    }()
    
    var checkView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    
    var titleLabelHeightConstraint: NSLayoutConstraint?
    
    override func setupViews() 
    {      
 
        addSubview(thumbnailImageView)         
        addSubview(separatorView)
        addSubview(rowView) 
        
        addConstraintsWithFormat("H:|-6-[v0]-16-|", views: thumbnailImageView)    
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: rowView)    
        addConstraintsWithFormat("H:|-16-[v0]-16-|", views: separatorView)      
         
        addConstraintsWithFormat("V:|-16-[v0]-8-[v1(60)]-10-[v2(3)]|", 
            views: thumbnailImageView, rowView, separatorView)        
         
        rowView.addSubview(labelsView)        
        rowView.addConstraintsWithFormat("H:|[v0]|", views: labelsView)
        rowView.addConstraintsWithFormat("V:|[v0(60)]|", views: labelsView)        

        labelsView.addSubview(welcomeTitleLabel) 
        labelsView.addSubview(welcomeDescLabel) 

        labelsView.addConstraintsWithFormat("H:|[v0]|", views: welcomeTitleLabel)
        labelsView.addConstraintsWithFormat("H:|[v0]|", views: welcomeDescLabel)

        labelsView.addConstraintsWithFormat("V:|[v0(20)][v1(40)]|", views: welcomeTitleLabel, welcomeDescLabel)
        
        self.separatorView.backgroundColor = UIColor.gray      

    }
   
}
