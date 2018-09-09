
//  gamves
//
//  Created by XCodeClub on 2018-09-07.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse

class FanpageVideoTableCell: UITableViewCell,
UIScrollViewDelegate,
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout 
{

	 var videosGamves  = [GamvesVideo]() 

    fileprivate let cellId = "videoCellId"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }   
    
    let videoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)        
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()    
    
    func setupViews() {

        backgroundColor = UIColor.clear
        
        self.addSubview(self.videoCollectionView)
        
        self.videoCollectionView.dataSource = self
        self.videoCollectionView.delegate = self
        
        self.videoCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)       
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.videoCollectionView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.videoCollectionView)  
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if let count = appCategory?.apps?.count {
        //    return count
        //}
        
        let count = self.videosGamves.count

        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! VideoCollectionViewCell
            
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        let width = self.frame.width       

        var height = ((width - 16 - 16) * 9 / 16) + 16 + 88

        height = height * CGFloat(self.videosGamves.count)
            
       	let size = CGSize(width: width, height: height)

        return size
    }
    
   /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 14, 0, 14)
    }*/

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
		return 0
	}
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /*if let app = appCategory?.apps?[indexPath.item] {
            featuredAppsController?.showAppDetailForApp(app)
        }*/        
    }  

    @objc func handleViewProfile(recognizer:UITapGestureRecognizer) {
        
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

    
}


extension FanpageVideoTableCell {
    
   func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        if row == 0 {
            
            Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
            
        }
        
        self.videoCollectionView.delegate = dataSourceDelegate
        self.videoCollectionView.dataSource = dataSourceDelegate
        self.videoCollectionView.tag = row
        self.videoCollectionView.setContentOffset(self.videoCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        self.videoCollectionView.backgroundView?.isHidden = true        
        self.videoCollectionView.reloadData()
    }
    
    @objc func scrollAutomatically(_ timer1: Timer) {
        
        for cell in self.videoCollectionView.visibleCells {
            let indexPath: IndexPath? = self.videoCollectionView.indexPath(for: cell)
            let count = Global.categories_gamves[self.videoCollectionView.tag]?.fanpages.count
            
            if ((indexPath?.row)!  < count! - 1){
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                
                self.videoCollectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
            }
            else{
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                self.videoCollectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
            }
            
        }
    }
    
    var collectionViewOffset: CGFloat
    {
        set
        {
            self.videoCollectionView.contentOffset.y = newValue
        }
        
        get {
            return self.videoCollectionView.contentOffset.y
        }
    }
}


