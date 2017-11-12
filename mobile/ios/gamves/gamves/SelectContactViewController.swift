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

class SelectContactViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var gamvesUsers = [GamvesParseUser]()
    
    var homeController: HomeController?
    
    var popUp:PopupDialog?
    
    var isGroup = Bool()
    
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

        self.navigationItem.titleView = Global.setTitle(title: "Select friend or family", subtitle: "                          ")
        
        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
    
        self.collectionView.register(ContactCell.self, forCellWithReuseIdentifier: cellId)
        
        if isGroup
        {
            let floaty = Floaty()
            floaty.buttonImage =  UIImage(named: "arrow_next_white")!
            self.view.addSubview(floaty)
            floaty.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveNext)))
        }
        
        self.fetchUsers()
    }
    
    func moveNext()
    {
        var selectedUsers:[GamvesParseUser] = self.countChecked()
        if selectedUsers.count > 1
        {
            homeController?.selectGroupName(users: selectedUsers)
        } else
        {
            let params = ["title":"Alert", "message":"Groups can only be created with more than two members including you."]
            popUp = Global.buildPopup(viewController: self, params: params)
            
        }
    
    }
    
    func countChecked() -> [GamvesParseUser]
    {
        var tempUsers = [GamvesParseUser]()
        
        for user in gamvesUsers
        {
            if user.isChecked
            {
                tempUsers.append(user)
            }
        }
        return tempUsers
    }
    
    
    func fetchUsers()
    {
        
        let userQuery = PFQuery(className:"_User")
        userQuery.order(byAscending: "updatedAt")
        userQuery.whereKey("objectId", notEqualTo: PFUser.current()?.objectId)
        userQuery.findObjectsInBackground(block: { (users, error) in
            
            if error == nil
            {
                let usersCount =  users?.count
                var count = 0
                
                print(usersCount)
                
                for user in users!
                {
                    let gamvesUser = GamvesParseUser()
                    gamvesUser.name = user["Name"] as! String
                    
                    print(gamvesUser.name)
                    
                    gamvesUser.userId = user.objectId!
                    gamvesUser.userName = user["username"] as! String
                    if user["status"] != nil
                    {
                        gamvesUser.status = user["status"] as! String
                    }
                    gamvesUser.gamvesUser = user as! PFUser
                    
                    let userId = user.objectId as! String
                    
                    if PFUser.current()?.objectId == userId
                    {
                        gamvesUser.isSender = true
                    }
                    
                    let picture = user["pictureSmall"] as! PFFile
                    picture.getDataInBackground(block: { (data, error) in
                        
                        let image = UIImage(data: data!)
                        gamvesUser.avatar = image!
                        gamvesUser.isAvatarDownloaded = true
                        gamvesUser.isAvatarQuened = false
                        
                        self.gamvesUsers.append(gamvesUser)
                        
                        if (usersCount! - 1) == count
                        {
                            self.collectionView.reloadData()
                        }
                        
                        count = count + 1

                    })
                }
            }
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        let countItems = Int(self.gamvesUsers.count)
        print(countItems)
        return countItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ContactCell
        
        let index = indexPath.item
        let contact:GamvesParseUser = self.gamvesUsers[index]
        
        cell.contact = contact
        cell.contact?.name = contact.name
        if contact.status != nil
        {
            cell.contact?.status = contact.status
        }
        cell.contact?.avatar = contact.avatar
        
        let checked = gamvesUsers[indexPath.item].isChecked
        
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
        
        if !isGroup
        {
    
            let contact = self.gamvesUsers[indexPath.item] as GamvesParseUser
            
            var chatId = Int64()
            
            if contact.chatId > 0
            {
                chatId = contact.chatId
            } else
            {
                chatId = Global.getRandomInt64() // self.randomBetween(min:10000000, max:1000000000)
            }
        
            if self.homeController != nil
            {
                self.homeController?.openChat(room: contact.name, chatId: chatId, users: [contact])
            }
            
        } else
        {
            
            let checked = gamvesUsers[indexPath.row].isChecked
            
            if !checked
            {
                gamvesUsers[indexPath.item].isChecked  = true
                
            } else
            {
                gamvesUsers[indexPath.item].isChecked = false
                
            }
            
            self.collectionView.reloadItems(at: [indexPath])
        
        }
    
    }
    
    //func randomBetween(min: Int64, max: Int64) -> Int {
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
                    var chatId = Int64()
                    
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
                        
                        chatId = Global.getRandomInt64() //self.randomBetween(min:100000000, max:1000000000)
                        
                    }
                    
                   
                }
            }
        }
    }

}
