//
//  RecommendationViewCell.swift
//  gamvesparents
//
//  Created by Jose Vigil on 15/01/2019.
//  Copyright © 2019 Gamves Parents. All rights reserved.
//

import UIKit

class RecommendationViewCell: BaseCell {


    //- Thumbnail view

    let thumbnailImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    //-Row view

    let rowView: UIView = {
        let view = UIView() 
        //view.backgroundColor = UIColor.green       
        return view
    }()    

    let userView: UIView = {
        let view = UIView()       
        //view.backgroundColor = UIColor.cyan 
        return view
    }()

    let iconView: UIView = {
        let view = UIView()  
        view.layer.cornerRadius = 17.5          
        //view.backgroundColor = UIColor.orange    
        return view
    }() 
    
    let iconImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor.white
        imageView.clipsToBounds = true
        return imageView
    }()

    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    //- Data View
    
    let dataView: UIView = {
        let view = UIView() 
        //view.backgroundColor = UIColor.yellow           
        return view
    }()

    let descTimeDotsView: UIView = {
        let view = UIView() 
        //view.backgroundColor = UIColor.gray           
        return view
    }()           
    
    let posterLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()

    let descTimeView: UIView = {
        let view = UIView() 
        //view.backgroundColor = UIColor.brown           
        return view
    }()               
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.backgroundColor = UIColor.clear    
        textView.textColor = UIColor.gray
        textView.isEditable = false
        return textView
    }()    

    let timeLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.gamvesColor
        label.textAlignment = .right
        return label
    }()
    
    //-DotsView
    
    let dotsView: UIView = {
        let view = UIView()        
        return view
    }()    

    let dotsImageView: CustomImageView = {
        let imageView = CustomImageView()
        var image  = UIImage(named: "dots_hor")?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = UIColor.black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //-Separator

    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray        
        return view
    }()
    
    override func setupViews() {             

        //- Thumbnail view
        
        self.addSubview(self.thumbnailImageView)
        self.addSubview(self.rowView)
        self.addSubview(self.separatorView)
        
        self.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: self.thumbnailImageView)
        self.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: self.rowView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.separatorView)
        
        self.addConstraintsWithFormat("V:|-16-[v0]-8-[v1(100)]-8-[v2(1)]|",
                                 views: self.thumbnailImageView, self.rowView, self.separatorView)        

        //Row View
        self.rowView.addSubview(self.userView)
        self.rowView.addSubview(self.dataView)
        
        self.rowView.addConstraintsWithFormat("V:|[v0(100)]|", views: self.userView)
        self.rowView.addConstraintsWithFormat("V:|[v0(100)]|", views: self.dataView)        
        self.rowView.addConstraintsWithFormat("H:|[v0(100)]-10-[v1]|", views: self.userView, self.dataView)

        self.userView.addSubview(self.userProfileImageView)
        self.userView.addConstraintsWithFormat("H:|-5-[v0(90)]-5-|", views: self.userProfileImageView)
        self.userView.addConstraintsWithFormat("V:|-5-[v0(90)]-5-|", views: self.userProfileImageView)

        self.userView.addSubview(self.iconView)     
        self.userView.addConstraintsWithFormat("H:|-65-[v0(35)]|", views: self.iconView)
        self.userView.addConstraintsWithFormat("V:|-65-[v0(35)]|", views: self.iconView)    

        self.iconView.addSubview(self.iconImageView)
        self.iconView.addConstraintsWithFormat("H:|-7.5-[v0(20)]-7.5-|", views: self.iconImageView)
        self.iconView.addConstraintsWithFormat("V:|-7.5-[v0(20)]-7.5-|", views: self.iconImageView)        

        self.dataView.addSubview(self.posterLabel)
        self.dataView.addSubview(self.descTimeDotsView)
        self.dataView.addConstraintsWithFormat("H:|[v0]|", views: self.posterLabel)
        self.dataView.addConstraintsWithFormat("H:|[v0]|", views: self.descTimeDotsView)
        self.dataView.addConstraintsWithFormat("V:|[v0(30)][v1]|", views: 
            self.posterLabel,
            self.descTimeDotsView)

        self.descTimeDotsView.addSubview(self.descTimeView)        
        self.descTimeDotsView.addSubview(self.dotsView)

        self.dataView.addConstraintsWithFormat("V:|[v0]|", views: self.descTimeView)
        self.dataView.addConstraintsWithFormat("V:|[v0]|", views: self.dotsView)
        self.dataView.addConstraintsWithFormat("H:|[v0][v1(60)]|", views: 
            self.descTimeView,
            self.dotsView)


        self.descTimeView.addSubview(self.descriptionTextView)        
        self.descTimeView.addSubview(self.timeLabel)

        self.descTimeView.addConstraintsWithFormat("H:|[v0]|", views: self.descriptionTextView)
        self.descTimeView.addConstraintsWithFormat("H:|[v0]|", views: self.timeLabel)
        self.dataView.addConstraintsWithFormat("V:|[v0][v1(20)]|", views: 
            self.descriptionTextView,
            self.timeLabel)

        self.dotsView.addSubview(self.dotsImageView)
        self.dotsView.addConstraintsWithFormat("H:|-10-[v0(40)]-10-|", views: self.dotsImageView)
        self.dotsView.addConstraintsWithFormat("V:|[v0(40)]-40-|", views: self.dotsImageView)       
        
    }

    func setThumbnailSize() {
        self.addConstraintsWithFormat("V:|[v0(100)]-8-[v1(1)]|",
                                 views: self.rowView, self.separatorView)        
    } 


    
}
