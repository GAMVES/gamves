//
//  VideoLauncher.swift
//  youtube
//
//  Created by Jose Vigil 08/12/2017.
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

    let titleContView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        return view
    }() 

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "VIDEO APPROVAL"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
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
    
    var isPlaying = false   
    
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

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.titleContView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.titleContView)

        self.addSubview(self.controlsContainerView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.controlsContainerView)        

        self.addConstraintsWithFormat("V:|[v0(100)][v1]|", views: self.titleContView, self.controlsContainerView)          

        self.titleContView.addSubview(self.titleLabel)

        self.titleContView.addConstraintsWithFormat("H:|[v0]|", views: self.titleLabel)
        self.titleContView.addConstraintsWithFormat("V:|-40-[v0]|", views: self.titleLabel)   

    }
    
    override func layoutSubviews() {
        
        self.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        self.controlsContainerView.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true        
        pausePlayButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20).isActive = true        
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //pausePlayButton.backgroundColor = UIColor.gray
        
        self.controlsContainerView.addSubview(videoLengthLabel)
        videoLengthLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        videoLengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 80).isActive = true
        videoLengthLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        self.controlsContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true        
        currentTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 80).isActive = true        
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true        
         
        self.controlsContainerView.addSubview(videoSlider)
        videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true        
        videoSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 80).isActive = true
        videoSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor).isActive = true
        videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true

    }

    func setPlayerUrl(urlString : String)
    {        
        setupPlayerView(urlString: urlString)

        setupGradientLayer() 
    }  
    
    @objc func handlePause() {
        if isPlaying {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: UIControlState())
        } else {
            player?.play()
            pausePlayButton.setImage(UIImage(named: "pause"), for: UIControlState())
        }
        isPlaying = !isPlaying
    }    
    
    
    @objc func handleSliderChange() 
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
    
    func setViews(view:UIView, videoLauncherVidew:VideoApprovalLauncher)
    {
        self.videoLauncher = videoLauncherVidew
        self.keyWindow = view
    }
    
    var videoId = Int()
    
    func setVideoId(videoId: Int) {
        self.videoId = videoId
    }

    var videoUrl = String()

    // VIDEO   

    var player: AVPlayer?
    
    func setupPlayerView(urlString : String) {                    
        
        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
            self.controlsContainerView.layer.addSublayer(playerLayer)
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

    func showVideoPlayer(videoGamves: VideoGamves, approved :Int){
                
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

            let infoHeight = 150
            let infoY = Int(videoApprovalPlayerView.frame.height) + 100
            let infoFrame = CGRect(x: 0, y: infoY, width: Int(keyWindow.frame.width), height: infoHeight)
            
            infoApprovalView = InfoApprovalView(frame: infoFrame, obj: videoGamves)
            view.addSubview(infoApprovalView)

            let diff = Int(videoHeight) + Int(infoHeight)
            let chatHeight = Int(keyWindow.frame.height) - diff
            
            let apprY = infoY + Int(infoApprovalView.frame.height)
            let apprFrame = CGRect(x: 0, y: apprY, width: Int(keyWindow.frame.width), height: chatHeight)
            
            buttonsApprovalView = ButtonsApprovalView(frame: apprFrame, obj: videoApprovalPlayerView, referenceId: videoId, delegate: self.delegate, approved: approved)
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

    func pauseVideo() {
        videoApprovalPlayerView.handlePause()
    }
    
}


