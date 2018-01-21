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
import KenBurns
import AACarousel

class FanpagePage: UIViewController,
    UICollectionViewDataSource, 
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout,
    AACarouselDelegate
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

    var coverImageView: KenBurnsImageView = {
        let imageView = KenBurnsImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()    

    lazy var arrowBackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "arrow_back_white")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        //button.backgroundColor = UIColor.green
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
        //button.backgroundColor = UIColor.cyan
        return button
    }()

    let separatorCenterView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.green        
        return view
    }()
    
    var iconImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill //.scaleFill
        image.clipsToBounds = true
        image.backgroundColor = UIColor.gamvesColor
        image.layer.cornerRadius = 30
        image.borderWidth = 3
        image.borderColor = UIColor.black
        return image
    }()

    var fanpageName: UILabel = {
        let label = UILabel()
        //label.text = "Setting"
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 20)
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
    
    let bottomLineContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black //UIColor(white: 0, alpha: 1)
        return view
    }()

    lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()   

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    var carouselView: AACarousel = {
        let iconView = AACarousel()
        return iconView
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.isHidden = true
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        print(self.fanpageImages.count)

        self.view.addSubview(self.coverContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.coverContainerView)
        
        self.coverContainerView.addSubview(self.coverImageView)
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.coverImageView)
        self.coverContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.coverImageView)
    
        self.coverContainerView.addSubview(self.arrowBackButton)
        self.coverContainerView.addSubview(self.iconImageView)
        self.coverContainerView.addSubview(self.separatorButtonsView)
        self.coverContainerView.addSubview(self.favoriteButton)
        
        //horizontal constraints
        self.coverContainerView.addConstraintsWithFormat("H:|[v0(60)][v1(60)]-10-[v2][v3(60)]|", views: arrowBackButton, iconImageView, separatorButtonsView, favoriteButton)
        
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.arrowBackButton)
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.iconImageView)
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.separatorButtonsView)       
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.favoriteButton)       
    
        self.coverContainerView.addSubview(self.separatorCenterView)        
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.separatorCenterView)           
        self.coverContainerView.addConstraintsWithFormat("V:|-60-[v0(50)]|", views: self.separatorCenterView)                                  

        self.separatorButtonsView.addSubview(self.fanpageName)
        self.separatorButtonsView.addConstraintsWithFormat("H:|[v0]|", views: self.fanpageName)
        self.separatorButtonsView.addConstraintsWithFormat("V:|[v0]|", views: self.fanpageName)

        self.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: self.cellVideoCollectionId)
       
        self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor
        
        self.view.addSubview(self.videosContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.videosContainerView)
        
        self.videosContainerView.addSubview(self.collectionView)
        self.videosContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.videosContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)       
        
        self.view.addSubview(self.imageCollectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.imageCollectionView)
        
        self.imageCollectionView.backgroundColor = UIColor.gamvesBlackColor

        self.view.addConstraintsWithFormat("V:|[v0(80)][v1(80)][v2]|", views: 
            self.coverContainerView,
            self.imageCollectionView, 
            self.videosContainerView)
        
        self.coverContainerView.addSubview(self.bottomLineContainerView)
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomLineContainerView)
        self.coverContainerView.addConstraintsWithFormat("V:|-77-[v0(3)]|", views: self.bottomLineContainerView)
        
        self.imageCollectionView.register(ImagesCollectionViewCell.self, forCellWithReuseIdentifier: self.cellImageCollectionId)
        
        self.activityVideoView = Global.setActivityIndicator(container: self.videosContainerView, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
        
        let widthImages = view.frame.width
        let heightImages = (view.frame.width - 16 - 16) * 9 / 16
        
        let padding = (view.frame.height - heightImages) / 2
        
        let metricsImages = [
            "widthImages":widthImages,
            "heightImages":heightImages,
            "padding" : padding
        ]
        
        self.view.addSubview(self.carouselView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.carouselView)
        self.view.addConstraintsWithFormat("V:|-padding-[v0(heightImages)]-padding-|", views: self.carouselView, metrics: metricsImages)
        self.carouselView.isHidden = true
        
        self.activityVideoView.startAnimating()        
        
    }
    
    func newKenBurnsImageView(image: UIImage) {
        self.coverImageView.setImage(image)
        self.coverImageView.zoomIntensity = 1.5
        self.coverImageView.setDuration(min: 5, max: 13)
        self.coverImageView.startAnimating()
    }

    fileprivate func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.coverContainerView.frame
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.gamvesBlackColor.cgColor]
        gradientLayer.locations = [0.2, 1.2]
        self.coverContainerView.tag = 1
        self.coverContainerView.layer.addSublayer(gradientLayer)
        self.coverContainerView.bringSubview(toFront: self.separatorButtonsView)
        self.coverContainerView.bringSubview(toFront: self.arrowBackButton)
        self.coverContainerView.bringSubview(toFront: self.favoriteButton)    
        self.coverContainerView.bringSubview(toFront: self.favoriteButton)
    }
    
    func setFanpageGamvesData(data: FanpageGamves)
    {
        self.fanpageGamves = data as FanpageGamves
        
        print(data.categoryName)

        self.fanpageName.text = self.fanpageGamves.name
        
        let fanpageId = data.fanpageObj?["fanpageId"] as! Int
        
        let name = data.fanpageObj?["pageName"] as! String
        
        self.newKenBurnsImageView(image: self.fanpageGamves.cover_image)
        
        self.iconImageView.image = self.fanpageGamves.icon_image
        
        if Downloader.fanpageImagesDictionary[fanpageId] != nil
        {
            self.fanpageImages =  Downloader.fanpageImagesDictionary[fanpageId] as! [FanpageImageGamves]
            
            self.fanpageImages.shuffled
            
            print(self.fanpageImages.count)
            
            var titleImageArray = [String]()
            var sourceArray = [String]()
            
            for gamvesImage in self.fanpageImages {
                
                titleImageArray.append(gamvesImage.name)
                sourceArray.append(gamvesImage.source)
            }
            
            self.carouselView.delegate = self
            
            self.carouselView.setCarouselData(paths: sourceArray,  describedTitle: titleImageArray, isAutoScroll: true, timer: 5.0, defaultImage: "defaultImage")
            
            //optional methods
            self.carouselView.setCarouselOpaque(layer: false, describedTitle: false, pageIndicator: false)
            
            self.carouselView.setCarouselLayout(displayStyle: 0, pageIndicatorPositon: 5, pageIndicatorColor: nil, describedTitleColor: nil, layerColor: nil)
            
            self.imageCollectionView.reloadData()

            self.startTimer()
        }
        
        if self.coverContainerView.tag != 1 {
            self.setupGradientLayer()
        }
        
        self.view.isHidden = false
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
        
        /*DispatchQueue.global(qos: .background).async {
            
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
        }*/
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
    
    
    var loaded = Bool()

    func setFanpageData()
    {
        self.videosGamves.removeAll()
        if !self.loaded {
            self.getFanpageVideos(fan: fanpageGamves)
            self.loaded = true
        }
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
                            
                            var videothum = qvideoinfo["thumbnail"] as! PFFile
                            
                            video.title                     = qvideoinfo["title"] as! String
                            video.description               = qvideoinfo["description"] as! String
                            video.thumbnail                 = videothum
                            video.categoryName              = qvideoinfo["categoryName"] as! String
                            video.videoId                   = qvideoinfo["videoId"] as! Int
                            video.s3_source                 = qvideoinfo["s3_source"] as! String
                            video.ytb_thumbnail_source      = qvideoinfo["ytb_thumbnail_source"] as! String
                            video.ytb_videoId               = qvideoinfo["ytb_videoId"] as! String
                            
                            let dateStr = qvideoinfo["ytb_upload_date"] as! String
                            let dateDouble = Double(dateStr)
                            let date = NSDate(timeIntervalSince1970: dateDouble!)
                            
                            video.ytb_upload_date           = date as Date
                            video.ytb_view_count            = qvideoinfo["ytb_view_count"] as! Int
                            video.ytb_tags                  = qvideoinfo["ytb_tags"] as! [String]
                            
                            let durStr = qvideoinfo["ytb_upload_date"] as! String
                            let durDouble = Double(durStr)
                            video.ytb_duration              = durDouble!
                            
                            video.ytb_categories            = qvideoinfo["ytb_categories"] as! [String]
                            //video.ytb_like_count            = qvideoinfo["ytb_like_count"] as! Int
                            video.order                     = qvideoinfo["order"] as! Int
                            video.fanpageId                 = qvideoinfo["fanpageId"] as! Int
                            
                            video.posterId                  = qvideoinfo["posterId"] as! String
                            
                            print(video.posterId)
                            
                            if Global.userDictionary[video.posterId] == nil && video.posterId != Global.gamves_official {
                            
                                let userQuery = PFQuery(className:"_User")
                                userQuery.whereKey("objectId", notEqualTo: video.posterId)
                                userQuery.findObjectsInBackground(block: { (users, error) in
                                    
                                    if error == nil
                                    {
                                        let usersCount =  users?.count
                                        var count = 0
                                        
                                        //print(usersCount)
                                        
                                        for user in users!
                                        {
                                            Global.addUserToDictionary(user: user as! PFUser, isFamily: false, completionHandler: { ( gamvesUser ) -> () in                                           
                                                
                                                
                                                self.collectionView.reloadData()
                                            })
                                        }
                                    }
                                })
                            }
                            
                            video.posterName                = qvideoinfo["poster_name"] as! String
                            
                            video.published                 = qvideoinfo.createdAt! as Date
                            
                            video.videoObj = qvideoinfo
                            
                            videothum.getDataInBackground(block: { (data, error) in
                                
                                if error == nil{
                                    
                                    video.image = UIImage(data: data!)!
                                    
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
                                }
                            })
                        }
                    }
                }
            }
        })
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
            
            cellVideo.thumbnailImageView.image = self.videosGamves[indexPath.row].image
            
            let posterId = self.videosGamves[indexPath.row].posterId
            
            if posterId == Global.gamves_official {
                
                cellVideo.userProfileImageView.image = UIImage(named:"gamves_icons_white")
                
            } else if let imagePoster = Global.userDictionary[posterId] {
                
                cellVideo.userProfileImageView.image = imagePoster.avatar
            }
            
            cellVideo.videoName.text = videosGamves[indexPath.row].title
            
            let published = String(describing: videosGamves[indexPath.row].published)
            
            let shortDate = published.components(separatedBy: " at ")
            
            cellVideo.videoDatePublish.text = shortDate[0]
            
            //cellVideo.descriptionTextView.text = videosGamves[indexPath.row].description
            
            return cellVideo
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize()
        
        if collectionView == self.imageCollectionView
        {
            
            size = CGSize(width: 160, height: 80)
            
        } else if collectionView == self.collectionView
        {
            let height = (view.frame.width - 16 - 16) * 9 / 16
            
            size = CGSize(width: view.frame.width, height: height + 16 + 88)
        }
        
        return size //CGSize(width: view.frame.width, height: height + 16 + 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing = CGFloat()
        
        if collectionView == self.imageCollectionView
        {
            spacing = 5
            
        } else if collectionView == self.collectionView
        {
            spacing = 0
        }
        
        return spacing
        
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
    
        if collectionView == self.imageCollectionView
        {
            self.carouselView.isHidden = false
            carouselView.startScrollImageView()
            
        } else if collectionView == self.collectionView
        {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)

            let videoLauncher = VideoLauncher()
            
            let video = self.videosGamves[indexPath.row]
            video.fanpageId = fanpageGamves.fanpageId
            
            videoLauncher.showVideoPlayer(videoGamves: video)
            
        }
        
    }
    
    func downloadImages(_ url:String, _ index:Int) {
        
        self.carouselView.images[index] = self.fanpageImages[index].cover_image
        
    }
    
    func didSelectCarouselView(_ view:AACarousel, _ index:Int) {
        
    }
    
    func callBackFirstDisplayView(_ imageView:UIImageView, _ url:[String], _ index:Int){
        
    }


}
