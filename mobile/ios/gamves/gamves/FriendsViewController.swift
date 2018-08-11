//
//  FriendsViewController.swift
//  gamves
//
//  Created by XCodeClub on 2018-07-23.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import GameKit
import Floaty
import PopupDialog
import NVActivityIndicatorView

protocol FriendApprovalProtocol {
    func closedRefresh()
    func update(name:String)
    func usersAdded(friendName:String, posterName:String)
}

class FriendsViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
FriendApprovalProtocol
{
    
    var homeController:HomeController!
    
    var activityIndicatorView:NVActivityIndicatorView?
    
    var isGroup = Bool()
    
    var popUp:PopupDialog?
    
    var publicProfileLauncher = PublicProfileLauncher()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let friendCellId = "friendCellId"
    
    let emptyCellId = "emptyCellId"
    
    let sectionHeaderId = "friendSectionHeader"
    
    let friendCell = "friendCell"
    
    var familyId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Friends and Users"
        
        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
        
        self.collectionView.register(FriendCell.self, forCellWithReuseIdentifier: friendCellId)
        
        self.collectionView.register(FriendEmptyCollectionViewCell.self, forCellWithReuseIdentifier: emptyCellId)
        
        self.collectionView.register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: friendCell)
        
        self.collectionView.register(FriendSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: sectionHeaderId)
        
        self.collectionView.reloadData()
        
        self.familyId = Global.gamvesFamily.objectId
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func closedRefresh() {
        
        self.activityIndicatorView?.startAnimating()

        if let userId = PFUser.current()?.objectId {
        
            Global.friends = Dictionary<String, GamvesUser>()

            Global.getFriendsAmount(posterId: userId, completionHandler: { ( countFriends ) -> () in                

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.activityIndicatorView?.stopAnimating()
                }
            })       
       }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! FriendSectionHeader
        
        sectionHeaderView.backgroundColor = UIColor.gamvesBackgoundColor
        
        if indexPath.section == 0 {
            
            let image  = UIImage(named: "friend")
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "Friends"
            
        } else if indexPath.section == 1 {
            
            let image  = UIImage(named: "user_list")
            sectionHeaderView.iconImageView.image = image
            
            sectionHeaderView.nameLabel.text = "Users list"
        }
        
        return sectionHeaderView
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var countItems = Int()
        
        if section == 0 {
            
            countItems = Global.friends.count
            
        } else if section == 1 {
            
            countItems = Global.allUsers.count
            
            if countItems == 0
            {
                countItems = 1
                
            }
        }
        
        print(countItems)
        return countItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 100)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        let index:Int = indexPath.item
        
        if indexPath.section == 0 {
            
            //let cella = self.collectionView.dequeueReusableCell(withReuseIdentifier: friendCellId, for: indexPath) as! FriendCollectionViewCell

            let cella = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.friendCell, for: indexPath) as! FriendCollectionViewCell
            
            let keysArray = Array(Global.friends.keys)
            
            print(keysArray)
            
            let realIndex = index - 1
            
            let keyIndex = keysArray[index] as String
            let friend:GamvesUser = Global.friends[keyIndex]!

            cella.profileImageView.image    = friend.avatar
            cella.nameLabel.text            = friend.name
            cella.schoolLabel.text          = friend.school.schoolName
            cella.gradeLabel.text           = friend.level.description 
            
            /*if friends.approved == 0 || friends.approved == 2 || friends.approved == -1 { // NOT
                
                if friends.approved == -1 {
                    
                    cella.statusLabel.text = "REJECTED"
                    
                    cella.setCheckLabel(color: UIColor.red, symbol: "-")
                    
                } else  {
                    
                    cella.statusLabel.text = "NOT APPROVED"
                    
                    cella.setCheckLabel(color: UIColor.gamvesYellowColor, symbol: "+" )
                }
                
                cella.checkLabel.isHidden = false
                
            } else if friends.approved == 1 { //APPROVED
                
                cella.statusLabel.text = "APPROVED"
                cella.checkLabel.isHidden = true
                
                cella.setCheckLabel(color: UIColor.gamvesGreenColor, symbol: "✓" )
            }
            
            cella.profileImageView.image = friends.user.avatar
            
            if friends.type == 1 {
                
                cella.typeLabel.text = "INVITED\nFRIEND"
                cella.typeLabel.backgroundColor = UIColor.gamvesLightBlueColor
                
            } else if friends.type == 2 {
                
                cella.typeLabel.text = "FRIEND\nINVITATION"
                cella.typeLabel.backgroundColor = UIColor.gamvesTurquezeColor
            }*/
            
            return cella
            
        } else if indexPath.section == 1 {
            
            let countItems = Global.allUsers.count
            
            if countItems == 0 {
                
                let celle = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.emptyCellId, for: indexPath) as! FriendEmptyCollectionViewCell
                
                celle.messageLabel.text = "No friends yet, invite!"
                
                return celle
                
            } else if countItems > 0 {
                
                let cellf = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.friendCell, for: indexPath) as! FriendCollectionViewCell
                
                let keysFriendsArray = Array(Global.allUsers.keys)
                
                let keyIndexFriend = keysFriendsArray[index] as String
                let friend:GamvesUser = Global.allUsers[keyIndexFriend]! as GamvesUser
                
                cellf.profileImageView.image    = friend.avatar
                cellf.nameLabel.text            = friend.name
                cellf.schoolLabel.text          = friend.school.schoolName
                cellf.gradeLabel.text           = friend.level.description
                
                return cellf
                
            }
            
            return cell
            
        }
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        let index:Int = indexPath.item
        
        if section == 0 {
            
            let keysArray = Array(Global.friends.keys)
            let keyIndex = keysArray[index]
            let friend:GamvesUser = Global.friends[keyIndex]!
            
            self.publicProfileLauncher = PublicProfileLauncher()
            //publicProfileLauncher.delegate = self
            
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            
            publicProfileLauncher.showProfileView(gamvesUser: friend)
                
            
        } else if section == 1 {
            
            let keysFriendArray = Array(Global.allUsers.keys)
            let keyFriendIndex = keysFriendArray[index]
            let friend:GamvesUser = Global.allUsers[keyFriendIndex]!
            
            print("user: \(friend.name)")
            
        }
        
        
        
    }
    
    func update(name:String)  {
        
        let title   = "Friend request sent to \(name) parents"
        let message = "An invitations to friend \(name) has been sent to the parents for appoval"
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            
            self.closedRefresh()
            
        }))
        
        self.present(alert, animated: true)
        
        
    }
    
    func usersAdded(friendName:String, posterName:String)   {
        
        let title   = "Congratulations!"
        let message = "\(friendName) and \(friendName) are now friends"
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            
            self.closedRefresh()
            
        }))
        
        self.present(alert, animated: true)
        
        
    }
    
    
}

