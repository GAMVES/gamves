//
//  VideoLauncher.swift
//  youtube
//
//  Created by Jose Vigil on 12/12/17.
//

import UIKit
import AVFoundation
import Parse

class VideoPlayerView: UIView {

    var videoLauncher:VideoLauncher!
    var keyWindow: UIView!
    var playerLayer: AVPlayerLayer!    

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

    var isPlaying = false
    var videoType = Int()
    var gradientLayer = CAGradientLayer()
    var videoUrl = String()
    var isVideoDown = Bool()       
    var videoFrame = CGRect()

    override init(frame: CGRect) {
        self.videoFrame = frame
        super.init(frame: frame)
    }
    
    func setViews(view:UIView, videoLauncherVidew:VideoLauncher) {
        self.videoLauncher = videoLauncherVidew
        self.keyWindow = view
    }   

    func handleDownButton() {
        self.videoLauncher.shrinkVideoDown()
    }

    func hideShowControllers(status:Bool) {
        self.activityIndicatorView.isHidden = status
        self.arrowDownButton.isHidden = status
        self.pausePlayButton.isHidden = status
        self.videoLengthLabel.isHidden = status
        self.currentTimeLabel.isHidden = status
        self.videoSlider.isHidden = status   
        self.gradientLayer.isHidden = status        
    }

    
    func handleSliderChange() {

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


    func setNativePlayer(url:String)
    {        
        setupPlayerView(urlString: url)
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
      

    var player: AVPlayer?
    
    func setupPlayerView(urlString:String) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeVideo), name: NSNotification.Name(rawValue: Global.notificationKeyCloseVideo), object: nil)
        
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
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //this is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = .clear

            if !isVideoDown
            {
                pausePlayButton.isHidden = false
            }
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
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        controlsContainerView.layer.addSublayer(gradientLayer)
    }
    
    required init?(coder aDecoder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func closeVideo()
    {
        //REMOVE IF EXISTS VIDEO RUNNING
        for subview in (UIApplication.shared.keyWindow?.subviews)! {
            if (subview.tag == 1)
            {
                self.handlePause()                
                subview.removeFromSuperview()
            }
        }
    }

}

class VideoLauncher: UIView, KeyboardDelegate {

    class func className() -> String {
        return "VideoLauncher"
    }
        
    var infoView:InfoView!
    var chatView:ChatView!
    var videoPlayerView:VideoPlayerView!
    
    var view:UIView!
    
    var originaChatYPosition = CGFloat()
    var originaChatHeightPosition = CGFloat()    

    var yLocation = CGFloat()
    var xLocation = CGFloat()
    var lastX = CGFloat()   

    var keyWindoWidth = CGFloat()
    var keyWindoHeight = CGFloat()

    //var valpha = CGFloat() 

    var originalVideoFrame = CGRect()
    var downVideoFrame = CGRect()
    
    var videoId = Int()

