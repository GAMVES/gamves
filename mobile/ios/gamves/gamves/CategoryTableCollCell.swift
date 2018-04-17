//
//  CategoryTableViewCollectionCell.swift
//  gamves
//
//  Created by Jose Vigil on 6/28/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class CategoryTableCollCell: UITableViewCell, UIScrollViewDelegate {

	let cellCollectionId = "cellCollectionId"
    
    var horizontalLeftAnchorConstraint: NSLayoutConstraint?
    
    private var startingScrollingOffset = CGPoint.zero

	lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //cv.backgroundColor = UIColor.white
        //cv.delegate = self
        return cv
    }()
    
    let cellBackgroundView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.white
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
        collectionView.register(FanpageCollectionViewCell.self, forCellWithReuseIdentifier: fanpageTrendingCell)
        
        let descgradient = "gradient_3"
        let gr = Gradients()
        
        if gr.colors[descgradient] != nil
        {
            let gradient: CAGradientLayer  = gr.getGradientByDescription(descgradient)
            gradient.frame = CGRect(x: 0, y: 0,width: cellBackgroundView.frame.width, height: cellBackgroundView.frame.height)
            self.cellBackgroundView.layer.insertSublayer(gradient, at: 0)
            self.cellBackgroundView.alpha = 0.8
        }
        
        collectionView.layer.backgroundColor = UIColor.clear.cgColor

        //self.collectionView.backgroundView?.alpha = 0        
        //self.collectionView.backgroundColor = UIColor.white
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
        horizontalLeftAnchorConstraint?.constant = collectionView.contentOffset.x / 4
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let index = collectionView.contentOffset.x / collectionView.frame.width
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())

    }
    

        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    

}

extension CategoryTableCollCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        if row == 0 {
            
            Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
            
        }
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        
        //collectionView.delegate = delegate
        
        //collectionView.backgroundView?.alpha = 0
        
        //collectionView.backgroundColor = UIColor.white
        collectionView.backgroundView?.isHidden = true
        
        
        collectionView.reloadData()
    }
    
    func scrollAutomatically(_ timer1: Timer) {
        
        for cell in collectionView.visibleCells {
            let indexPath: IndexPath? = collectionView.indexPath(for: cell)
            let count = Global.categories_gamves[collectionView.tag]?.fanpages.count
            
            if ((indexPath?.row)!  < count! - 1){
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                
                collectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
            }
            else{
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                collectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
            }
            
        }
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
