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
    
    let cellBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    	super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
           layout.scrollDirection = .horizontal
        }
        
        
        addSubview(cellBackgroundView)
        addConstraintsWithFormat("H:|[v0]|", views: cellBackgroundView)
        addConstraintsWithFormat("V:|[v0]|", views: cellBackgroundView)
        
    	addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: fanpageCell)
        
        let descgradient = "gradient_3"
        let gr = Gradients()
        
        if gr.colors[descgradient] != nil
        {
            let gradient: CAGradientLayer  = gr.getGradientByDescription(descgradient)
            gradient.frame = CGRect(x: 0, y: 0,width: cellBackgroundView.frame.width, height: cellBackgroundView.frame.height)
            self.cellBackgroundView.layer.insertSublayer(gradient, at: 0)
            self.cellBackgroundView.alpha = 0.8
        }
        
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
        
        collectionView.backgroundColor = UIColor.gamvesBackgoundColor
        
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
