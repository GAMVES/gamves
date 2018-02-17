//
//  SelectorView.swift
//  gamves
//
//  Created by Jose Vigil on 01/02/2018.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit

protocol SelectorProtocol {
    func categorySelected(category : CategoryGamves)
    func fanpageSelected(fanpage : FanpageGamves)
    func reoadFanpageCollection()
}

enum SelectorType {
    case TypeCategory
    case TypeFanpage
}

class SelectorView: BaseCell,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{
    
    var categoriesGamves = [CategoryGamves]()
    
    var gamvesFanpage = [FanpageGamves]()
    
    var delegateSelector:SelectorProtocol!

    var isEditFanpage = Bool()
    
    let selectorContView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gamvesBlackColor
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.layer.cornerRadius = 5
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = UIColor.gambesDarkColor
        return cv
    }()
    
    let catFanSelectorId = "catFanSelectorId"
    
    var selectedIndePath = IndexPath()
    
    var selectorType:SelectorType!

    init(frame: CGRect, isEdit:Bool) {
        super.init(frame: frame)

        print(isEdit)
        self.isEditFanpage = isEdit
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = self.frame.size
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        self.collectionView.setCollectionViewLayout(layout, animated: true)
        
        self.addSubview(self.selectorContView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.selectorContView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.selectorContView)
        
        self.selectorContView.addSubview(self.collectionView)
        
        self.selectorContView.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.selectorContView.addConstraintsWithFormat("V:|[v0(150)]|", views: self.collectionView)

        self.collectionView.register(CatFanSelectorViewCell.self, forCellWithReuseIdentifier: self.catFanSelectorId)
        
        let ids = Array(Global.categories_gamves.keys)
        
        if !self.isEditFanpage {
        
            for i in ids {
                
                let cat = Global.categories_gamves[i]?.name as! String
                
                if cat != "TRENDING" && cat != "PERSONAL" {
                    
                
                    self.categoriesGamves.append(Global.categories_gamves[i]!)
                }
            }
        
        } else {
           
            for i in ids {
                
                let cat = Global.categories_gamves[i]?.name as! String
                
                if cat == "PERSONAL" {
                    
                    self.categoriesGamves.append(Global.categories_gamves[i]!)
                }
            }

            self.collectionView.isUserInteractionEnabled = false
        }
        
    }
    
    func setSelectorType(type:SelectorType) {
        self.selectorType = type
    }
    
    func loadFanpage(category:CategoryGamves) {
        self.gamvesFanpage = category.fanpages
        self.collectionView.reloadData()
        self.delegateSelector.reoadFanpageCollection()
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = Int()
        
        if self.selectorType == SelectorType.TypeCategory {
        
           count = self.categoriesGamves.count
        
        } else if self.selectorType == SelectorType.TypeFanpage {
            
           count = self.gamvesFanpage.count
            
        }
        
        print(count)
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 150, height: 150)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.catFanSelectorId, for: indexPath) as! CatFanSelectorViewCell
        
        let index = indexPath.item
        
        if self.selectorType == SelectorType.TypeCategory {
            
            let category = self.categoriesGamves[index]
            cell.avatarImage.image = category.thum_image
            cell.nameLabel.text = category.name
            
        } else if self.selectorType == SelectorType.TypeFanpage {
            
            let fanpage = self.gamvesFanpage[indexPath.row]
            cell.avatarImage.image = fanpage.icon_image
            cell.nameLabel.text = fanpage.name
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("index : \(indexPath)")
        
        let cell = self.collectionView.cellForItem(at: indexPath) as! CatFanSelectorViewCell
        
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.white.cgColor
        cell.backgroundColor = UIColor.black
        cell.avatarImage.backgroundColor = UIColor.black
        cell.separatorView.backgroundColor = UIColor.black
        
        if self.selectorType == SelectorType.TypeCategory {
        
            let category = self.categoriesGamves[indexPath.item]
            delegateSelector.categorySelected(category: category)
            
        } else if self.selectorType == SelectorType.TypeFanpage {
            
            let fanpage = gamvesFanpage[indexPath.item]
            delegateSelector.fanpageSelected(fanpage: fanpage)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("index : \(indexPath)")
        
        let cell = self.collectionView.cellForItem(at: indexPath) as! CatFanSelectorViewCell
        
        cell.layer.borderWidth = 0.0
        cell.backgroundColor = UIColor.gambesDarkColor
        cell.avatarImage.backgroundColor = UIColor.gambesDarkColor
        cell.separatorView.backgroundColor = UIColor.gambesDarkColor
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        print("index : \(indexPath)")
        
        //let cell = self.collectionView.cellForItem(at: indexPath) as! CatFanSelectorViewCell
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UICollectionView {
    func deselectAllItems(animated: Bool = false) {
        for indexPath in self.indexPathsForSelectedItems ?? [] {
            self.deselectItem(at: indexPath, animated: animated)
        }
    }
}


