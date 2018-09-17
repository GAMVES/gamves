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
    func pauseVideo()
}

class ApprovalViewController: UIViewController, 
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout, 
ApprovalProtocol {  
    
    var homeViewController:HomeViewController?
    
    var isGroup = Bool()
    
    var popUp:PopupDialog?

    var videoApprovalLauncher = VideoApprovalLauncher()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    var labelEmptyMessage: UILabel = {
        let label = UILabel()
        label.text = "There are no approvals yet loaded for your to approve"        
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.gray
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
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

        if Global.approvals.count == 0 {

            self.view.addSubview(self.labelEmptyMessage)
            self.view.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: self.labelEmptyMessage)
            self.view.addConstraintsWithFormat("V:|[v0]|", views: self.labelEmptyMessage)
        }

    }
    

    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func closedRefresh() {
        
        Global.approvals = Dictionary<Int, Approvals>()
        
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
        
        let index:Int = indexPath.item
        
        let keysArray = Array(Global.approvals.keys)
        let keyIndex = keysArray[index]
        let approval:Approvals = Global.approvals[keyIndex]!
        
        //let approval:Approvals = Global.approvals[index]
        
        print(approval.title)
        
        cell.nameLabel.text = approval.title
        
        if approval.approved == 0 || approval.approved == 2 || approval.approved == -1 { // NOT
            
            if approval.approved == -1 {
                
                cell.statusLabel.text = "REJECTED"

                cell.setCheckLabel(color: UIColor.red, symbol: "-")
                
                //(color: UIColor.red, symbol: "-" )
                
            } else  {
                
               cell.statusLabel.text = "NOT APPROVED"

               cell.setCheckLabel(color: UIColor.gamvesYellowColor, symbol: "+" )
            }
            
            cell.checkLabel.isHidden = false
            
        } else if approval.approved == 1 { //APPROVED
        
            cell.statusLabel.text = "APPROVED"
            cell.checkLabel.isHidden = true

            cell.setCheckLabel(color: UIColor.gamvesGreenColor, symbol: "✓" )
        }
        
        if approval.type == 1 { //Video
         
            cell.typeLabel.text = "VIDEO"
            
        } else if approval.type == 2 { //Fanpage
            
            cell.typeLabel.text = "FANPAGE"
        }
        
        cell.profileImageView.image = approval.thumbnail!
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index:Int = indexPath.item
        
        let keysArray = Array(Global.approvals.keys)
        let keyIndex = keysArray[index]
        let approval:Approvals = Global.approvals[keyIndex]!
        
        //let approval:Approvals = Global.approvals[indexPath.item]
   
        if self.homeViewController != nil {
            
            if approval.type == 1 { //Video
                
                var video = GamvesVideo()
                
                video = Global.chatVideos[approval.referenceId]!
                
                self.videoApprovalLauncher = VideoApprovalLauncher()
                videoApprovalLauncher.delegate = self
                videoApprovalLauncher.showVideoPlayer(videoGamves: video, approved: approval.approved)
                
            } else if approval.type == 2 { //Fanpage
                
                var fanpage = GamvesFanpage()
                fanpage = approval.fanpage
                
                let fanpageApprovalLauncher = FanpageApprovalLauncher()
                fanpageApprovalLauncher.delegate = self
                fanpageApprovalLauncher.showFanpageList(fanpageGamves: fanpage)
                
            }
        }
    }


    func pauseVideo() {
        self.videoApprovalLauncher.pauseVideo()    
    }

}