    func showVideoPlayer(videoGamves: VideoGamves){
        
        self.keyWindoWidth = (UIApplication.shared.keyWindow?.frame.size.width)!
        self.keyWindoHeight = (UIApplication.shared.keyWindow?.frame.size.height)!

        let videoUrl = videoGamves.s3_source
        let videoObj = videoGamves.videoObj        
        
        
        let videoId = videoObj?["videoId"] as! Int
        
        self.videoId = videoId

        //let first5VideoId = videoId.substring(to:videoId.index(videoId.startIndex, offsetBy: 5))
        //let viId:Int = Int(first5VideoId)!
        
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
            videoPlayerView.setNativePlayer(url: videoUrl)
            view.addSubview(videoPlayerView)

            //let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView))
            //panGesture.delegate = self
            //videoPlayerView.isUserInteractionEnabled = true
            //videoPlayerView.addGestureRecognizer(panGesture)  

            let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedDownVideo))  
            swipeDown.direction = .down
            swipeDown.cancelsTouchesInView = false
            swipeDown.delaysTouchesEnded = false
            videoPlayerView.addGestureRecognizer(swipeDown)           
            
            let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedDownVideo))
            swipeUp.direction = .up
            swipeUp.cancelsTouchesInView = false
            swipeUp.delaysTouchesEnded = false                       
            videoPlayerView.addGestureRecognizer(swipeUp)  

            let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftClose))  
            swipeLeft.direction = .left
            swipeLeft.cancelsTouchesInView = false
            swipeLeft.delaysTouchesEnded = false                      
            videoPlayerView.addGestureRecognizer(swipeLeft)      

            videoPlayerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reopenVideo)))            
            
            let infoHeight = 90            
            let infoFrame = CGRect(x: 0, y: Int(videoPlayerView.frame.height), width: Int(keyWindow.frame.width), height: infoHeight)
            
            infoView = InfoView(frame: infoFrame, video: videoGamves)
            view.addSubview(infoView)

            let diff = Int(videoHeight) + Int(infoHeight)
            let chatHeight = Int(keyWindow.frame.height) - diff
            
            let chatY = Int(videoPlayerView.frame.height) + Int(infoView.frame.height)
            
            let chatFrame = CGRect(x: 0, y: chatY, width: Int(keyWindow.frame.width), height: chatHeight)
            
            chatView = ChatView(parent: ChatViewType.VideoLauncher, frame: chatFrame, isVideo: true)
            
            let params = ["chatId": videoId, "isVideoChat": true, "thumbnailImage": videoGamves.image, "delegate":self] as [String : Any]
            
            chatView.setParams(parameters: params)

            view.addSubview(chatView)
            
            chatView.loadChatFeed()
            
            videoPlayerView.setViews(view: view, videoLauncherVidew: self)
            
            keyWindow.addSubview(view)

            view.tag = 1
            
            self.saveHistroy()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in                   
                    
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
            })
        }
    }

    func swipedDownVideo(sender: UISwipeGestureRecognizer) {
        
        print("swiped down")

        self.videoPlayerView.hideShowControllers(status: true)

        self.shrinkVideoDown()
    }   

    func swipedUpVideo(sender: UISwipeGestureRecognizer) {
        
        print("swiped up")
        
        self.videoPlayerView.hideShowControllers(status: false)
        
        self.openVideoUp()
    }
    
    func swipeLeftVideo(sender: UISwipeGestureRecognizer) {
        
        print("swiped left")

    }

    func reopenVideo(sender: UITapGestureRecognizer)
    {
        if self.videoPlayerView.isVideoDown
        {
            self.openVideoUp()
        }
    }    

    
    func shrinkVideoDown()
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {           
            
            
            let totalHeight = UIApplication.shared.keyWindow?.frame.size.height
            let totalWidth = UIApplication.shared.keyWindow?.frame.size.width
            
            let thumbWidth = totalWidth! / 2
            let thumbHeight = thumbWidth * 9 / 16
            
            let x = (totalWidth! / 2) - (thumbWidth / 2)
            let y = totalHeight! - (thumbHeight + 30)
            
            self.yLocation = y            
            self.xLocation = x
            self.lastX = x  

            self.originalVideoFrame = self.videoPlayerView.frame                     
            
            let smallBottomFrame = CGRect(x: x, y: y, width: thumbWidth, height: thumbHeight)
            
            self.videoPlayerView.videoLauncher.view.frame = smallBottomFrame

            let smallOriginFrame = CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight)

            self.videoPlayerView.playerLayer.frame = smallOriginFrame

            UIApplication.shared.keyWindow?.bringSubview(toFront: self.videoPlayerView)
            
            self.downVideoFrame = smallBottomFrame
                    
            
        }, completion: { (completedAnimation) in            
            
            self.videoPlayerView.playerLayer.borderWidth = 1.0
            self.videoPlayerView.playerLayer.borderColor = UIColor.white.cgColor 

            UIApplication.shared.setStatusBarHidden(false, with: .fade)

            self.videoPlayerView.isVideoDown = true
            
        })
    }  


    func openVideoUp()
    {
       
        if self.videoPlayerView.isVideoDown
        {

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {                 
                
                
                self.videoPlayerView.videoLauncher.view.frame = self.originalVideoFrame

                let smallOriginFrame = CGRect(x: 0, y: 0, width: self.originalVideoFrame.width, height: self.originalVideoFrame.height)

                self.videoPlayerView.playerLayer.frame = self.originalVideoFrame           
                
            }, completion: { (completedAnimation) in            
                
                self.videoPlayerView.playerLayer.borderWidth = 0.0
                
                self.videoPlayerView.hideShowControllers(status: false)

                UIApplication.shared.setStatusBarHidden(true, with: .fade)

                self.videoPlayerView.isVideoDown = true
                
            })

        }
    } 


    func swipeLeftClose()
    {
        
        if self.videoPlayerView.isVideoDown
        {

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {                      
                
                let fwidth = self.downVideoFrame.width * -1           

                self.originalVideoFrame = self.videoPlayerView.frame
                
                let leftFrame = CGRect(x: fwidth, y: self.downVideoFrame.origin.y, width: self.downVideoFrame.width, height: self.downVideoFrame.height)
                
                self.videoPlayerView.videoLauncher.view.frame = leftFrame            

                self.videoPlayerView.playerLayer.frame = leftFrame            
                
            }, completion: { (completedAnimation) in                     

                UIApplication.shared.setStatusBarHidden(false, with: .fade)

                self.videoPlayerView.isVideoDown = false

                self.videoPlayerView.handlePause()

                for subview in (UIApplication.shared.keyWindow?.subviews)! {
                    if (subview.tag == 1) {
                        subview.removeFromSuperview()
                    }
                }
            })
        }
    }  


    func keyboardOpened(keybordHeight keybordEditHeight: CGFloat)
    {
        
        if (self.infoView != nil)
        {
            self.infoView.isHidden = true
            //self.chatView.dismissKeyboard()
        }
        
        let keyHeight = self.keyWindoHeight

        let viewsHeight = self.videoPlayerView.frame.height + keybordEditHeight //+ inputHeight

        let chatHeight = keyHeight - viewsHeight
        
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
    
    
    func saveHistroy() {
        
        let histroyPF: PFObject = PFObject(className: "History")
        
        histroyPF["videoId"] = self.videoId
        
        if let userId = PFUser.current()?.objectId {
            
            histroyPF["userId"] = userId
            
        }
        
        histroyPF.saveEventually()
        
    }
    
}
