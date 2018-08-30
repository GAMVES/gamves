//
//  SuggestionCell.swift
//  gamves
//
//  Created by Jose Vigil on 12/29/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class SearchGridImageCell: UITableViewCell {
    
    var button_1: UIButton = {
        let imageView = UIButton()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var button_2: UIButton = {
        let imageView = UIButton()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let button_3: UIButton = {
        let imageView = UIButton()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    weak var delegate: TableViewCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }
    
    func setupViews()
    {
        
        self.addSubview(button_1)
        self.addSubview(button_2)
        self.addSubview(button_3)
    
        let imageWidth = self.frame.width / 3
        
        let imageMetrics = ["iw":imageWidth]
        
        self.addConstraintsWithFormat("H:[v0(iw)][v1(iw)][v2(iw)]", views:
            self.button_1,
            self.button_2,
            self.button_3,
            metrics: imageMetrics)
        
        self.addConstraintsWithFormat("V:[v0(iw)]", views: button_1, metrics: imageMetrics)
        self.addConstraintsWithFormat("V:[v0(iw)]", views: button_2, metrics: imageMetrics)
        self.addConstraintsWithFormat("V:[v0(iw)]", views: button_3, metrics: imageMetrics)
        
        //Add Action Methods to UIButtons
        button_1.addTarget(self, action: #selector(FisrtButtonClick(_:)), for: .touchUpInside)
        button_2.addTarget(self, action: #selector(SecondButtonClick(_:)), for: .touchUpInside)
        button_3.addTarget(self, action: #selector(ThirdButtonClick(_:)), for: .touchUpInside)
        
    }
    
    @objc func FisrtButtonClick(_ sender: UIButton)  {
        
        delegate?.button_1_tapped(self)
    
    }
    
    @objc func SecondButtonClick(_ sender: UIButton)  {
        
        delegate?.button_2_tapped(self)
    
    }
    
    @objc func ThirdButtonClick(_ sender: UIButton)  {
        
        delegate?.button_3_tapped(self)
        
    }
    
}
