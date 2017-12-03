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

class CategoryHomePage: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    let categorySectionCellId = "categorySectionCellId"
    let categoryCollectionCellId = "categoryCollectionCellId"      
    
    var categories_gamves  = [CategoryGamves]()

    var width = CGFloat()
    var height = CGFloat()

    var sectionHeight:CGFloat = 80
    var storedOffsets = [Int: CGFloat]()    

    var dalaLoaded = Bool()
    
    weak var delegate:CellDelegate?
    
    var activityIndicatorView:NVActivityIndicatorView?
    
    
    lazy var tableView: UITableView = {
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tv = UITableView(frame: rect)
        tv.backgroundColor = UIColor.white
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.width = self.view.frame.width
        self.height = self.view.frame.height
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
        
        self.activityIndicatorView?.startAnimating()
                        
        self.view.addSubview(tableView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: tableView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: tableView)
        self.tableView.isHidden = true
        
        self.tableView.register(CategoryTableViewSectionCell.self, forCellReuseIdentifier: categorySectionCellId)
        self.tableView.register(CategoryTableCollCell.self, forCellReuseIdentifier: categoryCollectionCellId)
        
        self.loadCategories()
    }   
      
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        if (self.dalaLoaded)
        {
            let countCategories = self.categories_gamves.count
            return countCategories
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryCollectionCellId, for: indexPath) as! CategoryTableCollCell
        
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
        
        return 150
    }

   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {        
  
        let headerView = tableView.dequeueReusableCell(withIdentifier: categorySectionCellId) as! CategoryTableViewSectionCell
        
        let catcel:CategoryGamves = self.categories_gamves[section]
        
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
            let category = self.categories_gamves[section]
            
            print(category.name)
            
            delegate?.setCurrentPage(current: 1, direction: UIPageViewControllerNavigationDirection.forward, data: category)
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
        queryCategories.whereKey("hasFanpage", equalTo: true)
        
        if !Global.hasDateChanged()
        {
            queryCategories.cachePolicy = .cacheThenNetwork
        }
        
        queryCategories.order(byDescending: "order")
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
                        
                        let name = pcategory["description"] as! String
                        
                        let thumbnail = pcategory["thumbnail"] as! PFFile
                        
                        var count_urls = 0
                        
                        thumbnail.getDataInBackground(block: { (imageData, error) in
                            
                            if error == nil
                            {
                                
                                if let imageData = imageData
                                {
                                    let image = UIImage(data:imageData)
                                    
                                    //cat.cover = cover
                                    cat.name = name
                                    cat.thum_image = image!
                                    
                                    print(name)
                                    let backImage = pcategory["backImage"] as! PFFile
                                    
                                    print(backImage)
                                    
                                    
                                     backImage.getDataInBackground(block: { (backImageData, error) in
                                        
                                        if error == nil
                                        {
                                            
                                            if let backImageData = backImageData
                                            {
                                                
                                                let coverImage = UIImage(data:backImageData)
                                                
                                                if ((coverImage) != nil)
                                                {
                                                    cat.cover_image = coverImage!

                                                }
                                                
                                                self.categories_gamves.append(cat)

                                                var last = Bool()
                                                if count == total
                                                {
                                                    last = true
                                                }
                                                
                                                self.loadFunpageByCategory(cat: cat, lastCategory: last)
                                            }
                                            
                                            count  = count + 1
                                            
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
    
    
    
    func loadFunpageByCategory(cat: CategoryGamves, lastCategory: Bool)
    {
        
        print("***************FANPAGEBYCATEGORY*********************")
        
        var fanpageAmount = 0
        
        let category = cat.cateobj
        
        let queryFanpage = PFQuery(className:"Fanpage")
        
        print(category?.objectId)
        
        queryFanpage.whereKey("category", equalTo: category)
        
        //queryFanpage.cachePolicy = .cacheElseNetwork
        
        if !Global.hasDateChanged()
        {
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
                    
                    for fanpage in fanpagesArray
                    {
                        
                        //Download Images
                        Downloader.loadFanpageImages(fanpage: fanpage)
                        
                        var fan = FanpageGamves()
                        
                        let fpObj:PFObject = fanpage
                        
                        fan.fanpageObj = fpObj
                        fan.categoryObj = cat.cateobj
                        let fanpageId = fpObj["fanpageId"] as! String
                        let cover = fpObj["pageCover"] as! String
                        var name  = fpObj["pageName"] as! String
                        var icon  = fpObj["pageIcon"] as! String
                        var about  = fpObj["pageAbout"] as! String
                        
                        print(name)
                        print(cover)
                        print(icon)
                        
                        let iconURL = URL(string: icon)!
                        let sessionIcon = URLSession(configuration: .default)
                        
                        let downloadIcon = sessionIcon.dataTask(with: iconURL) {
                            (data, response, error) in
                            
                            guard error == nil else {
                                print(error!)
                                return
                            }
                            guard let data = data else {
                                print("Data is empty")
                                return
                            }
                            
                            let image = UIImage(data: data)
                            
                            if error == nil
                            {
                                let iconImage = UIImage(data:data)
                                fan.fanpageId = fanpageId
                                fan.icon_image = iconImage!
                                fan.name =  name
                                fan.about = about
                                
                                let coverURL = URL(string: cover)!
                                let sessionCover = URLSession(configuration: .default)
                                
                                let downloadCover = sessionCover.dataTask(with: coverURL) {
                                    (data, response, error) in
                                    
                                    guard error == nil else {
                                        print(error!)
                                        return
                                    }
                                    guard let data = data else {
                                        print("Data is empty")
                                        return
                                    }
                                    
                                    if error == nil
                                    {
                                        let coverImage = UIImage(data:data)
                                        fan.cover_image = coverImage!
                                        
                                        cat.fanpages.append(fan)                                     
                                        
                                        if ( (fanpageAmount-1) == count && lastCategory )
                                        {
                                            self.dalaLoaded=true
                                            
                                            DispatchQueue.main.async
                                            {
                                                self.tableView.isHidden = false
                                                self.activityIndicatorView?.stopAnimating()
                                                self.tableView.reloadData()
                                            }
                                            
                                            
                                        }
                                        self.tableView.reloadData()
                                        count = count + 1
                                    }
                                    
                                }
                                downloadCover.resume()                               
                                
                            }
                            
                        }
                        downloadIcon.resume()
                        
                    }
                }
            }
        }
    } 
    
    
    func getImageVideo(videothumburl: String, video:VideoGamves, completionHandler : (_ video:VideoGamves) -> Void)
    {
        
        if let vurl = URL(string: videothumburl)
        {
            
            if let data = try? Data(contentsOf: vurl)
            {
                video.thum_image = UIImage(data: data)!
                
                completionHandler(video)
            }
        }
    }

    

}

protocol CellDelegate : class
{
    func setCurrentPage(current: Int, direction: UIPageViewControllerNavigationDirection, data:AnyObject?)
}

extension CategoryHomePage: UICollectionViewDelegate, UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
             
        let id = collectionView.tag
        
        print(id)

        let countFanpages = self.categories_gamves[id].fanpages.count
        
        print(countFanpages)
        
        return countFanpages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: fanpageCell, for: indexPath) as! CategoryCollectionViewCell
        
        let id = collectionView.tag
        
        let row = indexPath.row
        
        print(self.categories_gamves[id].name)
        
        print(id)        
        print(row)
        
        print(self.categories_gamves[id].fanpages.count)

        let fanpage = self.categories_gamves[id].fanpages[row]
        
        print(fanpage.name)

        cell.fanpageImageView.layer.masksToBounds = true
        cell.fanpageImageView.layer.cornerRadius = 5
        
        cell.fanpageImageView.image = fanpage.icon_image
        
        cell.fanpageName.text = fanpage.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {    
        
        let id = collectionView.tag
        
        let category:CategoryGamves = self.categories_gamves[id]
        
        //print(category.name)
        
        let fanpage:FanpageGamves = category.fanpages[indexPath.row]
            
        
        //print(fanpage.fanpageObj?.objectId)
        
        if ( delegate != nil )
        {
            delegate?.setCurrentPage(current: 2, direction: UIPageViewControllerNavigationDirection.forward, data: fanpage)
        }
        
    }   

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize 
    {        
        return CGSize(width: 100, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize 
    {
      return CGSize(width: 100, height: 150)
    }    
    
}




