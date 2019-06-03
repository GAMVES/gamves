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

class CustomHeader: UITableViewHeaderFooterView {
    
    var delegate: CustomHeaderDelegate?

    let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyberChildrenColor
        return view
    }()

    let rowsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyberChildrenColor
        return view
    }()
    
    let upperView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyberChildrenColor
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyberChildrenColor
        return view
    }()

    let rightView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyberChildrenColor
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

    var arrowDownImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "arrow_down")
        return imageView
    }()

     let sectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        return view
    }()

     let firstLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left        
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.gray
        return label
    }()    
    
    var sectionNumber: Int!  // you don't have to do this, but it can be useful to have reference back to the section number so that when you tap on a button, you know which section you came from
         
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    
        self.addSubview(infoView)
        self.addSubview(sectionView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: infoView)
        self.addConstraintsWithFormat("H:|[v0]|", views: sectionView)
        
        self.addConstraintsWithFormat("V:|[v0(80)][v1(40)]|", views:
            infoView,            
            sectionView)   

        self.infoView.addSubview(rowsView)  
        self.infoView.addSubview(rightView) 

        self.infoView.addConstraintsWithFormat("V:|[v0]|", views: rowsView)
        self.infoView.addConstraintsWithFormat("V:|[v0]|", views: rightView)

        self.infoView.addConstraintsWithFormat("H:|[v0][v1(80)]|", views: rowsView, rightView)

        self.rowsView.addSubview(upperView)
        self.rowsView.addSubview(bottomView)

        self.rowsView.addConstraintsWithFormat("H:|[v0]|", views: upperView)
        self.rowsView.addConstraintsWithFormat("H:|[v0]|", views: bottomView)

        self.rowsView.addConstraintsWithFormat("V:|[v0(40)][v1(40)]|", views: upperView, bottomView)

        //self.helpImageView.backgroundColor = UIColor.cyan

        self.rightView.addSubview(helpImageView)
        self.rightView.addConstraintsWithFormat("H:|-20-[v0(60)]-20-|", views: helpImageView)
        self.rightView.addConstraintsWithFormat("V:|-20-[v0(60)]-20-|", views: helpImageView)

        self.upperView.addSubview(arrowUpImageView)
        self.upperView.addSubview(tipLabel)
        
        self.upperView.addConstraintsWithFormat("V:|-10-[v0(40)]|", views: arrowUpImageView)
        self.upperView.addConstraintsWithFormat("V:|-10-[v0(40)]-10-|", views: tipLabel)
        
        self.upperView.addConstraintsWithFormat("H:|-10-[v0(30)]-10-[v1]|", views:
            arrowUpImageView,
            tipLabel)       
                
        ///////////
        
        self.bottomView.addSubview(helpLabel)
        self.bottomView.addSubview(arrowDownImageView)
        
        self.bottomView.addConstraintsWithFormat("V:|[v0]|", views: helpLabel)
        self.bottomView.addConstraintsWithFormat("V:|-10-[v0(40)]-10-|", views: arrowDownImageView)
        
        self.bottomView.addConstraintsWithFormat("H:|-40-[v0]-10-[v1(40)]-10-|", views:
            helpLabel,
            arrowDownImageView)

        //self.arrowDownImageView.backgroundColor = UIColor.green

        self.sectionView.addSubview(firstLabel)
        self.sectionView.addConstraintsWithFormat("V:|-10-[v0(20)]-10-|", views: firstLabel)
        self.sectionView.addConstraintsWithFormat("H:|-20-[v0(100)]|", views: firstLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


