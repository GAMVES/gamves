//
//  NewVideoController.swift
//  gamves
//
//  Created by Jose Vigil on 12/3/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import DownPicker
import Alamofire
import NVActivityIndicatorView
import SwiftyJSON
import UITextView_Placeholder
import AVFoundation
import MobileCoreServices
import AWSS3
import AWSCore

protocol VideoProtocol {
    func selectedVideo(videoUrl: String, title: String, description : String, image : UIImage)
}

protocol SearchProtocol {
    func setResultOfsearch(videoId: String, title: String, description : String, duration : String, image : UIImage)
}

public enum UploadType {
    case youtube
    case local
}

class NewFanpageController: UIViewController,
SearchProtocol,
MediaDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    
    var activityIndicatorView:NVActivityIndicatorView?
    
    var type: UploadType!
    
    var homeController: HomeController?
    
    var category = CategoryGamves()

    var current : AnyObject?
    
    var imagesArray = [UIImage]()
    
	let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()
    
    //-- TITTLE
    
    let welcome: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Select category for your new fanpage"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()

    //-- CATEGORY
    
    let categoriesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        //view.backgroundColor = UIColor.white
        return view
    }()
    
    var categoryDownPicker: DownPicker!
    let categoryTypeTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let categorySeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
	//-- NAMES
    
    let namesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.cornerRadius = 5
        return view
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Fanpage name"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let aboutTextField: UITextView  = {
        let tv = UITextView()
        tv.placeholder = "About this fanpage"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let aboutSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //-- ICON
    
    let imagesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let iconConteinerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesBackgoundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var iconButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "camera")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleIcon), for: .touchUpInside)
        button.tag = 0
        return button
    }()
    
    let imageSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let coverConteinerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesBackgoundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var coverButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "camera")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleCover), for: .touchUpInside)
        button.setTitle("Select icon", for: UIControlState())
        button.tag = 0
        return button
    }()
    
    let imagesViewSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //-- IMAGES
    
    let imagesListView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadius = 5
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.gamvesBackgoundColor
        cv.dataSource = self
        cv.delegate = self
        cv.cornerRadius = 5
        return cv
    }()
    
    let imagesSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "add_white")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleAddImages), for: .touchUpInside)
        button.cornerRadius = 20
        //button.backgroundColor = UIColor.white
        button.borderColor = UIColor.white
        button.borderWidth = 2
        return button
    }()
    
    //-- BOTTOM
    
    let saveSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Add fanpage to Gamves", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var metricsNew = [String:CGFloat]()
    
    var newVideoId = String()
    
    var touchedButton = UIButton()
    
    let cellImageCollectionId = "cellImageCollectionId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navItem = UINavigationItem()
        navItem.title = "Share your video"
        
        let buttonArrowBack: UIButton = UIButton (type: UIButtonType.custom)
        buttonArrowBack.setImage(UIImage(named: "arrow_back_white"), for: UIControlState.normal)
        buttonArrowBack.frame = CGRect(x:0, y:0, width:30, height:30)
        buttonArrowBack.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
        let arrowButton = UIBarButtonItem(customView: buttonArrowBack)
        
        navigationItem.leftBarButtonItem = arrowButton

        //-- categoriesContainerView
        
        self.categoryTypeTextField.addTarget(self, action: #selector(self.categoryFieldDidChange(_:)), for: .editingChanged)

        self.view.addSubview(self.scrollView)
		self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView) 
		self.view.addConstraintsWithFormat("V:|[v0]|", views: self.scrollView)
        
        self.scrollView.contentSize.width = self.view.frame.width
        
        let cwidth:CGFloat = self.view.frame.width
        let cp:CGFloat = 12
        let cs:CGFloat = cwidth - (cp*2)
        
        //print(cwidth)
        //print(cp)
        //print(cs)
        
        self.metricsNew["cp"]    =  cp
        self.metricsNew["cs"]    =  cs
    
        self.scrollView.addSubview(self.welcome)
        self.scrollView.addSubview(self.categoriesContainerView)
        self.scrollView.addSubview(self.categorySeparatorView)
        self.scrollView.addSubview(self.namesView)
        self.scrollView.addSubview(self.imagesView)
        self.scrollView.addSubview(self.aboutSeparatorView)
        self.scrollView.addSubview(self.imagesListView)
        self.scrollView.addSubview(self.imagesViewSeparatorView)
        self.scrollView.addSubview(self.saveSeparatorView)
        self.scrollView.addSubview(self.saveButton)
        self.scrollView.addSubview(self.bottomView)
        
        self.scrollView.addConstraintsWithFormat(
            "V:|[v0(40)][v1(40)][v2(cp)][v3(120)][v4(cp)][v5(80)][v6(cp)][v7(100)][v8(cp)][v9(60)][v10]|", views:
            self.welcome,
            self.categoriesContainerView,
            self.categorySeparatorView,
            self.namesView,
            self.aboutSeparatorView,
            self.imagesView,
            self.imagesViewSeparatorView,
            self.imagesListView,
            self.saveSeparatorView,
            self.saveButton,
            self.bottomView,
            metrics: metricsNew)
        
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.welcome, metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.categoriesContainerView, metrics: metricsNew)
        
        self.categoriesContainerView.addSubview(self.categoryTypeTextField)
        
        self.categoriesContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.categoryTypeTextField)
        self.categoriesContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.categoryTypeTextField)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.categorySeparatorView, metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.namesView, metrics: metricsNew)
        
        self.namesView.addSubview(self.nameTextField)
        self.namesView.addSubview(self.nameSeparatorView)
        self.namesView.addSubview(self.aboutTextField)
        
        self.namesView.addConstraintsWithFormat("H:|[v0]|", views: self.nameTextField)
        self.namesView.addConstraintsWithFormat("H:|[v0]|", views: self.nameSeparatorView)
        self.namesView.addConstraintsWithFormat("H:|[v0]|", views: self.aboutTextField)
        
        self.namesView.addConstraintsWithFormat(
            "V:|[v0(40)][v1(1)][v2]|", views:
            self.nameTextField,
            self.nameSeparatorView,
            self.aboutTextField,
            metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.imagesView, metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.imagesViewSeparatorView, metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.aboutSeparatorView, metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.imagesListView, metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.saveSeparatorView, metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.saveButton, metrics: metricsNew)
        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.bottomView, metrics: metricsNew)
        
        self.imagesView.addSubview(self.iconConteinerView)
        self.imagesView.addSubview(self.imageSeparatorView)
        self.imagesView.addSubview(self.coverConteinerView)
        
        self.imagesView.addConstraintsWithFormat("V:|[v0(80)]|", views: self.iconConteinerView)
        self.imagesView.addConstraintsWithFormat("V:|[v0(80)]|", views: self.imageSeparatorView)
        self.imagesView.addConstraintsWithFormat("V:|[v0(80)]|", views: self.coverConteinerView)
        
        self.imagesView.addConstraintsWithFormat(
            "H:|[v0(80)][v1(cp)][v2]|", views:
            self.iconConteinerView,
            self.imageSeparatorView,
            self.coverConteinerView,
            metrics: metricsNew)
        
        self.iconConteinerView.addSubview(self.iconButton)
        self.iconConteinerView.addConstraintsWithFormat("H:|[v0(80)]|", views: self.iconButton)
        self.iconConteinerView.addConstraintsWithFormat("V:|[v0(80)]|", views: self.iconButton)
        
        self.coverConteinerView.addSubview(self.coverButton)
        self.coverConteinerView.addConstraintsWithFormat("H:|[v0(80)]|", views: self.coverButton)
        self.coverConteinerView.addConstraintsWithFormat("V:|[v0(80)]|", views: self.coverButton)
        
        self.imagesListView.addSubview(self.collectionView)
        self.imagesListView.addConstraintsWithFormat("V:|-10-[v0(80)]-10-|", views: self.collectionView)
        
        self.imagesListView.addSubview(self.imagesSeparatorView)
        self.imagesListView.addConstraintsWithFormat("V:|-10-[v0(80)]-10-|", views: self.imagesSeparatorView)
        
        self.imagesListView.addSubview(self.addButton)
        self.imagesListView.addConstraintsWithFormat("V:|-20-[v0(40)]-20-|", views: self.addButton)
        
        self.imagesListView.addConstraintsWithFormat(
            "H:|-10-[v0][v1(cp)][v2(40)]-20-|", views:
            self.collectionView,
            self.imagesSeparatorView,
            self.addButton,
            metrics: metricsNew)
        
        var catArray = [String]()
        
        let ids = Array(Global.categories_gamves.keys)
        
        for i in ids {
            catArray.append((Global.categories_gamves[i]?.name)!)
        }
        let categories: NSMutableArray = catArray as! NSMutableArray
        self.categoryDownPicker = DownPicker(textField: categoryTypeTextField, withData:categories as! [Any])
        self.categoryDownPicker.setPlaceholder("Tap to choose category...")

        self.categoryDownPicker.addTarget(self, action: #selector(selectedCategory), for: UIControlEvents.valueChanged )

		self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)

        //Looks for single or multiple taps.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        self.collectionView.register(ImagesCollectionViewCell.self, forCellWithReuseIdentifier: self.cellImageCollectionId)
    
        //self.prepTextFields(inView: [self.youtubeVideoRowView, self.titleDescContainerView])
        
    }
    
    func backButtonPressed(sender: UIBarButtonItem)
    {
        //self.delegateFeed.uploadData()
        //self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    override func viewWillLayoutSubviews() {
        
        self.scrollView.contentSize.width = self.view.frame.width
    }    
   
    
    func selectedCategory(picker: DownPicker)
    {
        print("changed")
        
        let value = picker.getTextField().text
        let fanpage = FanpageGamves()
        
        let ids = Array(Global.categories_gamves.keys)
        
        for i in ids {
            let cat = Global.categories_gamves[i]
            if cat?.name == value
            {
                self.category = cat!
            }
        }
        
        var fanArray = [String]()
        for fan in self.category.fanpages
        {
            fanArray.append(fan.name)
        }
        let fanpages = fanArray as! NSMutableArray
    
    }
    
    var thumbnailImage      = UIImage()
    var thumbnail_url       = String()
    var author_name         = String()
    var videoTitle          = String()
    var videoDescription    = String()
    var videoId             = String()
    var video_url           = String()

    var upload_date = String()
    var view_count  = String()
    var tags        = String()
    var duration    = String()
    var categories  = String()
    var like_count  = String()

    //LEAVE IT FOR SEARCHING IMAGES
    func getVideoDataUser(videoId: String, completionHandler : @escaping (_ resutl:Bool) -> ()){

    	let urlString = "\(Global.api_image_base)\(videoId)\(Global.api_image_format)"
        
        print(urlString)

        Alamofire.request(urlString, method: .get)
            .responseJSON { response in
                
                print("Success: \(response.result.isSuccess)")
                
                switch response.result {
                    case .success:
                        
                        if let json = response.result.value as? [String: Any]
                        {
                            let result = json["result"] ?? 0
                            self.thumbnail_url = (json["thumbnail_url"] as? String)!
                            self.author_name = (json["author_name"] as? String)!
                            self.videoTitle = (json["title"] as? String)!

                            print(self.thumbnail_url)
							print(self.author_name)
							print(self.videoTitle)                            

                            let coverURL = URL(string: self.thumbnail_url)!
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
                                    self.thumbnailImage = UIImage(data:data)!
                                    
                                    completionHandler(true)
                                    
                                }
                                
                            }
                            downloadCover.resume()
                            
                        }
                        
                        break
                    case .failure(let error):
                        print(error)
                }
           }
    }

    func getVideoDescription(videoId: String, completionHandlerDesc : @escaping (_ resutl:Bool) -> ()){

    	let urlString = "\(Global.api_desc_base)\(videoId)\(Global.api_desc_middle)\(Global.api_key)"
        
        print(urlString)

        Alamofire.request(urlString, method: .get)
            .responseJSON { response in
                
                print("Success: \(response.result.isSuccess)")
                
                switch response.result {
                    case .success:
                        
                        let jsonResponse = JSON(response.result.value!)
                            
                        var jsonArr:[JSON] = jsonResponse["items"].arrayValue
                        
                        var snptJson = jsonArr[0]["snippet"] as JSON
                        
                        self.videoDescription = snptJson["description"].stringValue
                        
                        print(self.videoDescription)
                        
                        
                        break
                    case .failure(let error):
                        print(error)
                }
           }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }
    
    
    
    func categoryFieldDidChange(_ textField: UITextField) {

	}

	func handleSearch() {
        self.type = UploadType.youtube
        
    }

    
    func handleCover() {
        self.touchedButton = coverButton
        let media = MediaController()
        media.delegate = self
        media.setType(type: MediaType.selectImage)
        media.searchType = SearchType.isSingleImage
        navigationController?.pushViewController(media, animated: true)
    }
  
    func handleIcon() {
        self.touchedButton = iconButton
        let media = MediaController()
        media.delegate = self
        media.setType(type: MediaType.selectImage)
        media.searchType = SearchType.isImageGallery
        navigationController?.pushViewController(media, animated: true)
    }
    
    func handleAddImages() {
        let media = MediaController()
        media.delegate = self
        media.setType(type: MediaType.selectImage)
        media.searchType = SearchType.isSingleImage
        navigationController?.pushViewController(media, animated: true)
    }

    
    func didPickImage(_ image: UIImage){
        self.touchedButton.setImage(image, for: .normal)
    }
    
    func didPickImages(_ images: [UIImage]){
        self.imagesArray = images
        self.collectionView.reloadData()
    }
    
    
    func didPickVideo(url: URL, data: Data, thumbnail: UIImage) {}
    

   	func handleVideo() {
        self.type = UploadType.local
        let media = MediaController()
        media.delegate = self
        media.setType(type: MediaType.selectVideo)
        navigationController?.pushViewController(media, animated: true)
    }
    
    func setResultOfsearch(videoId: String, title: String, description : String, duration: String, image : UIImage)
    {
    	self.videoId = videoId
    	self.videoTitle = title
    	self.videoDescription = description
    	self.thumbnailImage = image
        self.video_url = "https://www.youtube.com/watch?v=" + self.videoId
    	
    }
    
    func handleSave() {
        
        if !checErrors()
        {
            
            self.activityIndicatorView?.startAnimating()
            
            let fanpagePF: PFObject = PFObject(className: "Fanpages")
            
            fanpagePF["title"] = self.nameTextField.text
            
            fanpagePF["title"] = self.nameTextField.text
        }
    }
    
    
    func checErrors() -> Bool
    {
        var errors = false
        let title = "Error"
        var message = ""
        
        if self.videoSelThumbnail == nil
        {
            errors = true
            message += "Thumbnail image is empty please add a new video"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
            
        } else if self.videoSelData == nil
        {
            errors = true
            message += "Please choose a video"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
            
        } else if (self.categoryTypeTextField.text?.isEmpty)!
        {
            errors = true
            message += "Catgory is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.categoryTypeTextField)
            
        }
        
        return errors
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.imagesArray.count
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellImage = collectionView.dequeueReusableCell(withReuseIdentifier: cellImageCollectionId, for: indexPath) as! ImagesCollectionViewCell
        
        cellImage.imageView.image = self.imagesArray[indexPath.row]
        
        return cellImage
        
        return cellImage
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = (view.frame.width - 16 - 16) * 9 / 16
        
        return CGSize(width: view.frame.width, height: height + 16 + 88)
        
    }*/
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let image:UIImage = self.imagesArray[indexPath.row]
        
    }

}

