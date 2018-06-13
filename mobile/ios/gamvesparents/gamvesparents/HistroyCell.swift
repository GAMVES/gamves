//
//  ContactCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/15/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class HistoryCell: BaseCell {
    
    var checked = Bool()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            timeLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        //label.text = "Mark Zuckerberg"
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 2
        return label
    }()

    let timeView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()

    let elapsedLabel: UILabel = {
        let label = UILabel()
        //label.text = "Your friend's message and something else..."
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //label.text = "Your friend's message and something else..."
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()  
    
    override func setupViews() {

        //self.backgroundColor = UIColor.gray
        
        addSubview(profileImageView)
        addSubview(dividerLineView)

        setupContainerView()
        
        addConstraintsWithFormat("H:|-12-[v0(68)]", views: profileImageView)
        addConstraintsWithFormat("V:[v0(68)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat("H:|-82-[v0]|", views: dividerLineView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)        
    
    }
    
    fileprivate func setupContainerView() {
        let containerView = UIView()
        
        addSubview(containerView)
        
        addConstraintsWithFormat("H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat("V:|-5-[v0(70)]-5-|", views: containerView)

        //containerView.backgroundColor = UIColor.green
        
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(timeView)       

        //nameLabel.backgroundColor = UIColor.blue
        //timeLabel.backgroundColor = UIColor.red

        containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: nameLabel)
        
        containerView.addConstraintsWithFormat("V:|[v0(50)][v1(20)]|", views: nameLabel, timeView)
        
        containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: timeView)

        timeView.addSubview(timeLabel)
        timeView.addSubview(elapsedLabel)        

        timeView.addConstraintsWithFormat("H:|-5-[v0][v1]-5-|", views: timeLabel, elapsedLabel)        
        timeView.addConstraintsWithFormat("V:|[v0]|", views: timeLabel)
        timeView.addConstraintsWithFormat("V:|[v0]|", views: elapsedLabel)
    }
   
    
}

