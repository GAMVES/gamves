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

class FanpageApprovalView: UIView {

    var fanpageApprovalView:FanpageApprovalView!
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
            
            self.arrowDownButton.isHidden = true
            
            self.controlsContainerView.isHidden = true
            
            let smallFrame = CGRect(x: x, y: y, width: thumbWidth, height: thumbHeight)
            
            self.fanpageApprovalView.frame = smallFrame
            
            self.playerLayer.frame = smallFrame
            
            self.fanpageApprovalView.isUserInteractionEnabled = true
        
        
        }, completion: { (completedAnimation) in
            
            //maybe we'll do something here later...
            UIApplication.shared.setStatusBarHidden(true, with: .fade)
            
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setViews(view:UIView, fanpageApprovalView:FanpageApprovalView)
    {
        self.fanpageApprovalView = fanpageApprovalView
        self.keyWindow = view
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


class FanpageApprovalLauncher: UIView {
    
    var infoApprovalView:InfoApprovalView!
    
    var buttonsApprovalView:ButtonsApprovalView!
    
    var fanpageApprovalView:FanpageApprovalView!
    
    var delegate:ApprovalProtocol!
    
    var view:UIView!
    
    var originaChatYPosition = CGFloat()
    var originaChatHeightPosition = CGFloat()

    func showFanpageList(fanpageGamves: FanpageGamves){
        
        let fanpageId = fanpageGamves.fanpageId
        
        if let keyWindow = UIApplication.shared.keyWindow {

            view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.white
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            
            //16 x 9 is the aspect ratio of all HD videos
            let videoHeight = keyWindow.frame.width * 9 / 16
            let fanpagePlayerFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: videoHeight)
            
            fanpageApprovalView = FanpageApprovalView(frame: fanpagePlayerFrame)
            view.addSubview(fanpageApprovalView)

            let infoHeight = 200
            let infoFrame = CGRect(x: 0, y: Int(fanpageApprovalView.frame.height), width: Int(keyWindow.frame.width), height: infoHeight)
            
            infoApprovalView = InfoApprovalView(frame: infoFrame, obj: fanpageGamves)
            view.addSubview(infoApprovalt View)

            let diff = Int(videoHeight) + Int(infoHeight)
            let chatHeight = Int(keyWindow.frame.height) - diff
            
            let apprY = Int(fanpageApprovalView.frame.height) + Int(infoApprovalView.frame.height)
            let apprFrame = CGRect(x: 0, y: apprY, width: Int(keyWindow.frame.width), height: chatHeight)
            
            buttonsApprovalView = ButtonsApprovalView(frame: apprFrame, playerView: nil, videoId: nil, delegate: self.delegate)
            
            buttonsApprovalView.backgroundColor = UIColor.gamvesBackgoundColor
            view.addSubview(buttonsApprovalView)
            buttonsApprovalView.addSubViews()

            fanpageApprovalView.setViews(view: view, fanpageApprovalView: fanpageApprovalView)
            
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
