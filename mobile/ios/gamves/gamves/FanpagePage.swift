//
//  FanpageTableViewCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/19/17.
//

import UIKit
import Parse
import NVActivityIndicatorView
import KenBurns
import AXPhotoViewer
import FLAnimatedImage
import PINRemoteImage

//import AACarousel
//import SwiftPhotoGallery

class FanpagePage: UIViewController,
    UICollectionViewDataSource, 
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout,
    AXPhotosViewControllerDelegate        
{  

    //- All page view

    let coverContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red 
        return view
    }()

    //- Header background image

    var coverImageView: KenBurnsImageView = {
        let imageView = KenBurnsImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()    

    //- Go back button

    lazy var arrowBackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "arrow_back_white")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)        
        return button
    }()

    //- Fanpge avatar

    var avatarImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill 
        image.clipsToBounds = true
        image.backgroundColor = UIColor.gamvesColor
        image.layer.cornerRadius = 30
        image.borderWidth = 3
        image.borderColor = UIColor.black
        return image
    }()

     let separatorButtonsView: UIView = {
        let view = UIView()        
        return view
    }()

    //- Separetor Label

    let separatorCenterView: UIView = {
        let view = UIView()               
        return view
    }()        

    var fanpageName: UILabel = {
        let label = UILabel()        
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.white
        return label
    }()

    //- Favorite button

    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "favorite")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleFavoriteButton), for: .touchUpInside)        
        return button
    }()

    //- Images Collection

    lazy var imageCollectionView: UICollectionView = {
        //let layout = UICollectionViewFlowLayout()
        //layout.scrollDirection = .vertical
        //layout.sectionHeadersPinToVisibleBounds = true

         let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.headerReferenceSize = CGSize(width: 0, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.scrollDirection = .vertical

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.alwaysBounceHorizontal = true
        cv.showsHorizontalScrollIndicator = false
        cv.isPrefetchingEnabled = false        
        return cv
    }()   

    //- Fanpage Collection

    let collectionContainerView: UIView = {
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

    //- Bottom line 

    let bottomLineContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black //UIColor(white: 0, alpha: 1)
        return view
    }()

    //- Empty message

    var labelEmptyMessage: UILabel = {
        let label = UILabel()
        label.text = "There are no videos yet loaded for this fanpage"        
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.gray
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()


    //- VARIABLES & OBJCETS    

    var fanpageGamves  = GamvesFanpage()
    var videosGamves  = [GamvesVideo]()
    //var albums = Dictionary<String, [GamvesAlbum]>()
    //var fanpageImages = [GamvesFanpageImage]()     
    
    var groupAlbums = [[GamvesAlbum]]()
    var albumSections = [String]()

    weak var delegate:CellDelegate?       
    
    var activityVideoView: NVActivityIndicatorView!
    
    var timer:Timer? = nil

    var gallery:SwiftPhotoGallery?    

     var isFavorite = Bool()

    var favorite:PFObject!

    let cellVideoCollectionId = "cellVideoCollectionId"
    let cellImageCollectionId = "cellImageCollectionId"

    let sectionHeaderId = "fanpgageSectionHeader"

    var categoryName = String()   

    var posterId = String()  
    
    var isFortnite = Bool()

    var photosViewController: AXPhotosViewController?
    var photos = []
    
    override func viewDidLoad() {

        super.viewDidLoad()        

        self.view.addSubview(self.coverContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.coverContainerView)
        
        self.coverContainerView.addSubview(self.coverImageView)
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.coverImageView)
        self.coverContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.coverImageView)
    
        self.coverContainerView.addSubview(self.arrowBackButton)
        self.coverContainerView.addSubview(self.avatarImageView)
        self.coverContainerView.addSubview(self.separatorButtonsView)
        self.coverContainerView.addSubview(self.favoriteButton)
        
        //horizontal constraints
        self.coverContainerView.addConstraintsWithFormat("H:|[v0(60)][v1(60)]-10-[v2][v3(60)]|", views: arrowBackButton, avatarImageView, separatorButtonsView, favoriteButton)
        
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.arrowBackButton)
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.avatarImageView)
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
        
        self.view.addSubview(self.collectionContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionContainerView)
        
        self.collectionContainerView.addSubview(self.collectionView)
        self.collectionContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.collectionContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)       
        
        self.view.addSubview(self.imageCollectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.imageCollectionView)
        
        self.imageCollectionView.backgroundColor = UIColor.gamvesBlackColor

        self.view.addConstraintsWithFormat("V:|[v0(80)][v1(200)][v2]|", views: 
            self.coverContainerView,
            self.imageCollectionView, 
            self.collectionContainerView)
        
        self.coverContainerView.addSubview(self.bottomLineContainerView)
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomLineContainerView)
        self.coverContainerView.addConstraintsWithFormat("V:|-77-[v0(3)]|", views: self.bottomLineContainerView)
        
        self.imageCollectionView.register(ImagesCollectionViewCell.self, forCellWithReuseIdentifier: self.cellImageCollectionId)
        self.imageCollectionView.register(FanpageSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: self.sectionHeaderId)
        
        self.activityVideoView = Global.setActivityIndicator(container: self.collectionContainerView, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)//,x: 0, y: 0, width: 80.0, height: 80.0)
        
        let widthImages = view.frame.width
        let heightImages = (view.frame.width - 16 - 16) * 9 / 16
        
        let padding = (view.frame.height - heightImages) / 2
        
        let metricsImages = [
            "widthImages":widthImages,
            "heightImages":heightImages,
            "padding" : padding
        ]       
   

        self.gallery = SwiftPhotoGallery(delegate: self, dataSource: self)

        self.gallery?.backgroundColor = UIColor.black
        self.gallery?.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
        self.gallery?.currentPageIndicatorTintColor = UIColor.white
        self.gallery?.hidePageControl = false
        
        self.activityVideoView.startAnimating()          

        self.view.addSubview(self.labelEmptyMessage)
        self.view.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: self.labelEmptyMessage)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.labelEmptyMessage)

        self.labelEmptyMessage.isHidden = true

        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: 0, repeats: true)        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.view.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.favoriteButton.tintColor = UIColor.white
    }

    func setFanpageGamvesData(data: GamvesFanpage) {        
        
        self.checkFavorite()    

        self.fanpageGamves = data as GamvesFanpage

        self.categoryName = self.fanpageGamves.categoryName             

        if self.categoryName == "PERSONAL" {

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
            self.avatarImageView.isUserInteractionEnabled = true
            self.avatarImageView.addGestureRecognizer(tapGestureRecognizer)

        }
        
        self.fanpageName.text = self.fanpageGamves.name
        
        let fanpageId = data.fanpageObj?["fanpageId"] as! Int
        
        let name = data.fanpageObj?["pageName"] as! String
        
        self.newKenBurnsImageView(image: self.fanpageGamves.cover_image)
        
        self.avatarImageView.image = self.fanpageGamves.icon_image
        
        if Downloader.fanpageImagesDictionary[fanpageId] != nil {

            let allAbums =  Downloader.fanpageImagesDictionary[fanpageId] as! [GamvesAlbum]

            let groupDictionary = Dictionary(grouping: allAbums) { (album) -> String in
                return album.type
            }            

            //self.albumSections = groupDictionary.keys

            let keys = groupDictionary.keys.sorted()
            keys.forEach{ (key) in
                print(key)
                self.albumSections.append(key)
                groupAlbums.append(groupDictionary[key]!)
            }
            
            groupAlbums.forEach({
                $0.forEach({print($0)})
                print("-----------------------")
            })         
            
                            
            self.imageCollectionView.reloadData()

            self.startTimer()
        }
        
        if self.coverContainerView.tag != 1 {
            self.setupGradientLayer()
        }
        
        self.view.isHidden = false
    }

    func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer) {

        self.posterId = self.fanpageGamves.posterId

        if Global.userDictionary[posterId] != nil {

            let gamvesUserPoster = Global.userDictionary[posterId] as! GamvesUser

            let userDataDict:[String: GamvesUser] = ["gamvesUser": gamvesUserPoster]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Global.notificationKeyShowProfile), object: nil, userInfo: userDataDict)       
        }
            
    }

    func scrollAutomatically(_ sender: Timer) {
        
        var section = sender.userInfo as! Int
        
        for cell in self.imageCollectionView.visibleCells {
            let indexPath: IndexPath? = self.imageCollectionView.indexPath(for: cell)
            if ((indexPath?.row)!  < self.groupAlbums[section].count - 1){
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                
                self.imageCollectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
            }
            else{
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                self.imageCollectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
            }            
        }  
    
    }

    func checkFavorite() {


        let queryFavorite = PFQuery(className:"Favorites")

        if let userId = PFUser.current()?.objectId {
        
            queryFavorite.whereKey("userId", equalTo: userId)

        }

        if let fanpageId = self.fanpageGamves.fanpageObj?.objectId {

            queryFavorite.whereKey("referenceId", equalTo: fanpageId)

        }
        
        queryFavorite.findObjectsInBackground { (favoritePF, error) in
         
             if error == nil {
                
                var count = Int()
                
                count = (favoritePF?.count)!

                if count > 0 {

                    self.isFavorite = true               
                    
                    self.favoriteButton.tintColor = UIColor.red

                    self.favorite = favoritePF![0]

                } else {

                    self.unMarkFavorite()
                }

            } else {

                self.unMarkFavorite()
            }          
        }
    }

    func unMarkFavorite() {

        self.isFavorite = false

        self.favoriteButton.tintColor = UIColor.white

    }

    func handleFavoriteButton() {

        if !self.isFavorite {

            let favoritesPF: PFObject = PFObject(className: "Favorites")

            if let fanpageId = self.fanpageGamves.fanpageObj?.objectId {

                favoritesPF["referenceId"] = fanpageId

            }
            
            if let userId = PFUser.current()?.objectId {
            
                favoritesPF["userId"] = userId
                
            }
            
            favoritesPF["type"] = 1
            
            favoritesPF.saveInBackground(block: { (resutl, error) in
                
                if error == nil {
                
                    self.favoriteButton.tintColor = UIColor.red

                    self.isFavorite = true

                    self.favorite = favoritesPF
                }

            })            
            
        } else {

            self.favorite.deleteEventually()

            self.favoriteButton.tintColor = UIColor.white

            self.isFavorite = false
        }
        
    }


    func handleBackButton()  {
        
        if ( delegate != nil ) {

            if self.timer != nil {
                self.timer?.invalidate()
            }
            
            delegate?.setCurrentPage(current: 0, direction: -1, data: nil)
        }  

        self.labelEmptyMessage.isHidden = true
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
  
    func scrollToNextCell() {

        let cellSize = CGSize(width:self.coverContainerView.frame.width, height:self.coverContainerView.frame.height)        
        let contentOffset = self.imageCollectionView.contentOffset               
        self.imageCollectionView.scrollRectToVisible(CGRect(x:contentOffset.x + cellSize.width, y:contentOffset.y, width:cellSize.width, height:cellSize.height), animated: true)        
    }
    
    func startTimer()
    {
        let kAutoScrollDuration: CGFloat = 4.0
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(kAutoScrollDuration), target: self, selector: #selector(self.autoScrollImageSlider), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
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
    

    func setFanpageData() {   

        self.videosGamves = [GamvesVideo]()        
        self.collectionView.reloadData()        
        self.getFanpageVideos(fan: fanpageGamves)        
    }

     func autoScrollImageSlider() {

     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func getFanpageVideos(fan:GamvesFanpage)
    {

        self.activityVideoView.startAnimating()

        let countVideosLoaded = 0
        
        let videoRel:PFRelation = fan.fanpageObj!.relation(forKey: "videos")
        let queryvideos:PFQuery = videoRel.query()
        
        //queryvideos.whereKey("approved", equalTo: true)
        
        let filterTarget = [
            Global.schoolShort,
            Global.levelDescription.lowercased(),
            Global.userId] as [String]
        
        queryvideos.whereKey("target", containedIn: filterTarget)
        
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
                            
                            let video = GamvesVideo()
                            
                            var videothum = qvideoinfo["thumbnail"] as! PFFile
                            
                            video.authorized                = qvideoinfo["authorized"] as! Bool

                            if video.authorized 
                            {

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
                                
                                if Global.userDictionary[video.posterId] == nil && video.posterId != Global.gamves_official_id {
                                
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
                                        
                                        self.videosGamves.append(video)
                                        
                                        print("***********")
                                        print("countVideos: \(countVideos!)")
                                        print("countVideosLoaded: \(countVideosLoaded)")
                                        
                                        if ( (countVideos!-1) == count)
                                        {
                                            //self.videosGamves = fan.videos
                                            self.activityVideoView.stopAnimating()
                                            self.collectionView.reloadData()
                                        }
                                        count = count + 1
                                    }
                                })

                            } else {

                                if countVideos! > 1 {
                                    
                                    if ( (countVideos!-1) == count)
                                    {
                                        //self.videosGamves = fan.videos
                                        self.activityVideoView.stopAnimating()
                                        self.collectionView.reloadData()
                                    }
                                    count = count + 1
                                    
                                } else {
                                    self.showEmptyMessage()
                                }
                            }
                        }
                    }
            
                } else {
                   
                    self.showEmptyMessage()
                }

            }
        })
    } 

    func showEmptyMessage() {
        self.activityVideoView.stopAnimating()
        self.labelEmptyMessage.isHidden = false
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var count = Int()
        if collectionView == self.imageCollectionView {
            count = self.groupAlbums.count
        }
        return count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       
        var reuseHeaderView: UICollectionReusableView? = nil

        if kind == UICollectionElementKindSectionHeader {
               
            var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! FanpageSectionHeader
    
            /*var headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)

            headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
            let momentLabel = UILabel()
            momentLabel.translatesAutoresizingMaskIntoConstraints = false
            momentLabel.text = "Top Tags"
            momentLabel.font = UIFont(name: "Ubuntu-MediumItalic", size: 13)
            momentLabel.textColor = UIColor.red
            headerView.addSubview(momentLabel)
            momentLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5).isActive = true
            momentLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 5).isActive = true*/

        
            let name = self.albumSections[indexPath.section]        
            sectionHeaderView.nameLabel.text = name                        
            sectionHeaderView.backgroundColor = UIColor.black
            //sectionHeaderView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)                        

            return sectionHeaderView
        } 
        return reuseHeaderView!      
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {       
        //return CGSize(width: self.imageCollectionView.frame.size.width, height: 50)
        return CGSize(width: self.imageCollectionView.frame.width, height: 30)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if collectionView == self.imageCollectionView
        {
            count = self.groupAlbums[section].count
            
        } else if collectionView == self.collectionView
        {
            count = self.videosGamves.count
        }
        return count
    }  
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = BaseCell()
        
        if collectionView == self.imageCollectionView
        {
            let cellImage = collectionView.dequeueReusableCell(withReuseIdentifier: cellImageCollectionId, for: indexPath) as! ImagesCollectionViewCell
            let alb = self.groupAlbums[indexPath.section][indexPath.row]
            
            cellImage.imageView.image = alb.cover_image
            
            return cellImage
            
        } else if collectionView == self.collectionView
        {
            let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: cellVideoCollectionId, for: indexPath) as! VideoCollectionViewCell
            
            cellVideo.thumbnailImageView.image = self.videosGamves[indexPath.row].image
            
            let posterId = self.videosGamves[indexPath.row].posterId
            
            if posterId == Global.gamves_official_id {
                
                cellVideo.userProfileImageView.image = UIImage(named:"gamves_icons_white")
                
            } else if let imagePoster = Global.userDictionary[posterId] {
                
                cellVideo.userProfileImageView.image = imagePoster.avatar
            }
            
            cellVideo.videoName.text = videosGamves[indexPath.row].title
            
            let published = String(describing: videosGamves[indexPath.row].published)
            
            let shortDate = published.components(separatedBy: " at ")
            
            cellVideo.videoDatePublish.text = shortDate[0]       

            cellVideo.checkView.isHidden = true            

            let recognizer = UITapGestureRecognizer(target: self, action:#selector(handleViewProfile(recognizer:)))
            
            cellVideo.rowView.tag = indexPath.row

            cellVideo.rowView.addGestureRecognizer(recognizer)


            return cellVideo
        }
        
        return cell
    }
    

    func handleViewProfile(recognizer:UITapGestureRecognizer) {
        
        let v = recognizer.view!
        let index = v.tag
               
        let indexPath = IndexPath(item: index, section: 1)
        
        let posterId = self.videosGamves[indexPath.item].posterId
        
        print(posterId)
        
        let gamvesUserPoster = Global.userDictionary[posterId] as! GamvesUser

        if let userId = PFUser.current()?.objectId {

            //Not open my user
            
            if gamvesUserPoster.userId != userId {

                if gamvesUserPoster.userName == "gamvesadmin" {

                    var chatId = Int()

                    if gamvesUserPoster.chatId > 0 {

                        chatId = gamvesUserPoster.chatId
                    } else {
                        chatId = Global.getRandomInt()
                    }

                    let userDataDict:[String: AnyObject] = ["gamvesUser": gamvesUserPoster, "chatId": chatId as AnyObject]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Global.notificationOpenChatFromUser), object: nil, userInfo: userDataDict) 

                } else  {

                    let profileLauncher = PublicProfileLauncher()
                    profileLauncher.showProfileView(gamvesUser: gamvesUserPoster)

                }

            }
        }     
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize()
        
        if collectionView == self.imageCollectionView
        {
            
            size = CGSize(width: 50, height: 50)
            
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
    
        if collectionView == self.imageCollectionView {           

            //self.gallery?.modalPresentationStyle = .overCurrentContext
            //present(self.gallery!, animated: true, completion: nil)

            let selectedAlbums = self.groupAlbums[indexPath.section] as [GamvesAlbum]

            for album in selectedAlbums {

               let photo = AXPhoto(attributedTitle: NSAttributedString(string: album.name),
                image: UIImage(named: album.cover_image))

               self.phootos.append(photo)
            }

            let dataSource = AXPhotosDataSource(photos: self.photos, initialPhotoIndex: indexPath.row)
            let pagingConfig = AXPagingConfig(loadingViewClass: CustomLoadingView.self)
            let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
            //photosViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            photosViewController.delegate = self
            
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let bottomView = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44)))
            let customView = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 20)))
            customView.text = "\(photosViewController.currentPhotoIndex + 1)"
            customView.textColor = .white
            customView.sizeToFit()
            bottomView.items = [
                UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil),
                flex,
                UIBarButtonItem(customView: customView),
                flex,
                UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil),
            ]
            bottomView.backgroundColor = .clear
            bottomView.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            photosViewController.overlayView.bottomStackContainer.insertSubview(bottomView, at: 0) // insert custom
            
            self.customView = customView
            
            //container.addChildViewController(photosViewController)
            //container.view.addSubview(photosViewController.view)
            //photosViewController.didMove(toParentViewController: container)
            
            self.present(photosViewController, animated: true)
            self.photosViewController = photosViewController
            
        } else if collectionView == self.collectionView
        {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)

            let videoLauncher = VideoLauncher()
            
            let video = self.videosGamves[indexPath.row]
            video.fanpageId = fanpageGamves.fanpageId
            
            videoLauncher.showVideoPlayer(videoGamves: video)            
        }        
    }


    // MARK: - AXPhotosViewControllerDelegate
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              willUpdate overlayView: AXOverlayView,
                              for photo: AXPhotoProtocol,
                              at index: Int,
                              totalNumberOfPhotos: Int) {
        
        self.customView?.text = "\(index + 1)"
        self.customView?.sizeToFit()
    }
    
    // MARK: - Loading
    func loadContent(at indexPath: IndexPath, into imageView: FLAnimatedImageView) {
        func onBackgroundThread(_ block: @escaping () -> Void) {
            if Thread.isMainThread {
                DispatchQueue.global().async {
                    block()
                }
            } else {
                block()
            }
        }
        
        func onMainThread(_ block: @escaping () -> Void) {
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.async {
                    block()
                }
            }
        }
        
        func layoutImageView(with result: Any?) {
            let maxSize: CGFloat = 280
            var imageViewSize: CGSize
            if let animatedImage = result as? FLAnimatedImage {
                imageViewSize = (animatedImage.size.width > animatedImage.size.height) ?
                    CGSize(width: maxSize,height: (maxSize * animatedImage.size.height / animatedImage.size.width)) :
                    CGSize(width: maxSize * animatedImage.size.width / animatedImage.size.height, height: maxSize)
                
                onMainThread {
                    imageView.frame.size = imageViewSize
                    if let superview = imageView.superview {
                        imageView.center = superview.center
                    }
                }
            } else if let image = result as? UIImage {
                imageViewSize = (image.size.width > image.size.height) ?
                    CGSize(width: maxSize, height: (maxSize * image.size.height / image.size.width)) :
                    CGSize(width: maxSize * image.size.width / image.size.height, height: maxSize)
                
                onMainThread {
                    imageView.frame.size = imageViewSize
                    if let superview = imageView.superview {
                        imageView.center = superview.center
                    }
                }
            }
        }
        
        if let imageData = self.photos[indexPath.row].imageData {
            onBackgroundThread {
                let image = FLAnimatedImage(animatedGIFData: imageData)
                onMainThread {
                    imageView.animatedImage = image
                    layoutImageView(with: image)
                }
            }
        } else if let image = self.photos[indexPath.row].image {
            onMainThread {
                imageView.image = image
                layoutImageView(with: image)
            }
        } else if let url = self.photos[indexPath.row].url {
            imageView.pin_setImage(from: url, placeholderImage: nil) { (result) in
                layoutImageView(with: result.alternativeRepresentation ?? result.image)
            }
        }
    }
    
    func cancelLoad(at indexPath: IndexPath, for imageView: FLAnimatedImageView) {
        imageView.pin_cancelImageDownload()
        imageView.animatedImage = nil
        imageView.image = nil
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location),
            let cell = self.tableView.cellForRow(at: indexPath),
            let imageView = cell.contentView.viewWithTag(666) as? FLAnimatedImageView else {
            return nil
        }
        
        previewingContext.sourceRect = self.tableView.convert(imageView.frame, from: imageView.superview)
        
        let dataSource = AXPhotosDataSource(photos: self.photos, initialPhotoIndex: indexPath.row)
        let previewingPhotosViewController = AXPreviewingPhotosViewController(dataSource: dataSource)
        
        return previewingPhotosViewController
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let previewingPhotosViewController = viewControllerToCommit as? AXPreviewingPhotosViewController {
            self.present(AXPhotosViewController(from: previewingPhotosViewController), animated: false)
        }
    }
    
    /*

    func downloadImages(_ url:String, _ index:Int) {
        
    }
    
    func callBackFirstDisplayView(_ imageView:UIImageView, _ url:[String], _ index:Int){
       
    }   
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        var count = Int()
        if self.groupAlbums.count > 0 {
            count = self.groupAlbums[0].count
        }
        return count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        //return self.groupAlbums[0][0].cover_image
        var image = UIImage()
        if self.groupAlbums[0][0] != nil {
            image = self.groupAlbums[0][forIndex].cover_image
        }
        return image

    }


    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {        
        dismiss(animated: true, completion: nil)
    }

    */
}




