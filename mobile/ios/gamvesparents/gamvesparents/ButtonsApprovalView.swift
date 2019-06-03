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
        button.backgroundColor = UIColor.cyberChildrenColor
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

    var approved = Bool()
    
    init(frame: CGRect, obj: AnyObject, referenceId:Int?, delegate:ApprovalProtocol, approved:Int) {
        super.init(frame: frame)       
        
        self.delegate = delegate
        
        self.referenceId = referenceId!
        
        if (obj is VideoApprovalPlayerView) {
            
            self.approvalType = ApprovalType.TypeVideo
            
            let videoApprovalPlayerView = obj as! VideoApprovalPlayerView
            
            if videoApprovalPlayerView != nil {

                self.playerView = videoApprovalPlayerView

                if approved == -1 {

                    self.approveButton.setTitle("APPROVE VIDEO", for: UIControlState())
                    self.rejectButton.setTitle("REJECT VIDEO", for: UIControlState())
                    self.rejectButton.isEnabled = false
                    self.rejectButton.alpha = 0.4

                } else if approved == 0 {

                    self.approveButton.setTitle("APPROVE VIDEO", for: UIControlState())
                    self.rejectButton.setTitle("REJECT VIDEO", for: UIControlState())

                } else if approved == 1 {

                    self.approveButton.setTitle("APPROVE VIDEO", for: UIControlState())
                    self.approveButton.isEnabled = false
                    self.approveButton.alpha = 0.4

                    self.rejectButton.setTitle("REJECT VIDEO", for: UIControlState())                    
                    self.laterButton.setTitle("CLOSE VIDEO", for: UIControlState())


                }                     
                              
            }
            
        } else if (obj is FanpageApprovalView) {
            
            self.approvalType = ApprovalType.TypeFanpage
            
            let fanpageApprovalView = obj as! FanpageApprovalView
            
            if fanpageApprovalView != nil {

                self.fanpageView = fanpageApprovalView

                if approved == -1 {

                    self.approveButton.setTitle("APPROVE FANPAGE", for: UIControlState())
                    self.rejectButton.setTitle("REJECT FANPAGE", for: UIControlState())
                    self.rejectButton.isEnabled = false
                    self.rejectButton.alpha = 0.4

                } else if approved == 0 {

                    self.approveButton.setTitle("APPROVE FANPAGE", for: UIControlState())
                    self.rejectButton.setTitle("REJECT FANPAGE", for: UIControlState())
                

                } else if approved == 1 {

                    self.approveButton.setTitle("APPROVE FANPAGE", for: UIControlState())
                    self.approveButton.isEnabled = false
                    self.approveButton.alpha = 0.4

                    self.rejectButton.setTitle("REJECT FANPAGE", for: UIControlState())
                    self.laterButton.setTitle("CLOSE FANPAGE", for: UIControlState())
               }
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

        delegate.pauseVideo()       

        var alertTitle = String() //"Title"
        var alertMessage = String() //"message1\nmessage2"
        var positiveButtonText = String() //"OK"
        var negativeButtonText = String() //"Cancel"

        var typeName = String()

        if self.approvalType == ApprovalType.TypeVideo { 

            typeName = "video"
            alertTitle = "Reject \(typeName)"            

        } else if self.approvalType == ApprovalType.TypeFanpage {

            typeName = "fanpage"
            alertTitle = "Reject \(typeName)"             

        }       

        alertMessage = "Are you sure you want to reject your \(typeName)? If yes will no appear any longer to your son and friends."
        positiveButtonText = "YES"
        negativeButtonText = "NO"     
        
        Util.sharedInstance.showAlertView(title: alertTitle , message: alertMessage, actionTitles: [negativeButtonText, positiveButtonText], actions: [
        {()->() in

            print(negativeButtonText)

            self.delegate.closedRefresh()
            self.closeApprovalWindow()

        },{()->() in

            print(positiveButtonText)

            self.updateApprovalStatus(referenceId: self.referenceId, status: -1);           
        
        }])
        
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
                    
                    if self.approvalType == ApprovalType.TypeVideo { //Update Video Approval
                        
                        let queryApprovals = PFQuery(className: "Videos")
                        queryApprovals.whereKey("videoId", equalTo: referenceId)
                        queryApprovals.getFirstObjectInBackground { (video, error) in
                            
                            if error != nil
                            {
                                print("error")
                                
                            } else {
                                
                                video!["approved"] = true
                                video!["authorized"] = true
                                
                                video?.saveEventually()
                                
                                self.delegate.closedRefresh()
                                self.closeApprovalWindow()
                                
                            }
                        }
                        
                        
                    } else if self.approvalType == ApprovalType.TypeFanpage {
                        
                        let queryApprovals = PFQuery(className: "Fanpages")
                        queryApprovals.whereKey("fanpageId", equalTo: referenceId)
                        queryApprovals.getFirstObjectInBackground { (fanpage, error) in
                        
                            if error != nil
                            {
                                print("error")
                                
                            } else {
                                
                                fanpage!["approved"] = true
                                
                                fanpage?.saveEventually()
                                
                                self.delegate.closedRefresh()
                                self.closeApprovalWindow()
                                
                            }
                        }
                    }
                    
                })
            }
        }
    }
}
