//
//  ProfileViewController.swift
//  gamves
//
//  Created by Jose Vigil on 19/01/2018.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit


class ProfileView: UIView,  
    UICollectionViewDataSource, 
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout 
{

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

        //let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height

        //let metricsCollection = ["heght" : navigationBarHeight]

        self.addSubview(self.collectionView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView) //, metrics: metricsCollection)

        /*if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        collectionView.backgroundColor = UIColor.white*/        
        
        collectionView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)        
        collectionView.isPagingEnabled = false
        collectionView.reloadData()

        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(self.backAction(sender:)))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
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

        NotificationCenter.default.addObserver(self, selector: #selector(closeVideo), name: NSNotification.Name(rawValue: Global.notificationKeyCloseVideo), object: nil)         

        self.gamvesUser = user    
    }

    func closeVideo()
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


class ProfileLauncher: UIView {    
    
    var profileView:ProfileView!    
    
    var view:UIView!

    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    //private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))

    var panGesture  = UIPanGestureRecognizer()

    func showProfileView(gamvesUser: GamvesUser){          
        
        if let keyWindow = UIApplication.shared.keyWindow {

            view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.gamvesColor
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            
             //16 x 9 is the aspect ratio of all HD videos
            //let profileHeight = keyWindow.frame.width * 9 / 16
            let profileFrame = CGRect(x: 0, y: -60, width: keyWindow.frame.width, height: keyWindow.frame.height + 60) 

            self.profileView = ProfileView(frame: profileFrame)                        
            self.profileView.setUser(user: gamvesUser)
            //self.profileView.isUserInteractionEnabled = true
           
            self.profileView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture)))      
            
            //self.profileView.addGestureRecognizer(self.panGesture)

            view.addSubview(self.profileView)   
              
            keyWindow.addSubview(self.view)

            view.tag = 1
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in
                    
                    //UIApplication.shared.setStatusBarHidden(true, with: .fade)
                    
            })

        }
    }
  

    func handlePanGesture(sender: UIPanGestureRecognizer) {

        let touchPoint = sender.location(in: self.profileView?.window)

        if sender.state == UIGestureRecognizerState.began {

            initialTouchPoint = touchPoint

        } else if sender.state == UIGestureRecognizerState.changed {

            if touchPoint.y - initialTouchPoint.y > 0 {

                self.profileView.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.profileView.frame.size.width, height: self.view.frame.size.height)

            }

        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            
            if touchPoint.y - initialTouchPoint.y > 100 {                

                for subview in (UIApplication.shared.keyWindow?.subviews)! {
                    if (subview.tag == 1) {
                        subview.removeFromSuperview()
                    }
                }

            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.profileView.frame = CGRect(x: 0, y: 0, width: self.profileView.frame.size.width, height: self.profileView.frame.size.height)
                })
            }
        }
    }    
}
