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
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleContView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.text = "Title:"
        //label.font = UIFont.boldSystemFont(ofSize: 17)
        label.font = label.font.withSize(14)
        label.textAlignment = .left
        return label
    }()

    let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .left
        return label
    }()
    
    let descContView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.text = "Description:"
        label.font = label.font.withSize(14)
        label.textAlignment = .left
        return label
    }()
    
     let infoDescLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        //label.font = UIFont.boldSystemFont(ofSize: 10)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        label.numberOfLines = 5
        //label.backgroundColor = UIColor.lightGray
        return label
    }()

    ///////////////////////////////////////////////////


    init(frame: CGRect, obj: AnyObject) {
        super.init(frame: frame)    
        
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

        //self.infoContView.backgroundColor = UIColor.white
        
        self.infoContView.addSubview(self.titleContView)
        self.infoContView.addSubview(self.descContView)
        
        self.infoContView.addConstraintsWithFormat("H:|[v0]|", views: self.titleContView)
        self.infoContView.addConstraintsWithFormat("H:|[v0]|", views: self.descContView)
        
        self.infoContView.addConstraintsWithFormat("V:|[v0(40)][v1]|", views:
            self.titleContView,
            self.descContView)
        
        self.titleContView.addSubview(self.titleLabel)
        self.titleContView.addSubview(self.infoTitleLabel)

        self.titleContView.addConstraintsWithFormat("H:|-5-[v0(50)][v1]|", views:
            self.titleLabel,
            self.infoTitleLabel)
        
        self.titleContView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.titleLabel)
        self.titleContView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.infoTitleLabel)
        
        self.descContView.addSubview(self.infoDescLabel)
        self.descContView.addSubview(self.descLabel)

        self.descContView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.descLabel)
        self.descContView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.infoDescLabel)
        
        self.descContView.addConstraintsWithFormat("V:|-20-[v0(20)][v1]|", views:
            self.descLabel,
            self.infoDescLabel)
        
    } 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  
}
