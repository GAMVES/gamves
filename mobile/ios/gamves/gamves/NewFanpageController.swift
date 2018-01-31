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

class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

protocol VideoProtocol {
    func selectedVideo(videoUrl: String, title: String, description : String, image : UIImage)
}

protocol SearchProtocol {
    func setResultOfsearch(videoId: String, title: String, description : String, duration : String, image : UIImage)
    func setVideoSearchType(type: UploadType)
}

public enum UploadType {
    case youtube
    case local
}


public enum TouchedButton {
    case iconImage
    case coverImage
    case addButton
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
    
    var touchedButton : TouchedButton!
    
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
    let categoryTypeTextField: PaddedTextField = {
        let tf = PaddedTextField()
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
    
    let nameTextField: PaddedTextField = {
        let tf = PaddedTextField()
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
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let aboutSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //-- IMAGES
    
    let imagesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //-- ICON
    
    let iconContView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesBackgoundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()

     let iconLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Avatar"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        //label.backgroundColor = UIColor.white
        label.textColor = UIColor.white
        label.textAlignment = .center        
        return label
    }()   

    var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "camera")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true                
        return imageView
    }()
    
    let imageSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var iconButton: UIButton = {
        let button = UIButton()        
        button.translatesAutoresizingMaskIntoConstraints = false        
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleIcon), for: .touchUpInside)          
        button.layer.cornerRadius = 5   
        //button.backgroundColor = UIColor.gray   
        return button
    }()
    
    var backgroundIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
        //imageView.backgroundColor = UIColor.green
        imageView.layer.cornerRadius = 5
        return imageView
    }()

    //-- COVER
    
    let coverContView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesBackgoundColor        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5        
        return view
    }()

    var coverImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "camera")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSonPhotoImageView)))
        imageView.isUserInteractionEnabled = true        
        //imageView.tag = 1
        return imageView
    }()

    let coverLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Background image"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        //label.backgroundColor = UIColor.white
        label.numberOfLines = 2
        label.textColor = UIColor.white
        label.textAlignment = .center        
        return label
    }()

    var coverButton: UIButton = {
        let button = UIButton()        
        button.translatesAutoresizingMaskIntoConstraints = false        
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleCover), for: .touchUpInside)          
        button.layer.cornerRadius = 5              
        //button.backgroundColor = UIColor.gray
        return button
    }()

    var backgroundCoverImage: UIImageView = {
        let imageView = UIImageView()        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
        //imageView.backgroundColor = UIColor.green
        imageView.layer.cornerRadius = 5
        return imageView
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

    let imagesLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Fanpage images list"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        //label.backgroundColor = UIColor.white
        label.numberOfLines = 2
        label.textColor = UIColor.white
        label.textAlignment = .center        
        return label
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
    
    let cellImageCollectionId = "cellImageCollectionId"
    
    var selectedIconImage = UIImage()
    var selectedCoverImage = UIImage()

    var collRect:CGRect!
    
    var fanpageOrder = Int()
    
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
        
        self.imagesView.addSubview(self.iconContView)
        self.imagesView.addSubview(self.imageSeparatorView)
        self.imagesView.addSubview(self.coverContView)
        self.imagesView.addSubview(self.iconButton)
        
        self.imagesView.addSubview(self.coverButton) 
        self.imagesView.addSubview(self.backgroundCoverImage)
        self.imagesView.addSubview(self.backgroundIconImage)
        
        self.imagesView.addConstraintsWithFormat("V:|[v0(80)]|", views: self.iconContView)
        self.imagesView.addConstraintsWithFormat("V:|[v0(80)]|", views: self.imageSeparatorView)
        self.imagesView.addConstraintsWithFormat("V:|[v0(80)]|", views: self.coverContView)
        
        self.imagesView.addConstraintsWithFormat(
            "H:|[v0(80)][v1(cp)][v2]|", views:
            self.iconContView,
            self.imageSeparatorView,
            self.coverContView,
            metrics: metricsNew)
        
        self.iconContView.addSubview(self.iconImage)
        self.iconContView.addSubview(self.iconLabel)
      
        self.iconContView.addConstraintsWithFormat("H:|-15-[v0(50)]-15-|", views: self.iconImage)        
        self.iconContView.addConstraintsWithFormat("H:|[v0(80)]|", views: self.iconLabel)        

        self.iconContView.addConstraintsWithFormat(
            "V:|-5-[v0(50)][v1(20)]-5-|", views:
            self.iconImage,
            self.iconLabel)

        //iconImage.backgroundColor = UIColor.red
        //iconLabel.backgroundColor = UIColor.green                
        
        self.coverContView.addSubview(self.coverImage)
        self.coverContView.addSubview(self.coverLabel)        

        self.coverContView.addConstraintsWithFormat("H:|-15-[v0(50)][v1]-20-|", views: 
            self.coverImage,
            self.coverLabel)

        self.coverContView.addConstraintsWithFormat("V:|-5-[v0(50)]-25-|", views: self.coverImage)
        self.coverContView.addConstraintsWithFormat("V:|-5-[v0(70)]-5-|", views: self.coverLabel)

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

        self.imagesListView.addSubview(self.imagesLabel)        
        
        var catArray = [String]()
        
        let ids = Array(Global.categories_gamves.keys)        
        var categories = [String]()
        for i in ids {
            let cat = Global.categories_gamves[i]?.name as! String
            categories.append(cat)
        }
        self.categoryDownPicker = DownPicker(textField: categoryTypeTextField, withData:categories as! [Any])
        self.categoryDownPicker.setPlaceholder("Tap to choose category...")

        self.categoryDownPicker.addTarget(self, action: #selector(selectedCategory), for: UIControlEvents.valueChanged )

		self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)

        //Looks for single or multiple taps.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        self.collectionView.register(ImagesCollectionViewCell.self, forCellWithReuseIdentifier: self.cellImageCollectionId)
    
        //self.prepTextFields(inView: [self.youtubeVideoRowView, self.titleDescContainerView])
        
        self.prepTextFields(inView: [self.namesView])
        
    }
    
    override func viewDidLayoutSubviews() {

        DispatchQueue.main.async {        
            
            self.iconButton.frame = self.iconContView.bounds

            var frc: CGRect = self.coverContView.frame
            self.coverButton.frame = frc
            self.backgroundCoverImage.frame = frc
            
            var fri: CGRect = self.iconContView.frame
            self.backgroundIconImage.frame = fri

            self.imagesLabel.frame = self.collectionView.bounds

            self.collRect = self.collectionView.frame
            
        }
        
    }
    
    func backButtonPressed(sender: UIBarButtonItem) {
        //self.delegateFeed.uploadData()
        //self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func dismissKeyboard() {
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
        let fanpages = fanArray //as! NSMutableArray
        
        self.queryFanpageOrder()
    
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
        self.touchedButton = TouchedButton.coverImage
        let media = MediaController()
        media.isImageMultiSelection = false
        media.delegate = self
        media.termToSearch = self.nameTextField.text!
        media.setType(type: MediaType.selectImage)
        media.searchType = SearchType.isSingleImage
        media.searchSize = SearchSize.imageSmall
        navigationController?.pushViewController(media, animated: true)
    }
  
    func handleIcon() {
        self.touchedButton = TouchedButton.iconImage
        let media = MediaController()
        media.delegate = self
        media.isImageMultiSelection = false
        media.setType(type: MediaType.selectImage)
        media.termToSearch = self.nameTextField.text!
        media.searchType = SearchType.isImageGallery
        media.searchSize = SearchSize.imageSmall
        navigationController?.pushViewController(media, animated: true)
    }
    
    func handleAddImages() {
        self.touchedButton = TouchedButton.addButton
        let media = MediaController()
        media.delegate = self
        media.isImageMultiSelection = true
        media.setType(type: MediaType.selectImage)
        media.termToSearch = self.nameTextField.text!
        media.searchType = SearchType.isSingleImage
        media.searchSize = SearchSize.imageLarge
        navigationController?.pushViewController(media, animated: true)
    }

    func didPickImage(_ image: UIImage){
        
        if self.touchedButton == TouchedButton.iconImage {
        
            self.selectedIconImage = image
            
            //self.iconButton.setImage(image, for: .normal)            
            //self.iconButton.layer.cornerRadius = 5
            //self.iconButton.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            
            let size = CGSize(width: self.backgroundIconImage.frame.width, height: self.backgroundIconImage.frame.height)
            
            self.backgroundIconImage.image = self.scaleUIImageToSize(image: image, size: size)
            
            self.backgroundIconImage.layer.cornerRadius = 5
            self.backgroundIconImage.clipsToBounds = true
            
        } else if self.touchedButton == TouchedButton.coverImage {

            self.selectedCoverImage = image
        
            let size = CGSize(width: self.backgroundCoverImage.frame.width, height: self.backgroundCoverImage.frame.height)
        
            self.backgroundCoverImage.image = self.scaleUIImageToSize(image: image, size: size)
        
            self.backgroundCoverImage.layer.cornerRadius = 5
            self.backgroundCoverImage.clipsToBounds = true
            
        } else if self.touchedButton == TouchedButton.addButton {
            
            self.imagesArray.append(image)
            self.collectionView.reloadData()            
            
        }
        
    }

    func scaleUIImageToSize( image: UIImage, size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: .zero, size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage!
    }
    
    func didPickImages(_ images: [UIImage]){
        
        for image in images {
            self.imagesArray.append(image)
        }
        self.imagesLabel.isHidden = true
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
    
    func setResultOfsearch(videoId: String, title: String, description : String, duration: String, image : UIImage) {
    	self.videoId = videoId
    	self.videoTitle = title
    	self.videoDescription = description
    	self.thumbnailImage = image
        self.video_url = "https://www.youtube.com/watch?v=" + self.videoId
    }
    
    func setVideoSearchType(type: UploadType) {
    
    }
    
    func handleSave() {
        
        if !checErrors()
        {
            
            var albumsPF = [PFObject]()
            
            self.activityIndicatorView?.startAnimating()
            
            var count = 1
            
            let fanpagePF: PFObject = PFObject(className: "Fanpages")
            
            let fanpageAlbumRelation = fanpagePF.relation(forKey: "albums")
            
            for image in self.imagesArray {
            
                let albumPF: PFObject = PFObject(className: "Albums")
                
                let filename = "\(Global.generateFileName()).png"
                
                let imageFile = PFFile(name: filename, data: UIImageJPEGRepresentation(image, 1.0)!)
                
                albumPF["cover"] = imageFile
                
                albumPF["name"] = "\(count)"
                
                do {
                
                   try albumPF.saveInBackground()
                
                } catch let error {
                    print(error.localizedDescription)
                }
                
                fanpageAlbumRelation.add(albumPF)
                
                albumsPF.append(albumPF)
                
                count = count + 1
                
            }
            
            fanpagePF["pageName"] = self.nameTextField.text
            
            fanpagePF["pageAbout"] = self.aboutTextField.text
            
            fanpagePF["order"] = self.fanpageOrder
            
            let filenameIcon = "icon.png"
            
            let iconImageFile = PFFile(name: filenameIcon, data: UIImageJPEGRepresentation(self.selectedIconImage, 1.0)!)
            
            fanpagePF.setObject(iconImageFile, forKey: "pageIcon")
            
            let coverIcon = "cover.png"
            
            let coverImageFile = PFFile(name: coverIcon, data: UIImageJPEGRepresentation(self.selectedCoverImage, 1.0)!)
        
            fanpagePF.setObject(coverImageFile, forKey: "pageCover")
            
            var fanpageId = Global.getRandomInt()
            
            fanpagePF["fanpageId"] = fanpageId
            
            let categoryRelation = fanpagePF.relation(forKey: "category")
            categoryRelation.add(self.category.cateobj!)
            
            fanpagePF["categoryName"] = self.category.name
            
            fanpagePF["approved"] = false
            
            //let userPointer = PFObject(withoutDataWithClassName: "User", objectId: PFUser.current()?.objectId)            
            //fanpagePF["author"] = userPointer
            
            let authorRelation = fanpagePF.relation(forKey: "author")
            authorRelation.add(PFUser.current()!)
            
            fanpagePF.saveInBackground(block: { (fanpge, error) in
                
                if error == nil {
                    
                    for albumObj  in albumsPF {
                        
                        albumObj["referenceId"] = fanpageId
                       
                        do {
                            
                            try albumObj.saveInBackground()
                            
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
            
                    let approvals: PFObject = PFObject(className: "Approvals")
                    
                    approvals["referenceId"] = fanpageId
                    approvals["posterId"] = PFUser.current()?.objectId
                    let familyId = Global.gamvesFamily.objectId
                    approvals["familyId"] = familyId
                    approvals["approved"] = 0
                    approvals["title"] = self.nameTextField.text
                    approvals["type"] = 2
                    
                    approvals.saveInBackground { (resutl, error) in
                        
                        if error == nil {
                            
                            self.activityIndicatorView?.startAnimating()
                            
                            var message = String()
                            
                            if let fanpageName = self.nameTextField.text {
                                message = "The fanpage \(fanpageName) has been created and sent to your parents for appoval. Thanks for submitting!"
                            }
                            
                            let title = "Fanpage created!"
                            
                            let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                                
                                self.navigationController?.popToRootViewController(animated: true)
                                
                            }))
                            
                            self.present(alert, animated: true)
                            
                        }
                    }
                }
                
            })
            
        }
    }
    
    func queryFanpageOrder() {
        
        let queryFanpages = PFQuery(className: "Fanpages")
        print(self.category.name)
        queryFanpages.whereKey("category", equalTo: self.category.cateobj)
        queryFanpages.order(byDescending: "order")
        queryFanpages.getFirstObjectInBackground { (fanpage, error) in
            
            if error == nil
            {
                let count = fanpage!["order"] as! Int
                
                self.fanpageOrder = count + 1
                
                print("error: \(error)")
                
            } else {
                
                self.fanpageOrder = 0
                
            }
        }
    }
        
    
    
    func checErrors() -> Bool {
        var errors = false
        let title = "Error"
        var message = ""
        
        if (self.categoryTypeTextField.text?.isEmpty)!
        {
            errors = true
            message += "Catgory is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.categoryTypeTextField)
    
        } else if (self.nameTextField.text?.isEmpty)!
        {
            errors = true
            message += "Fanpage name cannot be empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.nameTextField)
            
        } else if (self.aboutTextField.text?.isEmpty)!
        {
            errors = true
            message += "Please provide and about description"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.aboutTextField)
            
        }  else if self.iconImage == nil
        {
            errors = true
            message += "Icon image is empty please add a new image"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
            
        }  else if self.coverImage == nil
        {
            errors = true
            message += "Cover image is empty please add a new image"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
            
        }  else if self.imagesArray.count < 2
        {
            errors = true
            message += "Image gallery must have at least three images, please add them"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
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
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        let height = self.collRect.height
        
        //let width = (height * 16 / 9) + 32
        
        let count:CGFloat = CGFloat(self.imagesArray.count)
        
        let width =  CGFloat(collectionView.frame.size.width / count)
        
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let image:UIImage = self.imagesArray[indexPath.row]
        
    }

}

