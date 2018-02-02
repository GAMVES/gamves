//
//  ChooseAvatarView.swift
//  gamves
//
//  Created by Jose Vigil on 02/02/2018.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit

protocol ChooseAvatarProtocol {
    func handleIcon()
}

class ChooseAvatarView: UIView {
    
    var delegateChooseAvatar:ChooseAvatarProtocol!

    //-- ICON
    
    let iconContView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesBackgoundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    let iconLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Avatar"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        //label.backgroundColor = UIColor.white
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "camera")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var iconButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleIcon), for: .touchUpInside)
        button.layer.cornerRadius = 5
        //button.backgroundColor = UIColor.gray
        return button
    }()
    
    var backgroundIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
        //imageView.backgroundColor = UIColor.green
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.iconContView)
        self.addConstraintsWithFormat("H:[v0]|", views: self.iconContView)
        self.addConstraintsWithFormat("V:[v0]|", views: self.iconContView)
        
        self.iconContView.addSubview(self.iconImage)
        self.iconContView.addSubview(self.iconLabel)
        
        self.iconContView.addConstraintsWithFormat("H:|-15-[v0(50)]-15-|", views: self.iconImage)
        self.iconContView.addConstraintsWithFormat("H:|[v0(80)]|", views: self.iconLabel)
        
        self.iconContView.addConstraintsWithFormat(
            "V:|-5-[v0(50)][v1(20)]-5-|", views:
            self.iconImage,
            self.iconLabel)
        
        self.addSubview(self.iconButton)
        self.addSubview(self.backgroundIconImage)
        
    }
    
    func handleIcon() {
        self.delegateChooseAvatar.handleIcon()
    }
    
    func clear() {
        self.iconImage.image = nil
        self.backgroundIconImage.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
