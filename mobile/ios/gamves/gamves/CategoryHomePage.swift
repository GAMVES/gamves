//
//  CategoryCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/19/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView

let fanpageCell = "fanpageCell"
let fanpageTrendingCell = "fanpageTrendingCell"

class CategoryHomePage: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    let categorySectionCellId = "categorySectionCellId"
    let categoryCollectionCellId = "categoryCollectionCellId"

    var width = CGFloat()
    var height = CGFloat()

    var sectionHeight:CGFloat = 80
    var storedOffsets = [Int: CGFloat]()    

    var dalaLoaded = Bool()
    
    weak var delegate:CellDelegate?
    
    var activityIndicatorView:NVActivityIndicatorView?
    
    var refreshControl: UIRefreshControl!
    
    lazy var tableView: UITableView = {
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tv = UITableView(frame: rect)
        //tv.backgroundColor = UIColor.white
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        self.width = self.view.frame.width
        self.height = self.view.frame.height
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gray) 

        self.activityIndicatorView?.startAnimating()
                        
        self.view.addSubview(tableView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: tableView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: tableView)
        self.tableView.isHidden = true
        
        self.tableView.register(CategoryTableViewSectionCell.self, forCellReuseIdentifier: categorySectionCellId)
        self.tableView.register(CategoryTableCollCell.self, forCellReuseIdentifier: categoryCollectionCellId)
        
        //self.tableView.backgroundColor = UIColor.gamvesBackgoundColor

        let homeImage = "background_list_1"
        let image = UIImage(named: homeImage)        

        self.tableView.backgroundView = UIImageView(image: image!)
        
        self.loadCategories()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(loadCategories), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("aparece")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        if (self.dalaLoaded)
        {
            let countCategories = Global.categories_gamves.count
            return countCategories
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryCollectionCellId, for: indexPath) as! CategoryTableCollCell        
        
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {        
        guard let tableViewCell = cell as? CategoryTableCollCell else
        {
            return
        }
        print(indexPath.row)
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        
        guard let tableViewCell = cell as? CategoryTableCollCell else
        {
            return
        }
        
        let row = indexPath.section
        
        print(row)
        
        tableViewCell.selectionStyle = .none
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: row)
        
        tableViewCell.collectionViewOffset = storedOffsets[row] ?? 0    
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
       self.selectSection(section: indexPath.row)
        
        print(indexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var size = CGFloat()
        
        if Global.categories_gamves.count > 0 {
        
            let id = indexPath.section
        
            let categoryName = Global.categories_gamves[id]?.name
        
            if categoryName == "TRENDING" {
                
                var height = (view.frame.width - 16 - 16) * 9 / 16
                height = height + 16 + 88
                size =  height
                
            } else {
                size = 150
            }
        
        } else {
            size = 150
        }
        
        return size

    }

   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {        
  
        let headerView = tableView.dequeueReusableCell(withIdentifier: categorySectionCellId) as! CategoryTableViewSectionCell
        
        let catcel:CategoryGamves = Global.categories_gamves[section]!
        
        headerView.name.text  = catcel.name
        
        headerView.icon.image  = catcel.thum_image
        
        headerView.backgroundImageView.image = catcel.cover_image
        
        let descgradient = "gradient_\(section)"
        let gr = Gradients()

        if gr.colors[descgradient] != nil
        {
            let gradient: CAGradientLayer  = gr.getGradientByDescription(descgradient)
            gradient.frame = CGRect(x: 0, y: 0,width: self.width, height: sectionHeight) //cellC.image.bounds
            headerView.gradientCategory.layer.insertSublayer(gradient, at: 0)
            headerView.gradientCategory.alpha = 0.8
        }
     
        headerView.layer.borderWidth  = 0
        headerView.tag = section
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickSection)))

        return headerView
    }
    
    
    func clickSection(_ sender:UIPanGestureRecognizer)
    {
        self.selectSection(section: (sender.view?.tag)!)
    }
    
    func selectSection(section : Int)
    {
        print(section)
        if ( delegate != nil )
        {
            let category = Global.categories_gamves[section]
            
            print(category?.name)
            
            delegate?.setCurrentPage(current: 1, direction: 1, data: category)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (self.dalaLoaded)
        {
            return sectionHeight
        } else 
        {
            return 0
        }
    }
    
    
    func loadCategories()
    {
        
        let queryCategories = PFQuery(className:"Categories")
        
        //queryCategories.whereKey("hasFanpage", equalTo: true)
        
        if !Global.hasDateChanged()
        {
            queryCategories.cachePolicy = .cacheThenNetwork
        }
        
        //queryCategories.order(byDescending: "order")
        queryCategories.order(byAscending: "order")
        
        var count = 0
        
        queryCategories.findObjectsInBackground { (categories, error) in
            
            if error != nil
            {
                print("error")
            } else {
                
                if let pcategories = categories
                {
                    
                    let categoryAmount = pcategories.count
                    
                    print(categoryAmount)
                    
                    var total = Int()
                    total = categoryAmount - 1                    
                    
                    for pcategory in pcategories
                    {
                        
                        let cat = CategoryGamves()
                        cat.cateobj = pcategory as PFObject
                        
                        print(pcategory.objectId)
                        
                        //let cover = pcategory["cover"] as! String
                        
                        let name = pcategory["name"] as! String
                        
                        let thumbnail = pcategory["thumbnail"] as! PFFile
                        
                        var count_urls = 0
                        
                        thumbnail.getDataInBackground(block: { (imageData, error) in
                            
                            if error == nil {
                                
                                if let imageData = imageData {
                                    
                                    let image = UIImage(data:imageData)
                                    
                                    cat.name = name
                                    cat.thum_image = image!
                                    
                                    print(name)
                                    let backImage = pcategory["backImage"] as! PFFile
                                    
                                    print(backImage)
                                    
                                    backImage.getDataInBackground(block: { (backImageData, error) in
                                        
                                        if error == nil {
                                            
                                            if let backImageData = backImageData {
                                                
                                                let coverImage = UIImage(data:backImageData)
                                                
                                                if ((coverImage) != nil) {
                                                    cat.cover_image = coverImage!
                                                }
                                                
                                                let order = pcategory["order"] as! Int
                                                
                                                Global.categories_gamves[order] = cat

                                                var last = Bool()
                                                
                                                print(count)
                                                print(total)
                                                
                                                if count == total {
                                                    
                                                    last = true
                                                    Global.sortCategoryByOrder()
                                                    self.tableView.reloadData()
                                                    
                                                    self.loadFanpagesFromCategories(completionHandler: { ( loaded:Bool ) -> () in
                                                        
                                                        DispatchQueue.main.async {
                                                            self.tableView.isHidden = false
                                                            self.activityIndicatorView?.stopAnimating()
                                                            self.tableView.reloadData()
                                                            self.refreshControl.endRefreshing()                                                            
                                                        }

                                                        //Global.loadFanpagesFavorites()
                                                    })
                                                }
                                                count  = count + 1
                                            }
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func loadFanpagesFromCategories(completionHandler : @escaping (_ resutl:Bool) -> ()) {
    
        let ids = Array(Global.categories_gamves.keys)
        
        for i in ids {
            
            var cat = Global.categories_gamves[i] as! CategoryGamves
            
            var fanpageAmount = 0
            
            let category = cat.cateobj
            
            let queryFanpage = PFQuery(className:"Fanpages")
            
            print(category?.objectId)
            
            queryFanpage.whereKey("category", equalTo: category)
            
            queryFanpage.whereKey("approved", equalTo: true)
            
            if !Global.hasDateChanged() {
                queryFanpage.cachePolicy = .cacheElseNetwork
            }
            
            queryFanpage.findObjectsInBackground { (fanpagesArray, error) in
                
                if error != nil
                {
                    print("error")
                } else {
                    
                    if let fanpagesArray = fanpagesArray
                    {
                        let fanpageAmount = fanpagesArray.count
                        
                        print(fanpageAmount)
                        
                        var total = Int()
                        total = fanpageAmount - 1
                        
                        var count = 0
                        
                        if fanpageAmount > 0 {
                        
                            for fanpage in fanpagesArray {
                                
                                //Download Images
                                Downloader.loadFanpageImages(fanpage: fanpage)
                                
                                let fan = GamvesFanpage()
                                
                                let fpObj:PFObject = fanpage
                                
                                fan.fanpageObj = fpObj
                                fan.categoryObj = cat.cateobj
                                fan.categoryName = fpObj["categoryName"] as! String
                                
                                let fanpageId = fpObj["fanpageId"] as! Int
                                let cover = fpObj["pageCover"] as! PFFile
                                let name  = fpObj["pageName"] as! String
                                let icon  = fpObj["pageIcon"] as! PFFile
                                let about  = fpObj["pageAbout"] as! String
                                
                                let posterId = fpObj["posterId"] as! String
                                
                                let authorRelation = fpObj["author"] as! PFRelation
                                let queryAuthor = authorRelation.query()
                                queryAuthor.findObjectsInBackground(block: { (users, error) in
                                    
                                    if error == nil {
                                        
                                        for user in users! {
                                            
                                            var isFamily = Bool()
                                            let author = user as! PFUser
                                            
                                            if author.objectId == PFUser.current()?.objectId {
                                                isFamily = true
                                            }
                                            
                                            Global.addUserToDictionary(user: author, isFamily: isFamily, completionHandler: { (gamvedUser) in
                                                
                                                fan.author = author as! PFUser
                                                fan.author_image = gamvedUser.avatar
                                                fan.posterId = posterId
                                                fan.fanpageId = fanpageId
                                                
                                                icon.getDataInBackground(block: { (iconImageData, error) in
                                                    
                                                    if error == nil {
                                                        
                                                        let iconImage = UIImage(data: iconImageData!)
                                                        
                                                        fan.icon_image = iconImage!
                                                        fan.name =  name
                                                        fan.about = about
                                                        
                                                        cover.getDataInBackground(block: { (coverImageData, error) in
                                                            
                                                            if error == nil {
                                                                
                                                                let coverImage = UIImage(data:coverImageData!)
                                                                fan.cover_image = coverImage!
                                                                
                                                                cat.fanpages.append(fan)
                                                                
                                                                if  (fanpageAmount-1) == count {
                                                                    self.dalaLoaded=true
                                                                    completionHandler(true)
                                                                }
                                                                count = count + 1
                                                            }
                                                        })
                                                    }
                                                })
                                            })
                                        }
                                    }
                                })
                            }
                        
                        } else {
                            
                            self.dalaLoaded = true
                            completionHandler(true)
                            
                        }
                    }
                }
            }
        }
    }
}

protocol CellDelegate : class
{
    func setCurrentPage(current: Int, direction: Int, data:AnyObject?)
}

extension CategoryHomePage: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
             
        let id = collectionView.tag as Int
        
        print(id)

        let countFanpages = Global.categories_gamves[id]?.fanpages.count
        
        print(countFanpages)
        
        return countFanpages!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let id = collectionView.tag
        
        let row = indexPath.row
        
        print(Global.categories_gamves[id]?.name)
        
        let fanpage = Global.categories_gamves[id]?.fanpages[row]
        
        if Global.categories_gamves[id]?.name == "TRENDING" {
            
            var tcell = collectionView.dequeueReusableCell(withReuseIdentifier: fanpageTrendingCell, for: indexPath) as! FanpageCollectionViewCell
            
            tcell.isLineHidden  = true
            
            tcell.thumbnailImageView.image = fanpage?.cover_image
            
            tcell.titleLabel.text = fanpage?.name
            
            tcell.userProfileImageView.image = fanpage?.icon_image
            
            tcell.authorImageView.image = fanpage?.author_image
            
            return tcell
            
        } else {
            
            var ccell = collectionView.dequeueReusableCell(withReuseIdentifier: fanpageCell, for: indexPath) as! CategoryCollectionViewCell
            
            ccell.fanpageImageView.layer.masksToBounds = true
            ccell.fanpageImageView.layer.cornerRadius = 5
            
            ccell.fanpageImageView.image = fanpage?.icon_image
            
            ccell.fanpageName.text = fanpage?.name
            
            return ccell
            
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {    
        
        let id = collectionView.tag as Int
        
        let category:CategoryGamves = Global.categories_gamves[id]!
        
        print(category.name)
        
        let fanpage:GamvesFanpage = category.fanpages[indexPath.row]
            
        
        print(fanpage.fanpageObj?.objectId)
        
        Global.fanpageData = fanpage
        
        if ( delegate != nil ) {
            
            print(fanpage.fanpageObj?.objectId)
            delegate?.setCurrentPage(current: 2, direction: 1, data: fanpage)
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize 
    {
      //return CGSize(width: 100, height: 150)
        
        var size = CGSize()
        
        let id = collectionView.tag
        
        if Global.categories_gamves[id]?.name == "TRENDING" {
            
            let height = (view.frame.width - 16 - 16) * 9 / 16
            size =  CGSize(width: view.frame.width, height: height + 16 + 88)
            
        } else {
            size = CGSize(width: 100, height: 150)
        }
        
        return size
    }    
    
}




