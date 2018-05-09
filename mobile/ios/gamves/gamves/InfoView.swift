//
//  InfoView.swift
//  gamves
//
//  Created by Jose Vigil on 9/4/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse

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

    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "like_gray")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .gray   
        button.addTarget(self, action: #selector(handleLikeButton(sender:)), for: .touchUpInside)
        button.tag = 1        
        return button
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

    lazy var notLikeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "likenot_gray")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .gray   
        button.addTarget(self, action: #selector(handleLikeButton(sender:)), for: .touchUpInside)
        button.tag = 2       
        return button
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

    var likeType = Int()
    var videoId = Int()
    var existLike = Bool()
    var likesPF:PFObject!

    init(frame: CGRect, video: VideoGamves)
    {
        super.init(frame: frame)    

        self.videoGamves = video
        self.videoId = video.videoId
        
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

        self.likeContainerView.addSubview(self.likeButton)
        self.likeContainerView.addSubview(self.likeLabel)

        self.likeContainerView.addConstraintsWithFormat("H:|-5-[v0(50)]-5-|", views: self.likeButton)
        self.likeContainerView.addConstraintsWithFormat("H:|-5-[v0(50)]-5-|", views: self.likeLabel)

        self.likeContainerView.addConstraintsWithFormat("V:|-5-[v0(50)]-5-[v1]|", views: self.likeButton, self.likeLabel)

        self.likeNotContainerView.addSubview(self.notLikeButton)
        self.likeNotContainerView.addSubview(self.likeNotLabel)

        self.likeNotContainerView.addConstraintsWithFormat("H:|-5-[v0(50)]-5-|", views: self.notLikeButton)
        self.likeNotContainerView.addConstraintsWithFormat("H:|-5-[v0(50)]-5-|", views: self.likeNotLabel)

        self.likeNotContainerView.addConstraintsWithFormat("V:|-5-[v0(50)]-5-[v1]|", views: self.notLikeButton, self.likeNotLabel)

        self.likeButton.imageView?.tintColor = UIColor.gray
        self.notLikeButton.imageView?.tintColor = UIColor.gray                   

        self.checkLike()
    
    } 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }   


    func checkLike() {

        let queryLikes = PFQuery(className:"Likes")

        if let userId = PFUser.current()?.objectId {
        
            queryLikes.whereKey("userId", equalTo: userId)

        }        

        queryLikes.whereKey("referenceId", equalTo: self.videoId)                        

        queryLikes.getFirstObjectInBackground(block: { (likePF, error) in
         
             if error == nil {
                
                self.likesPF = likePF

                self.existLike = true

                self.likeType = likePF!["likeType"] as! Int

                if self.likeType == 1 {

                    self.likeButton.imageView?.tintColor = UIColor.red
                    self.notLikeButton.imageView?.tintColor = UIColor.gray

                } else if self.likeType == 2 {

                    self.likeButton.imageView?.tintColor = UIColor.gray
                    self.notLikeButton.imageView?.tintColor = UIColor.red

                }

            }
        })
    }

 

    func handleLikeButton(sender: UIButton) {      

        if !self.existLike {

            self.likesPF = PFObject(className: "Likes")

            self.likesPF["referenceId"] = self.videoId
        
        
            if let userId = PFUser.current()?.objectId {
            
                self.likesPF["userId"] = userId
                
            }

        } 

        var status = Int()

        if sender.tag == 1 {

            status = 1

            if self.likeType == 1 {

                 self.likesPF.deleteEventually()

                 self.likeButton.imageView?.tintColor = UIColor.gray          

                 self.existLike = false  

                 self.likeType = 0      

                 return        

            }

        } else if sender.tag == 2 {

            status = 2

            if self.likeType == 2 {

                self.likesPF.deleteEventually()

                self.notLikeButton.imageView?.tintColor = UIColor.gray  

                self.existLike = false

                self.likeType = 0  

                return

            }

        }        
        
        self.likesPF["likeType"] = status
        
        self.likesPF.saveInBackground(block: { (resutl, error) in
            
            if error == nil {

                self.existLike = true

                if sender.tag == 1 {                   
                        
                    self.likeButton.imageView?.tintColor = UIColor.red                       
                    self.notLikeButton.imageView?.tintColor = UIColor.gray     

                    self.likeType = 1  

                } else if sender.tag == 2 {

                    self.notLikeButton.imageView?.tintColor = UIColor.red
                    self.likeButton.imageView?.tintColor = UIColor.gray

                    self.likeType = 2
                }
            }
        })
    }
  
}
