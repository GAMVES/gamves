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
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGroupPhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()

    var descLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.backgroundColor = UIColor.white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()    

    var dataLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.lightGray
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()    

    override func setupViews() {
        super.setupViews()

        self.contentView.addSubview(self.iconImageView)
        self.contentView.addSubview(self.descLabel)
        self.contentView.addSubview(self.dataLabel)
        
		self.contentView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.iconImageView)
		self.contentView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.descLabel)
		self.contentView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.dataLabel)

        self.contentView.addConstraintsWithFormat("H:|-15-[v0(30)]-10-[v1][v2(100)]|", views: self.iconImageView, self.descLabel, self.dataLabel)		            

    }   
    
}
