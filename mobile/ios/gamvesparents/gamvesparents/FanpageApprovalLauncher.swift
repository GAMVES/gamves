//
//  VideoLauncher.swift
//  youtube
//
//  Created by Jose Vigil 08/12/2017.
//

import UIKit
import AVFoundation
import Parse

class FanpageApprovalView: UIView,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{

    var fanpageApprovalView:FanpageApprovalView!
    var keyWindow: UIView!
    
    var fanpageGamves:FanpageGamves!
    
    var yLocation = CGFloat()
    var xLocation = CGFloat()
    var lastX = CGFloat()

    let titleContView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        return view
    }() 

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "FANPAGE APPROVAL"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    let imagesContView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gamvesColor
        return view
    }() 

    let avataCoverContView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()    

    var avatarImage: UIImageView = {
        let imageView = UIImageView()        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.gamvesBackgoundColor
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()    

    var coverImage: UIImageView = {
        let imageView = UIImageView()        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.gamvesBackgoundColor
        imageView.layer.cornerRadius = 5
        return imageView
    }()

    let collectionContView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.gamvesBackgoundColor
        return view
    }()  
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        //cv.backgroundColor = UIColor.gamvesBackgoundColor
        cv.layer.cornerRadius = 2
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellFanId = "cellFanId"
    
    var fanpageImagesArray  = [FanpageImageGamves]()
    
    var fanpageId = Int()
    
    override init(frame: CGRect) {
        super.init(frame: frame)            

        self.addSubview(self.titleContView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.titleContView)

        self.addSubview(self.imagesContView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.imagesContView)        

        self.addConstraintsWithFormat("V:|[v0(100)][v1]|", views: self.titleContView, self.imagesContView)
                    
        self.titleContView.addSubview(self.titleLabel)
        self.titleContView.addConstraintsWithFormat("H:|[v0]|", views: self.titleLabel)
        self.titleContView.addConstraintsWithFormat("V:|-40-[v0]|", views: self.titleLabel)   

        self.imagesContView.backgroundColor = UIColor.gamvesColor
        
        self.imagesContView.addSubview(self.avataCoverContView)
        self.imagesContView.addSubview(self.collectionContView)

        self.imagesContView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.avataCoverContView)
        self.imagesContView.addConstraintsWithFormat("H:|-15-[v0]-15-|", views: self.collectionContView)

        let widthSplit = self.frame.width / 10
        let coverWidth = (widthSplit * 7)
        let height = coverWidth * 9 / 16
        
        let collHeight = (300 - height) - 50
        
        let metricsFan = ["coverWidth" : coverWidth, "height" : height, "collHeight":collHeight]
        
        self.imagesContView.addConstraintsWithFormat("V:|-20-[v0(height)]-30-[v1(collHeight)]-20-|", views:
            self.avataCoverContView, self.collectionContView, metrics: metricsFan)

         self.collectionContView.addSubview(self.collectionView)

        self.collectionContView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.collectionView)
        self.collectionContView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.collectionView)


        self.avataCoverContView.addSubview(self.avatarImage)
        self.avataCoverContView.addSubview(self.coverImage)
        
        self.avataCoverContView.addConstraintsWithFormat("V:|-5-[v0]|", views: self.avatarImage, metrics:metricsFan)
        
        self.avataCoverContView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.coverImage)
        
        self.avataCoverContView.addConstraintsWithFormat("H:|-5-[v0]-15-[v1(coverWidth)]-5-|", views: self.avatarImage, self.coverImage, metrics:metricsFan)

       
        self.collectionView.register(ImagesCollectionViewCell.self, forCellWithReuseIdentifier: self.cellFanId)
    }
    
    override func layoutSubviews() {
        
        self.avatarImage.frame = CGRect(x: self.avatarImage.frame.minX, y: self.avatarImage.frame.minY, width: self.avatarImage.frame.width, height: self.avatarImage.frame.width)

    }
    
    func setFanpageId(fanpageId:Int) {
        print(fanpageId)
        self.fanpageId = fanpageId
    }
    
    func setFanpageGamves(fanpageGamves: FanpageGamves) {
        
        self.fanpageGamves = fanpageGamves
        self.avatarImage.image = fanpageGamves.icon_image
        self.coverImage.image = fanpageGamves.cover_image
        self.fanpageImagesArray = fanpageGamves.fanpage_images
        self.collectionView.reloadData()
        
    }
    
    func setViews(view:UIView, fanpageApprovalView:FanpageApprovalView)
    {
        self.fanpageApprovalView = fanpageApprovalView
        self.keyWindow = view
    }
 
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }   

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.fanpageImagesArray.count
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellImage = collectionView.dequeueReusableCell(withReuseIdentifier: cellFanId, for: indexPath) as! ImagesCollectionViewCell
        
        cellImage.imageView.image = self.fanpageImagesArray[indexPath.row].cover_image
        
        
        return cellImage
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let count:CGFloat = CGFloat(self.fanpageImagesArray.count)
        
        let width =  CGFloat(collectionView.frame.size.width / count)
        
        return CGSize(width: width, height: 190)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let image:UIImage = self.fanpageImagesArray[indexPath.row].cover_image
        
    }
    
}


