//
//  TutorialViewController.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-09-12.
//

import UIKit
import Parse
import GameKit
import Floaty
import PopupDialog
import NVActivityIndicatorView

protocol TutorialVideoProtocol {
    func closedRefresh()
}

class TutorialVideoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ApprovalProtocol {
    
    var videosGamves  = [GamvesVideo]() 

    var activityIndicatorView:NVActivityIndicatorView?
    
    var homeViewController:HomeViewController? 
    
    var isGroup = Bool()
    
    var popUp:PopupDialog?

     var labelEmptyMessage: UILabel = {
        let label = UILabel()
        label.text = "There are no tutorial yet loaded"        
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.gray
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()

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

    let tutorialCellId = "tutorialCellId"
    
    var familyId = String()
    
    var countTutorial = Int()
    var countHistories = Int()
    
    var videoApprovalLauncher = VideoApprovalLauncher()

    var countHistory = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Tutorials"

        let buttonIcon = UIImage(named: "arrow_back_white")        
        let leftBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButton(sender:)))
        leftBarButton.image = buttonIcon        
        self.navigationItem.leftBarButtonItem = leftBarButton         

        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)   

        self.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: self.tutorialCellId)        
        
        self.familyId = Global.gamvesFamily.objectId

        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gray) 

        self.activityIndicatorView?.startAnimating()       
        
        self.hideShowTabBar(hidden: true)

        if self.videosGamves.count > 0 {

            self.collectionView.reloadData()
            
        } else {

            self.getTutorialVideos( completionHandler: { ( resutl ) -> () in

                if resutl {

                    self.collectionView.reloadData()

                } else {

                    self.view.addSubview(self.labelEmptyMessage)
                    self.view.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: self.labelEmptyMessage)
                    self.view.addConstraintsWithFormat("V:|[v0]|", views: self.labelEmptyMessage)                     

                }

                self.activityIndicatorView?.stopAnimating()

            })
        }        
    }

    @objc func backButton(sender: UIBarButtonItem) {

        self.hideShowTabBar(hidden:false)

        self.navigationController?.popViewController(animated: true)
    }

    func hideShowTabBar(hidden: Bool)
    {
        self.tabBarController?.tabBar.isHidden = hidden
        
        if hidden
        {
            navigationController?.navigationBar.tintColor = UIColor.white
        } 
    }
    
    func getTutorialVideos(completionHandler : @escaping (_ resutl: Bool) -> ()) {

        let fanpageQuery = PFQuery(className: "Fanpages")        

        fanpageQuery.whereKey("categoryName", equalTo: "TUTORIALS")

        fanpageQuery.getFirstObjectInBackground { (fanpagePF, error) in

            if error == nil {

                var tutorialFanpage = fanpagePF

                let videosQuery = PFQuery(className: "Videos")

                videosQuery.whereKey("fanpageObjId", equalTo: tutorialFanpage?.objectId)

                videosQuery.findObjectsInBackground { (videosPF, error) in
                    
                    if error == nil {

                        var countVideos = videosPF?.count

                        if countVideos! > 0 {

                            var count = 0
                        
                            for videoPF in videosPF! {                                

                                let thumImage = videoPF["thumbnail"] as! PFFile
                                let videoId = videoPF["videoId"] as! Int
                                
                                thumImage.getDataInBackground(block: { (data, error) in
                                    
                                    if error == nil
                                    {
                                        let thumbImage = UIImage(data:data!)
                                        
                                        let gamvesVideo = Global.parseVideo(videoPF: videoPF, chatId : videoId, videoImage: thumbImage! )

                                        self.videosGamves.append(gamvesVideo)

                                        if count == (countVideos! - 1) {

                                            completionHandler(true)
                                        }

                                        count = count + 1
                                    }
                                })
                            }

                        } else {

                            completionHandler(false)
                        }
                    }
                }

            } else {

                completionHandler(false)
            }
        }       
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
        
        let count = self.videosGamves.count

        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: self.tutorialCellId, for: indexPath) as! VideoCollectionViewCell
            
        cellVideo.thumbnailImageView.image = self.videosGamves[indexPath.row].image
        
        let posterId = self.videosGamves[indexPath.row].posterId
        
        cellVideo.userProfileImageView.image = UIImage(named:"gamves_icons_white")
        
        cellVideo.videoName.text = videosGamves[indexPath.row].title
        
        let published = String(describing: videosGamves[indexPath.row].published)
        
        let shortDate = published.components(separatedBy: " at ")
        
        cellVideo.videoDatePublish.text = shortDate[0]       

        cellVideo.checkView.isHidden = true            

        //let recognizer = UITapGestureRecognizer(target: self, action:#selector(handleViewProfile(recognizer:)))
        
        cellVideo.rowView.tag = indexPath.row

        //cellVideo.rowView.addGestureRecognizer(recognizer)

        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
          let width = self.view.frame.width

        var height = ((width - 16 - 16) * 9 / 16) + 16 + 88

        height = height * CGFloat(self.videosGamves.count)
            
        let size = CGSize(width: width, height: height)

        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let video:GamvesVideo = self.videosGamves[indexPath.item]
   
        if self.homeViewController != nil {

            var chatId = video.videoId

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
