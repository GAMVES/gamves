//
//  FriendApprovalLauncher.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-11.
//

import UIKit
import AVFoundation
import Parse
import NVActivityIndicatorView

enum FriendApprovalType {
    case YouInvite
    case YouAreInvited
}

class FriendApprovalView: UIView {    

    var type:FriendApprovalType!

    var friendApproval:FriendApproval!

    var friendLauncher:FriendApprovalLauncher!
    var keyWindow: UIView!   

    let contanierView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false     
        view.backgroundColor = UIColor.red           
        return view
    }() 

    let titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false     
        view.backgroundColor = UIColor.gamvesBackgoundColor
        return view
    }()  

    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let image  = UIImage(named: "add_friend")
        imageView.image = image
        imageView.contentMode = .scaleAspectFill        
        imageView.tintColor = UIColor.white
        imageView.layer.masksToBounds = true
        return imageView
    }() 

    let titleLabel: PaddingLabel = {
        let label = PaddingLabel()        
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.black
        label.numberOfLines = 3
        label.textAlignment = .left        
        return label
    }()

    let userView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false     
        view.backgroundColor = UIColor.gambesDarkColor           
        return view
    }() 

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        return imageView
    }()    
    
    var nameLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor.white
        return label
    }()

    var schoolLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        return label
    }()

    var gradeLabel: UILabel = {
        let label = UILabel()        
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        return label
    }() 

    let schoolImageView: UIImageView = {
        let imageView = UIImageView()                
        imageView.contentMode = .scaleAspectFill                
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()

    let buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false     
        view.backgroundColor = UIColor.white         
        return view
    }()

    lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gamvesSemaphorGreenColor
        //button.setTitle("APPROVE SEND INVITATION", for: UIControlState())
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
        //button.setTitle("REJECT INVITATION", for: UIControlState())
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


    ///ALERT 
    var alertTitle = String() 
    var alertMessage = String()
    var positiveButtonText = String() //"OK"
    var negativeButtonText = String() //"Cancel"
    var typeName = String()

    var alertAction = Int()
    // 1 remove invitation
    // 

    init(frame: CGRect, friendApproval: FriendApproval, type:FriendApprovalType) {
        super.init(frame: frame)
    
        self.friendApproval = friendApproval

        self.type = type

        self.backgroundColor = UIColor.green        

        let friendId = friendApproval.friendId
        let friend =  Global.userDictionary[friendId] as! GamvesUser

        let posterId = friendApproval.posterId
        let poster =  Global.userDictionary[posterId] as! GamvesUser               

        self.nameLabel.text = friendApproval.user.name

        self.schoolLabel.text = friendApproval.user.school.schoolName

        self.schoolImageView.image = friendApproval.user.school.thumbnail

        let levelDesc = friendApproval.user.level.description
        let levelGrade = friendApproval.user.level.grade 

        let leve_desc = "\(levelGrade) - \(levelDesc)"

        self.gradeLabel.text = leve_desc 

        self.profileImageView.image = friendApproval.user.avatar        

        self.addSubview(self.contanierView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.contanierView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.contanierView)

        self.contanierView.addSubview(self.titleView)
        self.contanierView.addConstraintsWithFormat("H:|[v0]|", views: self.titleView)
        self.contanierView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.titleView)

        self.titleView.addSubview(self.iconImageView)        
        self.titleView.addConstraintsWithFormat("V:|-30-[v0(50)]|", views: self.iconImageView)
        self.titleView.addSubview(self.titleLabel)        
        self.titleView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.titleLabel)     

        self.titleView.addConstraintsWithFormat("H:|-30-[v0(50)]-30-[v1]-30-|", views: self.iconImageView, self.titleLabel)

        self.iconImageView.alpha = 0.5
        self.titleLabel.alpha = 0.5

        self.contanierView.addSubview(self.userView)
        self.contanierView.addConstraintsWithFormat("H:|[v0]|", views: self.userView)        

        self.contanierView.addSubview(self.buttonsView)
        self.contanierView.addConstraintsWithFormat("H:|[v0]|", views: self.buttonsView)

        self.contanierView.addConstraintsWithFormat("V:|-120-[v0(200)][v1]|", views: self.userView, self.buttonsView)        

        ///// USER 

        self.userView.addSubview(self.profileImageView)     
        self.userView.addConstraintsWithFormat("H:|-20-[v0(100)]|", views: self.profileImageView)
        self.userView.addConstraintsWithFormat("V:|-40-[v0(100)]|", views: self.profileImageView)

        self.userView.addSubview(self.nameLabel)     
        self.userView.addConstraintsWithFormat("H:|-140-[v0]|", views: self.nameLabel)
        self.userView.addConstraintsWithFormat("V:|-40-[v0(50)]|", views: self.nameLabel)

        self.userView.addSubview(self.schoolLabel)     
        self.userView.addConstraintsWithFormat("H:|-140-[v0]|", views: self.schoolLabel)
        self.userView.addConstraintsWithFormat("V:|-80-[v0(30)]|", views: self.schoolLabel)
            
        self.userView.addSubview(self.gradeLabel)     
        self.userView.addConstraintsWithFormat("H:|-140-[v0]|", views: self.gradeLabel)
        self.userView.addConstraintsWithFormat("V:|-110-[v0(30)]|", views: self.gradeLabel)  

        let width = self.frame.width 

        let leftMargin = width - 120

        let imageMetrics = ["leftMargin" : leftMargin]

        self.userView.addSubview(self.schoolImageView)     
        self.userView.addConstraintsWithFormat("H:|-leftMargin-[v0(100)]|", views: self.schoolImageView, metrics: imageMetrics)
        self.userView.addConstraintsWithFormat("V:|-130-[v0(30)]|", views: self.schoolImageView)          
        
        //BUTTONS

        self.buttonsView.addSubview(self.approveButton)
        self.buttonsView.addSubview(self.rejectButton)
        self.buttonsView.addSubview(self.laterButton)
        self.buttonsView.addSubview(self.bottomView)
        
        self.buttonsView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.approveButton)
        self.buttonsView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.rejectButton)
        self.buttonsView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.laterButton)
        self.buttonsView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)

        self.addConstraintsWithFormat("V:|-30-[v0(60)]-10-[v1(60)]-10-[v2(60)]-10-[v3]|",views:
            self.approveButton,
            self.rejectButton,  
            self.laterButton,          
            self.bottomView)

        self.setLabelAndButton()
    }   

    func setLabelAndButton() {

        var posterId = self.friendApproval.posterId           
        var friendId = self.friendApproval.friendId 

        var posterName =  String()
        var friendName =  String()


        if let nm =  Global.userDictionary[posterId]?.name {
            posterName = nm
        }

        if let fn =  Global.userDictionary[friendId]?.name {
            friendName = fn 
        }
        
        // YOU INVITE

        if self.type == FriendApprovalType.YouInvite { 

            let textButton = String()

            if  self.friendApproval!.approved == 0 {

                self.approveButton.isHidden = true

                //BUTTON

                self.rejectButton.setTitle("REMOVE SENT INVITATION", for: UIControlState())     

                //ALERT 

                self.alertMessage = "Are you sure you want to remove your invitation to \(typeName)?"
                self.positiveButtonText = "YES"
                self.negativeButtonText = "NO"        

                self.alertAction = 1

            }                 

            titleLabel.text = "You invited \(friendName) to become your friend"//\(friend.firstName)"
            iconImageView.image = UIImage(named: "call_sent")


        } else if self.type == FriendApprovalType.YouAreInvited { 

            self.approveButton.setTitle("ACCEPT INVITATION", for: UIControlState())

            titleLabel.text = "\(posterName) wants to become friends with you" //\(poster.firstName)"            
            iconImageView.image = UIImage(named: "call_received")
        }
    }
    
    
    func setViews(view:UIView, friendLauncherVidew:FriendApprovalLauncher)
    {
        self.friendLauncher = friendLauncherVidew
        self.keyWindow = view
    }
    
    required init?(coder aDecoder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }  

    @objc func touchUpLater() {
        
        self.closeApprovalWindow()
    }

    @objc func closeVideo()
    {
        //REMOVE IF EXISTS VIDEO RUNNING
        for subview in (UIApplication.shared.keyWindow?.subviews)! {
            if (subview.tag == 1)
            {                
                subview.removeFromSuperview()
                UIApplication.shared.setStatusBarHidden(false, with: .fade)
            }
        }
    }

     @objc func touchUpApprove() {
        
        if self.type == FriendApprovalType.YouInvite {           

            self.updateFriendRegisterApproval()

        } else if self.type == FriendApprovalType.YouAreInvited {            

            self.addFriend()            
        }        
    }
    
    @objc func touchUpReject() {        
        
        Util.sharedInstance.showAlertView(title: self.alertTitle , message: self.alertMessage, actionTitles: [self.negativeButtonText, self.positiveButtonText], actions: [
        {()->() in

            print(self.negativeButtonText)

            self.friendLauncher.delegate.refresh()
            self.closeApprovalWindow()

        },{()->() in

            print(self.positiveButtonText)
                 

            switch self.alertAction {
                
                case 1:
                    self.removeInvitation()
                    break

                case 2:
                    self.updateFriendApprovalStatus(status: -1)
                    break

                case 3:
                    break

                default:
                    break                
            }       
        
        }])        
    }
    
    
    func closeApprovalWindow() {
        
        //REMOVE IF EXISTS VIDEO RUNNING
        for subview in (UIApplication.shared.keyWindow?.subviews)! {
            
            if (subview.tag == 1)
            {
                subview.removeFromSuperview()
                UIApplication.shared.setStatusBarHidden(false, with: .fade)
            }
        }
    }

    func removeInvitation() {

        let friendApprovalPF = self.friendApproval.objectPF
        
        friendApprovalPF?.deleteInBackground(block: { (resutl, error) in
            
            self.friendLauncher.delegate.refresh()
            self.closeApprovalWindow()
            
        })
    }


     func updateFriendApprovalStatus(status: Int) {    

        let friendApprovalPF = self.friendApproval.objectPF       
                
        friendApprovalPF?["approved"] = status
        
        friendApprovalPF?.saveInBackground(block: { (resutl, error) in            
           
           self.friendLauncher.delegate.refresh()
           self.closeApprovalWindow()
            
        })            
        
    }
    

    func updateFriendRegisterApproval() {

        // VERIFY IF A PENDING INVITATION EXISTS

        self.friendLauncher.activityIndicatorView?.startAnimating()

        let friendApprovalPF = self.friendApproval.objectPF

        friendApprovalPF?["approved"] = 1
        
        friendApprovalPF?.saveInBackground(block: { (resutl, error) in    

            let friendsRegisterApproval: PFObject = PFObject(className: "FriendsApproval")

            var posterId = self.friendApproval.posterId  

            friendsRegisterApproval["posterId"] = posterId

            friendsRegisterApproval["friendApprovalId"] = friendApprovalPF?.objectId

            let friendId = self.friendApproval.friendId  

            var friend = Global.userDictionary[friendId]

            friendsRegisterApproval["friendId"] = friendId        

            let familyId = friend?.familyId

            print(familyId)

            friendsRegisterApproval["familyId"] = familyId 

            friendsRegisterApproval["approved"] = 0            

            friendsRegisterApproval["type"] = 2      
            
            friendsRegisterApproval.saveInBackground { (resutl, error) in
                
                if error == nil {                    

                    self.friendLauncher.activityIndicatorView?.stopAnimating()
                    self.friendLauncher.delegate.update(name: (friend?.name)!)
                    self.closeApprovalWindow()                                       
                }
            }
        })  
    }
    
    func addFriend() {
        
        var posterId = self.friendApproval.posterId           
        var friendId = self.friendApproval.friendId  
        
        self.friendLauncher.activityIndicatorView?.startAnimating()

        let friendApprovalPF = self.friendApproval.objectPF

        friendApprovalPF?["approved"] = 2
        
        friendApprovalPF?.saveInBackground(block: { (resutlFA, error) in                      
            

            self.getFriendIfnotExist(userId: friendId, friendId: posterId, completionHandler: { ( resutl ) -> () in

                if resutl {
                    
                    self.getFriendIfnotExist(userId: posterId, friendId: friendId, completionHandler: { ( friendObj ) -> () in                                           

                        if friendObj != nil {
                        
                            let posterName =  Global.userDictionary[posterId]?.name
                            let friendName =  Global.userDictionary[friendId]?.name
                            
                            self.friendLauncher.activityIndicatorView?.stopAnimating()
                            self.friendLauncher.delegate.usersAdded(friendName: friendName!, posterName: posterName!)
                            self.closeApprovalWindow()                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
                        
                        } else {
                            
                            print("error")
                        }
                        
                    })
                    
                } else {
                    
                    print("error")
                }                                            
            })
        })            
    }
    

    func getFriendIfnotExist(userId: String, friendId: String, completionHandler : @escaping (_ result: Bool) -> ()) {

        let userQuery = PFQuery(className:"Friends")
        userQuery.whereKey("userId", equalTo: userId)
        userQuery.getFirstObjectInBackground(block: { (friendObject, error) in               
    
            if friendObject != nil
            {

                friendObject?.addObjects(from: [friendId], forKey: "friends")
                
                friendObject?.saveInBackground(block: { (friendSPF, error) in
                
                    if error == nil {

                        completionHandler(true) 

                    } else {

                        completionHandler(false) 
                    }
                })

            } else {               

                let friendObj = PFObject(className: "Friends")
                friendObj["userId"] = userId
                friendObj["friends"] = [friendId]    

                friendObj.saveInBackground(block: { (friendSPF, error) in
                
                    if error == nil {

                        completionHandler(true) 

                    } else {

                        completionHandler(false) 
                    }

                })
            }                    
        })
    }
}


