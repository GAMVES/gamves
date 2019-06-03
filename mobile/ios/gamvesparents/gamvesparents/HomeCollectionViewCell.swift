//
//  HomeCollectionViewCell.swift
//  gamvesparents
//
//  Created by Jose Vigil on 11/20/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: BaseCell {	

    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true        
        return imageView
    }()
    
    var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left        
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textColor = UIColor.darkGray
        label.fitTextToBounds()
        return label
    }()

     lazy var secondIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true        
        return imageView
    }()
    
    var dataLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)                
        label.textColor = UIColor.darkGray
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.numberOfLines = 2
        label.fitTextToBounds()
        return label
    }()

    let backView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.cyberChildrenColor.cgColor
        view.layer.borderWidth = 1.5
        return view
    }()
    
    override func setupViews() {
        super.setupViews()

        self.contentView.addSubview(self.backView)
        self.contentView.addConstraintsWithFormat("H:|[v0]|", views: self.backView)
        self.contentView.addConstraintsWithFormat("V:|-7-[v0]-7-|", views: self.backView)
        
        self.backView.addSubview(self.iconImageView)
        self.backView.addSubview(self.descLabel)
        self.backView.addSubview(self.secondIconImageView)
        self.backView.addSubview(self.dataLabel)
        
        self.backView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.iconImageView)
        self.backView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.descLabel)
        self.backView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.secondIconImageView)
        self.backView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.dataLabel)
        
        self.backView.addConstraintsWithFormat("H:|-10-[v0(30)]-5-[v1][v2(30)][v3(120)]|", views: 
            self.iconImageView, 
            self.descLabel, 
            self.secondIconImageView,
            self.dataLabel)
        
    }

}
