//
//  FriendApprovalViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-11.
//

import UIKit
import Parse
import GameKit
//import Floaty
import PopupDialog
import NVActivityIndicatorView

protocol FriendApprovalProtocol {
    func refresh()
    func update(name:String)
    func usersAdded(friendName:String, posterName:String)
}

class FriendApprovalViewController: UIViewController,
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout,
FriendApprovalProtocol
{
    
    var activityIndicatorView:NVActivityIndicatorView?

    var homeController:HomeController?
    
    var isGroup = Bool()
    
    var popUp:PopupDialog?   

    var friendApprovalLauncher = FriendApprovalLauncher()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let approvlCellId = "approvlCellId"

    let emptyCellId = "emptyCellId"

    let sectionHeaderId = "friendSectionHeader"

    let friendCell = "friendCell"
    
    var familyId = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Friends Approvals"
        
        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
    
        self.collectionView.register(FriendApprovalCell.self, forCellWithReuseIdentifier: approvlCellId)

        self.collectionView.register(FriendEmptyCollectionViewCell.self, forCellWithReuseIdentifier: emptyCellId)
        
        self.collectionView.register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: friendCell)
      
        self.collectionView.register(FriendSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: sectionHeaderId)

        self.collectionView.reloadData()
        
        self.familyId = Global.gamvesFamily.objectId

        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)

        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: Global.notificationKeyFriendApprovalLoaded), object: nil)
        
        self.activityIndicatorView?.startAnimating()
        
        self.refresh()
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
        
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func refresh() {   

        self.activityIndicatorView?.startAnimating()    

        Global.friendApproval = Dictionary<String, FriendApproval>() 
        
        Global.getFriendsApprovasByFamilyId(familyId: self.familyId) { ( invites, invited, updated) in
            
            let userId = Global.gamvesFamily.sonsUsers[0].userId

            Global.getFriendsAmount(posterId: userId, completionHandler: { ( count ) -> () in
                
                print(count)

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

            let image  = UIImage(named: "invitation")
            sectionHeaderView.iconImageView.image = image

            sectionHeaderView.nameLabel.text = "Invitations"

        } else if indexPath.section == 1 {
        
            let image  = UIImage(named: "group")
            sectionHeaderView.iconImageView.image = image

            sectionHeaderView.nameLabel.text = "Friends list"
        }

        return sectionHeaderView

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var countItems = Int()

        if section == 0 {

            countItems = Global.friendApproval.count

        } else if section == 1 {

            countItems = Global.friends.count

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

            let cella = self.collectionView.dequeueReusableCell(withReuseIdentifier: approvlCellId, for: indexPath) as! FriendApprovalCell
                                    
            let keysArray = Array(Global.friendApproval.keys)
            
            print(keysArray)
            
            let realIndex = index - 1
            
            let keyIndex = keysArray[index] as String
            let friendApproval:FriendApproval = Global.friendApproval[keyIndex]!

            var title = String()
            
            print(friendApproval.title)

            cella.nameLabel.text = friendApproval.title    

            let type =  friendApproval.type
            let approved = friendApproval.approved
            let invite = friendApproval.invite

            if approved == 0  || approved == -1 { // NOT
                
                if friendApproval.approved == -1 {
                    
                    cella.statusLabel.text = "REJECTED"

                    cella.setCheckLabel(color: UIColor.red, symbol: "-")               
                    
                } else {
                    
                   cella.statusLabel.text = "NOT APPROVED"

                   cella.setCheckLabel(color: UIColor.gamvesYellowColor, symbol: "+" )
                }
                
                cella.checkLabel.isHidden = false
                
            } else if approved == 2 { //APPROVED
                
                cella.statusLabel.text = "APPROVED"
                cella.checkLabel.isHidden = true

                cella.setCheckLabel(color: UIColor.gamvesGreenColor, symbol: "✓" )
            
            }

            if invite {

                cella.typeIcon.image = UIImage(named: "call_sent")
                cella.typeLabel.text = "SENT" 
                cella.typeLabel.backgroundColor = UIColor.gamvesLightBlueColor

            } else {

                cella.typeIcon.image = UIImage(named: "call_received")
                cella.typeLabel.text = "RECEIVED" 
                cella.typeLabel.backgroundColor = UIColor.gamvesGreenColor

            }

            /*if type == 1 {

                if approved == 1 { //SENT
            
                    cella.statusLabel.text = "SENT"
                    cella.checkLabel.isHidden = true

                    cella.setCheckLabel(color: UIColor.gamvesGreenColor, symbol: ">" )
                
                }  

                cella.typeLabel.text = "INVITED\nFRIEND" //"INVITED\nFRIEND"
                cella.typeLabel.backgroundColor = UIColor.gamvesLightBlueColor


            } else if type == 2 {                

                cella.typeLabel.text = "FRIEND\nINVITATION"
                cella.typeLabel.backgroundColor = UIColor.gamvesTurquezeColor

            }*/               
             
            
            cella.profileImageView.image = friendApproval.user.avatar


            return cella
            


        } else if indexPath.section == 1 {

            let countItems = Global.friends.count

            if countItems == 0 {                

                let celle = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.emptyCellId, for: indexPath) as! FriendEmptyCollectionViewCell
                
                celle.messageLabel.text = "No friends yet, invite!"

                return celle

            } else if countItems > 0 {
            
                let cellf = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.friendCell, for: indexPath) as! FriendCollectionViewCell

                let keysFriendsArray = Array(Global.friends.keys)

                let keyIndexFriend = keysFriendsArray[index] as String
                let friend:GamvesUser = Global.friends[keyIndexFriend]! as GamvesUser

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
        
            let keysArray = Array(Global.friendApproval.keys)
            let keyIndex = keysArray[index]
            let friendApproval:FriendApproval = Global.friendApproval[keyIndex]!      
            
            self.friendApprovalLauncher = FriendApprovalLauncher()
            friendApprovalLauncher.delegate = self
            
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            
            friendApprovalLauncher.showUserForFriend(friendApproval: friendApproval, approved: friendApproval.approved, screenHeight: Int(screenHeight))

        } else if section == 1 {            
        
            let keysFriendArray = Array(Global.friends.keys)
            let keyFriendIndex = keysFriendArray[index]
            let friend:GamvesUser = Global.friends[keyFriendIndex]!   

            print("user: \(friend.name)")

        }        
       
    }   

    func update(name:String)  {

        let title   = "Friend request sent to \(name) parents"
        let message = "An invitations to friend \(name) has been sent to the parents for appoval"
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in                                                                             

            self.refresh()            
            
        }))
        
        self.present(alert, animated: true)

        
    }

     func usersAdded(friendName:String, posterName:String)   {

        let title   = "Congratulations!"
        let message = "\(posterName) and \(friendName) are now friends"
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in                                                                             

            self.refresh()            
            
        }))
        
        self.present(alert, animated: true)
        
    }
  

}
