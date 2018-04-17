//
//  CategoryPage.swift
//  gamves
//
//  Created by Jose Vigil on 7/18/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import KenBurns
import Parse

class CategoryPage: UIViewController, 
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout {
    
    weak var delegate:CellDelegate?

    var categoryGamves = CategoryGamves()
    var fanpagesGamves  = [FanpageGamves]()

    let coverContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor //UIColor(white: 0, alpha: 1)
        return view
    }()

    var coverImageView: KenBurnsImageView = {
        let imageView = KenBurnsImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var arrowBackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "arrow_back_white")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)        
        return button
    }()

     let separatorButtonsView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.blue
        return view
    }()

    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "favorite")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white   
        button.addTarget(self, action: #selector(handleFavoriteButton), for: .touchUpInside)        
        return button
    }()

    let separatorCenterView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.green        
        return view
    }()

    let categoryName: UILabel = {
        let label = UILabel()
        //label.text = "Setting"
        label.sizeToFit()        
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()

    let cellCollectionId = "cellCollectionId"

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()       

    var isFavorite = Bool()

    var favorite:PFObject!
    
    override func viewDidLoad() {

        super.viewDidLoad()

        let coverHeight = 80 //self.view.frame.width * 4 / 16

        let metricsCoverView = ["coverHeight": coverHeight]
        
        print(coverHeight)

        self.view.addSubview(self.coverContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.coverContainerView)
        self.view.addConstraintsWithFormat("V:|[v0(coverHeight)]|", views: self.coverContainerView, metrics: metricsCoverView)
           
        self.coverContainerView.addSubview(self.arrowBackButton)
        self.coverContainerView.addSubview(self.separatorButtonsView)
        self.coverContainerView.addSubview(self.favoriteButton)
        
        self.coverContainerView.addSubview(self.coverImageView)
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.coverImageView)
        self.coverContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.coverImageView)
        

        //horizontal constraints
        self.coverContainerView.addConstraintsWithFormat("H:|-10-[v0(60)]-10-[v1]-10-[v2(60)]-10-|", views: arrowBackButton, separatorButtonsView, favoriteButton)
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.arrowBackButton)
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.separatorButtonsView)       
        self.coverContainerView.addConstraintsWithFormat("V:|-10-[v0(60)]|", views: self.favoriteButton)       
    
        self.coverContainerView.addSubview(self.separatorCenterView)        
        self.coverContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.separatorCenterView)           
        self.coverContainerView.addConstraintsWithFormat("V:|-60-[v0(100)]|", views: self.separatorCenterView)                          

        //name = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: self.view.frame.height))        

        self.separatorButtonsView.addSubview(self.categoryName)
        self.separatorButtonsView.addConstraintsWithFormat("H:|[v0]|", views: self.categoryName)
        self.separatorButtonsView.addConstraintsWithFormat("V:|[v0]|", views: self.categoryName)
    
        self.categoryName.text = categoryGamves.name
    
        self.collectionView.register(FanpageCollectionViewCell.self, forCellWithReuseIdentifier: self.cellCollectionId)            
       
        self.view.addSubview(self.collectionView)     
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)           
        self.view.addConstraintsWithFormat("V:|-coverHeight-[v0]|", views: self.collectionView,metrics: metricsCoverView)
        
        //self.collectionView.backgroundColor = UIColor.gamvesBackgoundColor

        let homeImage = "background_vertical"
        let image = UIImage(named: homeImage)        

        self.collectionView.backgroundView = UIImageView(image: image!)
        
    }

    func checkFavorite() {


        let queryFavorite = PFQuery(className:"Favorites")

        if let userId = PFUser.current()?.objectId {
        
            queryFavorite.whereKey("userId", equalTo: userId)

        }

        if let categotyId = categoryGamves.cateobj?.objectId {

            queryFavorite.whereKey("referenceId", equalTo: categotyId)

        }
        
        queryFavorite.getFirstObjectInBackground { (favoritePF, error) in
            
            if error == nil {

                self.isFavorite = true               
                    
                self.favoriteButton.tintColor = UIColor.red

                self.favorite = favoritePF

            } else {

                self.isFavorite = false

                self.favoriteButton.tintColor = UIColor.white

            }
        }

    }

    func handleBackButton() 
    {
        print("hola") 
        if ( delegate != nil )
        {
            delegate?.setCurrentPage(current: 0, direction: UIPageViewControllerNavigationDirection.reverse, data: nil)
        }  
    }

    func handleFavoriteButton() {

        if !self.isFavorite {

            let favoritesPF: PFObject = PFObject(className: "Favorites")

            if let categotyId = categoryGamves.cateobj?.objectId {

                favoritesPF["referenceId"] = categotyId

            }
            
            if let userId = PFUser.current()?.objectId {
            
                favoritesPF["userId"] = userId
                
            }
            
            favoritesPF["type"] = 0
            
            favoritesPF.saveInBackground(block: { (resutl, error) in
                
                if error == nil {
                
                    self.favoriteButton.tintColor = UIColor.red

                    self.isFavorite = true

                    self.favorite = favoritesPF
                }

            })            
            
        } else {

            self.favorite.deleteEventually()

            self.favoriteButton.tintColor = UIColor.white

            self.isFavorite = false
        }
        
    }
    
    func newKenBurnsImageView(image: UIImage) {
        self.coverImageView.setImage(image)
        self.coverImageView.zoomIntensity = 1.5
        self.coverImageView.setDuration(min: 5, max: 13)
        self.coverImageView.startAnimating()
    }

    fileprivate func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.coverContainerView.frame
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.gamvesBlackColor.cgColor]
        gradientLayer.locations = [0.2, 1.2]
        self.coverContainerView.tag = 1
        self.coverContainerView.layer.addSublayer(gradientLayer)
        self.coverContainerView.bringSubview(toFront: self.separatorButtonsView)
        self.coverContainerView.bringSubview(toFront: self.arrowBackButton)
        self.coverContainerView.bringSubview(toFront: self.favoriteButton)
    }
    
    func setKurnImage(image: UIImage) {
        self.newKenBurnsImageView(image:image)
    }

    func setCategoryData()
    {

        self.checkFavorite()

        self.fanpagesGamves.removeAll()        
        self.fanpagesGamves = categoryGamves.fanpages
        self.categoryName.text = categoryGamves.name
        //self.coverImageView.image = categoryGamves.cover_image


        if categoryGamves.name == "TRENDING" {

            self.favoriteButton.isHidden = true
        
        }  else {

            self.favoriteButton.isHidden = false

        }    

        
        self.newKenBurnsImageView(image: categoryGamves.cover_image)
        
        self.collectionView.reloadData()
        if self.coverContainerView.tag != 1
        {
            self.setupGradientLayer()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fanpagesGamves.count
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellCollectionId, for: indexPath) as! FanpageCollectionViewCell
        
        cell.thumbnailImageView.image = fanpagesGamves[indexPath.row].cover_image
        
        cell.titleLabel.text = fanpagesGamves[indexPath.row].name
        
        cell.userProfileImageView.image = fanpagesGamves[indexPath.row].icon_image
        
        //cell.subtitleTextView.text = fanpagesGamves[indexPath.row].about

        let gr = Gradients()
        
        var gradient : CAGradientLayer = CAGradientLayer()

        //let randomIndex = Int(arc4random_uniform(UInt32(Global.pasterColorArray.count)))        

        gradient = gr.getPastelGradient()        
        gradient.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        cell.layer.insertSublayer(gradient, at: 0)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (view.frame.width - 16 - 16) * 9 / 16
        return CGSize(width: view.frame.width, height: height + 16 + 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let fanpage:FanpageGamves = fanpagesGamves[indexPath.row]
        
        if ( delegate != nil )
        {
            delegate?.setCurrentPage(current: 2, direction: UIPageViewControllerNavigationDirection.forward, data: fanpage)
        }
    }
    

}

