//
//  WelcomeViewController.swift
//  gamves
//
//  Created by XCodeClub on 2018-08-21.
//

import UIKit
import Parse
import NVActivityIndicatorView

class WelcomeViewController: UIViewController, 
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout {

    var homeController: HomeController?    

    var welcomes = [GamvesWelcome]()

    var welcomeIdentifier = "Cell"

    var activityView: NVActivityIndicatorView!

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.collectionView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView.register(WelcomeCollectionViewCell.self, forCellWithReuseIdentifier: welcomeIdentifier)

        // Do any additional setup after loading the view.

        self.activityView = Global.setActivityIndicator(container: self.view, type: Int(NVActivityIndicatorType.ballPulse.hashValue), color: UIColor.gray)        

        self.fetchWelcomes()
    }

    
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        let count = self.welcomes.count
        
        return count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize()      
       
        let height = (self.view.frame.width) * 9 / 16
           
        size = CGSize(width: self.view.frame.width, height: 250) //height: height + 16 + 88)      
        
        return size  
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.welcomeIdentifier, for: indexPath) as! WelcomeCollectionViewCell
            
        cell.thumbnailImageView.image = self.welcomes[indexPath.row].thumbnail
        
        cell.welcomeTitleLabel.text = self.welcomes[indexPath.row].title
        
        cell.welcomeDescLabel.text = self.welcomes[indexPath.row].description

        let recognizer = UITapGestureRecognizer(target: self, action:#selector(handleViewWelcome(recognizer:)))
        
        cell.rowView.tag = indexPath.row

        cell.rowView.addGestureRecognizer(recognizer)

        return cell
     
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    @objc func handleViewWelcome(recognizer:UITapGestureRecognizer) {


    }
    
    func fetchWelcomes()
    {
    
        self.activityView.startAnimating()

         let queryWelcome = PFQuery(className:"Welcomes")
        queryWelcome.findObjectsInBackground { (welcomesPF, error) in
            
            if error == nil
            {
                if let welcomesPF = welcomesPF
                {
                    
                    let welcomeCount = welcomesPF.count
                    if welcomeCount > 0
                    {

                        var count = 0
                        
                        for welcomePF in welcomesPF {

                            let welcome = GamvesWelcome()

                            welcome.objectId = welcomePF.objectId as! String

                            welcome.description = welcomePF["description"] as! String

                            welcome.description = welcomePF["description"] as! String
                            welcome.title = welcomePF["title"] as! String

                            let thumbnail = welcomePF["thumbnail"] as! PFFileObject

                            thumbnail.getDataInBackground(block: { (imageThumbnail, error) in

                                if error == nil {

                                    if let imageAvatarData = imageThumbnail {

                                        welcome.thumbnail = UIImage(data:imageAvatarData)     

                                        self.welcomes.append(welcome)

                                        if (welcomeCount - 1) == count {

                                            self.collectionView.reloadData()

                                            self.activityView.stopAnimating()
                                            
                                        }

                                        count = count + 1

                                    }
                                }
                            })
                            
                        }
                        
                        
                    } else
                    {
                        self.activityView.stopAnimating()
                    }
                }
            }
        }
    
    }

} 

