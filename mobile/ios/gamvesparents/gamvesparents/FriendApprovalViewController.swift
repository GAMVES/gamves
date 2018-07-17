//
//  FriendApprovalViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 2018-07-11.
//

import UIKit
import Parse
import GameKit
import Floaty
import PopupDialog

protocol FriendApprovalProtocol {
    func closedRefresh()    
}

class FriendApprovalViewController: UIViewController,
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout,
FriendApprovalProtocol
{

     var homeViewController:HomeViewController?
    
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
    
    var familyId = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Friends Approvals"
        
        self.view.addSubview(self.collectionView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)
    
        self.collectionView.register(FriendApprovalCell.self, forCellWithReuseIdentifier: approvlCellId)
        
        self.collectionView.reloadData()
        
        self.familyId = Global.gamvesFamily.objectId
    }
    

    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func closedRefresh() {       

        Global.friendApproval = Dictionary<String, FriendApproval>() 
        
        Global.getFriendsApprovasByFamilyId(familyId: self.familyId) { ( count ) in
            
            self.collectionView.reloadData()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int { 
        return 2 
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "FriendSectionHeader", for: indexPath) as! FriendSectionHeader

        if indexPath.section == 0 {

            let image  = UIImage(named: "add_friend")
            sectionHeaderView.profileImageView.image = image

            sectionHeaderView.nameLabel.text = "INVITATIONS"

        } else if indexPath.section == 1 {
        
            let image  = UIImage(named: "group")
            sectionHeaderView.profileImageView.image = image

            sectionHeaderView.nameLabel.text = "FRIENDS"
        }

        return sectionHeaderView

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var countItems = Int()

        if section == 0 {

            countItems = Global.friendApproval.count

        } else if section == 1 {

            countItems = Global.friends.count
        }
         
        print(countItems)
        return countItems
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
            let approval:FriendApproval = Global.friendApproval[keyIndex]!  

            var title = String()

            /*if approval.type == 1 {
                //type = FriendApprovalType.YouInvite                 
            } else if approval.type == 2 {
                //type = FriendApprovalType.YouAreInvited 
            }*/

            let friendId = approval.posterId

            let friend = Global.userDictionary[friendId] as! GamvesUser

            title = friend.name
            
            cella.nameLabel.text = title
            
            if approval.approved == 0 || approval.approved == 2 || approval.approved == -1 { // NOT
                
                if approval.approved == -1 {
                    
                    cella.statusLabel.text = "REJECTED"

                    cella.setCheckLabel(color: UIColor.red, symbol: "-")               
                    
                } else  {
                    
                   cella.statusLabel.text = "NOT APPROVED"

                   cella.setCheckLabel(color: UIColor.gamvesYellowColor, symbol: "+" )
                }
                
                cella.checkLabel.isHidden = false
                
            } else if approval.approved == 1 { //APPROVED
            
                cella.statusLabel.text = "APPROVED"
                cella.checkLabel.isHidden = true

                cella.setCheckLabel(color: UIColor.gamvesGreenColor, symbol: "✓" )
            }       
            
            cella.profileImageView.image = approval.thumbnail!

            return cella
            
        } else if indexPath.section == 1 {

            let cellf = self.collectionView.dequeueReusableCell(withReuseIdentifier: approvlCellId, for: indexPath) as! FriendCollectionViewCell

            

            return cellf
            
        }

        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index:Int = indexPath.item
        
        let keysArray = Array(Global.friendApproval.keys)
        let keyIndex = keysArray[index]
        let friendApproval:FriendApproval = Global.friendApproval[keyIndex]!      
        
        self.friendApprovalLauncher = FriendApprovalLauncher()
        friendApprovalLauncher.delegate = self
        friendApprovalLauncher.showUserForFriend(friendApproval: friendApproval, approved: friendApproval.approved, screenHeight: Int(self.view.frame.height))
       
    }   

  

}
