

//
//  ProfileCell.swift
//  gamves
//
//  Created by Jose Vigil on 10/10/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import IGColorPicker
import PulsingHalo


public enum ProfileSaveType {
    case profile
    case color
}

class ProfileCell: BaseCell,
    UICollectionViewDataSource,
    UICollectionViewDelegate, 
    UICollectionViewDelegateFlowLayout, 
    UIScrollViewDelegate,
    ColorPickerViewDelegate
{

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

    var backImageView: UIImageView = {        
        let imageView = UIImageView()        
        imageView.contentMode = .scaleAspectFill //.scaleFill
        imageView.clipsToBounds = true     
        imageView.image = UIImage(named: "universe")
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


    lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Edit Profile", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        button.layer.cornerRadius = 5 
        return button
    }()
    
    lazy var editFanpageButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Edit Fanpage", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleEditFanpage), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var saveProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Save Profile", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSaveProfile), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var cancelProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Cancel", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleCancelProfile), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()

    lazy var chatViewController: ChatViewController = {
        let launcher = ChatViewController()
        return launcher
    }()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var cellId = String()
    
    var colorPickerView: ColorPickerView!
    
    var editProfile = Bool()
    var editCreated = Bool()
    
    var editBackImageView:UIView!
    var editAvatarImageView:UIView!
    var editColorView:UIView!
    var editBioView:UIView!
    
    
    
    override func setupViews() {
        super.setupViews()

        self.getProfileVideos()
        
        let width = self.frame.width
        let paddingRegister = (width - 100)/2
        
        print(paddingRegister)
        
        let metricsRegisterView = ["paddingRegister": paddingRegister]
        
        self.addSubview(self.profileView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.profileView)
        
        self.addSubview(self.lineView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
 
        self.addSubview(self.dataView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.dataView)

        self.addSubview(self.footerView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.footerView)        
        
        self.addConstraintsWithFormat("V:|[v0(220)][v1(1)][v2][v3(70)]|", views:
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

        self.footerView.addSubview(self.editProfileButton)
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.editProfileButton)
        
        self.footerView.addSubview(self.editFanpageButton)
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.editFanpageButton)
        
        let splitFooter = (width - 60)/2
        
        let metricsFooterView = ["sf": splitFooter]
        
        self.footerView.addConstraintsWithFormat("H:|-20-[v0(sf)]-20-[v1(sf)]-20-|", views: self.editProfileButton, self.editFanpageButton, metrics: metricsFooterView)
        
        self.footerView.addSubview(self.saveProfileButton)
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.saveProfileButton)
        self.saveProfileButton.isHidden = true
        
        self.footerView.addSubview(self.cancelProfileButton)
        self.footerView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.cancelProfileButton)
        self.saveProfileButton.isHidden = true
        
        self.footerView.addConstraintsWithFormat("H:|-20-[v0(sf)]-20-[v1(sf)]-20-|", views: self.saveProfileButton, self.cancelProfileButton, metrics: metricsFooterView)
        
        
        if let sonImage:UIImage = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.avatar {
            self.sonProfileImageView.image = sonImage
            Global.setRoundedImage(image: sonProfileImageView, cornerRadius: 50, boderWidth: 5, boderColor: UIColor.gamvesBackgoundColor)

            self.sonProfileImageView.layer.shadowColor = UIColor.black.cgColor
            self.sonProfileImageView.layer.shadowOpacity = 1
            self.sonProfileImageView.layer.shadowOffset = CGSize.zero
            self.sonProfileImageView.layer.shadowRadius = 10
        }

        self.dataView.addSubview(self.collectionView)
        self.dataView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.collectionView) 
        self.dataView.addConstraintsWithFormat("V:|-20-[v0]|", views: self.collectionView) 
       
        self.bioLabel.text = "I like doing this and that with my information"

        self.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: self.cellVideoCollectionId)       

        self.collectionView.backgroundColor = UIColor.white
        
        self.profileSaveType = ProfileSaveType.profile
       
    }
    
    func handleEditProfile() {
        
        if !self.editCreated {
        
            DispatchQueue.main.async {
                
                self.editProfile = true
                
                //-- Bottom single button
                
                self.saveProfileButton.isHidden = false
                self.editProfileButton.isHidden = true
                self.editFanpageButton.isHidden = true
                
                //-- Background
                
                self.editBackImageView = UIView(frame: CGRect(x:30, y:30, width:50, height:50))
                
                var editBackImageButton = UIButton(type: UIButtonType.system)
                editBackImageButton = UIButton(frame: CGRect(x:0, y:0, width:50, height:50))
                let imageBack = UIImage(named: "camera_black")
                imageBack?.maskWithColor(color: UIColor.gamvesBackgoundColor)
                editBackImageButton.setImage(imageBack, for: .normal)
                editBackImageButton.isUserInteractionEnabled = true
                editBackImageButton.addTarget(self, action: #selector(self.handleChangeBackgoundImage), for: .touchUpInside)
                
                let haloBack = PulsingHaloLayer()
                haloBack.position.x = editBackImageButton.center.x
                haloBack.position.y = editBackImageButton.center.y
                haloBack.haloLayerNumber = 5
                haloBack.backgroundColor = UIColor.gamvesBackgoundColor.cgColor
                haloBack.radius = 40
                haloBack.start()
                
                self.editBackImageView.layer.addSublayer(haloBack)
                self.editBackImageView.addSubview(editBackImageButton)
                self.profileView.addSubview(self.editBackImageView)
                
                //-- Avatar
                
                let w = self.frame.width
                let halfWidth = w/2 - 25
                
                self.editAvatarImageView = UIView(frame: CGRect(x:halfWidth, y:25, width:50, height:50))
                
                var editAvatarButton = UIButton(type: UIButtonType.system)
                editAvatarButton = UIButton(frame: CGRect(x:0, y:0, width:50, height:50))
                let imageAvatar = UIImage(named: "camera_black")
                editAvatarButton.setImage(imageAvatar, for: .normal)
                editAvatarButton.addTarget(self, action: #selector(self.handleChangeAvatarImage), for: .touchUpInside)
                editAvatarButton.isUserInteractionEnabled = true
                
                let haloAvatar = PulsingHaloLayer()
                haloAvatar.position.x = editAvatarButton.center.x
                haloAvatar.position.y = editAvatarButton.center.y
                haloAvatar.haloLayerNumber = 5
                haloAvatar.backgroundColor = UIColor.gamvesBackgoundColor.cgColor
                haloAvatar.radius = 40
                haloAvatar.start()
                
                self.editAvatarImageView.layer.addSublayer(haloAvatar)
                self.editAvatarImageView.addSubview(editAvatarButton)
                self.registerRowView.addSubview(self.editAvatarImageView)
                
                //-- Color
                
                self.editColorView = UIView(frame: CGRect(x:30, y:60, width:50, height:50))
                
                var editColorButton = UIButton(type: UIButtonType.system)
                editColorButton = UIButton(frame: CGRect(x:0, y:0, width:50, height:50))
                let imageColor = UIImage(named: "color")
                imageColor?.maskWithColor(color: UIColor.lightGray)
                editColorButton.setImage(imageColor, for: .normal)
                editColorButton.addTarget(self, action: #selector(self.handleChangeColor), for: .touchUpInside)
                editColorButton.isUserInteractionEnabled = true
                
                let haloColor = PulsingHaloLayer()
                haloColor.position.x = editColorButton.center.x
                haloColor.position.y = editColorButton.center.y
                haloColor.haloLayerNumber = 5
                haloColor.backgroundColor = UIColor.lightGray.cgColor
                haloColor.radius = 40
                haloColor.start()

                self.editColorView.layer.addSublayer(haloColor)
                self.editColorView.addSubview(editColorButton)
                self.registerRowView.addSubview(self.editColorView)
                
                //-- Bio
                
                let bX = w - 60
                
                self.editBioView = UIView(frame: CGRect(x:bX, y:120, width:50, height:50))
        
                var editBioButton = UIButton(type: UIButtonType.system)
                editBioButton = UIButton(frame: CGRect(x:0, y:0, width:50, height:50))
                let imageBio = UIImage(named: "edit")
                imageBio?.maskWithColor(color: UIColor.lightGray)
                editBioButton.setImage(imageBio, for: .normal)
                editBioButton.addTarget(self, action: #selector(self.handleChangeBio), for: .touchUpInside)
                editBioButton.isUserInteractionEnabled = true
                
                let haloBio = PulsingHaloLayer()
                haloBio.position.x = editBioButton.center.x
                haloBio.position.y = editBioButton.center.y
                haloBio.haloLayerNumber = 5
                haloBio.backgroundColor = UIColor.lightGray.cgColor
                haloBio.radius = 40
                haloBio.start()
                
                self.editBioView.layer.addSublayer(haloBio)
                self.editBioView.addSubview(editBioButton)
                self.registerRowView.addSubview(self.editBioView)
                
                self.collectionView.reloadData()
                
                self.editCreated = true
            }
        }
        
    }
    
    func handleSaveProfile() {

        if self.profileSaveType == ProfileSaveType.profile {
            
            
        } else if self.profileSaveType == ProfileSaveType.color {
            
            //Close color window change button to original label
            
        }
    }
    
    func handleCancelProfile() {
        
        self.saveProfileButton.isHidden = true
        self.editProfileButton.isHidden = false
        self.editFanpageButton.isHidden = false
        
        self.editBackImageView.isHidden = true
        self.editAvatarImageView.isHidden = true
        self.editColorView.isHidden = true
        self.editBioView.isHidden = true
        
    }
    
    func handleEditFanpage() {
        
        //Call branch add code here
        
    }
    
    func handleChangeBackgoundImage(sender : UIButton) {
        
        //Media Controller Here
        
    }
    
    func handleChangeAvatarImage(sender : UIButton) {
        
        //Media Controller Here
        
    }

    
    func handleChangeColor(sender : UIButton) {
        
        //let width = self.frame.width - 40
        //let height = self.frame.height - 40
        
        //let colorFrame = CGRect(x: 20, y: 20, width: width, height: height)
        
        let colorFrame = self.dataView.frame
        
        let colorPickerViewController = ColorPickerViewController(frame: colorFrame)
        colorPickerViewController.cornerRadius = 20
        
        colorPickerViewController.colorPickerView.delegate = self
        
        self.addSubview(colorPickerViewController)
        
        self.saveProfileButton.setTitle("Save Color", for: .normal)
        
        self.profileSaveType = ProfileSaveType.color
        
    }
    
    // MARK: - ColorPickerViewDelegate
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        
        //self.selectedColorView.backgroundColor = colorPickerView.colors[indexPath.item]
        
        self.profileView.backgroundColor = colorPickerView.colors[indexPath.item]
        
        self.sonProfileImageView.borderColor = colorPickerView.colors[indexPath.item]
        
    }
    
    // MARK: - ColorPickerViewDelegateFlowLayout
    
    //func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //    return CGSize(width: 48, height: 48)
    //}
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    
    func handleChangeBio(sender : UIButton) {
        
        print("changed")
        
    }
    
    /*func handleChangeSlogan(sender : UIButton) {
        
        let alertController = UIAlertController(title: "Slogan ", message: "Enter your slogan", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let bio = alertController.textFields?[0].text
            
            self.bioLabel.text = bio
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "New slogan here"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }*/

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }

    func getProfileVideos()
    {
        
        self.activityIndicatorView?.startAnimating()
        
        let queryvideos = PFQuery(className:"Videos")      

        if let userId = PFUser.current()?.objectId {

            print(userId)
            
            queryvideos.whereKey("posterId", equalTo: userId)    
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
                            video.ytb_like_count            = qvideoinfo["ytb_like_count"] as! Int
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
        
        if self.editProfile {
        
            if videosGamves[indexPath.row].checked {
                
                cellVideo.checkView.isHidden = false
            
            } else {
                
                cellVideo.checkView.isHidden = true
            }
            
        } else {
            
            cellVideo.checkView.isHidden = true
        }
        
        cellVideo.videoName.text = videosGamves[indexPath.row].title
        
        let published = String(describing: videosGamves[indexPath.row].published)
        
        let shortDate = published.components(separatedBy: " at ")
        
        cellVideo.videoDatePublish.text = shortDate[0] 
        
        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize()      
       
        let height = (self.frame.width - 16 - 16) * 9 / 16
           
        size = CGSize(width: self.frame.width, height: height + 16 + 88)
        
        
        return size //CGSize(width: view.frame.width, height: height + 16 + 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing = CGFloat()        
        spacing = 0       
        return spacing
        
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
        if !self.editProfile {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Global.notificationKeyCloseVideo), object: self)

            let videoLauncher = VideoLauncher()
            
            let video = videosGamves[indexPath.row]
        
            videoLauncher.showVideoPlayer(videoGamves: video)
            
        } else {
            
            
            let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: cellVideoCollectionId, for: indexPath) as! VideoCollectionViewCell
            
            if videosGamves[indexPath.row].checked {
            
                videosGamves[indexPath.row].checked = false
                
            } else {
                
                videosGamves[indexPath.row].checked = true
            }
            
            self.collectionView.reloadData()
            
        }
    }
}



class ColorPickerViewController: UIView, ColorPickerViewDelegateFlowLayout {
    
    let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gamvesBackgoundColor
        return view
    }()
    
    let colorPickerView: ColorPickerView = {
        let view = ColorPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
       
        // Setup colorPickerView
        //colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.style = .circle
        colorPickerView.selectionStyle = .check
        colorPickerView.isSelectedColorTappable = false
        colorPickerView.preselectedIndex = colorPickerView.colors.indices.first
        
        self.addSubview(self.backgroundView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.backgroundView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.backgroundView)
        
        self.backgroundView.addSubview(self.colorPickerView)
        self.backgroundView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.colorPickerView)
        self.backgroundView.addConstraintsWithFormat("V:|[v0]|", views: self.colorPickerView)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}








