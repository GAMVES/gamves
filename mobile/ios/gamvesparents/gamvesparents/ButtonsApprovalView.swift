//
//  ButtonsApprovalView.swift
//  gamvesparents
//
//  Created by Jose Vigil on 1/1/18.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit
import Parse

enum ApprovalType {
    case TypeVideo
    case TypeFanpage
}

class ButtonsApprovalView: UIView {
    
    
    lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gamvesSemaphorGreenColor
        //button.setTitle("APPROVE VIDEO", for: UIControlState())
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
        //button.setTitle("REJECT VIDEO", for: UIControlState())
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
    var fanpageView:FanpageApprovalView!

    var referenceId = Int()
    
    var delegate:ApprovalProtocol!
    
    var approvalType:ApprovalType!
    
    init(frame: CGRect, obj: AnyObject, referenceId:Int?, delegate:ApprovalProtocol) {
        super.init(frame: frame)
        
        //let type = type(of: obj)
        
        self.delegate = delegate
        
        if (obj is VideoApprovalPlayerView) {
            
            self.approvalType = ApprovalType.TypeVideo
            
            let videoApprovalPlayerView = obj as! VideoApprovalPlayerView
            
            if videoApprovalPlayerView != nil {
                
                self.approveButton.setTitle("APPROVE VIDEO", for: UIControlState())
                self.rejectButton.setTitle("REJECT VIDEO", for: UIControlState())
               
                self.playerView = videoApprovalPlayerView
                self.referenceId = videoApprovalPlayerView.videoId
            }
            
        } else if (obj is FanpageApprovalView) {
            
            self.approvalType = ApprovalType.TypeFanpage
            
            let fanpageApprovalView = obj as! FanpageApprovalView
            
            if fanpageApprovalView != nil {
                
                self.approveButton.setTitle("APPROVE FANPAGE", for: UIControlState())
                self.rejectButton.setTitle("REJECT FANPAGE", for: UIControlState())
                
                self.fanpageView = fanpageApprovalView
                self.referenceId = fanpageApprovalView.fanpageId
            }
            
        }
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
    
    @objc func touchUpApprove() {
        
        updateApprovalStatus(referenceId: self.referenceId, status: 1);
    }
    
    @objc func touchUpReject() {
        
        updateApprovalStatus(referenceId: self.referenceId, status: -1);
    }
    
    @objc func touchUpLater() {
        
        self.closeApprovalWindow()
    }
    
    func closeApprovalWindow() {
        
        //REMOVE IF EXISTS VIDEO RUNNING
        for subview in (UIApplication.shared.keyWindow?.subviews)! {
            
            if (subview.tag == 1)
            {
                if self.approvalType == ApprovalType.TypeVideo {
                    self.playerView.handleDownButton()
                    self.playerView.handlePause()
                }
                subview.removeFromSuperview()
            }
        }
    }
    
    func updateApprovalStatus(referenceId:Int,  status: Int){
        
        print(referenceId)
        
        let queryApprovals = PFQuery(className: "Approvals")
        queryApprovals.whereKey("referenceId", equalTo: referenceId)
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
