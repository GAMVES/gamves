//
//  FriendSectionHeader.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-15.
//

import UIKit

class FriendSectionHeader: UICollectionViewCell {


	let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()    
    
    var nameLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {

    	self.addSubview(self.profileImageView)     
        self.addConstraintsWithFormat("H:|[v0(40)]|", views: self.profileImageView)
        self.addConstraintsWithFormat("V:|[v0(40)]|", views: self.profileImageView)

        self.addSubview(self.nameLabel)     
        self.addConstraintsWithFormat("H:|-60-[v0]|", views: self.nameLabel)
        self.addConstraintsWithFormat("V:|[v0(40)]|", views: self.nameLabel)

    }
}
