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

protocol ActivityProtocol {
    func closedRefresh()
}

class ActivityViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ApprovalProtocol {
    
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

        self.navigationItem.title = "Activity"
        
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
    
    func queryActivity() {
        
        let queryChatFeed = PFQuery(className: "ChatFeed")
        
        let userId = Global.gamvesFamily.sonsUsers[0].userId
        queryChatFeed.whereKey("members", contains: userId)
        
        queryChatFeed.findObjectsInBackground(block: { (chatfeeds, error) in
            
            let chatFeddsCount = chatfeeds?.count
            
            if chatFeddsCount! > 0 {
                
                ChatFeedMethods.parseChatFeed(chatFeedObjs: chatfeeds!, completionHandler: { ( chatId:Int ) -> () in
                    
                    self.collectionView.reloadData()
                    
                })
            }
        })
    }
    
    func closedRefresh() {
        
        Global.approvals = [Approvals]()
        
        Global.getApprovasByFamilyId(familyId: self.familyId) { ( count ) in
            
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let countItems = ChatFeedMethods.chatFeeds.count
        return countItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: approvlCellId, for: indexPath) as! ActivityCell
        
        let index = indexPath.item
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[index]!
        
        cell.nameLabel.text = chatfeed.room
        
        cell.profileImageView.image = chatfeed.chatThumbnail!
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let chatfeed:ChatFeed = ChatFeedMethods.chatFeeds[indexPath.item]!
   
        if self.homeViewController != nil {
        
            var video = VideoGamves()
            
            video = Global.chatVideos[chatfeed.chatId!]!
            
            let videoApprovalLauncher = VideoApprovalLauncher()
            videoApprovalLauncher.delegate = self
            videoApprovalLauncher.showVideoPlayer(videoGamves: video)
            
        }
    }
    
}