class FriendApprovalLauncher: UIView {  

    var activityIndicatorView:NVActivityIndicatorView?  
    
    var buttonsFriendApprovalView:FriendApprovalButtonsView!
    
    var friendApprovalView:FriendApprovalView!
    
    var delegate:FriendApprovalProtocol!
    
    var view:UIView!
    
    var originaChatYPosition = CGFloat()
    var originaChatHeightPosition = CGFloat()

    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    func showUserForFriend(friendApproval: FriendApproval, approved :Int, screenHeight:Int){
                
        if let keyWindow = UIApplication.shared.keyWindow {

            view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.white
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)                                    

            var type:FriendApprovalType!

            if friendApproval.invite {
                type = FriendApprovalType.YouInvite 
            } else {
                type = FriendApprovalType.YouAreInvited 
            }

            let friendFrame = CGRect(x: 0, y: 0, width: Int(keyWindow.frame.width) , height: Int(keyWindow.frame.height))

            friendApprovalView = FriendApprovalView(frame: friendFrame, friendApproval: friendApproval, type:type)
            friendApprovalView.backgroundColor = UIColor.gamvesColor           
           
            view.addSubview(friendApprovalView)

            let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))                                 
            friendApprovalView.addGestureRecognizer(panGesture)                       

            friendApprovalView.setViews(view: view, friendLauncherVidew: self)
            keyWindow.addSubview(view)

            view.tag = 1

            self.activityIndicatorView = Global.setActivityIndicator(container: view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in
                    
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
                    
            })
        }
    }

     @objc func handlePanGesture(sender: UIPanGestureRecognizer) {        

        let touchPoint = sender.location(in: self.view?.window)

        let touchY = touchPoint.y - initialTouchPoint.y

        if touchY > 100 {

            let alpha = self.view.alpha
            let remove = touchY/10000
            let finalAlpha = alpha - remove

            self.view.alpha = finalAlpha            

            if touchY > 500 {

                self.friendApprovalView.closeVideo()                

                UIApplication.shared.setStatusBarHidden(false, with: .fade)
            }
        }

        if sender.state == UIGestureRecognizerState.began {

            initialTouchPoint = touchPoint

        } else if sender.state == UIGestureRecognizerState.changed {

            if touchPoint.y - initialTouchPoint.y > 0 {

                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
                
            }

        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            
            if touchPoint.y - initialTouchPoint.y > 200 {                               

                self.friendApprovalView.closeVideo()
                
                UIApplication.shared.setStatusBarHidden(false, with: .fade)

            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }

    } 

    
}
