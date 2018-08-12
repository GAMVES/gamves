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
        label.textColor = UIColor.gamvesTurquezeDarkColor                
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center   
        label.numberOfLines = 2     
        return label
    }()

    let explanationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Click on one gift you want to subscribe and start counting points"
        label.textColor = UIColor.gamvesTurquezeDarkColor                
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 2 
        label.textAlignment = .center        
        return label
    }()

    //- Scores

    let scoresView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    }()

    let yourScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Points"
        label.textColor = UIColor.black 
        //label.backgroundColor = UIColor.green               
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center           
        return label
    }()

    let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false    
        label.textColor = UIColor.cyan  
        //label.backgroundColor = UIColor.cyan              
        label.font = UIFont.boldSystemFont(ofSize: 30)
        //label.text = "200"
        label.textAlignment = .center           
        return label
    }()    

    let yourMissingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Missing"
        label.textColor = UIColor.black   
        //label.backgroundColor = UIColor.blue             
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center           
        return label
    }()

    var missingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false       
        label.textColor = UIColor.white                
        label.font = UIFont.boldSystemFont(ofSize: 30)
        //label.text = "120"
        //label.backgroundColor = UIColor.red
        label.textAlignment = .center             
        return label
    }()

    //-- Line

    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gamvesTurquezeColor
        return view
    }()

	lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        //layout.minimumInteritemSpacing = 30
        layout.minimumLineSpacing = 1        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)   
        cv.backgroundColor = UIColor.gamvesTurquezeColor     
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    var cellGiftCollectionId = "cellGiftCollectionId"

    var points = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.gamvesTurquezeColor

        self.view.addSubview(self.titleView)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.collectionView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.titleView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)

        self.view.addConstraintsWithFormat("V:|[v0(150)][v1(5)][v2]|", views: 
            self.titleView, 
            self.lineView, 
            self.collectionView)   

		self.titleView.addSubview(self.titleLabel)
		self.titleView.addSubview(self.explanationLabel)
		self.titleView.addSubview(self.scoresView)		
		
		self.titleView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.titleLabel)
		self.titleView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.explanationLabel)
		self.titleView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.scoresView)

        self.titleView.addConstraintsWithFormat("V:|-5-[v0(40)][v1(40)][v2]|", views: 
        	self.titleLabel, 
        	self.explanationLabel,
        	self.scoresView)

		self.scoresView.addSubview(self.yourScoreLabel)
		self.scoresView.addSubview(self.scoreLabel)
		self.scoresView.addSubview(self.yourMissingLabel)
		self.scoresView.addSubview(self.missingLabel)

		self.scoresView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.yourScoreLabel)
		self.scoresView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.scoreLabel)
		self.scoresView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.yourMissingLabel)
		self.scoresView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.missingLabel)

		let width = self.view.frame.width

		let padding = ( width - 340 ) / 3

		let paddingMetrics = ["padding":padding]

		self.scoresView.addConstraintsWithFormat("H:|-10-[v0(70)][v1(100)]-10-[v2(70)][v3(100)]-10-|", views: 
        	self.yourScoreLabel, 
        	self.scoreLabel,
        	self.yourMissingLabel,
        	self.missingLabel,
        	metrics: paddingMetrics)

        self.collectionView.register(GiftViewCell.self, forCellWithReuseIdentifier: self.cellGiftCollectionId)       

        self.activityView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)        

        Global.queryPoints(completionHandler: { ( result:Int ) -> () in 

            self.points = result

            self.scoreLabel.text = "\(result)"

            self.fetchGifts()

        })

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
        cellVideo.descriptionLabel.text = self.gifts[indexPath.row].description

        cellVideo.priceLabel.text = "\(self.gifts[indexPath.row].price)"
        cellVideo.pointsLabel.text = "\(self.gifts[indexPath.row].points)"        
        
        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize()      
       
        let height = (self.view.frame.width) * 9 / 16
           
        size = CGSize(width: self.view.frame.width, height: 250) //height: height + 16 + 88)      
        
        return size  
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing = CGFloat()        
        spacing = 0       
        return spacing
    }
      
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let giftPoints = self.gifts[indexPath.row].points

        let subsRelation = self.gifts[indexPath.row].giftOBj.relation(forKey: "subscriptors")
        
          if self.gifts[indexPath.row].isChecked {
        
            self.gifts[indexPath.row].isChecked = false

            subsRelation.remove(Global.userPF)  

            self.missingLabel.text = ""   
            
        } else {
            
            self.gifts[indexPath.row].isChecked = true

            subsRelation.add(Global.userPF)  

            let missing = giftPoints - self.points                     

            self.missingLabel.text = "\(missing)"      
            
        }               

        self.gifts[indexPath.row].giftOBj.saveEventually()  

        for gift in self.gifts {

        	if gift !== self.gifts[indexPath.row] {

	    		gift.isChecked = false

                let subsLastRelation = gift.giftOBj.relation(forKey: "subscriptors")

                subsLastRelation.remove(PFUser.current()!)
	    	}
    	}
    	       
        self.collectionView.reloadData()            
    
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
                        
                        gift.giftOBj = giftPF

                        gift.objectId = (giftPF.objectId as? String)!

                        gift.description = (giftPF["description"] as? String!)!
                        gift.title = (giftPF["title"] as? String!)!

                        gift.price = (giftPF["price"] as? Int!)!
                        gift.points = (giftPF["points"] as? Int!)!

                        let relationSubscriptors = giftPF.relation(forKey: "subscriptors")

                        let queryRelation = relationSubscriptors.query()
                        queryRelation.whereKey("objectId", containedIn: [PFUser.current()?.objectId])
                        
                        queryRelation.getFirstObjectInBackground { (usersPF, error) in 

                        	if error == nil {

                        		gift.isChecked = true

                                print(self.points )

                                print(gift.points)

                                let missing = gift.points - self.points

                                self.missingLabel.text = "\(missing)"   
                        	
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

	                                    	self.activityView.stopAnimating()
	                                    	
	                                    }

										count = count + 1

	                                }
	                            }
	                        })
                        }
                    }
                    
                } else
                {
                    self.activityView.stopAnimating()
                }
                
            }
        })
    
    }

}
