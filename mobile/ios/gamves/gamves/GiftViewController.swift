//
//  GiftViewController.swift
//  gamves
//
//  Created by XCodeClub on 2018-08-01.
//

import UIKit
import NVActivityIndicatorView
import Parse

class GiftViewController: UIViewController, 
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout   {

	var homeController: HomeController?    

	var activityView: NVActivityIndicatorView!

	var gifts = [GamvesGift]()

	let titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false          
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select the gift you want"
        label.textColor = UIColor.gray                
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center        
        return label
    }()

    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        return view
    }()

	lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)        
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    var cellGiftCollectionId = "cellGiftCollectionId"


    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.titleView)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.collectionView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.titleView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)

        self.view.addConstraintsWithFormat("V:|[v0(240)][v1(1)][v2]|", views: 
            self.titleView, 
            self.lineView, 
            self.collectionView)   

		self.lineView.addSubview(self.titleLabel)
		self.lineView.addConstraintsWithFormat("H:|[v0]|", views: self.titleLabel)
        self.lineView.addConstraintsWithFormat("V:|[v0]|", views: self.titleLabel)       

        self.collectionView.register(GiftViewCell.self, forCellWithReuseIdentifier: self.cellGiftCollectionId)       

        self.activityView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)

        self.fetchGifts()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        count = self.gifts.count      
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
             
        let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: cellGiftCollectionId, for: indexPath) as! GiftViewCell
        
        cellVideo.thumbnailImageView.image = self.gifts[indexPath.row].thumbnail                                
        
        if self.gifts[indexPath.row].isChecked {
            
            cellVideo.checkView.isHidden = false
        
        } else {
            
            cellVideo.checkView.isHidden = true
        }            
        
        cellVideo.titleLabel.text = self.gifts[indexPath.row].title
        cellVideo.descriptionTextView.text = self.gifts[indexPath.row].description

        cellVideo.priceLabel.text = "\(self.gifts[indexPath.row].price)"
        cellVideo.pointsLabel.text = "\(self.gifts[indexPath.row].points)"        
        
        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize()      
       
        let height = (self.view.frame.width - 16 - 16) * 9 / 16
           
        size = CGSize(width: self.view.frame.width, height: height + 16 + 88)      
        
        return size 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing = CGFloat()        
        spacing = 0       
        return spacing
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /*if !self.editProfile || self.profileSaveType == ProfileSaveType.chat {
            
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
            
        }*/
    }

    func fetchGifts()
    {
    
        self.activityView.startAnimating()

        var queryGift = PFQuery(className: "Gifts")       
        
        queryGift.findObjectsInBackground(block: { (giftsPF, error) in
            
            if error == nil
            {
                
                let giftCount = giftsPF?.count
                if giftCount! > 0
                {

                    var count = 0
                    
                    for giftPF in giftsPF! {
                   
                        let gift = GamvesGift()

                        gift.objectId = (giftPF.objectId as? String)!

                        gift.description = (giftPF["description"] as? String!)!
                        gift.title = (giftPF["title"] as? String!)!

                        gift.price = (giftPF["price"] as? Int!)!
                        gift.points = (giftPF["points"] as? Int!)!

                        if giftPF["subscriptors"] != nil {

	                        if let userId = PFUser.current()?.objectId {

	                            let subscriptors:[String] = (giftPF["subscriptors"] as? [String])!

	        					if subscriptors.contains(userId) {

	        						gift.isChecked = true

	        					}      				
	        				}
        				} else {

        					gift.isChecked = false

        				}

                        let thumbnail = giftPF["thumbnail"] as! PFFile

                        thumbnail.getDataInBackground(block: { (imageThumbnail, error) in
                
                            if error == nil {

                                if let imageAvatarData = imageThumbnail {

                                    gift.thumbnail = UIImage(data:imageAvatarData)     

                                    self.gifts.append(gift)

                                    if (giftCount! - 1) == count {

                                    	self.collectionView.reloadData()

                                    	count = count + 1
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

}
