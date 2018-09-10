//
//  FriendSectionHeader.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-15.
//

import UIKit

protocol CustomHeaderViewDelegate: class {
    func selectSection(section: Int)
}

class FanpageSectionHeader: UITableViewCell {

    weak var delegate: CustomHeaderViewDelegate?
    var section: Int?
    
    var nameLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        //label.backgroundColor = UIColor.cyan
        return label
    }()  

    let expandImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "expand_more_white")
        imageView.image = image
        imageView.contentMode = .scaleAspectFill        
        imageView.layer.masksToBounds = true
        return imageView
    }()  

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {

        self.addSubview(self.nameLabel) 
        self.addSubview(self.expandImageView) 

        let width = self.frame.width 
        let imageLeft = width - 30 - 20
        let metricsImage = ["imageLeft":imageLeft]        

        self.addConstraintsWithFormat("H:|-20-[v0(imageLeft)][v1(30)]-20-|", views: self.nameLabel, self.expandImageView, metrics: metricsImage)
        
        self.addConstraintsWithFormat("V:|[v0]|", views: self.nameLabel)
        self.addConstraintsWithFormat("V:|-5-[v0(30)]-5-|", views: self.expandImageView)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnView(sender:)))        
        self.addGestureRecognizer(tapRecognizer)
        
   }
    
    @objc func tapOnView(sender: UIGestureRecognizer) {
       
        self.delegate?.selectSection(section: self.section!)
    }

}


