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

     let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesGreenColor
        return view
    }()

    let info: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Select the people you may know below and add them as friends"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.textAlignment = .center
        //label.backgroundColor = UIColor.gamvesGreenColor
        return label
    }()

    let friendsSelected: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Friends selected"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.gamvesGreenDarkColor
        return label
    }()    
   
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.gamvesGreenColor
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    let friendsAvailable: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Users list"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.gamvesGreenDarkColor
        label.textAlignment = .center
        return label
    }()

    lazy var tableView: UITableView = {
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tv = UITableView(frame: rect)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.gamvesGreenColor
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesGreenColor
        return view
    }()

    var addButton: UIButton = {
        let button = UIButton()        
        button.translatesAutoresizingMaskIntoConstraints = false        
        button.isUserInteractionEnabled = true
        button.setTitle("Invite friends", for: UIControlState())
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        button.layer.cornerRadius = 5              
        button.backgroundColor = UIColor.gamvesGreenDarkColor
        return button
    }()
    
    let cellIdCollectionView = "friendsCellIdCollectionView"
    let cellIdTableView = "friendsCellIdTableView"
    let sectionHeaderId = "friendSectionHeader"

    var groupUsers = [[GamvesUser]]()
    var schoolSections = [GamvesSchools]()

    //var allUsers = Dictionary<String, GamvesUser>()
    //var schools = Dictionary<String, GamvesSchools>()
    //var countUsersInSchool = Dictionary<String, Int>()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ADD FRIENDS"
        self.view.backgroundColor = UIColor.gamvesGreenColor
    
        self.view.addSubview(self.friendsSelected)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.friendsSelected)

        self.view.addSubview(self.infoView)  
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.infoView)

        self.view.addSubview(self.collectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
                
        self.view.addSubview(self.friendsAvailable)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.friendsAvailable)
        
        self.view.addSubview(self.tableView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.tableView)

        self.view.addSubview(self.buttonView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.buttonView)          

        self.view.addConstraintsWithFormat("V:|[v0(40)][v1(150)][v2(40)][v3][v4(80)]|", views:             
            self.friendsSelected,
            self.infoView, 
            self.friendsAvailable,
            self.tableView,
            self.buttonView)  

        self.infoView.addSubview(self.collectionView)
        self.infoView.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.infoView.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView)

        self.infoView.addSubview(self.info)                 
        self.infoView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.info)
        self.infoView.addConstraintsWithFormat("V:|[v0]|", views: self.info)

        self.buttonView.addSubview(self.addButton)
        self.buttonView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.addButton)    
        self.buttonView.addConstraintsWithFormat("V:|-5-[v0]-10-|", views: self.addButton)

        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)

        self.tableView.register(FriendsTableViewCell.self, forCellReuseIdentifier: self.cellIdTableView)                
        self.collectionView.register(CatFanSelectorViewCell.self, forCellWithReuseIdentifier: cellIdCollectionView)
        self.activityIndicatorView?.startAnimating()

        Global.fetchUsers(completionHandler: { (resutl) in

            if resutl {

                var alUsers = [GamvesUser]()

                let ukeys = Array(Global.gamvesAllUsers.keys)
               
                for key in ukeys {
                    
                    let user = Global.gamvesAllUsers[key]

                    if let userId = PFUser.current()?.objectId {

                        if let gUserId = user?.userId {

                            if gUserId != userId {

                                alUsers.append(user!)
                            }
                        }
                    }                    
                }                

                let groupDictionary = Dictionary(grouping: alUsers) { (user) -> String in
                    return user.schoolId
                }                            

                let keys = groupDictionary.keys.sorted()

                keys.forEach { (key) in
                    
                    print(key)

                    if Global.schools[key] != nil {

                        let school = Global.schools[key]
                        self.schoolSections.append(school!)
                        let user = groupDictionary[key]
                        self.groupUsers.append(user!)

                    }                    
                }
                
                self.groupUsers.forEach({
                    $0.forEach({print($0)})
                    print("-----------------------")
                })  

                DispatchQueue.main.async {

                    self.tableView.reloadData()
                    self.activityIndicatorView?.stopAnimating()

                }               
            }

        })

        self.disableAddButton()

        self.tableView.register(AddFriendSectionHeader.self, forHeaderFooterViewReuseIdentifier: self.sectionHeaderId)

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

        var count = Int()        
        count = self.groupUsers.count

        return count
    }   
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = Int()   
        count = self.groupUsers[section].count        
        
        return count
    }     

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()

        height = 100

        return height    
    }         

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.sectionHeaderId) as? AddFriendSectionHeader else {
            return nil
        }

        let school = self.schoolSections[section] as GamvesSchools

        header.schoolIconImageView.image = school.icon

        header.nameLabel.text = school.schoolName        
                
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdTableView, for: indexPath) as! FriendsTableViewCell

        let user = self.groupUsers[indexPath.section][indexPath.row]
        
        cell.nameLabel.text = user.name

        let status = "\(user.level.grade) - \(user.level.description)"

        cell.statusLabel.text = status

        cell.profileImageView.image = user.avatar
            
        if user.isChecked {

            cell.checkLabel.isHidden = false
            
        } else {

            cell.checkLabel.isHidden = true            
        }

        return cell 
    } 

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {  
        
        print(indexPath.row)

        self.info.isHidden = true
        
        tableView.deselectRow(at: indexPath, animated: false)     
        
        let user =  self.groupUsers[indexPath.section][indexPath.row]

        let checked = user.isChecked
            
        if !checked {

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


    @objc func handleAdd() {  

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
