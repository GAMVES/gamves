//
//  BugsViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 19/11/2018.
//  Copyright © 2018 Gamves. All rights reserved.
//

import UIKit

class BugsViewCell: BaseCell {


	var checked = Bool()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            statusLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    
    var nameLabel: UILabel = {
        let label = UILabel()
        //label.backgroundColor = UIColor.cyan
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        //label.backgroundColor = UIColor.red
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    var checkLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    /*let typeLabel: UILabel = {
        let label = UILabel()
        //label.text = "Your friend's message and something else..."
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()*/
    
    override func setupViews() {
        
        addSubview(profileImageView)
        addSubview(dividerLineView)    
        
        setupContainerView()
        
        addConstraintsWithFormat("H:|-12-[v0(68)]", views: profileImageView)
        addConstraintsWithFormat("V:[v0(68)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat("H:|-82-[v0]|", views: dividerLineView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)      
    
    }

    func setCheckLabel(color:UIColor, symbol:String) {

        checkLabel =  Global.createCircularLabel(text: symbol, size: 30, fontSize: 24.0, borderWidth: 3.0, color:color ) //UIColor.gamvesColor)
        addSubview(checkLabel)

        addConstraintsWithFormat("H:|-50-[v0(30)]", views: checkLabel)
        addConstraintsWithFormat("V:|-60-[v0(30)]", views: checkLabel)

    }
    
    fileprivate func setupContainerView() {
        
        let containerView = UIView()
        let nameStatusView = UIView()
        
        addSubview(containerView)
        addSubview(nameStatusView)
        
        //addConstraintsWithFormat("H:|-90-[v0][v1]|", views: containerView, nameStatusView)
        addConstraintsWithFormat("H:|-90-[v0]|", views: containerView)
        
        addConstraintsWithFormat("V:[v0(50)]", views: containerView)
        //addConstraintsWithFormat("V:[v0(50)]", views: nameStatusView)
        
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(statusLabel)
        
        containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: nameLabel)
        containerView.addConstraintsWithFormat("V:|[v0]-10-[v1(20)]|", views: nameLabel, statusLabel)
        containerView.addConstraintsWithFormat("H:|[v0]-12-|", views: statusLabel)
        
        //nameStatusView.addSubview(typeLabel)
        //nameStatusView.addConstraintsWithFormat("H:|[v0]-20-|", views: typeLabel)
        //nameStatusView.addConstraintsWithFormat("V:|-20-[v0]|", views: typeLabel)
        
    }

    
	/*let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.gray
        return view
    }()

	 lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true        
        return imageView
    }()       
    
    var descLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont.systemFont(ofSize: 16)                
        label.textColor = UIColor.lightGray
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()


    let backView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.gamvesColor.cgColor
        view.layer.borderWidth = 2
        return view
    }()

    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.gray
        return view
    }()

    override func setupViews() {
        super.setupViews()
        
        self.contentView.addSubview(self.backView)

		self.contentView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.backView)
        self.contentView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.backView)

        self.backView.addSubview(self.topView)
        self.backView.addSubview(self.iconImageView)
        self.backView.addSubview(self.descLabel)
        self.backView.addSubview(self.bottomView)

        let width:Int = Int(self.frame.width)   
        let hPadding = (width - 40)  / 2

        var metricsPadding = [String:Int]()

		metricsPadding["hPadding"] = hPadding
        
        self.backView.addConstraintsWithFormat("H:|[v0]|", views: self.topView)
        self.backView.addConstraintsWithFormat("H:|-hPadding-[v0(40)]-hPadding-|", views: 
        	self.iconImageView, metrics: metricsPadding)
        self.backView.addConstraintsWithFormat("H:|[v0]|", views: self.descLabel)
        self.backView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)

		self.backView.addConstraintsWithFormat("V:|[v0(30)][v1(40)][v2][v3(10)]|", views:
			self.topView,
			self.iconImageView, 
			self.descLabel,
			self.bottomView)
        
    }*/
    
}
