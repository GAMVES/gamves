//
//  FriendSectionHeader.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-15.
//

import UIKit

class FriendSectionHeader: UICollectionViewCell {


	let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill        
        imageView.tintColor = UIColor.white
        imageView.layer.masksToBounds = true
        return imageView
    }()    
    
    var nameLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = UIColor.black
        return label
    }()

    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {

    	self.addSubview(self.iconImageView)     
        self.addConstraintsWithFormat("H:|-20-[v0(60)]|", views: self.iconImageView)
        self.addConstraintsWithFormat("V:|-20-[v0(60)]|", views: self.iconImageView)

        self.addSubview(self.nameLabel)     
        self.addConstraintsWithFormat("H:|-100-[v0]|", views: self.nameLabel)
        self.addConstraintsWithFormat("V:|-30-[v0(40)]|", views: self.nameLabel)       

        self.addSubview(self.dividerLineView)
        self.addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        self.addConstraintsWithFormat("V:[v0(0.3)]|", views: dividerLineView)

        self.iconImageView.alpha = 0.5
        self.nameLabel.alpha        = 0.5
        self.dividerLineView.alpha  = 0.5 

    }
}
