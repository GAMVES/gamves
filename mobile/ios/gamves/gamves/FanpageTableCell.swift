//
//  FanpageCollectionCell.swift
//  gamves
//
//  Created by Jose Vigil on 2018-09-06.
//

import UIKit

class FanpageTableCell: UITableViewCell, 
UICollectionViewDataSource, 
UICollectionViewDelegate, 
UICollectionViewDelegateFlowLayout {
    
    var albums = [GamvesAlbum]()   

    var delegate:FanpageCollectionsDelegate!

    fileprivate let cellId = "appCellId"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }   
    
    let albumCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)        
        cv.backgroundColor = UIColor.clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        //cv.dataSource = self
        //cv.delegate = self
        return cv
    }()    
    
    func setupViews() {
        
        backgroundColor = UIColor.clear
        
        addSubview(albumCollectionView)        
        
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        
        self.albumCollectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: cellId)       
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.albumCollectionView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.albumCollectionView)         
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if let count = appCategory?.apps?.count {
        //    return count
        //}

        return self.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AlbumCollectionViewCell

        let album = self.albums[indexPath.item]

        cell.imageView.image = album.cover_image  

        //cell.app = appCategory?.apps?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        var width = 100

        let album = self.albums[indexPath.item]        

        if let x:CGFloat = album.cover_image.size.width,
           let y:CGFloat = album.cover_image.size.height {

            if x > y {
                width = 200
            }
        }

        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 14, 0, 14)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.delegate.albumSection(albums: self.albums, index:indexPath.row)
        
    }

}



/*extension FanpageTableCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        if row == 0 {
            
            Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
            
        }
        
        self.albumCollectionView.delegate = dataSourceDelegate
        self.albumCollectionView.dataSource = dataSourceDelegate
        self.albumCollectionView.tag = row
        
        self.albumCollectionView.setContentOffset(self.albumCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        self.albumCollectionView.backgroundView?.isHidden = true        
        self.albumCollectionView.reloadData()
    }
    
    @objc func scrollAutomatically(_ timer1: Timer) {
        
        for cell in self.albumCollectionView.visibleCells {
            let indexPath: IndexPath? = self.albumCollectionView.indexPath(for: cell)
            let count = Global.categories_gamves[self.albumCollectionView.tag]?.fanpages.count
            
            if ((indexPath?.row)!  < count! - 1){
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                
                self.albumCollectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
            }
            else{
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                self.albumCollectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
            }
            
        }
    }
    
    var collectionViewOffset: CGFloat
    {
        set
        {
            self.albumCollectionView.contentOffset.x = newValue
        }
        
        get {
            return self.albumCollectionView.contentOffset.x
        }
    }
}*/







