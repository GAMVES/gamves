//
//  CustomHeader.swift
//  gamves
//
//  Created by Jose Vigil on 2018-07-04.
//

import UIKit

protocol CustomHeaderDelegate: class {
    func didTapButton(in section: Int)
}

// define CustomHeader class with necessary `delegate`, `@IBOutlet` and `@IBAction`:

class CustomHeader: UITableViewHeaderFooterView {
    
    var delegate: CustomHeaderDelegate?
    
    let upperView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        return view
    }()
    
    var arrowUpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "arrow_up_text_white")
        return imageView
    }()
    
    let tipLabel: UILabel = {
        let label = UILabel()
        label.text="Type keywords to find your video"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = UIColor.white
        return label
    }()
    
    ////////
    
    
    let helpLabel: UILabel = {
        let label = UILabel()
        label.text="Or select suggestions below"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = UIColor.white
        return label
    }()
    
    var helpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "help_white")
        return imageView
    }()
    
    
    var sectionNumber: Int!  // you don't have to do this, but it can be useful to have reference back to the section number so that when you tap on a button, you know which section you came from
    
    /*func didTapButton(_ sender: AnyObject) {
     delegate?.didTapButton(in: sectionNumber)
     }*/
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        //self.delegate = self as! CustomHeaderDelegate
        
        self.addSubview(upperView)
        self.addSubview(bottomView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: upperView)
        self.addConstraintsWithFormat("H:|[v0]|", views: bottomView)
        
        self.addConstraintsWithFormat("V:|[v0(60)][v1(60)]|", views:
            upperView,
                                      bottomView)
        
        upperView.addSubview(arrowUpImageView)
        upperView.addSubview(tipLabel)
        
        upperView.addConstraintsWithFormat("V:|-10-[v0(40)]|", views: arrowUpImageView)
        upperView.addConstraintsWithFormat("V:|-10-[v0(40)]-10-|", views: tipLabel)
        
        upperView.addConstraintsWithFormat("H:|-10-[v0(40)]-10-[v1]|", views:
            arrowUpImageView,
                                           tipLabel)
        
        /////////////
        
        bottomView.addSubview(helpLabel)
        bottomView.addSubview(helpImageView)
        
        bottomView.addConstraintsWithFormat("V:|[v0]|", views: helpLabel)
        bottomView.addConstraintsWithFormat("V:|-10-[v0(40)]-10-|", views: helpImageView)
        
        bottomView.addConstraintsWithFormat("H:|-40-[v0]-10-[v1(40)]-10-|", views:
            helpLabel,
                                            helpImageView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


