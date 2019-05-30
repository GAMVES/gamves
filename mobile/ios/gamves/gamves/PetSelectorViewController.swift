//
//  PetSelectorViewController.swift
//  gamves
//
//  Created by Jose Vigil on 08/12/2018.
//  Copyright © 2018 Gamves. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Parse

class PetSelectorViewController: UIViewController, 
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout   {

    var homeController: HomeController?    

    var activityView: NVActivityIndicatorView!

    var pets = [GamvesPet]()

    let titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false          
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select the pet you want"
        label.textColor = UIColor.white                
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center   
        label.numberOfLines = 2     
        return label
    }()  

    //- Scores

    let petPreView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    }()

    let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = UIColor.gamvesPetBackgroundLightColor         
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 2     
        label.isHidden = false
        label.textAlignment = .center           
        return label
    }() 

    //-- Line

    let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        return view
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()        
        layout.minimumLineSpacing = 1        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)   
        cv.backgroundColor = UIColor.gamvesPetBackgroundColor     
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    var cellPetCollectionId = "cellPetCollectionId"

    var points = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.gamvesPetBackgroundColor

        self.view.addSubview(self.titleView)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.collectionView)

        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.titleView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.lineView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)

        self.view.addConstraintsWithFormat("V:|[v0(150)][v1(5)][v2]|", views: 
            self.titleView, 
            self.lineView, 
            self.collectionView)   

        self.titleView.addSubview(self.titleLabel)       
        self.titleView.addSubview(self.petPreView)      
        
        self.titleView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.titleLabel)        
        self.titleView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.petPreView)

        self.titleView.addConstraintsWithFormat("V:|-5-[v0(40)][v1]|", views: 
            self.titleLabel,             
            self.petPreView)
        
        self.petPreView.addSubview(self.thumbImageView)
        self.petPreView.addSubview(self.nameLabel)
        
        self.petPreView.addConstraintsWithFormat("V:|-15-[v0(80)]-15-|", views: self.thumbImageView)
        self.petPreView.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.nameLabel)               

        self.petPreView.addConstraintsWithFormat("H:|-15-[v0(80)]-10-[v1]-10-|", views: 
            self.thumbImageView, 
            self.nameLabel)

        self.collectionView.register(PetViewCell.self, forCellWithReuseIdentifier: self.cellPetCollectionId)       

        self.activityView = Global.setActivityIndicator(container: self.view, type: Int(NVActivityIndicatorType.ballPulse.hashValue), color: UIColor.gray)        

        let ids = Array(Global.pets.keys)             
        for i in ids {
            let gamvesPet = Global.pets[i] as! GamvesPet
            pets.append(gamvesPet)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if self.homeController!.pet != nil {
            
            self.setPet(pet: self.homeController!.pet)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        count = self.pets.count
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
             
        let cellPet = collectionView.dequeueReusableCell(withReuseIdentifier: cellPetCollectionId, for: indexPath) as! PetViewCell
        
        cellPet.thumbnailImageView.image = self.pets[indexPath.row].thumbnail
        
        if self.pets[indexPath.row].isChecked {
            
            cellPet.checkView.isHidden = false
        
        } else {
            
            cellPet.checkView.isHidden = true
        }            
        
        cellPet.title.text = self.pets[indexPath.row].name
        cellPet.descriptionLabel.text = self.pets[indexPath.row].description
        
        return cellPet
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize()      
       
        //let height = (self.view.frame.width) * 9 / 16
           
        size = CGSize(width: self.view.frame.width, height: 80) //height: height + 16 + 88)      
        
        return size  
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing = CGFloat()        
        spacing = 0       
        return spacing
        
    }      
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.setPet(pet: self.pets[indexPath.row])

        self.saveUserPet(pet: self.pets[indexPath.row])

        self.collectionView.reloadData()               
    }

    func setPet(pet : GamvesPet) {

        let thumbnail = pet.thumbnail
        thumbImageView.image = thumbnail  
        nameLabel.isHidden = false
        nameLabel.text = "Your pet is \(pet.name)"      
    }

    func saveUserPet(pet : GamvesPet) {

        var petsId = String()

        var userPets:PFObject?
        
        if self.homeController!.pet != nil {
            
            userPets = self.homeController!.userPets
            
            petsId = self.homeController!.pet.objectId

        } else {
            
            userPets = PFObject(className: "UserPets")
            
            if let userId = PFUser.current()?.objectId {
                userPets!["userId"] = userId
            }
            
            userPets!["status"] = 0
            
            petsId = pet.objectId

        }

        userPets!["petsId"] = petsId

        userPets!.saveInBackground(block: { (resutl, error) in
            
            if resutl {

                self.homeController!.userPets = userPets
                
                self.homeController!.pet = pet

            }            

        })
        
        
    }

}
