//
//  AccountCollectionViewCell.swift
//  gamvesparents
//
//  Created by Jose Vigil on 27/01/2018.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit

class AccountCollectionViewCell: BaseCell {

	let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.gray
        return view
    }()

	 lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true        
        return imageView
    }()       
    
    var descLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont.systemFont(ofSize: 16)                
        label.textColor = UIColor.lightGray
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()


    let backView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.gamvesColor.cgColor
        view.layer.borderWidth = 2
        return view
    }()

    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.gray
        return view
    }()

    override func setupViews() {
        super.setupViews()
        
        self.contentView.addSubview(self.backView)

		self.contentView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.backView)
        self.contentView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.backView)

        self.backView.addSubview(self.topView)
        self.backView.addSubview(self.iconImageView)
        self.backView.addSubview(self.descLabel)
        self.backView.addSubview(self.bottomView)

        let width:Int = Int(self.frame.width)   
        let hPadding = (width - 40)  / 2

        var metricsPadding = [String:Int]()

		metricsPadding["hPadding"] = hPadding
        
        self.backView.addConstraintsWithFormat("H:|[v0]|", views: self.topView)
        self.backView.addConstraintsWithFormat("H:|-hPadding-[v0(40)]-hPadding-|", views: 
        	self.iconImageView, metrics: metricsPadding)
        self.backView.addConstraintsWithFormat("H:|[v0]|", views: self.descLabel)
        self.backView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)

		self.backView.addConstraintsWithFormat("V:|[v0(30)][v1(40)][v2][v3(10)]|", views:
			self.topView,
			self.iconImageView, 
			self.descLabel,
			self.bottomView)
        
    }
    
}
