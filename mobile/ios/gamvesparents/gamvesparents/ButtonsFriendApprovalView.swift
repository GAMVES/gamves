//
//  ButtonsFriendApprovalView.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-12.
//

import UIKit
import Parse


class ButtonsFriendApprovalView: UIView {    

    var type:FriendApprovalType!

    var friendApproval:FriendApproval!

     lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gamvesSemaphorGreenColor
        button.setTitle("APPROVE SEND INVITATION", for: UIControlState())
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
        button.setTitle("REJECT INVITATION", for: UIControlState())
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
    
    var delegate:FriendApprovalProtocol!
    
    var approvalType:ApprovalType!

    var approved = Bool()
    
    init(frame: CGRect, obj: FriendApprovalView, friendApproval: FriendApproval, delegate:FriendApprovalProtocol, approved:Int) {
        super.init(frame: frame)               

        self.friendApproval = friendApproval

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
    
    
    @objc func touchUpApprove() {
        
        if self.type == FriendApprovalType.YouInvite {

            

        } else if self.type == FriendApprovalType.YouAreInvited {

            self.addFriend()            
        }

        
    }
    
    @objc func touchUpReject() {

        var alertTitle = String() //"Title"
        var alertMessage = String() //"message1\nmessage2"
        var positiveButtonText = String() //"OK"
        var negativeButtonText = String() //"Cancel"

        var typeName = String()              

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

            self.updateFriendApprovalStatus(status: -1)
        
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
                    //self.playerView.handlePause()
                }
                subview.removeFromSuperview()
            }
        }
    }


     func updateFriendApprovalStatus(status: Int) {    

        let friendApprovalPF = self.friendApproval.objectPF       
                
        friendApprovalPF?["approved"] = status
        
        friendApprovalPF?.saveInBackground(block: { (resutl, error) in            
           
           self.delegate.closedRefresh()
           self.closeApprovalWindow()
            
        })            
        
    }
    

    func addFriend() {

        let friendApprovalPF = self.friendApproval.objectPF

        friendApprovalPF?["approved"] = 0
        
        friendApprovalPF?.saveInBackground(block: { (resutl, error) in            
           
            let userId = self.friendApproval.friendId

            let friend =  Global.userDictionary[userId] as! GamvesUser            

            var family = PFObject(className: "Family")

             let friendsApproval: PFObject = PFObject(className: "FriendsApproval")
            
            friendsApproval["posterId"] = self.friendApproval.posterId
            friendsApproval["familyId"] = friend.familyId 
            friendsApproval["approved"] = 0    
            friendsApproval["type"] = 2    
            friendsApproval["friendId"] = self.friendApproval.friendId 

            friendsApproval.saveInBackground { (resutl, error) in
                
                if error == nil {

                    self.delegate.closedRefresh()
                    self.closeApprovalWindow()
                
                }
            }           
            
        })           

    }
    
   

}
