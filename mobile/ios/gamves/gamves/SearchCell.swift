//
//  SearchCell.swift
//  gamves
//
//  Created by Jose Vigil on 12/4/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    
    var checked = Bool()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            titleLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            descLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }    
    
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        //label.text = "Mark Zuckerberg"
        label.font = UIFont.systemFont(ofSize: 16)
        //label.backgroundColor = UIColor.cyan
        return label
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        //label.text = "Your friend's message and something else..."
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        //label.backgroundColor = UIColor.green
        return label
    }()    

    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        //label.backgroundColor = UIColor.gray
        return label
    }()
    
    var delegate:VidewVideoProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)      
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }
    
    func setupViews()
    {

        addSubview(thumbnailImageView)
        addSubview(dividerLineView)               
        
        setupContainerView()
        
        addConstraintsWithFormat("H:|-12-[v0(68)]", views: thumbnailImageView)
        addConstraintsWithFormat("V:[v0(68)]", views: thumbnailImageView)

        thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickThumbnail)))       
        
        addConstraint(NSLayoutConstraint(item: thumbnailImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat("H:|-82-[v0]|", views: dividerLineView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)          
    }
    
    func clickThumbnail(sender: UIPanGestureRecognizer)
    {        
        let rowid:Int = Int((sender.view?.tag)!)
        if delegate != nil {
            delegate?.openVideoById(id: rowid)
        }        
    }
    

    fileprivate func setupContainerView() {
         let containerView = UIView()
        
        addSubview(containerView)
        
        addConstraintsWithFormat("H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat("V:[v0(50)]", views: containerView)
        
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(descLabel)
        containerView.addSubview(timeLabel)       
        
        containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: titleLabel)
        
        containerView.addConstraintsWithFormat("V:|[v0][v1][v2]|", views: titleLabel, descLabel, timeLabel)
        
        containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: descLabel)
        containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: timeLabel)

        
    }

    
    
}


