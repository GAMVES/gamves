//
//  File.swift
//  gamves
//
//  Created by Jose Vigil on 2018-07-19.
//


import UIKit
import AVFoundation
import Parse

class PublicProfileView: UIView,
 UICollectionViewDataSource, 
 UICollectionViewDelegate, 
 UICollectionViewDelegateFlowLayout 
 {


    var publicProfileLauncher:PublicProfileLauncher!
    var keyWindow: UIView!
    var playerLayer: AVPlayerLayer!    

    var homeController:HomeController!
    let profileCellId = "profileCellId"
    var profileHome:ProfileCell!
    var gamvesUser:GamvesUser!

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()  

    override init(frame: CGRect) {        
        super.init(frame: frame)

        self.collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: self.profileCellId)       

        self.addSubview(self.collectionView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
      
        collectionView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)        
        collectionView.isPagingEnabled = false
        collectionView.reloadData()
    }
    
    func setViews(view:UIView, launcher:PublicProfileLauncher) {
        self.publicProfileLauncher = launcher
        self.keyWindow = view
    }

    required init?(coder aDecoder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }   

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let identifier: String

        identifier = profileCellId

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)

        profileHome = cell as! ProfileCell        

        profileHome.gamvesUser = self.gamvesUser         

        profileHome.setSonProfileImageView()

        profileHome.setProfileType(type: ProfileSaveType.chat)

        return cell

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: self.frame.height - 50)
    }

    func setUser(user:GamvesUser) {    

        NotificationCenter.default.addObserver(self, selector: #selector(closeProfile), name: NSNotification.Name(rawValue: Global.notificationKeyCloseVideo), object: nil)         

        self.gamvesUser = user    
    }
    
    
    func closeProfile()
    {
        //REMOVE IF EXISTS VIDEO RUNNING
        for subview in (UIApplication.shared.keyWindow?.subviews)! {
            if (subview.tag == 1)
            {                
                subview.removeFromSuperview()
            }
        }
    }    

}

class PublicProfileLauncher: UIView {

    class func className() -> String {
        return "PublicProfileLauncher"
    }
        
    var infoView:InfoView!
    var chatView:ChatView!
    var publicProfileView:PublicProfileView!
    
    var view:UIView!
    
    var originaChatYPosition = CGFloat()
    var originaChatHeightPosition = CGFloat()    

    var yLocation = CGFloat()
    var xLocation = CGFloat()
    var lastX = CGFloat()   

    var keyWindoWidth = CGFloat()
    var keyWindoHeight = CGFloat()

    //var valpha = CGFloat() 

    var originalVideoFrame = CGRect()
    //var downVideoFrame = CGRect()
    
    var videoId = Int()

    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    func showProfileView(gamvesUser: GamvesUser){
        
        self.keyWindoWidth = (UIApplication.shared.keyWindow?.frame.size.width)!
        self.keyWindoHeight = (UIApplication.shared.keyWindow?.frame.size.height)!   
        
        if let keyWindow = UIApplication.shared.keyWindow {

            self.view = UIView(frame: keyWindow.frame)
            self.view.backgroundColor = UIColor.white
            
            self.view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 60, width: 10, height: 10 + 60)                       
            
            let publicProfileFrame = CGRect(x: 0, y: -60, width: keyWindow.frame.width, height: keyWindow.frame.height  + 60)           

            self.publicProfileView = PublicProfileView(frame: publicProfileFrame)                        
            
            self.view.addSubview(self.publicProfileView)               
           
            let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))                                 
            self.publicProfileView.addGestureRecognizer(panGesture)                       
            
            self.publicProfileView.setViews(view: self.view, launcher: self)
            
            keyWindow.addSubview(self.view)

            view.tag = 1
            
            self.saveHistroy()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in                   
                    
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
            })
        }
    }    

    func handlePanGesture(sender: UIPanGestureRecognizer) {        

        let touchPoint = sender.location(in: self.view?.window)

        let touchY = touchPoint.y - initialTouchPoint.y

        if touchY > 100 {

            let alpha = self.view.alpha
            let remove = touchY/10000
            let finalAlpha = alpha - remove

            self.view.alpha = finalAlpha            

            if touchY > 500 {

                self.publicProfileView.closeProfile()

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

                self.publicProfileView.closeProfile()
                
                UIApplication.shared.setStatusBarHidden(false, with: .fade)

            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }

    } 

    
    
    func shrinkVideoDown()
    {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {           
            
            
            let totalHeight = UIApplication.shared.keyWindow?.frame.size.height
            let totalWidth = UIApplication.shared.keyWindow?.frame.size.width
            
            let thumbWidth = totalWidth! / 2
            let thumbHeight = thumbWidth * 9 / 16
            
            let x = (totalWidth! / 2) - (thumbWidth / 2)
            let y = totalHeight! - (thumbHeight + 30)
            
            self.yLocation = y            
            self.xLocation = x
            self.lastX = x  

            self.originalVideoFrame = self.publicProfileView.frame
            
            //let smallBottomFrame = CGRect(x: x, y: y, width: thumbWidth, height: thumbHeight)
            
            //self.publicProfileView.publicProfileLauncher.view.frame = smallBottomFrame

            let smallOriginFrame = CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight)

            self.publicProfileView.playerLayer.frame = smallOriginFrame

            UIApplication.shared.keyWindow?.bringSubview(toFront: self.publicProfileView)
            
            //self.downVideoFrame = smallBottomFrame
                    
            
        }, completion: { (completedAnimation) in            
            
            self.publicProfileView.playerLayer.borderWidth = 1.0
            self.publicProfileView.playerLayer.borderColor = UIColor.white.cgColor

            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            
        })
    }  


    
    
    
    func keyboardclosed()
    {
        if (self.infoView != nil)
        {
            self.infoView.isHidden = false
        }
        
        self.chatView.frame.origin.y = self.originaChatYPosition
        
        self.chatView.frame.size.height = self.originaChatHeightPosition        
    }
    
    
    func saveHistroy() {
        
        let histroyPF: PFObject = PFObject(className: "History")
        
        histroyPF["videoId"] = self.videoId
        
        if let userId = PFUser.current()?.objectId {
            
            histroyPF["userId"] = userId
            
        }
        
        histroyPF.saveEventually()
        
    }
    
}
