//
//  ButtonsApprovalView.swift
//  gamvesparents
//
//  Created by Jose Vigil on 1/1/18.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit
import Parse

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
    

    init(frame: CGRect, playerView:VideoApprovalPlayerView?, videoId:Int?, delegate:ApprovalProtocol) {
        
        super.init(frame: frame)
        
        if playerView != nil {
            
            self.playerView = playerView
            self.videoId = videoId!
        }
        
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
