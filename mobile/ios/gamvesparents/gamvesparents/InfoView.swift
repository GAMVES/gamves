//
//  InfoView.swift
//  gamves
//
//  Created by Jose Vigil on 9/4/17.
//

import UIKit
import Parse

class InfoView: UIView {
    
    var videoGamves:GamvesVideo!

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


    let viewContainerView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()   

    lazy var viewImage: UIImageView = {
        let imageView = UIImageView()          
        let image = UIImage(named: "view_gray")
        imageView.image = image    
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray 

        //imageView.addTarget(self, action: #selector(handleviewImage(sender:)), for: .touchUpInside)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)

        imageView.tag = 1        
        return imageView
    }()

    let viewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Review"
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

    init(frame: CGRect, video: GamvesVideo)
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

        self.likesHolderView.addSubview(self.viewContainerView)
        //self.likesHolderView.addSubview(self.likeNotContainerView)
        
        self.likesHolderView.addConstraintsWithFormat("V:|[v0]|", views: self.viewContainerView)      
        self.likesHolderView.addConstraintsWithFormat("H:|[v0]|", views: self.viewContainerView)

        
        
    
    }
    
    override func layoutSubviews() {
        
        let widthView = self.viewContainerView.frame.width - 50
        
        if widthView > 0 {
            
            let margin = widthView / 2

            let metricsView = ["margin" : margin]

            self.viewContainerView.addSubview(self.viewImage)
            self.viewContainerView.addSubview(self.viewLabel)
            
            self.viewContainerView.addConstraintsWithFormat("H:|-margin-[v0(50)]-margin-|", views: self.viewImage, metrics: metricsView)
            self.viewContainerView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.viewLabel)

            self.viewContainerView.addConstraintsWithFormat("V:|-5-[v0(50)]-5-[v1]|", views: self.viewImage, self.viewLabel)
            
        }
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        //Review here

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }       
 

    func handleviewImage(sender: UIButton) {      

      


    }
  
}
