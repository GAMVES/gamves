//
//  OtherAccountsViewController.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-09-04.
//

import UIKit
import Parse
import NVActivityIndicatorView
import Floaty

class OtherAccountsViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {

    var gamvesVendors = [GamvesVendor]()

     let infoView: UIView = {
        let view = UIView()        
        return view
    }()

    let info: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Click the + button below and add a new account. If the accout is not availabe contact Gamves official"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.cyberChildrenColor
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

    var floaty = Floaty(size: 80)   

    var cellId = "cellId"
    let sectionHeaderId = "feedSectionHeader"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        self.view.addSubview(self.infoView)  
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.infoView)

        self.view.addSubview(self.collectionView)  
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)

        self.view.addConstraintsWithFormat("V:|-100-[v0(100)][v1]|", views:                         
            self.infoView,             
            self.collectionView) 

        self.infoView.addSubview(self.info)  
        self.infoView.addConstraintsWithFormat("H:|-40-[v0]-40-|", views: self.info)
        self.infoView.addConstraintsWithFormat("V:|[v0]|", views: self.info)

        let buttonIcon = UIImage(named: "arrow_back_white")        
       
        
        let leftBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButton(sender:)))
        
        leftBarButton.image = buttonIcon        
        self.navigationItem.leftBarButtonItem = leftBarButton   

        self.navigationItem.title = "Other Accounts"

        self.floaty.paddingY = 35
        self.floaty.paddingX = 20                    
        self.floaty.itemSpace = 30
        
        self.floaty.hasShadow = true
        self.floaty.buttonColor = UIColor.cyberChildrenColor
        var addImage = UIImage(named: "add_symbol")
        addImage = addImage?.maskWithColor(color: UIColor.white)
        addImage = Global.resizeImage(image: addImage!, targetSize: CGSize(width:40, height:40))
        self.floaty.buttonImage = addImage
        self.floaty.sizeToFit()

        let itemNewFortnite = FloatyItem()
        var groupAddImage = UIImage(named: "fortnite_black")
        groupAddImage = groupAddImage?.maskWithColor(color: UIColor.white)
        itemNewFortnite.icon = groupAddImage
        itemNewFortnite.buttonColor = UIColor.cyberChildrenColor
        itemNewFortnite.titleLabelPosition = .left
        itemNewFortnite.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemNewFortnite.title = "Fortnite"
        itemNewFortnite.handler = { item in           

            let fortniteViewController = FortniteViewController()
            //fortniteViewController.isRegistering = true
            self.navigationController?.pushViewController(fortniteViewController, animated: true)
                                                            
        }  

        self.floaty.addItem(item: itemNewFortnite)          
        self.view.addSubview(self.floaty)

        self.collectionView.register(OtherAccountViewCell.self, forCellWithReuseIdentifier: self.cellId)
        self.collectionView.register(OtherAccountSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: sectionHeaderId)

        self.loadOtherAccountVendors()      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.hideShowTabBar(hidden: true)
        
    }

    @objc func backButton(sender: UIBarButtonItem) {

        self.hideShowTabBar(hidden:false)

        self.navigationController?.popViewController(animated: true)
    }


    func loadOtherAccountVendors() 
    {

        let otherQuery = PFQuery(className:"OtherAccounts")     


        if var userId = PFUser.current()?.objectId {                
            let son_userId = Global.defaults.string(forKey: "\(userId)_son_userId")!
            otherQuery.whereKey("userId", equalTo:son_userId)                       
        }
             
        otherQuery.getFirstObjectInBackground(block: { (otherAccountsPF, error) in
        
            if error == nil
            {  

                let vendorsRelation = otherAccountsPF!["vendors"] as! PFRelation
                let queryVendors = vendorsRelation.query()
                queryVendors.findObjectsInBackground { (vendorsPF, error) in

                    if error == nil {

                        var countVendors = vendorsPF?.count
                        var count = Int()

                        for vendorPF in vendorsPF! {

                            let vendor = GamvesVendor()
                            vendor.objectId = vendorPF.objectId!
                            vendor.name = vendorPF["name"] as! String
                            vendor.type = vendorPF["type"] as! Int
                            vendor.username = vendorPF["username"] as! String
                            vendor.password = vendorPF["password"] as! String
                            vendor.objectPF = vendorPF

                            if count == (countVendors! - 1) {

                                self.gamvesVendors.append(vendor)

                                self.collectionView.reloadData()
                            }

                            count = count + 1
                        }
                    }
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

        var sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! OtherAccountSectionHeader

        sectionHeaderView.backgroundColor = UIColor.black

        var image  = UIImage(named: "games")?.withRenderingMode(.alwaysTemplate)
        image = image?.maskWithColor(color: UIColor.white)            
        sectionHeaderView.iconImageView.image = image
        
        sectionHeaderView.nameLabel.text = "Games" 

        return sectionHeaderView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {        
        return self.gamvesVendors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OtherAccountViewCell
        
        let vendor = self.gamvesVendors[indexPath.item]
        
        cell.nameLabel.text = vendor.name
        
        var image = UIImage()
        
        if vendor.type == 1 {
            image = UIImage(named: "fortnite")!
        }
        
        cell.vendorImageView.image = image
        
        Global.setRoundedImage(image: cell.vendorImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.lightGray)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {        
        return CGSize(width: self.view.frame.width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let vendor = self.gamvesVendors[indexPath.item]

        if vendor.type == 1 {

            let fortniteViewController = FortniteViewController()
            fortniteViewController.userTextField.text = vendor.username
            fortniteViewController.passTextField.text = vendor.password
            //fortniteViewController.isRegistering = false
            self.navigationController?.pushViewController(fortniteViewController, animated: true)
        }
    }


    //Move this to Global
    func hideShowTabBar(hidden: Bool)
    {
        self.tabBarController?.tabBar.isHidden = hidden
        
        if hidden
        {
            navigationController?.navigationBar.tintColor = UIColor.white
        } 
    }


}
