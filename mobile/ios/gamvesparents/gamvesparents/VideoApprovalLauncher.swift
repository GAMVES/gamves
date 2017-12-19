//
//  VideoLauncher.swift
//  youtube
//
//  Created by Brian Voong on 8/11/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class VideoApprovalPlayerView: UIView {

    var videoLauncher:VideoApprovalLauncher!
    var keyWindow: UIView!
    var playerLayer: AVPlayerLayer!

    var yLocation = CGFloat()
    var xLocation = CGFloat()
    var lastX = CGFloat()

    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()

     lazy var arrowDownButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "arrow_down")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleDownButton), for: .touchUpInside)        
        return button
    }()

    func handleDownButton() 
    {
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let totalHeight = self.keyWindow.frame.size.height
            let totalWidth = self.keyWindow.frame.size.width
            
            let thumbWidth = totalWidth / 2
            let thumbHeight = thumbWidth * 9 / 16
            
            let x = (totalWidth / 2) - (thumbWidth / 2)
            let y = totalHeight - (thumbHeight + 30)
            
            self.yLocation = y
            self.xLocation = x
            self.lastX = x
            
            self.activityIndicatorView.isHidden = true
            self.arrowDownButton.isHidden = true
            self.pausePlayButton.isHidden = true
            self.videoLengthLabel.isHidden = true
            self.currentTimeLabel.isHidden = true
            self.videoSlider.isHidden = true
            
            self.controlsContainerView.isHidden = true
            
            let smallFrame = CGRect(x: x, y: y, width: thumbWidth, height: thumbHeight)
            
            self.videoLauncher.view.frame = smallFrame
            
            self.playerLayer.frame = smallFrame
            
            let gesture = UIPanGestureRecognizer(target: self, action:  #selector(self.wasDragged))
            self.videoLauncher.view.addGestureRecognizer(gesture)
            self.videoLauncher.view.isUserInteractionEnabled = true
        
        
        }, completion: { (completedAnimation) in
            
            //maybe we'll do something here later...
            UIApplication.shared.setStatusBarHidden(true, with: .fade)
            
        })
    }
    
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state ==
        UIGestureRecognizerState.changed
        {
            
            let translation = gestureRecognizer.translation(in: self)
           
            print("///////////////")
            
            print(gestureRecognizer.view!.center.x)
            print(self.xLocation)
            
            if(gestureRecognizer.view!.center.x > self.xLocation)
            {
                gestureRecognizer.view!.center = CGPoint(x:self.xLocation + translation.x, y:self.yLocation )
                
            } else  if(gestureRecognizer.view!.center.x < self.xLocation)
            {
                let xVariable = gestureRecognizer.view!.center.x
                
                let disX = self.lastX - xVariable
                
                self.videoLauncher.view.backgroundColor = UIColor.black.withAlphaComponent(disX*0.1)
                self.videoLauncher.view.isOpaque = false
                
                gestureRecognizer.view!.center = CGPoint(x:xVariable, y:self.yLocation)
                
                self.lastX = xVariable
                
            }
            
            gestureRecognizer.setTranslation(CGPoint(x:0,y:0), in: self)
        }
        
    }

    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()    
    
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "pause")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = true
        
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        
        return button
    }()
    
    var isPlaying = false
    
    func handlePause() {
        if isPlaying {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: UIControlState())
        } else {
            player?.play()
            pausePlayButton.setImage(UIImage(named: "pause"), for: UIControlState())
        }
        isPlaying = !isPlaying
    }    
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .right
        return label
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .white
        slider.setThumbImage(UIImage(named: "thumb"), for: UIControlState())        
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)        
        return slider
    }()
    
    func handleSliderChange() 
    {
        print(videoSlider.value)
        
        if let duration = player?.currentItem?.duration 
        {
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let value = Float64(videoSlider.value) * totalSeconds
            
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                //perhaps do something later here
            })
        }
    } 

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setViews(view:UIView, videoLauncherVidew:VideoApprovalLauncher)
    {
        self.videoLauncher = videoLauncherVidew
        self.keyWindow = view
    }

    var videoUrl = String()

    func setPlayerUrl(urlString : String)
    {        
        setupPlayerView(urlString: urlString)

        setupGradientLayer()              
        
        controlsContainerView.frame = frame
        addSubview(self.controlsContainerView)        
     
        controlsContainerView.addSubview(arrowDownButton)        
        arrowDownButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        arrowDownButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30).isActive = true
        
        controlsContainerView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        controlsContainerView.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        controlsContainerView.addSubview(videoLengthLabel)
        videoLengthLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        videoLengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        videoLengthLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        controlsContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        controlsContainerView.addSubview(videoSlider)
        videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
        videoSlider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        videoSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor).isActive = true
        videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true

    }

    // VIDEO   

    var player: AVPlayer?
    
    func setupPlayerView(urlString : String) {
        
        //warning: use your own video url here, the bandwidth for google firebase storage will run out as more and more people use this file
        
        //let urlString = "https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726"
        
        print(urlString)
        
        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = self.frame
            
            player?.play()
            
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            
            //track player progress
            
            let interval = CMTime(value: 1, timescale: 2)
            player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                
                let seconds = CMTimeGetSeconds(progressTime)
                let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
                let minutesString = String(format: "%02d", Int(seconds / 60))
                
                self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
                
                //lets move the slider thumb
                if let duration = self.player?.currentItem?.duration {
                    let durationSeconds = CMTimeGetSeconds(duration)
                    
                    self.videoSlider.value = Float(seconds / durationSeconds)
                    
                }
                
            })
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //this is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = .clear
            pausePlayButton.isHidden = false
            isPlaying = true
            
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
    
    fileprivate func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        controlsContainerView.layer.addSublayer(gradientLayer)
    }
    
    required init?(coder aDecoder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }   

}


