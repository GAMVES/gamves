//
//  FeedSectionHeader.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-09-05.
//

import UIKit

class FeedSectionHeader: UICollectionViewCell {
    
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor.white
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
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
        self.addConstraintsWithFormat("H:|-10-[v0(28)]|", views: self.iconImageView)
        self.addConstraintsWithFormat("V:|-10-[v0(28)]|", views: self.iconImageView)
        
        self.addSubview(self.nameLabel)
        self.addConstraintsWithFormat("H:|-60-[v0]|", views: self.nameLabel)
        self.addConstraintsWithFormat("V:|-5-[v0(40)]|", views: self.nameLabel)
        
        self.addSubview(self.dividerLineView)
        self.addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        self.addConstraintsWithFormat("V:[v0(0.3)]|", views: dividerLineView)
        
        //self.iconImageView.alpha    = 0.5
        //self.nameLabel.alpha        = 0.5
        //self.dividerLineView.alpha  = 0.5
        
    }
}
