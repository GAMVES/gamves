//
//  InfoView.swift
//  gamves
//
//  Created by Jose Vigil on 9/4/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class InfoView: UIView {
    
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


    let likesHolderView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    let likeContainerView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let likeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "like_gray")
        return imageView
    }()

    let likeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Like"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        //label.backgroundColor = UIColor.lightGray
        return label
    }()

    let likeNotContainerView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    let likeNotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "likenot_gray")
        return imageView
    }()

    let likeNotLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dislike"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        //label.backgroundColor = UIColor.lightGray
        return label
    }()


    init(frame: CGRect, video: VideoGamves)
    {
        super.init(frame: frame)    

        self.videoGamves = video
        
        self.infoContainerView.frame = frame  

        self.addSubview(self.infoContainerView)     
        self.addConstraintsWithFormat("H:|[v0]|", views: self.infoContainerView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.infoContainerView)    

        self.infoContainerView.addSubview(self.descHolderView)        
        self.infoContainerView.addSubview(self.likesHolderView)
        
        let width = self.frame.width       

        let descHolderWidth = (width / 3) * 2
        
        let metricsHolderView = ["descHolderWidth": descHolderWidth]

        self.infoContainerView.addConstraintsWithFormat("H:|[v0(descHolderWidth)][v1]|", views: self.descHolderView, self.likesHolderView, metrics: metricsHolderView)

        self.infoContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.descHolderView)
        self.infoContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.likesHolderView)
        
        self.descHolderView.addSubview(self.infoTitleLabel)
        self.descHolderView.addSubview(self.infoDescLabel)

        self.descHolderView.addConstraintsWithFormat("V:|-5-[v0(15)]-5-[v1]|", views: self.infoTitleLabel, self.infoDescLabel)
        self.descHolderView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.infoTitleLabel)
        self.descHolderView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.infoDescLabel)
        
        self.infoTitleLabel.text = self.videoGamves.title
        self.infoDescLabel.text = self.videoGamves.description

        self.likesHolderView.addSubview(self.likeContainerView)
        self.likesHolderView.addSubview(self.likeNotContainerView)
        
        self.likesHolderView.addConstraintsWithFormat("V:|[v0]|", views: self.likeContainerView)
        self.likesHolderView.addConstraintsWithFormat("V:|[v0]|", views: self.likeNotContainerView)

        self.likesHolderView.addConstraintsWithFormat("H:|[v0][v1]|", views: self.likeContainerView, self.likeNotContainerView)

        self.likeContainerView.addSubview(self.likeImageView)
        self.likeContainerView.addSubview(self.likeLabel)

        self.likeContainerView.addConstraintsWithFormat("H:|-5-[v0(50)]-5-|", views: self.likeImageView)
        self.likeContainerView.addConstraintsWithFormat("H:|-5-[v0(50)]-5-|", views: self.likeLabel)

        self.likeContainerView.addConstraintsWithFormat("V:|-5-[v0(50)]-5-[v1]|", views: self.likeImageView, self.likeLabel)

        self.likeNotContainerView.addSubview(self.likeNotImageView)
        self.likeNotContainerView.addSubview(self.likeNotLabel)

        self.likeNotContainerView.addConstraintsWithFormat("H:|-5-[v0(50)]-5-|", views: self.likeNotImageView)
        self.likeNotContainerView.addConstraintsWithFormat("H:|-5-[v0(50)]-5-|", views: self.likeNotLabel)

        self.likeNotContainerView.addConstraintsWithFormat("V:|-5-[v0(50)]-5-[v1]|", views: self.likeNotImageView, self.likeNotLabel)
    
    } 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  
}