class VideoApprovalLauncher: UIView {
    
    
    var infoApprovalView:InfoApprovalView!
    
    var buttonsApprovalView:ButtonsApprovalView!
    
    var videoApprovalPlayerView:VideoApprovalPlayerView!
    
    var delegate:ApprovalProtocol!
    
    var view:UIView!
    
    var originaChatYPosition = CGFloat()
    var originaChatHeightPosition = CGFloat()

    func showVideoPlayer(videoGamves: VideoGamves){
                
        let videoUrl = videoGamves.s3_source
        let videoObj = videoGamves.videoObj!
        let videoId  = videoObj["videoId"] as! Int
        
        let fanpageId = videoGamves.fanpageId
        
        print("Showing video player....\(videoUrl)")
        
        if let keyWindow = UIApplication.shared.keyWindow {

            view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.white
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            
            //16 x 9 is the aspect ratio of all HD videos
            let videoHeight = keyWindow.frame.width * 9 / 16
            let videoPlayerFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: videoHeight)
            
            videoApprovalPlayerView = VideoApprovalPlayerView(frame: videoPlayerFrame)
            videoApprovalPlayerView.setPlayerUrl(urlString: videoUrl)
            view.addSubview(videoApprovalPlayerView)

            let infoHeight = 200
            let infoFrame = CGRect(x: 0, y: Int(videoApprovalPlayerView.frame.height), width: Int(keyWindow.frame.width), height: infoHeight)
            
            infoApprovalView = InfoApprovalView(frame: infoFrame, video: videoGamves)
            view.addSubview(infoApprovalView)

            let diff = Int(videoHeight) + Int(infoHeight)
            let chatHeight = Int(keyWindow.frame.height) - diff
            
            let apprY = Int(videoApprovalPlayerView.frame.height) + Int(infoApprovalView.frame.height)
            let apprFrame = CGRect(x: 0, y: apprY, width: Int(keyWindow.frame.width), height: chatHeight)
            
            buttonsApprovalView = ButtonsApprovalView(frame: apprFrame, playerView: videoApprovalPlayerView, videoId: videoId, delegate: self.delegate)
            buttonsApprovalView.backgroundColor = UIColor.gamvesBackgoundColor
            view.addSubview(buttonsApprovalView)
            buttonsApprovalView.addSubViews()

            videoApprovalPlayerView.setViews(view: view, videoLauncherVidew: self)
            keyWindow.addSubview(view)

            view.tag = 1
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in
                    
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
                    
            })
        }
    }
    
}

class ButtonsApprovalView: UIView {

    
    lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gamvesSemaphorGreenColor
        button.setTitle("APPROVE VIDEO", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(touchUpApprove), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gamvesSemaphorRedColor
        button.setTitle("REJECT VIDEO", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(touchUpReject), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()

     lazy var laterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gamvesColor
        button.setTitle("DECIDE LATER", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(touchUpLater), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()

    let bottomView: UIView = {
        let view = UIView()       
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()     

    var playerView:VideoApprovalPlayerView!
    var videoId = Int()
    
    var delegate:ApprovalProtocol!

    
    init(frame: CGRect, playerView:VideoApprovalPlayerView, videoId:Int, delegate:ApprovalProtocol) {
        super.init(frame: frame)  
        self.playerView = playerView
        self.videoId = videoId
        self.delegate = delegate
    }

    func addSubViews() {

        self.addSubview(self.approveButton)
        self.addSubview(self.rejectButton)
        self.addSubview(self.laterButton)
        self.addSubview(self.bottomView)
        
        self.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.approveButton)
        self.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.rejectButton)
        self.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.laterButton)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)
        
        self.addConstraintsWithFormat("V:|-30-[v0(60)]-10-[v1(60)]-10-[v2(60)][v3]|", views: 
            self.approveButton, 
            self.rejectButton, 
            self.laterButton,
            self.bottomView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchUpApprove() {
        
        updateApprovalStatus(videoId: self.videoId, status: 1);
    }
    
    func touchUpReject() {

        updateApprovalStatus(videoId: self.videoId, status: -1);
    }
    
    func touchUpLater() {

        self.closeApprovalWindow()       
    }

    func closeApprovalWindow() {

        //REMOVE IF EXISTS VIDEO RUNNING
        for subview in (UIApplication.shared.keyWindow?.subviews)! {
            if (subview.tag == 1)
            {
                self.playerView.handleDownButton()
                self.playerView.handlePause()                
                subview.removeFromSuperview()
            }
        }
    }

    func updateApprovalStatus(videoId:Int,  status: Int){

        print(videoId)
        
        let queryApprovals = PFQuery(className: "Approvals")        
        queryApprovals.whereKey("videoId", equalTo: videoId)
        queryApprovals.getFirstObjectInBackground { (approval, error) in
            
            if error != nil
            {
                print("error")
                
            } else {

                approval?["approved"] = status
                
                approval?.saveInBackground(block: { (resutl, error) in
                    
                    self.delegate.closedRefresh()
                    self.closeApprovalWindow()
                    
                    
                })
            }
        }

    }



   

}
