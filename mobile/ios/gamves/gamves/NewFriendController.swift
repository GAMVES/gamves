//
//  NewFriendController.swift
//  gamves
//
//  Created by Jose Vigil on 2018-07-09.
//

import UIKit
import NVActivityIndicatorView
import Parse

class NewFriendController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UITableViewDataSource, 
    UITableViewDelegate
 {   

    var homeController: HomeController?

    
    var selectedUsers = [GamvesUser]()
    
    var activityIndicatorView:NVActivityIndicatorView?

    let info: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Select the people you may know below and add them as friends"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.textAlignment = .center
        label.backgroundColor = UIColor.gamvesColor
        return label
    }()

    let friendsSelected: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Friends selected"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.gambesDarkColor
        return label
    }()    
   
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.gamvesBlackColor
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()


    let friendsAvailable: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Friends list"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.gambesDarkColor
        label.textAlignment = .center
        return label
    }()

    lazy var tableView: UITableView = {
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tv = UITableView(frame: rect)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.green
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    var addButton: UIButton = {
        let button = UIButton()        
        button.translatesAutoresizingMaskIntoConstraints = false        
        button.isUserInteractionEnabled = true
        button.setTitle("Invite friends", for: UIControlState())
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        button.layer.cornerRadius = 5              
        button.backgroundColor = UIColor.gamvesBlackColor
        return button
    }()
    
    let cellIdCollectionView = "friendsCellIdCollectionView"
    let cellIdTableView = "friendsCellIdTableView"
    let sectionHeaderId = "friendSectionHeader"

    var allUsers = Dictionary<String, GamvesUser>()
    var schools = Dictionary<String, GamvesSchools>()
    var countUsersInSchool = Dictionary<String, Int>()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ADD FRIENDS"

        self.view.backgroundColor = UIColor.gamvesColor

        self.view.addSubview(self.info)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.info)        

        self.view.addSubview(self.friendsSelected)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.friendsSelected)

        self.view.addSubview(self.collectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
                
        self.view.addSubview(self.friendsAvailable)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.friendsAvailable)
        
        self.view.addSubview(self.tableView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.tableView)
        
        self.view.addSubview(self.addButton)
        self.view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.addButton)     

        self.view.addConstraintsWithFormat("V:|[v0(80)][v1(40)][v2(150)][v3(40)][v4][v5(60)]-10-|", views: 
            self.info,
            self.friendsSelected,
            self.collectionView, 
            self.friendsAvailable,
            self.tableView,
            self.addButton)        

        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)

        self.tableView.register(FriendsTableViewCell.self, forCellReuseIdentifier: self.cellIdTableView)        
        
        self.collectionView.register(CatFanSelectorViewCell.self, forCellWithReuseIdentifier: cellIdCollectionView)

        self.activityIndicatorView?.startAnimating()

        Global.fetchUsers(completionHandler: { (resutl) in

            if resutl {

                let ukeys = Array(Global.gamvesAllUsers)        
               
                for key in ukeys {

                    let gamvesUser = Global.gamvesAllUsers[key.key]

                    let schoolId:String = gamvesUser!.schoolId                  

                    //Not friend filter

                    if  Global.friends[(gamvesUser?.userId)!] == nil {

                        self.allUsers[schoolId] = gamvesUser

                        let current = self.countUsersInSchool[schoolId]

                    let next = current! + 1

                        self.countUsersInSchool[schoolId] = next
                   }   
                }
              
                DispatchQueue.main.async {

                    self.tableView.reloadData()
                    self.activityIndicatorView?.stopAnimating()

                }
            }
        })

        self.disableAddButton()

        self.tableView.register(AddFeedSectionHeader.self, forHeaderFooterViewReuseIdentifier: self.sectionHeaderId)

    }   

    
    override func viewWillAppear(_ animated: Bool) {
        
        if Global.gamvesAllUsers.count > 0 {
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        if self.selectedUsers.count > 0 {
            
            self.selectedUsers.removeAll()
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }

        self.disableAddButton()
    }   

    override func viewWillDisappear(_ animated: Bool) {

        for user in self.selectedUsers {

            Global.gamvesAllUsers[user.userId]?.isChecked = false
        }

    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.selectedUsers.count
        print(count)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: 130, height: 130)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdCollectionView, for: indexPath) as! CatFanSelectorViewCell        
        
        let index = indexPath.item
        let user:GamvesUser = self.selectedUsers[index]

        cell.avatarImage.image = user.avatar
        cell.nameLabel.text = user.name       
   
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("index : \(indexPath)")
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        print("index : \(indexPath)")
        
        //let cell = self.collectionView.cellForItem(at: indexPath) as! CatFanSelectorViewCell
        
    }

    ////////////////
    // TABLE VIEW //
    //////////////

    func numberOfSections(in tableView: UITableView) -> Int {
        let count = Global.schools.count
        print(count)
        return count
    }   
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let skeys = Array(Global.schools)        
        let schoolId = skeys[section].key

        let count = self.countUsersInSchool[schoolId]

        return count!
    } 

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()

        height = 100

        return height    
    }         


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.sectionHeaderId) as? AddFeedSectionHeader else {
            return nil
        }

        //header.customLabel.text = "Section \(section + 1)"

        let skeys = Array(Global.schools)        
        let schoolId = skeys[section].key

        let school = Global.schools[schoolId]

        header.schoolIconImageView.image = school?.icon
        
        header.nameLabel.text = school?.schoolName
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdTableView, for: indexPath) as! FriendsTableViewCell

        let skeys = Array(Global.schools)        
        let schoolId = skeys[indexPath.section]

        let user:GamvesUser =   self.allUsers[schoolId.key]!

        cell.nameLabel.text = user.name
        print(user.name)
        cell.profileImageView.image = user.avatar            
            
        if user.isChecked
        {
            cell.checkLabel.isHidden = false
            
        } else
        {
            cell.checkLabel.isHidden = true
            
        }

        return cell 
    } 

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {  
        
        print(indexPath.row)        

        //let user = Global.gamvesAllUsers[indexPath.row] as GamvesUser

        let skeys = Array(Global.schools)        
        let schoolId = skeys[indexPath.section]

        let user:GamvesUser = self.allUsers[schoolId.key]!

        let checked = user.isChecked
            
        if !checked
        {
            user.isChecked  = true

            if !self.selectedUsers.contains(where: { $0.name == user.name }) {
            
                self.selectedUsers.append(user) 
            }

            self.enableAddButton()
            
        } else
        {
            user.isChecked = false

            let indexOfUser = selectedUsers.index{$0 === user}
            
            print(indexOfUser)
    
            self.selectedUsers.remove(at: indexOfUser!)

            self.disableAddButton()
        }        

        DispatchQueue.main.async {

            self.collectionView.reloadData()

            self.tableView.reloadData()

        }        
        
    }     

    func enableAddButton() {

        self.addButton.isEnabled = true 
        self.addButton.alpha = 1
    }

    func disableAddButton() {

        self.addButton.isEnabled = false
        self.addButton.alpha = 0.4
    }       


    func handleAdd() {  

        self.activityIndicatorView?.startAnimating()  

        let countFriendsApproval = self.selectedUsers.count

        var count = 0

        for user in self.selectedUsers {

            let friendsApproval: PFObject = PFObject(className: "FriendsApproval")

            if let userId = PFUser.current()?.objectId {
                friendsApproval["posterId"] = userId    
            }       

            let name = Global.userDictionary[user.userId]?.firstName

            let familyId = Global.gamvesFamily.objectId

            print(familyId)

            friendsApproval["familyId"] = familyId 

            friendsApproval["approved"] = 0
            
            friendsApproval["friendId"] = user.userId

            friendsApproval["type"] = 1          
            
            friendsApproval.saveInBackground { (resutl, error) in
                
                if error == nil {

                    if count == (countFriendsApproval - 1) {
                    
                        self.activityIndicatorView?.stopAnimating()
                        
                        let title = "Friend Approval Requested!"
                        let message = "The invitations for becoming new friends have been sent to your parents for appoval. Thanks for submitting!"
                        
                        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in                                                 
                            
                            DispatchQueue.main.async {

                                //let indexOfUser = Global.gamvesAllUsers.index{$0 === user}

                                Global.gamvesAllUsers[user.userId]?.isChecked = true
                                
                                //Global.gamvesAllUsers[indexOfUser!].isChecked = false

                                self.tableView.reloadData()
                            }            

                            self.navigationController?.popToRootViewController(animated: true)
                            self.homeController?.clearNewVideo()
                            
                        }))
                        
                        self.present(alert, animated: true)

                    }

                    count = count + 1 
                }
            }
        }
    }       
}
