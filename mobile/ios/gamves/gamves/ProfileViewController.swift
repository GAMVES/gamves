//
//  ProfileViewController.swift
//  gamves
//
//  Created by Jose Vigil on 19/01/2018.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import PulsingHalo
import KenBurns

class ProfileViewController: UIViewController,
     UICollectionViewDataSource,
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout, 
    UIScrollViewDelegate {

     var profileSaveType:ProfileSaveType!

    var metricsHome = [String:Int]()

    var userStatistics = [UserStatistics]()

    var videosGamves  = [VideoGamves]()
    let cellVideoCollectionId = "cellVideoCollectionId"
    
    let profileView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gamvesBackgoundColor
        return view
    }()
    
    // SON VIEW
    
    let registerRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    }()

    var backImageView: KenBurnsImageView = {
        let imageView = KenBurnsImageView()
        imageView.contentMode = .scaleAspectFill //.scaleFill
        imageView.clipsToBounds = true     
        //imageView.image = UIImage(named: "universe")
        return imageView
    }()
    
    let leftregisterRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.white
        return view
    }()
    
    var sonProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let rightregisterRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.white
        return view
    }()
    
    let sonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        //label.backgroundColor = UIColor.green
        return label
    }()
    

    let bioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray        
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center        
        return label
    }()

    // DATA
    
    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    let dataView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.white
        return v
    }()
    
    // DATA VIEW
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    let footerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.red
        return v
    }()

    lazy var chatButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Edit Profile", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleChat), for: .touchUpInside)
        button.layer.cornerRadius = 5 
        return button
    }()
    
    func handleChat() {
        
    }
    
    lazy var gotoFampageButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Edit Fanpage", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleGotoFanpage), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    func handleGotoFanpage() {
        
    }
    
    var saveDesc:String  = "Save Profile"
    var colorDesc:String = "Choose Color"
    

    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var cellId = String()
    
    var profilePF:PFObject!

    var initialSetting = InitialSetting()

    var gamvesUser = GamvesParseUser()

    override func viewDidLoad() {
        super.viewDidLoad()

          self.chatButton.setTitle(saveDesc, for: .normal)
        
        self.getProfileVideos()
        
        let width = self.view.frame.width
        let paddingRegister = (width - 100)/2
        
        print(paddingRegister)
        
        let metricsRegisterView = ["paddingRegister": paddingRegister]
        
        self.view.addSubview(self.profileView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.profileView)
        
        self.view.addSubview(self.lineView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
 
        self.view.addSubview(self.dataView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.dataView)

        self.view.addSubview(self.footerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.footerView)
        
        self.view.addConstraintsWithFormat("V:|[v0(220)][v1(1)][v2][v3(70)]|", views:
            self.profileView, 
            self.lineView, 
            self.dataView,
            self.footerView)        
        
        // SON VIEW  
        
        self.profileView.addSubview(self.backImageView)
        self.profileView.addSubview(self.registerRowView)
        self.profileView.addSubview(self.sonLabel)
        self.profileView.addSubview(self.bioLabel)

        self.profileView.addConstraintsWithFormat("H:|[v0]|", views: self.backImageView)
        self.profileView.addConstraintsWithFormat("V:|[v0(100)]|", views:
            self.backImageView)        
        
        self.profileView.addConstraintsWithFormat("H:|[v0]|", views: self.registerRowView)
        self.profileView.addConstraintsWithFormat("H:|[v0]|", views: self.sonLabel)
        self.profileView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.bioLabel)
        
        self.profileView.addConstraintsWithFormat("V:|-50-[v0(100)]-5-[v1(20)][v2]|", views:
            self.registerRowView,
            self.sonLabel,
            self.bioLabel,
            metrics: metricsRegisterView)

        self.profileView.bringSubview(toFront: self.registerRowView)
        
        let userId = PFUser.current()?.objectId
        
        let name = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.name
        self.sonLabel.text = name
        self.sonLabel.textAlignment = NSTextAlignment.center
        
        self.registerRowView.addSubview(self.leftregisterRowView)
        self.registerRowView.addSubview(self.sonProfileImageView)
        self.registerRowView.addSubview(self.rightregisterRowView)
        
        self.registerRowView.addConstraintsWithFormat("V:|[v0]|", views: self.leftregisterRowView)
        self.registerRowView.addConstraintsWithFormat("V:|[v0]|", views: self.sonProfileImageView)
        self.registerRowView.addConstraintsWithFormat("V:|[v0]|", views: self.rightregisterRowView)            
        
        self.registerRowView.addConstraintsWithFormat("H:|[v0(paddingRegister)][v1(100)][v2(paddingRegister)]|", views: 
            self.leftregisterRowView, 
            self.sonProfileImageView, 
            self.rightregisterRowView, 
            metrics: metricsRegisterView)

        self.footerView.addSubview(self.chatButton)
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.chatButton)
        
        self.footerView.addSubview(self.gotoFampageButton)
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.gotoFampageButton)
        
        let splitFooter = (width - 60)/2
        
        let metricsFooterView = ["sf": splitFooter]
        
        self.footerView.addConstraintsWithFormat("H:|-20-[v0(sf)]-20-[v1(sf)]-20-|", views: self.chatButton, self.gotoFampageButton, metrics: metricsFooterView)
        
        self.footerView.addSubview(self.chatButton)
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.chatButton)
        self.chatButton.isHidden = true
        self.setSonProfileImageView()

        self.dataView.addSubview(self.collectionView)
        self.dataView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.collectionView) 
        self.dataView.addConstraintsWithFormat("V:|-20-[v0]|", views: self.collectionView) 
       
        //self.bioLabel.text = "I like doing this and that with my information"

        self.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: self.cellVideoCollectionId)       

        self.collectionView.backgroundColor = UIColor.white
        
        self.profileSaveType = ProfileSaveType.profile
        
        self.loadProfileInfo()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSonProfileImageView() {
        
        let userId = PFUser.current()?.objectId
        
        if let sonImage:UIImage = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.avatar {
            self.sonProfileImageView.image = sonImage
            Global.setRoundedImage(image: sonProfileImageView, cornerRadius: 50, boderWidth: 5, boderColor: UIColor.gamvesBackgoundColor)
            
            self.sonProfileImageView.layer.shadowColor = UIColor.black.cgColor
            self.sonProfileImageView.layer.shadowOpacity = 1
            self.sonProfileImageView.layer.shadowOffset = CGSize.zero
            self.sonProfileImageView.layer.shadowRadius = 10
        }
        
    }

     func loadProfileInfo() {
        
        let queryUser = PFQuery(className:"Profile")
        
        queryUser.whereKey("userId", equalTo: gamvesUser.userObj.objectId)
        
        queryUser.getFirstObjectInBackground { (profile, error) in
            
            if error == nil {
                
                if let prPF:PFObject = profile {
                    
                    self.profilePF = prPF
                    
                    if self.profilePF["pictureBackground"] != nil {
                
                        let backImage = self.profilePF["pictureBackground"] as! PFFile
                        
                        let colorArray:[CGFloat] = self.profilePF["backgroundColor"] as! [CGFloat]
                        
                        let bio = self.profilePF["bio"] as! String
                        
                        self.bioLabel.text = bio
                        
                        let backgroundColor = UIColor.rgb(colorArray[0], green: colorArray[1], blue: colorArray[2])
                        
                        self.initialSetting.backColor = backgroundColor
                        self.profileView.backgroundColor = backgroundColor
                        
                        backImage.getDataInBackground { (imageData, error) in
                            
                            if error == nil {
                                
                                if let imageData = imageData
                                {
                                    let image = UIImage(data:imageData)
                                    
                                    self.newKenBurnsImageView(image: image!)
                                    
                                    self.initialSetting.backImage = image
                                    
                                    self.initialSetting.bio = self.bioLabel.text!
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    

    func getProfileVideos()
    {
        
        self.activityIndicatorView?.startAnimating()
        
        let queryvideos = PFQuery(className:"Videos")      

        if let userId = gamvesUser.userObj.objectId {

            print(userId)
            
            queryvideos.whereKey("posterId", equalTo: userId)    
        }
        
        queryvideos.whereKey("approved", equalTo: true)

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
                                                        
                            video.posterName                = qvideoinfo["poster_name"] as! String
                            
                            video.published                 = qvideoinfo.createdAt! as Date
                            
                            video.videoObj = qvideoinfo
                            
                            video.checked                   = qvideoinfo["public"] as! Bool
                            
                            videothum.getDataInBackground(block: { (data, error) in
                                
                                if error == nil{
                                    
                                    video.image = UIImage(data: data!)!
                                    
                                    self.videosGamves.append(video)
                                    
                                    print("***********")
                                    print("countVideos: \(countVideos!)")
                                    print("countVideosLoaded: \(countVideosLoaded)")
                                    
                                    if ( (countVideos!-1) == count)
                                    {
                                        self.initialSetting.videos = self.videosGamves
                                        
                                        self.activityIndicatorView?.stopAnimating()
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
        count = self.videosGamves.count      
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
             
        let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: cellVideoCollectionId, for: indexPath) as! VideoCollectionViewCell
        
        cellVideo.thumbnailImageView.image = videosGamves[indexPath.row].image
        
        let posterId = videosGamves[indexPath.row].posterId
        
        if posterId == Global.gamves_official {
            
            cellVideo.userProfileImageView.image = UIImage(named:"gamves_icons_white")
            
        } else if let imagePoster = Global.userDictionary[posterId] {
            
            cellVideo.userProfileImageView.image = imagePoster.avatar
        }
        
        cellVideo.checkView.isHidden = false
        
        cellVideo.videoName.text = videosGamves[indexPath.row].title
        
        let published = String(describing: videosGamves[indexPath.row].published)
        
        let shortDate = published.components(separatedBy: " at ")
        
        cellVideo.videoDatePublish.text = shortDate[0] 
        
        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize()      
       
        let height = (self.view.frame.width - 16 - 16) * 9 / 16
           
        size = CGSize(width: self.view.frame.width, height: height + 16 + 88)
        
        
        return size //CGSize(width: view.frame.width, height: height + 16 + 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing = CGFloat()        
        spacing = 0       
        return spacing
        
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
      
    }

    func newKenBurnsImageView(image: UIImage) {
        self.backImageView.setImage(image)
        self.backImageView.zoomIntensity = 1.5
        self.backImageView.setDuration(min: 5, max: 13)
        self.backImageView.startAnimating()
    }

}
