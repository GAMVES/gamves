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

    var approved = Bool()
    
    init(frame: CGRect, obj: AnyObject, referenceId:Int?, delegate:ApprovalProtocol, approved:Bool) {
        super.init(frame: frame)
        
        //let type = type(of: obj)

        self.approved = approved
        
        self.delegate = delegate
        
        self.referenceId = referenceId!
        
        if (obj is VideoApprovalPlayerView) {
            
            self.approvalType = ApprovalType.TypeVideo
            
            let videoApprovalPlayerView = obj as! VideoApprovalPlayerView
            
            if videoApprovalPlayerView != nil {

                self.playerView = videoApprovalPlayerView
                
                if !self.approved {
                
                    self.approveButton.setTitle("APPROVE VIDEO", for: UIControlState())
                    self.rejectButton.setTitle("REJECT VIDEO", for: UIControlState())
                    
                    //self.referenceId = videoApprovalPlayerView.videoId
                
                } else {
                    
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

                if !self.approved {
                
                    self.approveButton.setTitle("APPROVE FANPAGE", for: UIControlState())

                    self.rejectButton.setTitle("REJECT FANPAGE", for: UIControlState())

                } else {

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
        

       /* let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
              
            switch action.style {

              case .default:
                    print("default")
                    self.updateApprovalStatus(referenceId: self.referenceId, status: -1);

              case .cancel:
                    print("cancel")

              case .destructive:
                    print("destructive")

            }

        }))

        //let currentController = Global.getCurrentViewController()
        //currentController?.present(alert, animated: true, completion: nil)
        //self.present(alert, animated: true, completion: nil)

        //let win = UIWindow(frame: UIScreen.main.bounds)

        let currentController = Global.getCurrentViewController()
        
        currentController?.view.backgroundColor = .clear
        
        //win.rootViewController = currentController
        //win.windowLevel = UIWindowLevelAlert + 1
        //win.makeKeyAndVisible()
       

        currentController?.present(alert, animated: true, completion: nil)      

        

        //currentController?.view.bringSubview(toFront: alert.view)*/

        // show alert.


        let alertTitle = "Title"
        let alertMessage = "message1\nmessage2"
        let positiveButtonText = "OK"
        let negativeButtonText = "Cancel"
        
        Util.sharedInstance.showAlertView(title: alertTitle , message: alertMessage, actionTitles: [negativeButtonText, positiveButtonText], actions: [
        {()->() in

            print(negativeButtonText)

        },{()->() in

            print(positiveButtonText)
        
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
