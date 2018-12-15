//
//  PetViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 08/12/2018.
//  Copyright © 2018 Gamves. All rights reserved.
//


import UIKit

class PetViewCell: BaseCell {

	 var checked = Bool()

	let containerlView: UIView = {
        let view = UIView()              
        return view
    }()

	 //- Thumbnail

	 let thumbnailView: UIView = {
        let view = UIView()              
        return view
    }()
  
    let thumbnailImageView: CustomImageView = {
        let imageView = CustomImageView()        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    //- Row   

    let rowView: UIView = {
        let view = UIView()              
        return view
    }()


    let title: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()      
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false                
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        //label.backgroundColor = UIColor.cyan
        label.numberOfLines = 4
        return label
    }()

    let separatorView: UIView = {
        let view = UIView()                
        return view
    }()

    //- Bottom   

 	let bottomView: UIView = {
        let view = UIView()              
        return view
    }()
    
    //- Check

    var rightContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }() 
    
    var checkView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()    
    
    var titleHeightConstraint: NSLayoutConstraint?
    
    override func setupViews() 
    { 

        self.backgroundColor = UIColor.white
        self.alpha = 0.3

       self.addSubview(self.containerlView)         
       self.addSubview(self.separatorView)
       
       self.addConstraintsWithFormat("H:|[v0]|", views: self.containerlView)    
       self.addConstraintsWithFormat("H:|[v0]|", views: self.separatorView)    
       
       self.addConstraintsWithFormat("V:|[v0][v1(3)]|", 
            views: self.containerlView, self.separatorView)

 	   self.containerlView.addSubview(self.thumbnailView)         
       self.containerlView.addSubview(self.rowView)

	   self.containerlView.addConstraintsWithFormat("V:|[v0]|", views: self.thumbnailView)    
       self.containerlView.addConstraintsWithFormat("V:|[v0]|", views: self.rowView) 

       self.containerlView.addConstraintsWithFormat("H:|-10-[v0(80)][v1]|", 
            views: self.thumbnailView, self.rowView)

       self.thumbnailView.addSubview(self.thumbnailImageView)  
       self.thumbnailView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.thumbnailImageView)     
       self.thumbnailView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.thumbnailImageView)

       self.rowView.addSubview(self.title)         
       self.rowView.addSubview(self.descriptionLabel)
       self.rowView.addSubview(self.bottomView)
        
       self.rowView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.title)    
       self.rowView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.descriptionLabel)    
       self.rowView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.bottomView)

       self.rowView.addConstraintsWithFormat("V:|-15-[v0(50)]-10-[v1]-10-[v2(100)]-10-|", 
            views: self.title, self.descriptionLabel, self.bottomView)

        
        self.separatorView.backgroundColor = UIColor.gray           

    }
    
}

