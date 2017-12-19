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

	let infoContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(white: 0, alpha: 1)
        view.backgroundColor = UIColor.red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }() 

    let descHolderView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.text = "Chat room"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        //label.backgroundColor = UIColor.lightGray
        return label
    }()

     let infoDescLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.text = "Chat room"
        label.textColor = UIColor.gray
        //label.font = UIFont.boldSystemFont(ofSize: 10)
        label.font = label.font.withSize(11)
        label.textAlignment = .left
        label.numberOfLines = 5
        //label.backgroundColor = UIColor.lightGray
        return label
    }()


    ///////////////////////////////////////////////////


    init(frame: CGRect, video: VideoGamves)
    {
        super.init(frame: frame)    

        self.videoGamves = video
        
        self.infoContainerView.frame = frame  

        self.addSubview(self.infoContainerView)     
        self.addConstraintsWithFormat("H:|[v0]|", views: self.infoContainerView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.infoContainerView)    

        self.infoContainerView.addSubview(self.descHolderView)
        
        
        let width = self.frame.width       

        let descHolderWidth = (width / 3) * 2
        
        let metricsHolderView = ["descHolderWidth": descHolderWidth]

        self.infoContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.descHolderView)
        self.infoContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.descHolderView)
        
        self.descHolderView.addSubview(self.infoTitleLabel)
        self.descHolderView.addSubview(self.infoDescLabel)

        self.descHolderView.addConstraintsWithFormat("V:|-20-[v0]-20-[v1]|", views: self.infoTitleLabel, self.infoDescLabel)
        
        self.descHolderView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.infoTitleLabel)
        self.descHolderView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.infoDescLabel)
        
        self.infoTitleLabel.text = self.videoGamves.title
        self.infoDescLabel.text = self.videoGamves.description
        
    } 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  
}
