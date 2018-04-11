//
//  ProfileController.swift
//  gamves
//
//  Created by XCodeClub on 2018-04-08.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit

class ProfileController: UIViewController,
    UICollectionViewDelegate, 
    UICollectionViewDataSource, 
    UICollectionViewDelegateFlowLayout  
{

    var homeController:HomeController!
    let profileCellId = "profileCellId"
    var profileHome:ProfileCell!
    var gamvesUser:GamvesUser!

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()


        /*self.collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: self.profileCellId)

        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height

        let metricsCollection = ["heght" : navigationBarHeight]

        self.view.addSubview(self.collectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.collectionView, metrics: metricsCollection)*/

       


        /*if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        collectionView.backgroundColor = UIColor.white*/     


        
        /*self.collectionView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)        
        self.collectionView.isPagingEnabled = false
        self.collectionView.reloadData()*/



        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(self.backAction(sender:)))
        // Do any additional setup after loading the view.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }   

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let identifier: String

        identifier = profileCellId

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)

        profileHome = cell as! ProfileCell        

        profileHome.gamvesUser = self.gamvesUser         

        profileHome.setSonProfileImageView()

        profileHome.setProfileType(type: ProfileSaveType.chat)

        return cell

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height - 50)
    }

    func setUser(user:GamvesUser) {    

        //NotificationCenter.default.addObserver(self, selector: #selector(closeVideo), name: NSNotification.Name(rawValue: Global.notificationKeyCloseVideo), object: nil)

        self.gamvesUser = user    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
