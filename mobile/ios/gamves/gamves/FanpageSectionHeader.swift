//
//  FriendSectionHeader.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-15.
//

import UIKit

class FanpageSectionHeader: UICollectionReusableView {
    
    var nameLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        //label.backgroundColor = UIColor.cyan
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

        self.addSubview(self.nameLabel)     
        self.addConstraintsWithFormat("H:|-20-[v0]|", views: self.nameLabel)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.nameLabel)       
        
   }
}
