//
//  BugListViewController.swift
//  gamves
//
//  Created by Jose Vigil on 19/11/2018.
//  Copyright © 2018 Gamves. All rights reserved.
//

import UIKit
import Parse

class BugListViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {

    var gamvesBugs = [GamvesBug]()

    let infoView: UIView = {
        let view = UIView()        
        return view
    }()

    let info: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Below is the list of bugs you reported. The ones approved sum points."
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.gamvesColor
        label.numberOfLines = 3
        label.textAlignment = .center     
        //label.backgroundColor = UIColor.green   
        return label
    }()    

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()   

    var cellId = "cellId"
    let sectionHeaderId = "feedSectionHeader"

    override func viewDidLoad() {
        super.viewDidLoad()

     
        self.view.backgroundColor = UIColor.white

        self.view.addSubview(self.infoView)  
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.infoView)

        self.view.addSubview(self.collectionView)  
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)

        self.view.addConstraintsWithFormat("V:|[v0(100)][v1]|", views:                         
            self.infoView,             
            self.collectionView) 

        self.infoView.addSubview(self.info)  
        self.infoView.addConstraintsWithFormat("H:|-40-[v0]-40-|", views: self.info)
        self.infoView.addConstraintsWithFormat("V:|[v0]|", views: self.info)

        let buttonIcon = UIImage(named: "arrow_back_white")        
       
        
        let leftBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButton(sender:)))
        
        leftBarButton.image = buttonIcon        
        self.navigationItem.leftBarButtonItem = leftBarButton  

        self.collectionView.register(BugsViewCell.self, forCellWithReuseIdentifier: self.cellId)
        self.collectionView.register(BugsSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: sectionHeaderId)

        self.loadBugs()      

    }
  
    @objc func backButton(sender: UIBarButtonItem) {        

        self.navigationController?.popViewController(animated: true)
    }


    func loadBugs() 
    {

        let otherQuery = PFQuery(className:"Bugs")    


        if var userId = PFUser.current()?.objectId {                            
            otherQuery.whereKey("posterId", equalTo:userId)
        }
             
        otherQuery.findObjectsInBackground(block: { (bugsPF, error) in 
            
            if error == nil
            {  

                var countBugs = bugsPF?.count
                var count = Int()

                for bugPF in bugsPF! {

                    let bug = GamvesBug()
                    bug.objectId = bugPF.objectId!
                    bug.objectPF = bugPF

                    bug.description = bugPF["description"] as! String

                    let screenshot = bugPF["screenshot"] as! PFFileObject
                            
                    screenshot.getDataInBackground(block: { (data_icon, error) in

                        let screenShotImage = UIImage(data: data_icon!)

                        bug.screenshot = screenShotImage 

                        self.gamvesBugs.append(bug)

                        if count == (countBugs! - 1)
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
       
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {        
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! BugsSectionHeader

        sectionHeaderView.backgroundColor = UIColor.black

        var image  = UIImage(named: "report_bug")?.withRenderingMode(.alwaysTemplate)
        image = image?.maskWithColor(color: UIColor.white)            
        sectionHeaderView.iconImageView.image = image
        
        sectionHeaderView.nameLabel.text = "Bugs" 

        return sectionHeaderView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {        
        return self.gamvesBugs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BugsViewCell
        
        let bug = self.gamvesBugs[indexPath.item]
        
        cell.descLabel.text = bug.description
        
        //var image = UIImage()
        
        //image = UIImage(named: "bugimage")!       
        
        
        cell.iconImageView.image = bug.screenshot
        
        Global.setRoundedImage(image: cell.iconImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.lightGray)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {        
        return CGSize(width: self.view.frame.width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        /*let vendor = self.gamvesBugs[indexPath.item]

        if vendor.type == 1 {

            let fortniteViewController = FortniteViewController()
            fortniteViewController.userTextField.text = vendor.username
            fortniteViewController.passTextField.text = vendor.password
            //fortniteViewController.isRegistering = false
            self.navigationController?.pushViewController(fortniteViewController, animated: true)
        }*/
    }

}
