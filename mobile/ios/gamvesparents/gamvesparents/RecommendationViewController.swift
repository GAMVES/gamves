//
//  EventViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 25/12/2018.
//  Copyright © 2018 Gamves Parents. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import Floaty
import ParseLiveQuery
import Atributika

class RecommendationViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    
    var activityView: NVActivityIndicatorView!

     let liveQueryClientFeed: Client = ParseLiveQuery.Client(server: Global.localWs) // .localWs)
  
    private var subscription: Subscription<PFObject>!
    
    var queryRecommendation:PFQuery<PFObject>!
    
    var tabBarViewController:TabBarViewController?    

    var puserId = String()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    let cellId = "cellId"
    let sectionHeaderId = "recommendationSectionHeader"

     let rowHeight = CGFloat(130)

     var recommendationLoaded = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()   

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
        }             

        self.view.addSubview(collectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        self.activityView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)//,x: 0, y: 0, width: 80.0, height: 80.0)
        
        self.collectionView.register(RecommendationViewCell.self, forCellWithReuseIdentifier: cellId)

        self.collectionView.register(RecommendationSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: sectionHeaderId)

        self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor   

        self.registerLiveQuery()
        self.fetchRecommendations()    

    }

    func registerLiveQuery()
    {
        queryRecommendation = PFQuery(className: "Recommendations")
        
        //if let userId = PFUser.current()?.objectId {
        
            //let filterTarget = [
            //    Global.schoolShort,
            //    Global.levelDescription.lowercased(),
            //    userId] as [String]

            //queryRecommendation.whereKey("target", containedIn: filterTarget)
        //}
        
        self.subscription = liveQueryClientFeed.subscribe(queryRecommendation).handle(Event.created) { _, notification in            
            
            self.fetchRecommendations()
            
        }        
        
        //self.collectionView.reloadData()
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        var count = 0
        
        if recommendationLoaded {            
        
            count = 2
        }
        
        return count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! RecommendationSectionHeader
        
        sectionHeaderView.backgroundColor = UIColor.black
        
        if indexPath.section == 0 {
            
            var image  = UIImage(named: "add_notification_white")?.withRenderingMode(.alwaysTemplate)
            //image = image?.maskWithColor(color: UIColor.white)
            //image = Global.resizeImage(image: image!, targetSize: CGSize(width:40, height:40))
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "New"
            
        } else if indexPath.section == 1 {
            
            var image  = UIImage(named: "time_earlier_white")?.withRenderingMode(.alwaysTemplate)
            //image = image?.maskWithColor(color: UIColor.white)
            //image = Global.resizeImage(image: image!, targetSize: CGSize(width:40, height:40))
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "Earlier"
        }
        
        return sectionHeaderView
        
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {

        var countItems = Int()

        if recommendationLoaded {        
        
            if section == 0 {
                
                countItems = Global.recommendations.count
                
            } else if section == 1 {

                countItems = Global.recommendationsVideo.count               
            }
        }
        
        print(countItems)

        return countItems

    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RecommendationViewCell

        let index = indexPath.item
        var recommendation = GamvesRecommendation()
        
        print(indexPath.section)
        
        if indexPath.section == 0 {
            
            recommendation = Global.recommendations[index]
            
        } else if indexPath.section == 1 {
            
            recommendation = Global.recommendationsVideo[index]
            
        }

        if recommendation.type == 2 {
            cell.setThumbnailSize()
        }

        var message:String = recommendation.description

        let delimitator = Global.admin_delimitator

        if message.range(of:delimitator) != nil
        {            
            if let range = message.range(of: delimitator) 
            {
                message.removeSubrange(range)
            }
        } 

        cell.descriptionTextView.text = message
        
        cell.userProfileImageView.image = recommendation.avatar       

        if recommendation.type == 1 { //recommendation

                

        } else if recommendation.type == 2 { //video

            cell.thumbnailImageView.image = recommendation.cover
            cell.iconImageView.image = UIImage(named: "video")?.withRenderingMode(.alwaysTemplate)
            cell.iconView.backgroundColor = UIColor.blue     
        } 

        let b = Style("b").font(.boldSystemFont(ofSize: 18))       
        cell.posterLabel.attributedText = recommendation.title.style(tags: b).attributedString
        
        cell.descriptionTextView.text = recommendation.description
        
        var image = String()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let elapsedTimeInSeconds = Date().timeIntervalSince(recommendation.date)
        
        let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
            dateFormatter.dateFormat = "MM/dd/yy"
        } else if elapsedTimeInSeconds > secondInDays {
            dateFormatter.dateFormat = "EEE"
        }

        cell.timeLabel.text = recommendation.date.elapsedTime       

        //GRADIENT

        let gr = Gradients()        
        var gradient : CAGradientLayer = CAGradientLayer()
        gradient = gr.getPastelGradient()        
        gradient.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        cell.layer.insertSublayer(gradient, at: 0)
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var size = CGSize()
        var height = CGFloat()

        let index = indexPath.item

        var recommendation:GamvesRecommendation!

        if indexPath.section == 0 {
                
            recommendation = Global.recommendations[index]
            
        } else if indexPath.section == 1 {
            
            recommendation = Global.recommendationsVideo[index]
        }        

        if recommendation.type == 1 || recommendation.type == 6 { //video || welcome

            height = (self.view.frame.width - 16 - 16) * 9 / 16
            
            size = CGSize(width: self.view.frame.width, height: height + 16 + 100)

        } else { //if recommendation.type == 2 { //fanpage

            height = self.rowHeight
            
            size = CGSize(width: self.view.frame.width, height: height)

        }
        
        return size //CGSize(width: self.frame.width, height: rowHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()

        let index = indexPath.item
        var recommendation = GamvesRecommendation()
        
        print(indexPath.section)
        
        if indexPath.section == 0 {
            
            recommendation = Global.recommendations[index]
            
        } else if indexPath.section == 1 {
            
            recommendation = Global.recommendationsVideo[index]
            
        }
        
        //Everything here is wrong
        
        print(recommendation.posterId)

        if recommendation.posterId != PFUser.current()?.objectId {

            if recommendation.type == 0 { //recommendation

                          

            } else if recommendation.type == 2 { //fanpage

                //let fanpage = recommendation.fanpage

                //self.homeController?.switchToMenuIndex(index: 0)        
        
                let videoPF:PFObject = recommendation.video.videoObj as! PFObject
                
                print(videoPF.objectId)
                print(videoPF["title"] as! String)

                NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)

                Global.getGamvesVideoFromObject(videoPF: videoPF, completionHandler: { (videoGamves) in          
                    
                    let videoId = videoPF["videoId"] as! Int

                    print(videoId)

                    let videoLauncher = VideoLauncher()
                    videoLauncher.showVideoPlayer(videoGamves: videoGamves)

                })


            } 

            /*else if recommendation.type == 3 { //friend

                self.homeController!.showFriendApproval()

            } else if recommendation.type == 4 { //birthday  

                let posterId = recommendation.posterId

                let gamvesUserPoster = Global.userDictionary[posterId] as! GamvesUser

                let profileLauncher = PublicProfileLauncher()
                profileLauncher.showProfileView(gamvesUser: gamvesUserPoster) 

            } else if recommendation.type == 5 { //recommendation

                

            } else if recommendation.type == 6 { //welcome

                if self.homeController != nil
                {
                    self.homeController?.showWelcomeViewcontroller()
                }
            
            }*/

        }        
    }

    func fetchRecommendations()
    {
    
        self.activityView.startAnimating()
        
        queryRecommendation.findObjectsInBackground(block: { (recommendationsPF, error) in
            
            if error == nil
            {
                
                let recosCount = recommendationsPF?.count
                if recosCount! > 0
                {

                    var count = 0
                    
                    for recommendationPF in recommendationsPF! {
                   
                        let recommendation = GamvesRecommendation()

                        recommendation.objectId = recommendationPF.objectId as! String
                        recommendation.title = recommendationPF["title"] as! String
                        
                        if recommendationPF["referenceId"] != nil {
                            recommendation.referenceId = recommendationPF["referenceId"] as! Int
                        }

                        recommendation.description = recommendationPF["description"] as! String
                        ////recommendation.posterName = recommendationPF["posterName"] as! String
                        recommendation.date = recommendationPF["date"] as! Date
                        
                        if Calendar.current.isDateInToday(recommendation.date) {
                            recommendation.isNew = true
                        }
                        
                        recommendation.posterId = recommendationPF["posterId"] as! String

                        let type =  recommendationPF["type"] as? Int 

                        if type == 1 { //recommendation

                            
                            
                        } else if type == 2 { //Video

                            let videoGamves = GamvesVideo()
                            let videoObj:PFObject = recommendationPF["video"] as! PFObject

                            do {
                                try videoObj.fetchIfNeeded()
                            } catch _ {
                               print("There was an error fetching video poiner")         
                            }

                            videoGamves.videoObj = videoObj
                            recommendation.video = videoGamves
                            print(videoObj["title"] as! String)
                        
                        } 
 
                        if let objectId:String = recommendationPF.objectId {
                            recommendation.objectId = objectId   
                        }               

                        recommendation.type = type!
                        
                        var cover:AnyObject!                        

                        if recommendationPF["cover"] != nil {
                            cover = recommendationPF["cover"] as! PFFileObject
                        }                        

                        let avatar = recommendationPF["posterAvatar"] as! PFFileObject

                        avatar.getDataInBackground(block: { (imageAvatar, error) in
                
                            if error == nil {

                                if let imageAvatarData = imageAvatar {

                                    recommendation.avatar = UIImage(data:imageAvatarData)  

                                    if cover != nil {

                                        cover!.getDataInBackground(block: { (imageCover, error) in
                    
                                            if error == nil {

                                                if let imageCoverData = imageCover {

                                                    recommendation.cover = UIImage(data:imageCoverData)                                                    

                                                    count = count + 1
                                                }
                                            }
                                        })

                                    } 

                                }
                            }
                        })
                    }
                    
                } else
                {
                    self.activityView.stopAnimating()
                }
                
            }
        })
    
    }    
    
    func uploadData()
    {
        self.reloadCollectionView()
    }
    
    func reloadCollectionView()
    {
        ChatFeedMethods.sortAllFeeds()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.collectionView.reloadData()
        }
    }

     


}
