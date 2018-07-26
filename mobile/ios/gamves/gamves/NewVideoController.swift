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

class NewVideoController: UIViewController,
SearchProtocol,
MediaDelegate,
SelectorProtocol {
    
    var type: UploadType!
    
    var homeController: HomeController?
    
    var category = GamvesCategory()
    var fanpage = GamvesFanpage()
    var current : AnyObject?
    
	let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()

	//-- TITTLE
    
    let selectCategory: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Select category for your video"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    //-- CATEGORY     

    let categoriesContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    let categoryTypeSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var selectorCategoryView:SelectorView!
    
    let categorySeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //-- FANPAGE

    let selectFanpage: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Select fanpage for your category"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    var selectorFanpageView:SelectorView!  

    //-- localVideoRowView local

     let localVideoRowView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.gamvesColor
        return view
    }() 

    lazy var videoButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Choose video", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleVideo), for: .touchUpInside)       
        button.layer.cornerRadius = 5
        button.isEnabled = false
        return button
    }()	

    let localVideoSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

	//-- previewVideoRowView 

    let previewVideoRowView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5   
        return view
    }()
    
    let previewVideoSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()    


	let thumbnailConteinerView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesBackgoundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var cameraButton: UIButton = {
        let cameraButton = UIButton()
        let image = UIImage(named: "camera")
        cameraButton.setImage(image, for: .normal)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.contentMode = .scaleAspectFit
        cameraButton.isUserInteractionEnabled = true
        cameraButton.addTarget(self, action: #selector(handleCameraImage), for: .touchUpInside)
        cameraButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        cameraButton.tag = 0
        cameraButton.isEnabled = false
        return cameraButton
    }()

    let thumbnailSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


	let titleDescContainerView: UIView = {
        let view = UIView()                
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Title"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white
        tf.tag = 1
        tf.isEnabled = false
        return tf
    }()

    let titleDescSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let descriptionTextView: UITextView  = {
        let tv = UITextView()
        tv.placeholder = "Description"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.tag = 2
        tv.isEditable = false
        return tv
    }()
   
    //-- save

    var activityIndicatorView:NVActivityIndicatorView?

    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Add video to Gamves", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSave(sender:)), for: .touchUpInside)       
        button.layer.cornerRadius = 5
        button.isEnabled = false
        return button
    }()

    let bottomView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var searchController: SearchController = {
        let search = SearchController()
        search.newVideoController = self
        search.delegateSearch = self
        return search
    }()
    
    var metricsNew = [String:CGFloat]()
    
    var videoSelLocalUrl:URL?
    var videoSelData = Data()
    var videoSelThumbnail = UIImage()
    
    var newVideoId = String()   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.saveButton.isEnabled = true       
        
        let navItem = UINavigationItem()
        navItem.title = "Share your video"
        
        let buttonArrowBack: UIButton = UIButton (type: UIButtonType.custom)
        buttonArrowBack.setImage(UIImage(named: "arrow_back_white"), for: UIControlState.normal)
        buttonArrowBack.frame = CGRect(x:0, y:0, width:30, height:30)
        buttonArrowBack.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
        let arrowButton = UIBarButtonItem(customView: buttonArrowBack)
        
        navigationItem.leftBarButtonItem = arrowButton

		self.view.addSubview(self.scrollView)
        
        //-- categoriesContainerView
        
        //self.categoryTypeTextField.addTarget(self, action: #selector(self.categoryFieldDidChange(_:)), for: .editingChanged)

		self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView) 
		self.view.addConstraintsWithFormat("V:|[v0]|", views: self.scrollView)
    
        self.scrollView.contentSize.width = self.view.frame.width

        self.scrollView.addSubview(self.selectCategory)
        self.scrollView.addSubview(self.categoriesContainerView)
        self.scrollView.addSubview(self.categorySeparatorView)        
        self.scrollView.addSubview(self.localVideoRowView)
        self.scrollView.addSubview(self.localVideoSeparatorView)        
        self.scrollView.addSubview(self.previewVideoRowView)
        self.scrollView.addSubview(self.previewVideoSeparatorView)
        self.scrollView.addSubview(self.saveButton)
        self.scrollView.addSubview(self.bottomView)

        
        let cwidth:CGFloat = self.view.frame.width
        let cp:CGFloat = 20
        let cs:CGFloat = cwidth - (cp*2)
        
        print(cwidth)
        print(cp)
        print(cs)
        
        self.metricsNew["cp"]    =  cp
        self.metricsNew["cs"]    =  cs      

        self.metricsNew["yt"]  =  40
        self.metricsNew["cy"]  =  cp       

        self.scrollView.addConstraintsWithFormat(
            "V:|[v0(40)][v1(340)][v2(cp)][v3(60)][v4(cy)][v5(120)][v6(cp)][v7(60)][v8]|", views:
            self.selectCategory,
            self.categoriesContainerView,
            self.categorySeparatorView,            
            self.localVideoRowView,
            self.localVideoSeparatorView,            
            self.previewVideoRowView,
            self.previewVideoSeparatorView,
            self.saveButton,
            self.bottomView,
            metrics: metricsNew)           
        
        self.scrollView.addConstraintsWithFormat("H:|[v0(cs)]|", views: self.selectCategory, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.categoriesContainerView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.categorySeparatorView, metrics: metricsNew)        
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.localVideoRowView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.localVideoSeparatorView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.previewVideoRowView, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.saveButton, metrics: metricsNew)
        self.scrollView.addConstraintsWithFormat("H:|-cp-[v0(cs)]-cp-|", views: self.bottomView, metrics: metricsNew)        
      
	    //-- categoriesContainerView
        
        let selectorWidth = cwidth - 20
        let selRect = CGRect(x: 0, y: 0, width: cwidth, height: 150)
        
        self.selectorCategoryView = SelectorView(frame: selRect, isEdit: false)
        self.selectorCategoryView.setSelectorType(type: SelectorType.TypeCategory)
        self.selectorCategoryView.delegateSelector = self
        
        self.categoriesContainerView.addSubview(self.selectorCategoryView)
        self.categoriesContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.selectorCategoryView)
        
        self.categoriesContainerView.addSubview(self.categoryTypeSeparatorView)
        self.categoriesContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.categoryTypeSeparatorView)

        self.categoryTypeSeparatorView.addSubview(self.selectFanpage)
        self.categoryTypeSeparatorView.addConstraintsWithFormat("H:|[v0]|", views: self.selectFanpage)
        self.categoryTypeSeparatorView.addConstraintsWithFormat("V:|[v0]|", views: self.selectFanpage)
        
        self.selectorFanpageView = SelectorView(frame: selRect, isEdit: false)
        self.selectorFanpageView.delegateSelector = self
        self.selectorFanpageView.setSelectorType(type: SelectorType.TypeFanpage)

        self.categoriesContainerView.addSubview(self.selectorFanpageView)
        self.categoriesContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.selectorFanpageView)
        
        self.categoriesContainerView.addConstraintsWithFormat(
            "V:|[v0(150)][v1(40)][v2(150)]|",
            views:
            self.selectorCategoryView,
            self.categoryTypeSeparatorView,
            self.selectorFanpageView)
        
        let ids = Array(Global.categories_gamves.keys)
        var categories = [String]()
        for i in ids {
            let cat = Global.categories_gamves[i]?.name as! String
            categories.append(cat)
        }        

        self.localVideoRowView.addSubview(self.videoButton)             

        self.localVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.videoButton)
        self.localVideoRowView.addConstraintsWithFormat("H:|[v0]|", views:
            self.videoButton)

        //-- previewVideoRowView 
    
        self.previewVideoRowView.addSubview(self.thumbnailConteinerView)
        self.previewVideoRowView.addSubview(self.thumbnailSeparatorView)    
        self.previewVideoRowView.addSubview(self.titleDescContainerView)            

        self.previewVideoRowView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.thumbnailConteinerView)      
        self.previewVideoRowView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.thumbnailSeparatorView)  
        self.previewVideoRowView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.titleDescContainerView)
        self.previewVideoRowView.addConstraintsWithFormat("H:|[v0(120)][v1(2)][v2]|", views: 
            self.thumbnailConteinerView,
            self.thumbnailSeparatorView,
            self.titleDescContainerView)

        self.thumbnailConteinerView.addSubview(self.cameraButton)
        self.previewVideoRowView.addConstraintsWithFormat("H:|[v0]|", views: self.cameraButton)
        self.previewVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.cameraButton)

        self.titleDescContainerView.addSubview(self.titleTextField)
        self.titleDescContainerView.addSubview(self.titleDescSeparatorView)     
        self.titleDescContainerView.addSubview(self.descriptionTextView)

        self.titleDescContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.titleTextField)    
        self.titleDescContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.titleDescSeparatorView)    
        self.titleDescContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.descriptionTextView)

        self.titleDescContainerView.addConstraintsWithFormat("V:|[v0(40)][v1(2)][v2]|", views:
            self.titleTextField,
            self.titleDescSeparatorView,
            self.descriptionTextView)   
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor) //,x: 0, y: 0, width: 80.0, height: 80.0)

        //Looks for single or multiple taps.
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        self.prepTextFields(inView: [self.titleDescContainerView])

        self.categoryTypeSeparatorView.isHidden = true
        self.selectorFanpageView.isHidden = true

        self.localVideoRowView.isHidden = true
        self.localVideoSeparatorView.isHidden = true   

        self.previewVideoRowView.isHidden = true
        self.previewVideoSeparatorView.isHidden = true
        self.saveButton.isHidden = true
        self.bottomView.isHidden = true
        
    }
    
    func categorySelected(category: GamvesCategory) {
        self.categoryTypeSeparatorView.isHidden = false
        self.selectorFanpageView.isHidden = false  
        self.selectorFanpageView.loadFanpage(category: category)        
    }
    
    func fanpageSelected(fanpage: GamvesFanpage) {
        
        self.fanpage = fanpage

        self.localVideoRowView.isHidden = false
        self.localVideoSeparatorView.isHidden = false   
        
        self.videoButton.isEnabled = true
        self.cameraButton.isEnabled = true
        self.titleTextField.isEnabled = true
        self.descriptionTextView.isEditable = true

    }
    
    func reoadFanpageCollection() {
        self.selectorFanpageView.collectionView.reloadData()
    }
    
    func backButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
      
    override func viewWillLayoutSubviews() {
        
        self.scrollView.contentSize.width = self.view.frame.width
        
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
    
    func handleVideo() {
        self.type = UploadType.local
        let media = MediaController()
        media.delegate = self
        media.delegateSearch = self
        //media.termToSearch = fanpageTextField.text!
        //media.termToSearch = self.fanpage.name
        media.setType(type: MediaType.selectVideo)
        media.setSearchType(type: SearchType.isVideo)
        navigationController?.pushViewController(media, animated: true)
    }

	func handleSearch() {
        self.type = UploadType.youtube
        //searchController.termToSearch = fanpageTextField.text!
        //searchController.termToSearch = self.fanpage.name
        searchController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(searchController, animated: true)
    }

  
    func handleCameraImage() {
        let media = MediaController()
        media.delegate = self
        media.delegateSearch = self
        //media.termToSearch = fanpageTextField.text!
        media.termToSearch = self.fanpage.name
        media.setType(type: MediaType.selectImage)
        navigationController?.pushViewController(media, animated: true)
    }
    
    func didPickImage(_ image: UIImage){
        self.cameraButton.setImage(image, for: .normal)
        self.videoSelThumbnail = image
    }
    
    func didPickVideo(url: URL, data: Data, thumbnail: UIImage) {

        self.showVideoRow()
        
        self.videoSelLocalUrl = url
        self.videoSelData = data
        self.videoSelThumbnail = thumbnail
        
        DispatchQueue.main.async()
        {
            self.cameraButton.setImage(thumbnail, for: .normal)
        }
        
    }

    func setResultOfsearch(videoId: String, title: String, description : String, duration: String, image : UIImage)
    {
        self.showVideoRow()

    	self.videoId = videoId
    	self.videoTitle = title
    	self.videoDescription = description
    	self.thumbnailImage = image
        self.videoSelThumbnail = image

        self.video_url = "https://www.youtube.com/watch?v=" + self.videoId        
        
    	self.titleTextField.text = title
    	self.descriptionTextView.text = description
    	self.cameraButton.setImage(image, for: .normal)
        
        self.saveButton.isEnabled = true
        
    }

    func showVideoRow()
    {
        self.previewVideoRowView.isHidden = false
        self.previewVideoSeparatorView.isHidden = false
        self.saveButton.isHidden = false
        self.bottomView.isHidden = false
    }
    
    func setVideoSearchType(type: UploadType) {
        self.type = type
    }
    
    func handleSave(sender : UIButton) {

        sender.isEnabled = false
        
        if !checErrors()
        {
            
            self.activityIndicatorView?.startAnimating()
            
            if self.type == UploadType.local {
                
                var json = [String:Any]()
                
                self.uploadToS3(completionHandler: { (url) in
                    
                    json["downloaded"] = true
                    json["removed"] = true
                    json["s3_source"] = url.absoluteString
                    json["authorized"] = false
                    
                    json["fulltitle"] = self.titleTextField.text
                    json["description"] = self.descriptionTextView.text
                    
                    self.saveVideo(json: json)
                    
                })
               
                
            } else if self.type == UploadType.youtube {
             
                self.saveYoutubeVideo(url: nil)
                
            }
            
        }
    }
    
    func saveYoutubeVideo(url:URL?) {
        
        let params = ["videoId":videoId] as [String : Any]
        
        PFCloud.callFunction(inBackground: "getYoutubeVideoInfo", withParameters: params) { (result, error) in
            
            if error == nil
            {
                
                do {
                    
                    if var json = result as? [String:Any] {
                        
                        print(json)
                    
                        json["downloaded"] = false
                        json["removed"] = false
                        json["authorized"] = false
                        
                        self.saveVideo(json: json)
                    }
                    
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    func saveVideo( json : [String:Any] ) {
        
        print(json)
        
        self.videoTitle       = json["fulltitle"] as! String
        //self.videoDescription = (json["description"] as? String)!
        
        let videoPF: PFObject = PFObject(className: "Videos")
        
        videoPF["title"] = self.titleTextField.text
        videoPF["description"] = self.descriptionTextView.text
        
        let videoNumericId = Global.getRandomInt()
        
        videoPF["videoId"] = videoNumericId as Int
    
        videoPF["downloaded"]   = json["downloaded"] as! Bool
        videoPF["removed"]      = json["removed"] as! Bool
        videoPF["authorized"]    = json["authorized"] as! Bool
        
        videoPF["categoryName"] = self.category.name
        
        videoPF["order"] = -1 //LEAVE TO BACKEND
        
        videoPF["public"] = true
        
        let fanpageNumericId = Global.getRandomInt()
        videoPF["fanpageId"] = fanpageNumericId
        
        //videoPF["videoId"] = self.videoId
        
        videoPF["fanpageObjId"] = self.fanpage.fanpageObj?.objectId
        
        videoPF["posterId"] = PFUser.current()?.objectId
        
        let userId = PFUser.current()?.objectId
        let name = Global.gamvesFamily.getFamilyUserById(userId: userId!)?.name
        
        videoPF["poster_name"] = name
        
        let short = Global.gamvesFamily.schoolShort
        
        videoPF["folder"] = short
        
        print(videoPF)
        
        //videoPF["s3_source"]    = String()

        if self.videoSelThumbnail != nil {
        
            let filename = "\(Global.generateFileName()).png"
        
            let thumbnail = PFFile(name: filename, data: UIImageJPEGRepresentation(self.videoSelThumbnail, 1.0)!)
    
            videoPF.setObject(thumbnail!, forKey: "thumbnail")
            
        }
            
        if json["s3_source"] != nil {
            
            videoPF["s3_source"] = json["s3_source"]
            
            videoPF["source_type"] = 1
        
        } else  {
            
            let upload_date     = json["upload_date"] as? String
            let view_count      = json["view_count"] as! Double
            let tags            = json["tags"] as! NSArray
            let duration        = json["duration"] as! String
            let categoriesArray = json["categories"] as! NSArray
            //let like_count      = json["like_count"] as! Int
        
            self.thumbnail_url    = (json["thumbnail"] as? String)!
            videoPF["ytb_source"]   =  self.video_url
            videoPF["ytb_thumbnail_source"] = self.thumbnail_url
            videoPF["ytb_videoId"]  = self.videoId
            
            videoPF["ytb_upload_date"]  = upload_date
            videoPF["ytb_view_count"]   = view_count
            videoPF["ytb_tags"]         = tags
            videoPF["ytb_duration"]     = duration
            videoPF["ytb_categories"]   = categoriesArray
            //videoPF["ytb_like_count"]   = like_count
            videoPF["source_type"] = 2
            
        }
     
        videoPF.saveInBackground { (resutl, error) in
            
            if error == nil
            {
                
                let approvals: PFObject = PFObject(className: "Approvals")
                
                approvals["referenceId"] = videoNumericId
                approvals["posterId"] = PFUser.current()?.objectId
                let familyId = Global.gamvesFamily.objectId
                approvals["familyId"] = familyId
                approvals["approved"] = 0
                approvals["notified"] = false
                approvals["title"] = self.videoTitle
                approvals["type"] = 1
                
                approvals.saveInBackground { (resutl, error) in
                    
                    if error == nil {
                        
                        self.activityIndicatorView?.startAnimating()
                        
                        let title = "Video Uploaded!"
                        let message = "The video \(self.videoTitle) has been uploaded and sent to your parents for appoval. Thanks for submitting!"
                        
                        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                            
                            self.activityIndicatorView?.stopAnimating()
                            self.navigationController?.popToRootViewController(animated: true)
                            self.homeController?.clearNewVideo()
                            
                        }))
                        
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    func uploadToS3(completionHandler : @escaping (_ resutl:URL) -> ()){
        
        let accessKey = "AKIAJP4GPKX77DMBF5AQ"
        let secretKey = "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"
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let url = self.videoSelLocalUrl
        let remoteName = "\(Global.generateFileName()).mp4"
        
        //HERE SET THE SCHOOL PACKAGE, same that is set to video folder
        
        let S3BucketName = "gamves/stpauls" //Modify here to get school short 
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = url!
        uploadRequest.key = remoteName
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "video/mp4" //"image/jpeg"
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task) -> Any? in
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            //if let exception = task.exception {
            //    print("Upload failed with exception (\(exception))")
            //}
            
            if task.result != nil {
                
                let url = AWSS3.default().configuration.endpoint.url
                
                if let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!) {
                
                    completionHandler(publicURL)
                    
                    print("Uploaded to:\(publicURL)")
                    
                }
                
            }
            return nil
            
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
            
        }
        /*else if (self.categoryTypeTextField.text?.isEmpty)!
        {
            errors = true
            message += "Catgory is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.categoryTypeTextField)
            
        } else if (self.fanpageTextField.text?.isEmpty)!
        {
            errors = true
            message += "Fanpage is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: self.fanpageTextField)
            
        }*/
 
        else if (self.titleTextField.text?.characters.count)! < 1
        {
            errors = true
            message += "The title of the video is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus:self.titleTextField)
        }
        else if (self.descriptionTextView.text?.isEmpty)!
        {
            errors = true
            message += "The description of the video is empty"
            Global.alertWithTitle(viewController: self, title: title, message: message, toFocus: nil)
        }
        return errors
    }

}

