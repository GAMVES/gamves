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
        label.font = UIFont.boldSystemFont(ofSize: 20)
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

    init(frame: CGRect, friendApproval: FriendApproval, type:FriendApprovalType) {
        super.init(frame: frame)

        self.type = type

        self.backgroundColor = UIColor.green        

        let friendId = friendApproval.friendId
        let friend =  Global.userDictionary[friendId] as! GamvesUser

        let posterId = friendApproval.posterId
        let poster =  Global.userDictionary[posterId] as! GamvesUser        

        if type == FriendApprovalType.YouInvite {                        

            titleLabel.text = "\(poster.firstName) wants to become friends with \(friend.firstName)"

        } else if type == FriendApprovalType.YouAreInvited { 

            titleLabel.text = "\(friend.firstName) wants to become friends with \(poster.firstName)"            
        }

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
        self.addConstraintsWithFormat("V:|-20-[v0]|", views: self.contanierView)

        self.contanierView.addSubview(self.titleView)
        self.contanierView.addConstraintsWithFormat("H:|[v0]|", views: self.titleView)
        self.contanierView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.titleView)

        self.titleView.addSubview(self.iconImageView)        
        self.titleView.addConstraintsWithFormat("V:|-30-[v0(50)]|", views: self.iconImageView)
        self.titleView.addSubview(self.titleLabel)        
        self.titleView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.titleLabel)     

        self.titleView.addConstraintsWithFormat("H:|-30-[v0(50)]-30-[v1]-30-|", views: self.iconImageView, self.titleLabel)

        self.iconImageView.alpha = 0.3
        self.titleLabel.alpha = 0.3

        self.contanierView.addSubview(self.userView)
        self.contanierView.addConstraintsWithFormat("H:|[v0]|", views: self.userView)        
        self.contanierView.addConstraintsWithFormat("V:|-120-[v0(200)]|", views: self.userView)        

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
            
            let friendHeight = 320
            let buttonsHeight = screenHeight - friendHeight 

            print(buttonsHeight)

            let friendFrame = CGRect(x: 0, y: 0, width: Int(keyWindow.frame.width), height: friendHeight)

            var type:FriendApprovalType!

            if friendApproval.type == 1 {
                type = FriendApprovalType.YouInvite 
            } else if friendApproval.type == 2 {
                type = FriendApprovalType.YouAreInvited 
            }

            friendApprovalView = FriendApprovalView(frame: friendFrame, friendApproval: friendApproval, type:type)
            friendApprovalView.backgroundColor = UIColor.cyberChildrenColor           
           
            view.addSubview(friendApprovalView)
            
            let apprFrame = CGRect(x: 0, y: friendHeight, width: Int(keyWindow.frame.width), height: buttonsHeight)
            
            buttonsFriendApprovalView = ButtonsFriendApprovalView(frame: apprFrame, obj: friendApprovalView, friendApproval: friendApproval, delegate: self.delegate, approved: approved)
            buttonsFriendApprovalView.backgroundColor = UIColor.gamvesBackgoundColor
            buttonsFriendApprovalView.type = type
            
            if friendApproval.type == 2 
            {
                buttonsFriendApprovalView.friendApproval = friendApproval
            }

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
