//
//  SearchCell.swift
//  gamves
//
//  Created by Jose Vigil on 12/4/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import YouTubePlayer

class SearchVideoCell: UITableViewCell {
    
    var checked = Bool()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            titleLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            descLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }    
    
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()                
        label.font = UIFont.boldSystemFont(ofSize: 16)        
        label.textAlignment = .center
        label.numberOfLines = 3
        //label.backgroundColor = UIColor.green
        return label
    }()    
    
    let descLabel: UILabel = {
        let label = UILabel()        
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 3
        //label.backgroundColor = UIColor.cyan  
        return label
    }()    

    let timeView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        //view.backgroundColor = UIColor.green
        view.layer.cornerRadius = 5
        return view
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 15)         
        //label.font = UIFont.systemFont(ofSize: 15)
        //label.textAlignment = .center
        label.textAlignment = NSTextAlignment.center
        return label
    }()

    var cellHeight = Int()

    var videoId = String()
    
    //var delegate:VidewVideoProtocol?

    var videoPlayer:YouTubePlayerView!

    let playImageButton: UIButton = {
        let playButton = UIButton()
        let image = UIImage(named: "play")
        playButton.setImage(image, for: .normal)
        //playButton.addTarget(self, action:#selector(playPause(button:)), for: .touchUpInside)
        playButton.contentMode = .scaleAspectFill
        playButton.isUserInteractionEnabled = true
        playButton.layer.masksToBounds = true
        return playButton
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)      
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }
    
    func setupViews() {

        let containerView = UIView()

        addSubview(thumbnailImageView)
        addSubview(timeView)       
        addSubview(playImageButton)
        addSubview(containerView)
        addSubview(dividerLineView)                     
        

        let thumbnailWidth  = (120 * 16) / 9 

        let metricsVideo = ["thumbnailWidth": thumbnailWidth, "cellHeight": 120 ]
        
        addConstraintsWithFormat("H:|-12-[v0(thumbnailWidth)][v1]|", views: thumbnailImageView, containerView, metrics: metricsVideo)
        
        addConstraintsWithFormat("V:[v0(cellHeight)]", views: thumbnailImageView, metrics: metricsVideo)
        addConstraintsWithFormat("V:|-5-[v0]-5-|", views: containerView)

        //thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickThumbnail)))       
        
        addConstraint(NSLayoutConstraint(item: thumbnailImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("V:|[v0(1)]|", views: dividerLineView)          

        let playerFrame = thumbnailImageView.frame
        self.videoPlayer = YouTubePlayerView(frame: playerFrame)
        addSubview(self.videoPlayer)
        self.videoPlayer.isHidden = true    

        let playX = (thumbnailWidth  / 2) - 20
        let playY = (120  / 2) - 20

        let metricsPlay = ["playX": playX, "playY": playY]    

        addConstraintsWithFormat("H:|-playX-[v0(60)]|", views: playImageButton, metrics: metricsPlay)
        addConstraintsWithFormat("V:|-playY-[v0(60)]|", views: playImageButton, metrics: metricsPlay)

        let paddingtime = thumbnailWidth - 60

        let metricsTime = ["paddingtime": paddingtime]

        addConstraintsWithFormat("H:|-paddingtime-[v0(60)]|", views: timeView, metrics: metricsTime)
        addConstraintsWithFormat("V:|-100-[v0(30)]|", views: timeView)

        timeView.addSubview(timeLabel)
        
        timeView.addConstraintsWithFormat("H:|[v0]|", views: timeLabel)        
        timeView.addConstraintsWithFormat("V:|[v0]|", views: timeLabel)                      
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(descLabel)        
        
        containerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: titleLabel)        
        containerView.addConstraintsWithFormat("V:|[v0(80)][v1(40)]-30-|", views: titleLabel, descLabel)        
        containerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: descLabel)

   }
    
    func loadVideo() {
        print(self.videoId)
        self.videoPlayer.loadVideoID(self.videoId)
    }

   /*func playPause(button: UIButton) {
    
        
        //let rowid:Int = Int((sender.view?.tag)!)   

        self.thumbnailImageView.isHidden = true   

        self.videoPlayer.loadVideoID(self.videoId)
                

        //if delegate != nil {
            
            //delegate?.openVideoById(id: rowid)

        //}        

    }   */

    
}


