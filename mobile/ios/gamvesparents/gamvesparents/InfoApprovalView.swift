//
//  InfoView.swift
//  gamves
//
//  Created by Jose Vigil on 9/4/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class InfoApprovalView: UIView {
    
    var videoGamves:VideoGamves!
    var fanpageGamves:FanpageGamves!

	let infoContView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(white: 0, alpha: 1)
        view.backgroundColor = UIColor.red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()     

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.text = "Title:"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        return label
    }()

    let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = label.font.withSize(14)
        label.textAlignment = .left
        return label
    }()   

    let descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.text = "Description:"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        return label
    }()
    
     let infoDescLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        //label.font = UIFont.boldSystemFont(ofSize: 10)
        label.font = label.font.withSize(14)
        label.textAlignment = .left
        label.numberOfLines = 5
        //label.backgroundColor = UIColor.lightGray
        return label
    }()

    ///////////////////////////////////////////////////


    init(frame: CGRect, obj: AnyObject)
    {
        super.init(frame: frame)
        
        let type = type(of: obj)
        
        if (obj is VideoGamves) {
            
            let video = obj as! VideoGamves
            
            self.videoGamves = video
            
            self.infoTitleLabel.text = video.title
            self.infoDescLabel.text = video.description
        
        } else if (obj is FanpageGamves) {
            
            let fanpage = obj as! FanpageGamves
            
            self.fanpageGamves = fanpage
            
            self.infoTitleLabel.text = fanpage.name
            self.infoDescLabel.text = fanpage.about
            
        }

        self.infoContView.frame = frame

        self.addSubview(self.infoContView)     
        self.addConstraintsWithFormat("H:|[v0]|", views: self.infoContView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.infoContView)    

        self.infoContView.backgroundColor = UIColor.white
        
        self.infoContView.addSubview(self.titleLabel)
        self.infoContView.addSubview(self.infoTitleLabel)       

        self.infoContView.addSubview(self.descLabel)
        self.infoContView.addSubview(self.infoDescLabel)


        self.infoContView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.titleLabel)
        self.infoContView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.infoTitleLabel)
        
        self.infoContView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.descLabel)
        self.infoContView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.infoDescLabel)
        
        self.infoContView.addConstraintsWithFormat("V:|-20-[v0(15)][v1(30)]-10-[v2(20)][v3]|", 
            views: 
            self.titleLabel, 
            self.infoTitleLabel,            
            self.descLabel,
            self.infoDescLabel)

        self.infoTitleLabel.text = self.videoGamves.title
        self.infoDescLabel.text = self.videoGamves.description              
        
    } 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  
}
