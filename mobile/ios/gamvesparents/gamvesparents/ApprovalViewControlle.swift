//
//  AddChatViewController.swift
//  gamves
//
//  Created by Jose Vigil on 10/13/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import GameKit
import Floaty
import PopupDialog

class ApprovalViewControlle: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var homeViewController:HomeViewController?
    
    //var gamvesUsers = [GamvesParseUser]()
    
    var isGroup = Bool()
    
    var popUp:PopupDialog?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellId = "contactCellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationItem.titleView = Global.setTitle(title: "Select friend or family", subtitle: "                          ")
        
        //self.navigationItem.title = "Select contact"    
        
        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
    
        self.collectionView.register(ContactCell.self, forCellWithReuseIdentifier: cellId)
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let countItems = Global.approvals.count
        print(countItems)
        return countItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ContactCell
        
        let index = indexPath.item
        let approval:Approvals = Global.approvals[index]
        
        cell.contact?.name = approval.videoName
        cell.contact?.avatar = approval.thumbnail!
        
        let checked = approval.approved
        
        if checked
        {
            cell.checkLabel.isHidden = false
        } else
        {
            cell.checkLabel.isHidden = true
        }

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
        let approval:Approvals = Global.approvals[indexPath.item]
   
        if self.homeViewController != nil
        {
            
            var video = VideoGamves()
            
            video = Global.chatVideos[approval.videoId]!
            
            let videoLauncher = VideoLauncher()
            
            videoLauncher.showVideoPlayer(videoGamves: video)         
            
        }
       
    }
    
    //func randomBetween(min: Int, max: Int) -> Int {
    //    return GKRandomSource.sharedRandom().nextInt(upperBound: max - min) + min
    //}
    
    func findChatWithUser(user:PFUser)
    {
        
        let queryChatFeed = PFQuery(className:"ChatFeed")
    
        queryChatFeed.whereKey("participants", equalTo: PFUser.current())
        queryChatFeed.whereKey("participants", equalTo: user)
        
        let innerQuery = PFQuery(className: "ChatFeed")
        innerQuery.whereKey("counter", equalTo: 2)  // exactly two users
        innerQuery.whereKey("users", equalTo: PFUser.current()) // at least user1 is there
        
        let query = PFQuery(className: "ChatFeed")
        query.whereKey("objectId", matchesQuery: innerQuery) // exactly two users including user1
        query.whereKey("users", equalTo: user) // select groups which also have user2

        query.findObjectsInBackground { (chatFeeds, error) in
            
            if error != nil
            {
                print("error")
                
            } else {
                
                if let chatFeeds = chatFeeds
                {
                    
                    let chatsAmount = chatFeeds.count
                    var chatId = Int()
                    
                    if chatsAmount>0
                    {
                        
                        print(chatsAmount)
                        
                        var total = Int()
                        total = chatsAmount - 1
                        var i = 0
                        
                        for chatFeed in chatFeeds
                        {
                        
                            let usersRealtion = chatFeed["participants"] as! PFRelation
                            
                            let usersQuery = usersRealtion.query()
                        }
                        
                    } else
                    {
                        
                        chatId = Global.getRandomInt() //self.randomBetween(min:100000000, max:1000000000)
                        
                    }
                    
                   
                }
            }
        }
    }

}
