//
//  GiftViewCell.swift
//  gamves
//
//  Created by XCodeClub on 2018-08-09.
//

import UIKit

class GiftViewCell: BaseCell {

	 var checked = Bool()

	 let containerlView: UIView = {
        let view = UIView()              
        return view
    }()

	 //- Thumbnail

	 let thumbnailView: UIView = {
        let view = UIView()              
        return view
    }()
  
    let thumbnailImageView: CustomImageView = {
        let imageView = CustomImageView()        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    //- Row   

    let rowView: UIView = {
        let view = UIView()              
        return view
    }()


    let titleLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()      
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false        
        textView.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
        textView.textColor = UIColor.lightGray
        textView.font = UIFont.systemFont(ofSize: 18)
        return textView
    }()

    //- Numbers   

 	let numbersView: UIView = {
        let view = UIView()              
        return view
    }()

    let labelPriceLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Price"
        return label
    }()

     let priceLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    let labelPointsLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Points"
        return label
    }()

     let pointsLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    let separatorView: UIView = {
        let view = UIView()                
        return view
    }()
    
    var checkView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()    
    
    var titleLabelHeightConstraint: NSLayoutConstraint?
    
    override func setupViews() 
    { 

       self.addSubview(self.containerlView)         
       self.addSubview(self.separatorView)
       
       self.addConstraintsWithFormat("H:|[v0]|", views: self.containerlView)    
       self.addConstraintsWithFormat("H:|[v0]|", views: self.separatorView)    
       
       self.addConstraintsWithFormat("V:|[v0][v1(3)]|", 
            views: self.containerlView, self.separatorView)

 	   self.containerlView.addSubview(self.thumbnailView)         
       self.containerlView.addSubview(self.rowView)

	   self.containerlView.addConstraintsWithFormat("V:|[v0]|", views: self.thumbnailView)    
       self.containerlView.addConstraintsWithFormat("V:|[v0]|", views: self.rowView) 

       self.containerlView.addConstraintsWithFormat("H:|[v0(150)][v1]|", 
            views: self.thumbnailView, self.rowView)

       self.rowView.addSubview(self.titleLabel)         
       self.rowView.addSubview(self.descriptionTextView)
       self.rowView.addSubview(self.numbersView)
        
       self.rowView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.titleLabel)    
       self.rowView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.descriptionTextView)    
       self.rowView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.numbersView)

       self.rowView.addConstraintsWithFormat("V:|-5-[v0(50)]-5-[v1]-5-[v2(40)]|", 
            views: self.titleLabel, self.descriptionTextView, self.numbersView)
       
		self.numbersView.addSubview(self.labelPriceLabel)
		self.numbersView.addSubview(self.priceLabel)
		self.numbersView.addSubview(self.labelPointsLabel)
		self.numbersView.addSubview(self.pointsLabel)
		

		self.numbersView.addConstraintsWithFormat("V:|[v0]|", views: self.labelPriceLabel)    
		self.numbersView.addConstraintsWithFormat("V:|[v0]|", views: self.priceLabel)    
		self.numbersView.addConstraintsWithFormat("V:|[v0]|", views: self.labelPointsLabel)    
		self.numbersView.addConstraintsWithFormat("V:|[v0]|", views: self.pointsLabel)    

		self.rowView.addConstraintsWithFormat("H:|-15-[v0(50)]-5-[v1(100)]-5-[v2(50)]-5-[v3]|", 
            views: self.labelPriceLabel, self.priceLabel, self.labelPointsLabel, self.pointsLabel)
        
        self.separatorView.backgroundColor = UIColor.gray
        
        self.checkView = UIView()        
        
        var checkLabel = UILabel()
        
        checkLabel =  Global.createCircularLabel(text: "✓", size: 30, fontSize: 20.0, borderWidth: 2.0, color: UIColor.gamvesColor) 
        
        let cw = self.frame.width
        let ch = cw * 9 / 16
        
        let pr = cw - 80
        let pt = ch - 60
        
        let paddingMetrics = ["pr":pr,"pt":pt]
        
        self.addSubview(self.checkView)
        self.addConstraintsWithFormat("H:|-pr-[v0(30)]", views: self.checkView, metrics : paddingMetrics)
        self.addConstraintsWithFormat("V:|-pt-[v0(30)]", views: self.checkView, metrics : paddingMetrics)
        
        self.checkView.addSubview(checkLabel)      
        self.checkView.addConstraintsWithFormat("H:|[v0(30)]|", views: checkLabel)
        self.checkView.addConstraintsWithFormat("V:|[v0(30)]|", views: checkLabel)
        

    }
    
}
