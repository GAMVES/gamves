//
//  CategoryTableViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/25/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class CategoryTableViewSectionCell: UITableViewCell {   
   

    var backgroundImageView: UIImageView = {        
        let backgroundImageView = UIImageView()        
        backgroundImageView.contentMode = .scaleToFill
        return backgroundImageView
    }()       
      
    var gradientCategory: UIView = {
        let view = UIView()
        return view       
    }()

    var icon: UIImageView = {
        let iconView = UIImageView()
        //iconView.backgroundColor = UIColor.green
        return iconView
    }()
    
    lazy var arrowFordButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "arrow_next_white")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleFordButton), for: .touchUpInside)
        return button
    }()

    var name: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)        
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    	super.init(style: style, reuseIdentifier: reuseIdentifier)
            
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(gradientCategory)
        contentView.addSubview(icon)
        contentView.addSubview(arrowFordButton)
    
        contentView.addConstraintsWithFormat("H:|-10-[v0(60)]-10-|", views: icon)        
        contentView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: icon)

    	contentView.addConstraintsWithFormat("H:|[v0]|", views: gradientCategory)
    	contentView.addConstraintsWithFormat("V:|[v0]|", views: gradientCategory)

        contentView.addConstraintsWithFormat("H:|[v0]|", views: backgroundImageView)
        contentView.addConstraintsWithFormat("V:|[v0]|", views: backgroundImageView)
        
        name = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width - 80, height: self.frame.height))
        
        name.textColor = UIColor.white
        
        name.font = UIFont.boldSystemFont(ofSize: 25.0)
        
        contentView.addSubview(name)        

        contentView.addConstraintsWithFormat("H:|-100-[v0]-10-|", views: name)
        contentView.addConstraintsWithFormat("V:|-10-[v0]|", views: name)
        
        contentView.addConstraintsWithFormat("H:|-250-[v0(60)]-20-|", views: arrowFordButton)
        contentView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: arrowFordButton)

    }
    
    func handleFordButton()
    {
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
