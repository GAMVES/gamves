//
//  CatFanSelectorViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 01/02/2018.
//

import UIKit

class CatFanSelectorViewCell: UICollectionViewCell {
    
    var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let separatorView: UIView = {
        let view = UIView()  
        return view
    }()
    
    let nameLabel: PaddingLabel = {
        let label = PaddingLabel()        
        label.font = UIFont.boldSystemFont(ofSize: 15)        
        label.numberOfLines = 2
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(avatarImage)
        self.addSubview(separatorView)
        self.addSubview(nameLabel)
        
        self.addConstraintsWithFormat("H:|-30-[v0(90)]-30-|", views: avatarImage)
        self.addConstraintsWithFormat("H:|-30-[v0(90)]-30-|", views: separatorView)
        self.addConstraintsWithFormat("H:|[v0(150)]|", views: nameLabel)
        
        self.addConstraintsWithFormat("V:|-20-[v0(90)][v1(5)][v2]|", views: avatarImage, separatorView, nameLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
