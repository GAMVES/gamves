//
//  CategoryTableViewCollectionCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/28/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class CategoryTableCollCell: UITableViewCell {


	let cellCollectionId = "cellCollectionId"  
    

	lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        //cv.dataSource = self
        //cv.delegate = self
        return cv
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    	super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
           layout.scrollDirection = .horizontal
        }
        
    	addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: fanpageCell)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    

}

extension CategoryTableCollCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        
        //collectionView.delegate = delegate
        
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat
    {
        set
        {
            collectionView.contentOffset.x = newValue
        }
        
        get {
            return collectionView.contentOffset.x
        }
    }
}