class FanpageApprovalLauncher: UIView {
    
    var infoApprovalView:InfoApprovalView!
    
    var buttonsApprovalView:ButtonsApprovalView!
    
    var fanpageApprovalView:FanpageApprovalView!
    
    var delegate:ApprovalProtocol!
    
    var view:UIView!
    
    var originaChatYPosition = CGFloat()
    var originaChatHeightPosition = CGFloat()

    func showFanpageList(fanpageGamves: FanpageGamves){
        
        let fanpageId = fanpageGamves.fanpageId
        
        if let keyWindow = UIApplication.shared.keyWindow {

            view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.white
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            
            //16 x 9 is the aspect ratio of all HD videos
            let videoHeight = 400//keyWindow.frame.width * 9 / 16
            let fanpagePlayerFrame = CGRect(x: 0, y: 0, width: Int(keyWindow.frame.width), height: videoHeight)
            
            fanpageApprovalView = FanpageApprovalView(frame: fanpagePlayerFrame)
            print(fanpageGamves.fanpageId)
            print(fanpageGamves.fanpage_images.count)
            fanpageApprovalView.setFanpageId(fanpageId: fanpageGamves.fanpageId)
            fanpageApprovalView.setFanpageGamves(fanpageGamves: fanpageGamves)
            view.addSubview(fanpageApprovalView)

            let infoHeight = 120
            let infoFrame = CGRect(x: 0, y: Int(fanpageApprovalView.frame.height), width: Int(keyWindow.frame.width), height: infoHeight)
            
            infoApprovalView = InfoApprovalView(frame: infoFrame, obj: fanpageGamves)
            view.addSubview(infoApprovalView)

            let diff = Int(videoHeight) + Int(infoHeight)
            let chatHeight = Int(keyWindow.frame.height) - diff
            
            let apprY = Int(fanpageApprovalView.frame.height) + Int(infoApprovalView.frame.height)
            let apprFrame = CGRect(x: 0, y: apprY, width: Int(keyWindow.frame.width), height: chatHeight)
            
            buttonsApprovalView = ButtonsApprovalView(frame: apprFrame, obj: fanpageApprovalView, referenceId: fanpageId, delegate: self.delegate, approved: 0)
            
            buttonsApprovalView.backgroundColor = UIColor.gamvesBackgoundColor
            view.addSubview(buttonsApprovalView)
            buttonsApprovalView.addSubViews()

            fanpageApprovalView.setViews(view: view, fanpageApprovalView: fanpageApprovalView)
            
            keyWindow.addSubview(view)

            view.tag = 1
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in
                    
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
                    
            })
        }
    }
    
}
