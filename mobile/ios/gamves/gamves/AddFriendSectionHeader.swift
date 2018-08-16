//
//  AddFeedSectionHeader.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-15.
//

import UIKit

class AddFriendSectionHeader: UITableViewHeaderFooterView {


    let containerView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.black
        return view
    }()    

	let schoolIconImageView: UIImageView = {
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

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {

        self.addSubview(self.containerView) 
        self.addConstraintsWithFormat("H:|[v0]|", views: self.containerView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.containerView)

    	self.containerView.addSubview(self.schoolIconImageView)     
        self.containerView.addConstraintsWithFormat("H:|-10-[v0(28)]|", views: self.schoolIconImageView)
        self.containerView.addConstraintsWithFormat("V:|-10-[v0(28)]|", views: self.schoolIconImageView)

        self.containerView.addSubview(self.nameLabel)     
        self.containerView.addConstraintsWithFormat("H:|-60-[v0]|", views: self.nameLabel)
        self.containerView.addConstraintsWithFormat("V:|-5-[v0(40)]|", views: self.nameLabel)       

        self.containerView.addSubview(self.dividerLineView)
        self.containerView.addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        self.containerView.addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)      

    }
}
