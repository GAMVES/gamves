//
//  CategoryCollectionViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/28/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit



class CategoryCollectionViewCell: BaseCell
{
    
    var fanpageImageView: UIImageView = {        
        let fanpageImageView = UIImageView()        
        fanpageImageView.contentMode = .scaleAspectFill //.scaleFill
        fanpageImageView.clipsToBounds = true
        fanpageImageView.backgroundColor = UIColor.gamvesColor
        fanpageImageView.layer.cornerRadius = 10
        return fanpageImageView
    }()

    let fanpageName: UILabel = {
        let label = UILabel()
        //label.text = "Setting"
        //label.font = UIFont.systemFont(ofSize: 14)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    

    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(fanpageImageView)        
        contentView.addSubview(separatorView)
        contentView.addSubview(fanpageName)          

        contentView.addConstraintsWithFormat("H:|-10-[v0(80)]-10-|", views: fanpageImageView)         
        contentView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: separatorView)
        contentView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: fanpageName)
            
        //vertical constraints
        contentView.addConstraintsWithFormat("V:|-10-[v0(80)]-[v1(2)]-[v2]-10-|", views: fanpageImageView, separatorView, fanpageName)

    }    
    
}
