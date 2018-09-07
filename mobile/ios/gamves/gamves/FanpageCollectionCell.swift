//
//  FanpageCollectionCell.swift
//  gamves
//
//  Created by Jose Vigil on 2018-09-06.
//

import UIKit

class FanpageCollectionCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var albums = [GamvesAlbum]()   

    fileprivate let cellId = "appCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }   
    
    let albumCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)        
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()    
    
    func setupViews() {
        backgroundColor = UIColor.clear
        
        addSubview(albumCollectionView)        
        
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        
        self.albumCollectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: cellId)       
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.albumCollectionView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.albumCollectionView)  

        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: 0, repeats: true)              
        
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
        
        /*if let app = appCategory?.apps?[indexPath.item] {
            featuredAppsController?.showAppDetailForApp(app)
        }*/
        
    }

     @objc func scrollAutomatically(_ sender: Timer) {
        
        var section = sender.userInfo as! Int
        
        for cell in self.albumCollectionView.visibleCells {
            let indexPath: IndexPath? = self.albumCollectionView.indexPath(for: cell)
            if ((indexPath?.row)!  < self.albums.count - 1){
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

    
}







