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
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false                
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        //label.backgroundColor = UIColor.cyan
        label.numberOfLines = 4
        return label
    }()

    //- Bottom   

 	let bottomView: UIView = {
        let view = UIView()              
        return view
    }()

     //- Numbers   

    let numbersView: UIView = {
        let view = UIView()              
        return view
    }()   

    //- Price  

    let priceRowView: UIView = {
        let view = UIView()              
        return view
    }()    

    let labelPriceLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Price U$S"
        label.textColor = UIColor.gray
        label.textAlignment = .left  
        return label
    }()

     let priceLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .left 
        return label
    }()

     //- Points  

    let pointsRowView: UIView = {
        let view = UIView()              
        return view
    }() 

    let labelPointsLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.gray
        label.textAlignment = .left  
        label.text = "Points"
        return label
    }()

     let pointsLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .left 
        return label
    }()

    let separatorView: UIView = {
        let view = UIView()                
        return view
    }()

    //- Check

    var rightContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
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

        self.backgroundColor = UIColor.white
        self.alpha = 0.3

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

       self.thumbnailView.addSubview(self.thumbnailImageView)  
       self.thumbnailView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.thumbnailImageView)     
       self.thumbnailView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.thumbnailImageView)

       self.rowView.addSubview(self.titleLabel)         
       self.rowView.addSubview(self.descriptionLabel)
       self.rowView.addSubview(self.bottomView)
        
       self.rowView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.titleLabel)    
       self.rowView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.descriptionLabel)    
       self.rowView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.bottomView)

       self.rowView.addConstraintsWithFormat("V:|-15-[v0(50)]-10-[v1]-10-[v2(100)]-10-|", 
            views: self.titleLabel, self.descriptionLabel, self.bottomView)

        self.bottomView.addSubview(self.numbersView)
        self.bottomView.addSubview(self.rightContainerView)

        self.bottomView.addConstraintsWithFormat("V:|[v0]|", views: self.numbersView)    
        self.bottomView.addConstraintsWithFormat("V:|-50-[v0]|", views: self.rightContainerView)
        self.bottomView.addConstraintsWithFormat("H:|[v0][v1(50)]|", views: self.numbersView, self.rightContainerView)   

        self.numbersView.addSubview(self.priceRowView)
        self.numbersView.addSubview(self.pointsRowView)

        self.numbersView.addConstraintsWithFormat("H:|[v0]|", views: self.priceRowView)    
        self.numbersView.addConstraintsWithFormat("H:|[v0]|", views: self.pointsRowView)
        self.numbersView.addConstraintsWithFormat("V:|[v0][v1]|", views: self.priceRowView, self.pointsRowView)    
        
        self.priceRowView.addSubview(self.labelPriceLabel)
        self.priceRowView.addSubview(self.priceLabel)
       
        self.priceRowView.addConstraintsWithFormat("V:|[v0]|", views: self.labelPriceLabel)   
        self.priceRowView.addConstraintsWithFormat("V:|[v0]|", views: self.priceLabel)
        self.priceRowView.addConstraintsWithFormat("H:|[v0(80)][v1]|", views: self.labelPriceLabel, self.priceLabel) 

        self.pointsRowView.addSubview(self.labelPointsLabel)
        self.pointsRowView.addSubview(self.pointsLabel)

        self.pointsRowView.addConstraintsWithFormat("V:|[v0]|", views: self.labelPointsLabel)   
        self.pointsRowView.addConstraintsWithFormat("V:|[v0]|", views: self.pointsLabel)
        self.pointsRowView.addConstraintsWithFormat("H:|[v0(50)][v1]|", views: self.labelPointsLabel, self.pointsLabel)    
        
        self.separatorView.backgroundColor = UIColor.gray
        
        self.checkView = UIView()        
        
        var checkLabel = UILabel()
        
        checkLabel =  Global.createCircularLabel(text: "✓", size: 80, fontSize: 60.0, borderWidth: 8.0, color: UIColor.gamvesColor) 
        
        let cw = self.frame.width
        let ch = cw * 9 / 16
        
        let pr = cw - 100
        let pt = ch - 90
        
        let paddingMetrics = ["pr":pr,"pt":pt]
        
        self.addSubview(self.checkView)
        self.addConstraintsWithFormat("H:|-pr-[v0(80)]", views: self.checkView, metrics : paddingMetrics)
        self.addConstraintsWithFormat("V:|-pt-[v0(80)]", views: self.checkView, metrics : paddingMetrics)
        
        self.checkView.addSubview(checkLabel)      
        self.checkView.addConstraintsWithFormat("H:|[v0(80)]|", views: checkLabel)
        self.checkView.addConstraintsWithFormat("V:|[v0(80)]|", views: checkLabel)        

    }
    
}
