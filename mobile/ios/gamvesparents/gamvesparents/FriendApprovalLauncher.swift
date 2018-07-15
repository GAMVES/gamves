//
//  FriendApprovalLauncher.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-11.
//

import UIKit
import AVFoundation
import Parse


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
        //view.backgroundColor = UIColor.red           
        return view
    }() 

    let titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false     
        view.backgroundColor = UIColor.gambesDarkColor
        return view
    }()   

    let titleLabel: PaddingLabel = {
        let label = PaddingLabel()        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.numberOfLines = 3
        label.textAlignment = .center
        //label.backgroundColor = UIColor.gamvesColor
        return label
    }()

    let userView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false     
        view.backgroundColor = UIColor.gamvesColor           
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

    init(frame: CGRect, friendApproval: FriendApproval, type:FriendApprovalType) {
        super.init(frame: frame)

        self.type = type

        let sonId = friendApproval.posterId
        let son =  Global.userDictionary[sonId] as! GamvesUser

        let friendId = friendApproval.friendId
        let friend =  Global.userDictionary[friendId] as! GamvesUser

        if type == FriendApprovalType.YouInvite {

            titleLabel.text = "\(son.firstName) wants to be a friend of \(friend.firstName), please accept and send a requeste to his/her parents"

        } else if type == FriendApprovalType.YouAreInvited { 

            titleLabel.text = "FRIEND REQUEST"
        }

        self.nameLabel.text = friend.name
        self.schoolLabel.text = Global.gamvesFamily.schoolName

        let level = "\(friend.levelNumber) - \(friend.levelDescription)"     

        self.gradeLabel.text = level 

        self.profileImageView.image = friendApproval.thumbnail        

        self.addSubview(self.contanierView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.contanierView)
        self.addConstraintsWithFormat("V:|-50-[v0]|", views: self.contanierView)

        self.contanierView.addSubview(self.titleView)
        self.contanierView.addConstraintsWithFormat("H:|[v0]|", views: self.titleView)
        self.contanierView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.titleView)

        self.titleView.addSubview(self.titleLabel)
        self.titleView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.titleLabel)
        self.titleView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.titleLabel)

        self.contanierView.addSubview(self.userView)
        self.contanierView.addConstraintsWithFormat("H:|[v0]|", views: self.userView)        
        self.contanierView.addConstraintsWithFormat("V:|-120-[v0(250)]|", views: self.userView)        

        ///// USER 

        self.userView.addSubview(self.profileImageView)     
        self.userView.addConstraintsWithFormat("H:|-20-[v0(100)]|", views: self.profileImageView)
        self.userView.addConstraintsWithFormat("V:|-20-[v0(100)]|", views: self.profileImageView)

        self.userView.addSubview(self.nameLabel)     
        self.userView.addConstraintsWithFormat("H:|-140-[v0]|", views: self.nameLabel)
        self.userView.addConstraintsWithFormat("V:|-20-[v0(50)]|", views: self.nameLabel)

        self.userView.addSubview(self.schoolLabel)     
        self.userView.addConstraintsWithFormat("H:|-140-[v0]|", views: self.schoolLabel)
        self.userView.addConstraintsWithFormat("V:|-60-[v0(30)]|", views: self.schoolLabel)
            
        self.userView.addSubview(self.gradeLabel)     
        self.userView.addConstraintsWithFormat("H:|-140-[v0]|", views: self.gradeLabel)
        self.userView.addConstraintsWithFormat("V:|-90-[v0(30)]|", views: self.gradeLabel)   
        

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

}


class FriendApprovalLauncher: UIView {    
    
    var buttonsFriendApprovalView:ButtonsFriendApprovalView!
    
    var friendApprovalView:FriendApprovalView!
    
    var delegate:FriendApprovalProtocol!
    
    var view:UIView!
    
    var originaChatYPosition = CGFloat()
    var originaChatHeightPosition = CGFloat()

    func showUserForFriend(friendApproval: FriendApproval, approved :Int, screenHeight:Int){
                
        if let keyWindow = UIApplication.shared.keyWindow {

            view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.white
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)                 
            
            let friendHeight = 450
            let buttonsHeight = screenHeight - friendHeight 

            print(buttonsHeight)

            let friendFrame = CGRect(x: 0, y: 0, width: Int(keyWindow.frame.width), height: friendHeight)

            var type:FriendApprovalType!

             if friendApproval.type == 1 {
                type = FriendApprovalType.YouInvite 
            } else if friendApproval.type == 2 {
                type = FriendApprovalType.YouInvite 
            }

            friendApprovalView = FriendApprovalView(frame: friendFrame, friendApproval: friendApproval, type:type)
            friendApprovalView.backgroundColor = UIColor.gamvesColor           

           
            view.addSubview(friendApprovalView)
            
            let apprFrame = CGRect(x: 0, y: buttonsHeight, width: Int(keyWindow.frame.width), height: buttonsHeight)
            
            buttonsFriendApprovalView = ButtonsFriendApprovalView(frame: apprFrame, obj: friendApprovalView, delegate: self.delegate, approved: approved)
            buttonsFriendApprovalView.backgroundColor = UIColor.gamvesBackgoundColor
            
            view.addSubview(buttonsFriendApprovalView)
            buttonsFriendApprovalView.addSubViews()

            friendApprovalView.setViews(view: view, friendLauncherVidew: self)
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