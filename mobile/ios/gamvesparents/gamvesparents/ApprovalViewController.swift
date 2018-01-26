//
//  AddChatViewController.swift
//  gamves
//
//  Created by Jose Vigil on 10/13/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import GameKit
import Floaty
import PopupDialog

protocol ApprovalProtocol {
    func closedRefresh()
}

class ApprovalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ApprovalProtocol {
    
    var homeViewController:HomeViewController?
    
    var isGroup = Bool()
    
    var popUp:PopupDialog?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let approvlCellId = "approvlCellId"
    
    var familyId = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Approvals"
        
        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
    
        self.collectionView.register(ApprovalCell.self, forCellWithReuseIdentifier: approvlCellId)
        
        self.collectionView.reloadData()
        
        self.familyId = Global.gamvesFamily.objectId
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func closedRefresh() {
        
        Global.approvals = [Approvals]()
        
        Global.getApprovasByFamilyId(familyId: self.familyId) { ( count ) in
            
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let countItems = Global.approvals.count
        print(countItems)
        return countItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: approvlCellId, for: indexPath) as! ApprovalCell
        
        let index = indexPath.item
        let approval:Approvals = Global.approvals[index]
        
        print(approval.title)
        
        cell.nameLabel.text = approval.title
        
        if approval.approved == 0 || approval.approved == 2 { // NOT
            
            cell.statusLabel.text = "NOT APPROVED"
            cell.checkLabel.isHidden = false
            
        } else if approval.approved == 1 { //APPROVED
        
            cell.statusLabel.text = "APPROVED"
            cell.checkLabel.isHidden = true
        }
        
        if approval.type == 1 { //Video
            
        } else if approval.type == 2 { //Fanpage
            
        }
        
        cell.profileImageView.image = approval.thumbnail!
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let approval:Approvals = Global.approvals[indexPath.item]
   
        if self.homeViewController != nil {
            
            if approval.type == 1 { //Video
                
                var video = VideoGamves()
                
                video = Global.chatVideos[approval.referenceId]!
                
                let videoApprovalLauncher = VideoApprovalLauncher()
                videoApprovalLauncher.delegate = self
                videoApprovalLauncher.showVideoPlayer(videoGamves: video)
                
            } else if approval.type == 2 { //Fanpage
                
                
                
            }
            
            
        }
    }
    
   
}
