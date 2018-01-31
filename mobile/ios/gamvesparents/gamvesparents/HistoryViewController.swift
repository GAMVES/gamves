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

protocol HistroyProtocol {
    func closedRefresh()
}

class HistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ApprovalProtocol {
    
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
    
    let historyCellId = "historyCellId"
    
    var familyId = String()
    
    var countHistory = Int()
    var countHistories = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "History"
        
        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
    
        self.collectionView.register(HistoryCell.self, forCellWithReuseIdentifier: historyCellId)
        
        self.familyId = Global.gamvesFamily.objectId
        
        self.getHistrory()
    }
    
    func getHistrory() {
        
        let historyQuery = PFQuery(className: "History")
        historyQuery.whereKey("userId", equalTo: Global.gamvesFamily.sonsUsers[0].userObj.objectId)
        
        historyQuery.findObjectsInBackground { (histories, error) in
            if error == nil {
                
                self.countHistories = (histories?.count)!
                
                for history in histories! {
                    
                    var historyGamves = HistoryGamves()
                    
                    let videoId = history["videoId"] as! Int
                    
                    historyGamves.videoId = videoId
                    
                    if Global.chatVideos[videoId] != nil {
                        
                        historyGamves.videoGamves = Global.chatVideos[videoId]!
                        
                        self.appendVideoToHistoryAndCount(history: historyGamves)
                        
                    } else {
                        
                        let videoQuery = PFQuery(className: "Videos")
                        videoQuery.whereKey("videoId", equalTo: videoId)
                        
                        videoQuery.findObjectsInBackground(block: { (videoObjs, error) in
                            
                            if error == nil {
                                
                                for video in videoObjs! {
                                    
                                    let thumbnail = video["thumbnail"] as! PFFile
                                    
                                    thumbnail.getDataInBackground(block: { (data, error) in
                                        
                                        if error == nil {
                                            
                                            let thumbImage = UIImage(data:data!)
                                            
                                            let  videoGamves = Global.parseVideo(video: video, chatId : videoId, videoImage: thumbImage! )
                                            
                                            historyGamves.videoGamves = videoGamves
                                            
                                            self.appendVideoToHistoryAndCount(history: historyGamves)
                                            
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func appendVideoToHistoryAndCount(history: HistoryGamves){
        
        history.videoGamves.thumbnail.getDataInBackground { (data, error) in
            
            if error == nil {
                
                let image = UIImage(data: data!)
                
                history.videoGamves.image = image!
            
                Global.histories.append(history)
                
                if ( self.countHistories - 1 ) == self.countHistory {
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        
        self.countHistory = self.countHistory + 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func closedRefresh() {
        
        //Global.approvals = [Approvals]()
        
        Global.getApprovasByFamilyId(familyId: self.familyId) { ( count ) in
            
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let countItems = Global.histories.count
        print(countItems)
        return countItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: historyCellId, for: indexPath) as! HistoryCell
        
        let index = indexPath.item
        let history:HistoryGamves = Global.histories[index]
    
        cell.nameLabel.text = history.videoGamves.title

        cell.profileImageView.image = history.videoGamves.image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let history:HistoryGamves = Global.histories[indexPath.item]
   
        if self.homeViewController != nil {
            
            var video = VideoGamves()
            
            video = Global.chatVideos[history.referenceId]!
            
            let videoApprovalLauncher = VideoApprovalLauncher()
            videoApprovalLauncher.delegate = self
            videoApprovalLauncher.showVideoPlayer(videoGamves: video)
        
        
        }
    }
    
   
}
