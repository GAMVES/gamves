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

    let infoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Click the + button below and add a new account. If the accout is not availabe contact Gamves official"
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 3
        return label
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.lightGray
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    var floaty = Floaty(size: 80)   

    var cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        let buttonIcon = UIImage(named: "arrow_back_white")        
        let leftBarButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(backButton(sender:)))
        leftBarButton.image = buttonIcon        
        self.navigationItem.leftBarButtonItem = leftBarButton   

        self.navigationItem.title = "Other Accounts"

        self.floaty.paddingY = 35
        self.floaty.paddingX = 20                    
        self.floaty.itemSpace = 30
        
        self.floaty.hasShadow = true
        self.floaty.buttonColor = UIColor.gamvesGreenColor
        var addImage = UIImage(named: "add_symbol")
        addImage = addImage?.maskWithColor(color: UIColor.white)
        addImage = Global.resizeImage(image: addImage!, targetSize: CGSize(width:40, height:40))
        self.floaty.buttonImage = addImage
        self.floaty.sizeToFit()

        let itemNewFortnite = FloatyItem()
        var groupAddImage = UIImage(named: "fortnite_black")
        groupAddImage = groupAddImage?.maskWithColor(color: UIColor.white)
        itemNewFortnite.icon = groupAddImage
        itemNewFortnite.buttonColor = UIColor.gamvesGreenColor
        itemNewFortnite.titleLabelPosition = .left
        itemNewFortnite.titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20)
        itemNewFortnite.title = "Fortnite"
        itemNewFortnite.handler = { item in           

            let fortniteViewController = FortniteViewController()
            fortniteViewController.isRegistering = true
            self.navigationController?.pushViewController(fortniteViewController, animated: true)
                                                            
        }  

        self.floaty.addItem(item: itemNewFortnite)          
        self.view.addSubview(self.floaty)

        self.loadOtherAccountVendors()      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.hideShowTabBar(hidden: true)
        
    }

    func backButton(sender: UIBarButtonItem) {

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

    func hideShowTabBar(hidden: Bool)
    {
        self.tabBarController?.tabBar.isHidden = hidden
        
        if hidden
        {
            navigationController?.navigationBar.tintColor = UIColor.white
        } 
    }


}
