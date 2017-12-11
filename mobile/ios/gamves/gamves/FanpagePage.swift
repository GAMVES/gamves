//
//  FanpageTableViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/19/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

class FanpagePage: UIViewController,
    UICollectionViewDataSource, 
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout
{
    
    var activityVideoView: NVActivityIndicatorView!
    
    weak var delegate:CellDelegate?
    
    var fanpageGamves  = FanpageGamves()
    var videosGamves  = [VideoGamves]()
    var fanpageImages = [FanpageImageGamves]()
    
    var timer:Timer? = nil

    let coverContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red //UIColor(white: 0, alpha: 1)
        return view
    }()

    lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    lazy var arrowBackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "arrow_back_white")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)        
        return button
    }()

     let separatorButtonsView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.blue        
        return view
    }()

    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "favorite")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)        
        return button
    }()

    let separatorCenterView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.green        
        return view
    }()

    let categoryName: UILabel = {
        let label = UILabel()
        //label.text = "Setting"
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = UIColor.white
        return label
    }()

    let cellVideoCollectionId = "cellVideoCollectionId"
    let cellImageCollectionId = "cellImageCollectionId"
    
    let videosContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white //UIColor(white: 0, alpha: 1)
        return view
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
   

    func handleBackButton() 
    {
        print("hola") 
        if ( delegate != nil )
        {
            if self.timer != nil
            {
                self.timer?.invalidate()
            }
            
            delegate?.setCurrentPage(current: 0, direction: UIPageViewControllerNavigationDirection.reverse, data: nil)
        }  
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        print(self.fanpageImages.count)

        self.view.addSubview(self.coverContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.coverContainerView)
        
        self.coverContainerView.addSubview(self.imageCollectionView)
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.imageCollectionView)
        self.coverContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.imageCollectionView)
    
        self.coverContainerView.addSubview(self.arrowBackButton)
        self.coverContainerView.addSubview(self.separatorButtonsView)
        self.coverContainerView.addSubview(self.favoriteButton)

        //horizontal constraints
        self.coverContainerView.addConstraintsWithFormat("H:|-10-[v0(60)]-10-[v1]-10-[v2(60)]-10-|", views: arrowBackButton, separatorButtonsView, favoriteButton)
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.arrowBackButton)
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.separatorButtonsView)       
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.favoriteButton)       
    
        self.coverContainerView.addSubview(self.separatorCenterView)        
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.separatorCenterView)           
        self.coverContainerView.addConstraintsWithFormat("V:|-60-[v0(50)]|", views: self.separatorCenterView)                          

        //name = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: self.view.frame.height))        

        self.coverContainerView.addSubview(self.categoryName)        
        self.coverContainerView.addConstraintsWithFormat("H:|-100-[v0]|", views: self.categoryName)           
        self.coverContainerView.addConstraintsWithFormat("V:|-100-[v0(50)]|", views: self.categoryName)                          
    
        self.setupGradientLayer() 

        self.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: self.cellVideoCollectionId)
       
        self.view.addSubview(self.videosContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.videosContainerView)
        
        self.videosContainerView.addSubview(self.collectionView)
        self.videosContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.videosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
        
        let imagesHeight = self.view.frame.width * 4 / 16
        
        let imagesMetrics = ["imagesHeight":imagesHeight]
        
        self.view.addConstraintsWithFormat("V:|[v0(imagesHeight)][v1]|", views: self.coverContainerView, self.videosContainerView, metrics: imagesMetrics)
        
        self.imageCollectionView.register(ImagesCollectionViewCell.self, forCellWithReuseIdentifier: self.cellImageCollectionId)
        
        self.activityVideoView = Global.setActivityIndicator(container: self.videosContainerView, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
        
         self.activityVideoView.startAnimating()
    
    }
    
    func setFanpageGamvesData(data: FanpageGamves)
    {
        self.fanpageGamves = data as FanpageGamves
        
        let fanpageId = data.fanpageObj?["fanpageId"] as! String
        
        if Downloader.fanpageImagesDictionary[fanpageId] != nil
        {
            self.fanpageImages =  Downloader.fanpageImagesDictionary[fanpageId] as! [FanpageImageGamves]
            
            self.fanpageImages.shuffled
            
            print(self.fanpageImages.count)
            
            self.imageCollectionView.reloadData()
            
            self.startTimer()
            
        }
    }
    
    
    /**
     Scroll to Next Cell
     */
    func scrollToNextCell()
    {
        //get cell size
        let cellSize = CGSize(width:self.coverContainerView.frame.width, height:self.coverContainerView.frame.height)
        
        //get current content Offset of the Collection view
        let contentOffset = self.imageCollectionView.contentOffset;
        
        //scroll to next cell
        self.imageCollectionView.scrollRectToVisible(CGRect(x:contentOffset.x + cellSize.width, y:contentOffset.y, width:cellSize.width, height:cellSize.height), animated: true);
        
    }
    
    func startTimer()
    {
        let kAutoScrollDuration: CGFloat = 4.0
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(kAutoScrollDuration), target: self, selector: #selector(self.autoScrollImageSlider), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
    }
    
    func autoScrollImageSlider() {
        
        DispatchQueue.global(qos: .background).async {
            
            DispatchQueue.main.async {
                
                let lastIndex = (self.fanpageImages.count) - 1
                
                let currentIndex = self.imageCollectionView.indexPathsForVisibleItems
                let nextIndex = currentIndex[0].row + 1
                
                if nextIndex > lastIndex {
                    
                    self.btnLeftArrowAction()
                    
                } else {
                    
                    self.btnRightArrowAction()
                    
                }
            }
        }
    }
    
    func btnLeftArrowAction() {
        let collectionBounds = self.imageCollectionView.bounds
        let contentOffset = CGFloat(floor(self.imageCollectionView.contentOffset.x - collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
    }
    
    func btnRightArrowAction() {
        let collectionBounds = self.imageCollectionView.bounds
        let contentOffset = CGFloat(floor(self.imageCollectionView.contentOffset.x + collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
    }
    
    func moveCollectionToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x : contentOffset ,y : self.imageCollectionView.contentOffset.y ,width : self.imageCollectionView.frame.width,height : self.imageCollectionView.frame.height)
        self.imageCollectionView.scrollRectToVisible(frame, animated: true)
    }
    
    fileprivate func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.coverContainerView.frame
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        self.coverContainerView.layer.addSublayer(gradientLayer)
    }

    func setFanpageData()
    {
        self.videosGamves.removeAll()
        self.getFanpageVideos(fan: fanpageGamves)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func getFanpageVideos(fan:FanpageGamves)
    {
        
        let countVideosLoaded = 0
        
        let videoRel:PFRelation = fan.fanpageObj!.relation(forKey: "videos")
        let queryvideos:PFQuery = videoRel.query()
        
        if !Global.hasDateChanged()
        {
            queryvideos.cachePolicy = .cacheThenNetwork
        }
        queryvideos.findObjectsInBackground(block: { (videoObjects, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                let countVideosLoaded = Int()
                
                var countVideos = videoObjects?.count
                var count = 0
                
                print(countVideos)
                
                if countVideos! > 0
                {
                    if let videoArray = videoObjects
                    {
                        for qvideoinfo in videoArray
                        {
                            
                            let video = VideoGamves()
                            
                            let videothumburl:String = qvideoinfo["thumbnailUrl"] as! String
                            let videoDescription:String = qvideoinfo["description"] as! String
                            let videoCategory:String = qvideoinfo["category"] as! String
                            let videoUrl:String = qvideoinfo["source"] as! String
                            let videoTitle:String = qvideoinfo["title"] as! String
                            let videoFromName:String = qvideoinfo["fromName"] as! String
                            
                            video.video_title = videoTitle
                            video.thumb_url = videothumburl
                            video.description = videoDescription
                            video.video_category = videoCategory
                            video.video_url = videoUrl
                            video.video_fromName = videoFromName
                            video.videoobj = qvideoinfo
                            
                            self.getImageVideo(videothumburl: videothumburl, video: video, completionHandler:{(video:VideoGamves) -> Void in
                                
                                fan.videos.append(video)
                                
                                print("***********")
                                print("countVideos: \(countVideos!)")
                                print("countVideosLoaded: \(countVideosLoaded)")

                                if ( (countVideos!-1) == count)
                                {
                                    self.videosGamves = fan.videos
                                    self.activityVideoView.stopAnimating()
                                    self.collectionView.reloadData()
                                }
                                count = count + 1                             
                            })
                        }
                    }
                }
            }
        })
    }

    func getImageVideo(videothumburl: String, video:VideoGamves, completionHandler : (_ video:VideoGamves) -> Void)
    {
        
        if let vurl = URL(string: videothumburl)
        {
            
            if let data = try? Data(contentsOf: vurl)
            {
                video.thum_image = UIImage(data: data)!
                
                completionHandler(video)
            }
        }
    }


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if collectionView == self.imageCollectionView
        {
            count = self.fanpageImages.count
            
        } else if collectionView == self.collectionView
        {
            count = self.videosGamves.count
        }
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = BaseCell()
        
        if collectionView == self.imageCollectionView
        {
            let cellImage = collectionView.dequeueReusableCell(withReuseIdentifier: cellImageCollectionId, for: indexPath) as! ImagesCollectionViewCell
            
            cellImage.imageView.image = self.fanpageImages[indexPath.row].cover_image
            
            return cellImage
            
        } else if collectionView == self.collectionView
        {
            let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: cellVideoCollectionId, for: indexPath) as! VideoCollectionViewCell
            
            cellVideo.thumbnailImageView.image = videosGamves[indexPath.row].thum_image
            
            cellVideo.descriptionTextView.text = videosGamves[indexPath.row].description
            
            return cellVideo
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height = CGFloat()
        
        if collectionView == self.imageCollectionView
        {
            height = self.coverContainerView.frame.height
            
        } else if collectionView == self.collectionView
        {
            height = (view.frame.width - 16 - 16) * 9 / 16
        }
        
        return CGSize(width: view.frame.width, height: height + 16 + 88)
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
    
        if collectionView == self.imageCollectionView
        {
            
        } else if collectionView == self.collectionView
        {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)

            let videoLauncher = VideoLauncher()
            
            let video = videosGamves[indexPath.row]
            //video.fanpageId = fanpageGamves.fanpageId
            
            videoLauncher.showVideoPlayer(videoGamves: video)
            
        }
        
    }


}
