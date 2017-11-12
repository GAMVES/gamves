//
//  CategoryTableViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/25/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {   
         

    var userThumbnail: UIImageView = {
        let iconView = UIImageView()
        //iconView.backgroundColor = UIColor.green
        return iconView
    }()

    let userName: UILabel = {
        let label = UILabel()        
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.orange
        return label
    }()    

    let message: UILabel = {
        let label = UILabel()        
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.gray
        return label
    }()  

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)        
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    	super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.gray
            
        contentView.addSubview(userThumbnail)
        contentView.addSubview(userName)
        contentView.addSubview(message)    
    
        contentView.addConstraintsWithFormat("H:|-10-[v0(60)]-10-|", views: userThumbnail)        
        contentView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: userThumbnail)

    	contentView.addConstraintsWithFormat("H:|-10-[v0]|", views: userName)
    	contentView.addConstraintsWithFormat("V:|-10-[v0]|", views: userName)

        contentView.addConstraintsWithFormat("H:|-80-[v0]|", views: message)
        contentView.addConstraintsWithFormat("V:|-80-[v0]|", views: message)       
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
