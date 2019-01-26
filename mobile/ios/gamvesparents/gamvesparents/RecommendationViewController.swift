//
//  EventViewController.swift
//  gamvesparents
//TabBarViewController
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
    let sectionHeaderId = "recommendationSectionHeaderId"
    
    let recommendationEmptyViewCellId = "recommendationEmptyViewCell"
    let recommendationVideoCellId = "recommendationVideoCellId"
    let recommendationViewCellId = "recommendationViewCellId"   

     let rowHeight = CGFloat(100)

     var recommendationLoaded = Bool()

     override func viewDidLoad() {
        super.viewDidLoad()                       

        self.view.addSubview(collectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        self.activityView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)//,x: 0, y: 0, width: 80.0, height: 80.0)
        
        self.collectionView.register(RecommendationSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: sectionHeaderId)

        self.collectionView.register(RecommendationEmptyViewCell.self, forCellWithReuseIdentifier: self.recommendationEmptyViewCellId)
        self.collectionView.register(RecommendationVideoCell.self, forCellWithReuseIdentifier: self.recommendationVideoCellId)
        self.collectionView.register(RecommendationViewCell.self, forCellWithReuseIdentifier: self.recommendationViewCellId)        

        self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor   

        self.loadRecommendations(completionRecommHandler: { ( resutl ) -> () in })

        NotificationCenter.default.addObserver(self, selector: #selector(self.loadRecommendationsFromObserver), name: NSNotification.Name(rawValue: Global.notificationKeyRecommendationLoaded), object: nil)

    }


    @objc func loadRecommendationsFromObserver() {        

        self.loadRecommendations(completionRecommHandler: { ( resutlRecomm ) -> () in

            if resutlRecomm {

            }
        })        
    }

    func loadRecommendations(completionRecommHandler : @escaping (_ resutl:Bool) -> ()) {

        self.registerLiveQuery()      

        if let userId = PFUser.current()?.objectId
        {
            self.puserId = userId
            
            print(userId)

            self.fetchRecommendations(completionHandler: { ( resutl ) -> () in    

                if resutl {

                    self.activityView.stopAnimating()

                    self.recommendationLoaded = true

                    self.collectionView.reloadData()

                    completionRecommHandler(true)
                }
            })
        }        

    }


    func registerLiveQuery()
    {
        queryRecommendation = PFQuery(className: "Recommendations")   

        //queryRecommendation.whereKey("userId", equalTo: userId)
        
        self.subscription = liveQueryClientFeed.subscribe(queryRecommendation).handle(Event.created) { _, recommendation in            
            
            self.fetch()
            
        }             

        self.subscription = liveQueryClientFeed.subscribe(queryRecommendation).handle(Event.updated) { _, recommendation in            
            
            
            self.fetch()
        } 
    }

    func fetch() {

        self.fetchRecommendations(completionHandler: { ( resutl ) -> () in    

            if resutl {

                self.activityView.stopAnimating()
            }
        })
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
            
            sectionHeaderView.nameLabel.text = "Child recommendations"
            
        } else if indexPath.section == 1 {
            
            var image  = UIImage(named: "time_earlier_white")?.withRenderingMode(.alwaysTemplate)
            //image = image?.maskWithColor(color: UIColor.white)
            //image = Global.resizeImage(image: image!, targetSize: CGSize(width:40, height:40))
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "Educational videos"
        }
        
        return sectionHeaderView
        
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {

        var countItems = Int()
        
        print(section)

        if recommendationLoaded {        
        
            if section == 0 {
                
                countItems = Global.recommendations.count
                
                if countItems == 0 {
                    countItems = 1
                }
                
            } else if section == 1 {

                countItems = Global.recommendationsVideo.count               
            }
        }
        
        print(countItems)

        return countItems

    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {               

        let index = indexPath.item
        var recommendation = GamvesRecommendation()
        
        print(indexPath.section)

        let cell = UICollectionViewCell()
        
        print(indexPath.section)
        
        if indexPath.section == 0 {

            if Global.recommendations.count == 0 {

                let cellEmpty = collectionView.dequeueReusableCell(withReuseIdentifier: self.recommendationEmptyViewCellId, for: indexPath) as! RecommendationEmptyViewCell                    

                cellEmpty.messageLabel.text = "Family and child has not been added yet, touch to add"

                return cellEmpty

            } else {

                recommendation = Global.recommendations[index]

                let cellRed = collectionView.dequeueReusableCell(withReuseIdentifier: self.recommendationViewCellId, for: indexPath) as! RecommendationViewCell

                return cellRed

                //HERE RECOMMENDATION
            }           
            
            
        } else if indexPath.section == 1 {

            let cellvideo = collectionView.dequeueReusableCell(withReuseIdentifier: self.recommendationVideoCellId, for: indexPath) as! RecommendationVideoCell
            
            recommendation = Global.recommendationsVideo[index]

            if recommendation.type == 2 {
                cellvideo.setThumbnailSize()
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

            cellvideo.descriptionTextView.text = message
            
            cellvideo.userProfileImageView.image = recommendation.avatar       

            if recommendation.type == 1 { //recommendation

                    

            } else if recommendation.type == 2 { //video

                cellvideo.thumbnailImageView.image = recommendation.cover
                cellvideo.iconImageView.image = UIImage(named: "video")?.withRenderingMode(.alwaysTemplate)
                cellvideo.iconView.backgroundColor = UIColor.blue     
            } 

            let b = Style("b").font(.boldSystemFont(ofSize: 18))       
            cellvideo.posterLabel.attributedText = recommendation.title.style(tags: b).attributedString
            
            cellvideo.descriptionTextView.text = recommendation.description
            
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

            cellvideo.timeLabel.text = recommendation.date.elapsedTime       

            //GRADIENT

            let gr = Gradients()        
            var gradient : CAGradientLayer = CAGradientLayer()
            gradient = gr.getPastelGradient()        
            gradient.frame = CGRect(x: 0, y: 0, width: cellvideo.frame.width, height: cellvideo.frame.height)
            cellvideo.layer.insertSublayer(gradient, at: 0)
        
            return cellvideo
        }

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        //var size = CGSize()
        //var height = CGFloat()

        /*let index = indexPath.item

        var recommendation:GamvesRecommendation!

        if indexPath.section == 0 {
                    
            if Global.recommendations.count == 0 {

                size = CGSize(width: self.view.frame.width, height: height + 16 + 100)

            } else {

                recommendation = Global.recommendations[index]
            }            
            
        } else if indexPath.section == 1 {
            
            recommendation = Global.recommendationsVideo[index]
        }        

        if recommendation.type == 1 || recommendation.type == 6 { //video || welcome

            height = (self.view.frame.width - 16 - 16) * 9 / 16
            
            size = CGSize(width: self.view.frame.width, height: height + 16 + 100)

        } else { //if recommendation.type == 2 { //fanpage

            height = self.rowHeight
            
            size = CGSize(width: self.view.frame.width, height: height)

        }*/

        var height = CGFloat()

        if indexPath.section == 0 {

            height = 80

        } else if indexPath.section == 1 {

            height = 120

        }
        
        return CGSize(width: self.view.frame.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()

        let index = indexPath.item
        var recommendation = GamvesRecommendation()
        
        print(indexPath.section)
        
        if indexPath.section == 0 {
            
            if Global.recommendations.count == 0 {
                
                self.tabBarViewController!.accountViewController.showImagePicker(type: ProfileImagesTypes.Son)

            } else {

                recommendation = Global.recommendations[index]    
            }            
            
        } else if indexPath.section == 1 {
            
            recommendation = Global.recommendationsVideo[index]

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
             
    }

    func fetchRecommendations(completionHandler : @escaping (_ resutl:Bool) -> ())
    {
    
        self.activityView.startAnimating()
        
        queryRecommendation.findObjectsInBackground(block: { (recommendationsPF, error) in
            
            if error == nil
            {
                
                let recosCount = recommendationsPF?.count
                print(recosCount)
                if recosCount! > 0
                {

                    var count = 0
                    
                    for recPF in recommendationsPF! {
                   
                        let recommendation = GamvesRecommendation()

                        recommendation.objectId = recPF.objectId as! String
                        recommendation.title = recPF["title"] as! String
                        
                        var referenceId = 0

                        if recPF["referenceId"] != nil {
                            referenceId = recPF["referenceId"] as! Int
                            recommendation.referenceId = referenceId
                        }

                        recommendation.description = recPF["description"] as! String
                        ////recommendation.posterName = recPF["posterName"] as! String
                        recommendation.date = recPF["date"] as! Date
                        
                        if Calendar.current.isDateInToday(recommendation.date) {
                            recommendation.isNew = true
                        }
                        
                        //recommendation.posterId = recPF["posterId"] as! String

                        let type =  recPF["type"] as? Int                         
 
                        if let objectId:String = recPF.objectId {
                            recommendation.objectId = objectId   
                        }               

                        recommendation.type = type!                    

                        let thumbnail = recPF["thumbnail"] as! PFFileObject

                        thumbnail.getDataInBackground(block: { (imageAvatar, error) in
                
                            if error == nil {

                                if let imageAvatarData = imageAvatar {

                                    recommendation.avatar = UIImage(data:imageAvatarData) 
                    
                                    //GET RELATIONS

                                    if type == 1 { //recommendation
            
            
                                    } else if type == 2 { //Video                                       

                                        
                                        //Relation query not working
                                        let videoRelation = recPF.relation(forKey: "video") as PFRelation                
                                        let videoMembers = videoRelation.query()                                        
                                        videoMembers.findObjectsInBackground(block: { (videosPF, error) in

                                            if error == nil
                                            {     

                                                let countVideos =  videosPF!.count

                                                print(countVideos)

                                                for videoPF in videosPF! {

                                                    Global.getGamvesVideoFromObject(videoPF: videoPF, completionHandler: { (videoGamves) in            
                                                        
                                                        
                                                        recommendation.video = videoGamves

                                                        Global.recommendationsVideo.append(recommendation)                                                      

                                                        if (count == (recosCount! - 1) )  {

                                                            completionHandler(true)

                                                        }

                                                        count = count + 1
                                                    })      
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
