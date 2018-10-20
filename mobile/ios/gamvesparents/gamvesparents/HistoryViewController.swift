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
//import Floaty
import PopupDialog
import NVActivityIndicatorView

protocol HistroyProtocol {
    func closedRefresh()
}

class HistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ApprovalProtocol {
    
    var activityIndicatorView:NVActivityIndicatorView?
    
    var homeViewController:HomeViewController? 
    
    var isGroup = Bool()
    
    var popUp:PopupDialog?

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No video history found"
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 4
        label.textAlignment = .center
        return label
    }()

    let historyCellId = "historyCellId"
    
    var familyId = String()
    
    var countHistory = Int()
    var countHistories = Int()
    
    var videoApprovalLauncher = VideoApprovalLauncher()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "History"
        
        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
    
        self.collectionView.register(HistoryCell.self, forCellWithReuseIdentifier: historyCellId)

        self.view.addSubview(self.messageLabel)
        
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.messageLabel)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.messageLabel)

        self.messageLabel.isHidden = true
        
        self.familyId = Global.gamvesFamily.objectId

        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gray) 

        self.activityIndicatorView?.startAnimating()
        
        self.getHistrory()
    }
    
    func getHistrory() {
        
        let historyQuery = PFQuery(className: "History")
        historyQuery.whereKey("userId", equalTo: Global.gamvesFamily.sonsUsers[0].userObj.objectId)
        
        historyQuery.findObjectsInBackground { (histories, error) in
            if error == nil {
                
                self.countHistories = (histories?.count)!

                if self.countHistories > 0 {
                
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
                                                
                                                let  videoGamves = Global.parseVideo(videoPF: video, chatId : videoId, videoImage: thumbImage! )
                                                
                                                historyGamves.videoGamves = videoGamves
                                                
                                                self.appendVideoToHistoryAndCount(history: historyGamves)
                                                
                                            }
                                        })
                                    }
                                }
                            })
                        }
                    }

                } else {

                    self.messageLabel.isHidden = false

                    self.activityIndicatorView?.stopAnimating()

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

                        self.activityIndicatorView?.stopAnimating()

                        self.collectionView.reloadData()
                    }
                }
            }
        }
        
        self.countHistory = self.countHistory + 1
    }
    
    func pauseVideo() {
        videoApprovalLauncher.pauseVideo()
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

        let time = history.videoGamves.videoObj?.createdAt as! Date

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let elapsedTimeInSeconds = Date().timeIntervalSince(time)
        
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "MM/dd/yy"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEE"
        }
        
        cell.timeLabel.text = dateFormatter.string(from: time)        
        
        let formatterLong = DateFormatter()
        
        formatterLong.dateFormat = "HH:mm:ss"

        let timeLong = formatterLong.string(from: time)

        cell.elapsedLabel.text = timeLong  

        cell.profileImageView.image = history.videoGamves.image

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.gamvesLightGrayColor
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let history:HistoryGamves = Global.histories[indexPath.item]
   
        if self.homeViewController != nil {

            var chatId = history.videoId

            var video = GamvesVideo()
                
            video = Global.chatVideos[chatId]!
            
            print(video.ytb_videoId)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)
            
            let videoLauncher = VideoLauncher()
            videoLauncher.showVideoPlayer(videoGamves: video)

            
            /*var video = VideoGamves()
            
            video = Global.chatVideos[history.referenceId]!
            
            videoApprovalLauncher = VideoApprovalLauncher()
            videoApprovalLauncher.delegate = self
            videoApprovalLauncher.showVideoPlayer(videoGamves: video, approved: 0)*/
        
        }
    }
}
