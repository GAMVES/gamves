//
//  FriendCollectionViewCell.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-15.
//

import UIKit

class FriendCollectionViewCell: BaseCell {

	override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            schoolLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            gradeLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()    
    
    var nameLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = UIColor.lightGray
        return label
    }()

    var schoolLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.lightGray
        return label
    }()

    var gradeLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()

    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        return view
    }()

    override func setupViews() {

    	self.addSubview(self.profileImageView)     
        self.addConstraintsWithFormat("H:|-30-[v0(68)]", views: self.profileImageView)
        self.addConstraintsWithFormat("V:[v0(68)]", views: self.profileImageView)

        self.addConstraint(NSLayoutConstraint(item: self.profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        self.addSubview(self.dividerLineView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.dividerLineView)
        self.addConstraintsWithFormat("V:[v0(0.6)]|", views: self.dividerLineView)

        self.addSubview(self.nameLabel)     
        self.addConstraintsWithFormat("H:|-120-[v0]|", views: self.nameLabel)
        self.addConstraintsWithFormat("V:|-10-[v0(40)]|", views: self.nameLabel)

        self.addSubview(self.schoolLabel)     
        self.addConstraintsWithFormat("H:|-120-[v0]|", views: self.schoolLabel)
        self.addConstraintsWithFormat("V:|-40-[v0(30)]|", views: self.schoolLabel)
            
        self.addSubview(self.gradeLabel)     
        self.addConstraintsWithFormat("H:|-120-[v0]|", views: self.gradeLabel)
        self.addConstraintsWithFormat("V:|-70-[v0(20)]|", views: self.gradeLabel)   

    }    
    
}
