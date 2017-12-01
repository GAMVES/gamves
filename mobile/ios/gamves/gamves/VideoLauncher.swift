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

class VideoPlayerView: UIView {  

    var videoLauncher:VideoLauncher!
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
        //self.handlePause()
        
        /*for subview in (UIApplication.shared.keyWindow?.subviews)! {
            if (subview.tag == 1) {
                subview.removeFromSuperview()
            }
        }*/
        
        self.videoLauncher.chatView.dismissKeyboard()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let totalHeight = self.keyWindow.frame.size.height
            let totalWidth = self.keyWindow.frame.size.width
            
            let thumbWidth = totalWidth / 2
            let thumbHeight = thumbWidth * 9 / 16
            
            let x = (totalWidth / 2) - (thumbWidth / 2)
            let y = totalHeight - (thumbHeight + 30)
            
            self.yLocation = y
            print(y)
            self.xLocation = x
            self.lastX = x
            
            self.activityIndicatorView.isHidden = true
            self.arrowDownButton.isHidden = true
            self.pausePlayButton.isHidden = true
            self.videoLengthLabel.isHidden = true
            self.currentTimeLabel.isHidden = true
            self.videoSlider.isHidden = true
            
            self.controlsContainerView.isHidden = true
            
            //self.controlsContainerView.isHidden = true
            
            self.videoLauncher.infoView.isHidden = true
            self.videoLauncher.chatView.isHidden = true
            
            let smallFrame = CGRect(x: x, y: y, width: thumbWidth, height: thumbHeight)
            
            self.videoLauncher.view.frame = smallFrame
            
            self.playerLayer.frame = smallFrame            

            //let gesture = UIPanGestureRecognizer(target: self, action:  #selector(self.wasDragged))
            //self.videoLauncher.view.addGestureRecognizer(gesture)
            //self.videoLauncher.view.isUserInteractionEnabled = true
            
            //self.playerLayer.frame = CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight)
            
            //let smallFrame = CGRect(x: x, y: y, width: thumbWidth, height: thumbHeight)
            
            //self.keyWindow.frame = smallFrame
            
            //self.playerLayer.bounds = smallFrame
            
            //self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            //gesture.delegate = self as! UIGestureRecognizerDelegate
            
            //self.videoLauncher.view.backgroundColor = UIColor.black
            
            
            
            
        }, completion: { (completedAnimation) in
            
            //maybe we'll do something here later...
            UIApplication.shared.setStatusBarHidden(true, with: .fade)
            
        })
    }

    /*func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
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
        
    }*/

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
    
    func setViews(view:UIView, videoLauncherVidew:VideoLauncher)
    {
        self.videoLauncher = videoLauncherVidew
        self.keyWindow = view
        //self.infoView = infoView
        //self.chatView = chatView
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

        //DispatchQueue.main.async
        //{
        
            if let url = URL(string: urlString) {
                
                do
                {
                    self.player = AVPlayer(url: url)
                
                } catch 
                {
                    print("Error info: \(error)")
                }
                
                
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                self.layer.addSublayer(self.playerLayer)
                self.playerLayer.frame = self.frame
                
                self.player?.play()
                
                self.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
                
                //track player progress
                
                let interval = CMTime(value: 1, timescale: 2)
                self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                    
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
        //}
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

class VideoLauncher: UIView, KeyboardDelegate {
        
    var infoView:InfoView!
    var chatView:ChatView!
    var videoPlayerView:VideoPlayerView!
    
    var view:UIView!
    
    var originaChatYPosition = CGFloat()
    var originaChatHeightPosition = CGFloat()

    var panGesture = UIPanGestureRecognizer()

    func showVideoPlayer(videoGamves: VideoGamves){ //videoUrl :String, videoId:String, fanpageId:String) {
                
        let videoUrl = videoGamves.video_url
        let videoObj = videoGamves.videoobj!
        let videoId = videoObj["videoId"] as! String
        //let viId:Int = NumberFormatter().number(from: videoId) as! Int

        let first5VideoId = videoId.substring(to:videoId.index(videoId.startIndex, offsetBy: 5))
        
        let viId:Int = Int(first5VideoId)!
        let fanpageId = videoGamves.fanpageId
        
        print("Showing video player....\(videoUrl)")
        
        if let keyWindow = UIApplication.shared.keyWindow {

            view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.white
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            
            //16 x 9 is the aspect ratio of all HD videos
            let videoHeight = keyWindow.frame.width * 9 / 16
            let videoPlayerFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: videoHeight)

            videoPlayerView = VideoPlayerView(frame: videoPlayerFrame)
            videoPlayerView.setPlayerUrl(urlString: videoUrl)
            view.addSubview(videoPlayerView)

            self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView))
            videoPlayerView.isUserInteractionEnabled = true
            videoPlayerView.addGestureRecognizer(self.panGesture)
            
            let infoHeight = 90            
            let infoFrame = CGRect(x: 0, y: Int(videoPlayerView.frame.height), width: Int(keyWindow.frame.width), height: infoHeight)
            
            infoView = InfoView(frame: infoFrame, video: videoGamves)
            view.addSubview(infoView)

            let diff = Int(videoHeight) + Int(infoHeight)
            let chatHeight = Int(keyWindow.frame.height) - diff
            
            let chatY = Int(videoPlayerView.frame.height) + Int(infoView.frame.height)
            
            let chatFrame = CGRect(x: 0, y: chatY, width: Int(keyWindow.frame.width), height: chatHeight)
            
            chatView = ChatView(frame: chatFrame, isVideo: true)
            
            let params = ["chatId": viId, "isVideoChat": true, "thumbnailImage": videoGamves.thum_image, "delegate":self] as [String : Any]
            
            chatView.setParams(parameters: params)

            view.addSubview(chatView)
            
            chatView.loadChatFeed()
            
            videoPlayerView.setViews(view: view, videoLauncherVidew: self)
            
            keyWindow.addSubview(view)

            view.tag = 1
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in
                    
                    //maybe we'll do something here later...
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
                    
                    
            })
        }
    }


    func draggedView(sender: UIPanGestureRecognizer)
    {
       
        self.view.bringSubview(toFront: sender.view!)
        
        let translation = sender.translation(in: self.view)

        print(translation)
 
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
 
        sender.setTranslation(CGPoint.zero, in: self.view) 

    }
    
    func keyboardOpened(keybordHeight keybordEditHeight: CGFloat)
    {
        
        if (self.infoView != nil)
        {
            self.infoView.isHidden = true
        }
        
        let keyHeight = UIApplication.shared.keyWindow?.frame.height

        let viewsHeight = self.videoPlayerView.frame.height + keybordEditHeight //+ inputHeight

        let chatHeight = keyHeight! - viewsHeight
        
        let yPosition = self.videoPlayerView.frame.size.height
        
        self.originaChatYPosition = self.chatView.frame.origin.y
        
        self.chatView.frame.origin.y = yPosition
        
        self.originaChatHeightPosition = self.chatView.frame.size.height
 
        self.chatView.frame.size.height = chatHeight      
                      
    }
    
    
    func keyboardclosed()
    {
        if (self.infoView != nil)
        {
            self.infoView.isHidden = false
        }
        
        self.chatView.frame.origin.y = self.originaChatYPosition
        
        self.chatView.frame.size.height = self.originaChatHeightPosition
        
    }
    
    
}
