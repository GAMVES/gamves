//
//  NewVideoController.swift
//  gamves
//
//  Created by Jose Vigil on 12/3/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import DownPicker
import Alamofire
import NVActivityIndicatorView
import SwiftyJSON 

class NewVideoController: UIViewController  {
    
    var homeController: HomeController?
    
    var category = CategoryGamves()

	let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesBackgoundColor
        return v
    }()

	
    //-- CATEGORY     

    let categoriesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    var categoryDownPicker: DownPicker!
    let categoryTypeTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let categoryTypeSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()  

    var fanpageDownPicker: DownPicker!
    let fanpageTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false        
        return tf
    }()

    let fanpageSeparatorView: UIView = {
        let view = UIView()        
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var typeDownPicker: DownPicker!
    let typeTextField: UITextField = {
        let tf = UITextField()        
        tf.translatesAutoresizingMaskIntoConstraints = false        
        return tf
    }()

    //-- VIDEO

    let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    let inputVideoRowView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()   

     let previewVideoRowView: UIView = {
        let view = UIView()        
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    //-- inputVideoRowView youtube

	let youtubeUrlTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Youtube url"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "o7Kd6VVp6jE"        
        return tf
    }()

    lazy var checkUrlButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Check video", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)        
        button.addTarget(self, action: #selector(handleCheck), for: .touchUpInside)       
        button.layer.cornerRadius = 5 
        return button
    }()

    //-- inputVideoRowView local

    lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Record video", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)        
        button.addTarget(self, action: #selector(handleRecord), for: .touchUpInside)       
        button.layer.cornerRadius = 5 
        return button
    }()


	lazy var uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Upload video", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)        
        button.addTarget(self, action: #selector(handleUpload), for: .touchUpInside)       
        button.layer.cornerRadius = 5 
        return button
    }()

	//-- previewVideoRowView 

    lazy var thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "camera")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()

    let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Youtube url"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "o7Kd6VVp6jE"        
        return tf
    }()

    let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Youtube url"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = "o7Kd6VVp6jE"        
        return tf
    }()

    var thumbnailImage = UIImage()
    var thumbnail_url = String()
    var author_name = String()
    var videoTitle = String()
    var videoDescription = String()

    //-- save

    var activityIndicatorView:NVActivityIndicatorView?

    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor        
        button.setTitle("Save son or doughter", for: UIControlState())
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


    override func viewDidLoad() {
        super.viewDidLoad()
        
		self.view.addSubview(self.scrollView)

		self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView) 
		self.view.addConstraintsWithFormat("V:|[v0]|", views: self.scrollView)        
        self.scrollView.backgroundColor = UIColor.gamvesBackgoundColor

		self.scrollView.addSubview(self.categoriesContainerView)
		self.scrollView.addSubview(self.videoContainerView)
		self.scrollView.addSubview(self.saveButton)
		self.scrollView.addSubview(self.bottomView)

		self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.categoriesContainerView)		
		self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.videoContainerView)
		self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.saveButton)
		self.scrollView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: self.bottomView)

		self.scrollView.addConstraintsWithFormat(
            "V:|-12-[v0(120)]-12-[v1(120)]-12-[v2(40)][v3]|", views: 
            self.categoriesContainerView, 
            self.videoContainerView, 
            self.saveButton, 
            self.bottomView)

        //-- categoriesContainerView

        self.categoryTypeTextField.addTarget(self, action: #selector(self.categoryFieldDidChange(_:)), for: .editingChanged)

		self.categoriesContainerView.addSubview(self.categoryTypeTextField)
        self.categoriesContainerView.addSubview(self.categoryTypeSeparatorView)
        self.categoriesContainerView.addSubview(self.fanpageTextField)                
        self.categoriesContainerView.addSubview(self.fanpageSeparatorView)  
        self.categoriesContainerView.addSubview(self.typeTextField)    

        self.categoriesContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.categoryTypeTextField)
        self.categoriesContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.categoryTypeSeparatorView)        
        self.categoriesContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.fanpageTextField)
        self.categoriesContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.fanpageSeparatorView)       
        self.categoriesContainerView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: self.typeTextField)         

        let moduleContainerHeight = 120        
        let categoryEditTextHeight = moduleContainerHeight / 3  

		var metricsCategory = [String:Int]()

		metricsCategory["editTextHeight"]  =  categoryEditTextHeight		

        self.categoriesContainerView.addConstraintsWithFormat(
            "V:|[v0(editTextHeight)][v1(2)][v2(editTextHeight)][v3(2)][v4(editTextHeight)]|", 
            views: 
            self.categoryTypeTextField, 
            self.categoryTypeSeparatorView, 
            self.fanpageTextField,
            self.fanpageSeparatorView,            
            self.typeTextField,
            metrics: metricsCategory) 
        
        var catArray = [String]()
        for cats in Global.categories_gamves {	
        	catArray.append(cats.name)
        }
        let categories: NSMutableArray = catArray as! NSMutableArray
        self.categoryDownPicker = DownPicker(textField: categoryTypeTextField, withData:categories as! [Any])
        self.categoryDownPicker.setPlaceholder("Tap to choose category...")

        self.categoryDownPicker.addTarget(self, action: #selector(selectedCategory), for: UIControlEvents.valueChanged )

        let types: NSMutableArray = ["Youtube", "Local"]		
        self.typeDownPicker = DownPicker(textField: typeTextField, withData:types as! [Any])
        self.typeDownPicker.setPlaceholder("Tap to choose type of video...")

        self.typeDownPicker.addTarget(self, action: #selector(selectedType), for: UIControlEvents.valueChanged )
        
        self.fanpageDownPicker = DownPicker(textField: fanpageTextField)

        self.fanpageDownPicker.isEnabled = false
        self.typeDownPicker.isEnabled = false

        //-- videoContainerView        

        self.videoContainerView.addSubview(self.inputVideoRowView)
		self.videoContainerView.addSubview(self.previewVideoRowView)

		self.videoContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.inputVideoRowView)		
		self.videoContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.previewVideoRowView)		
		
		self.videoContainerView.addConstraintsWithFormat("V:|[v0(40)][v1(120)]|", views: 
			self.inputVideoRowView,
			self.previewVideoRowView)		

		//-- inputVideoRowView youtube

		self.inputVideoRowView.addSubview(self.youtubeUrlTextField)
		self.inputVideoRowView.addSubview(self.checkUrlButton)		

		self.inputVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.youtubeUrlTextField)		
		self.inputVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.checkUrlButton)	

		self.inputVideoRowView.addConstraintsWithFormat("H:|[v0(200)][v1]|", views: 
			self.youtubeUrlTextField,
			self.checkUrlButton)		

		//-- inputVideoRowView local

		self.inputVideoRowView.addSubview(self.recordButton)
		self.inputVideoRowView.addSubview(self.uploadButton)		

		self.inputVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.recordButton)		
		self.inputVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.uploadButton)	

		self.inputVideoRowView.addConstraintsWithFormat("H:|[v0][v1]|", views: 
			self.recordButton,
			self.uploadButton)

		//-- previewVideoRowView 
	
		self.previewVideoRowView.addSubview(self.thumbnailView)
		self.previewVideoRowView.addSubview(self.titleTextField)	
		self.previewVideoRowView.addSubview(self.descriptionTextField)		

		self.previewVideoRowView.addConstraintsWithFormat("V:|[v0(120)]|", views: self.thumbnailView)		
		self.previewVideoRowView.addConstraintsWithFormat("V:|[v0(40)]|", views: self.titleTextField)	
		self.previewVideoRowView.addConstraintsWithFormat("V:|[v0(80)]|", views: self.descriptionTextField)	

		self.previewVideoRowView.addConstraintsWithFormat("H:|[v0(120)][v1][v2]|", views: 
			self.thumbnailView,
			self.titleTextField,
			self.descriptionTextField)

		self.videoContainerView.isHidden = true
		self.saveButton.isHidden = true
		self.inputVideoRowView.isHidden = true
		self.previewVideoRowView.isHidden = true	

		self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)

		self.handleCheck()

    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func selectedCategory(picker: DownPicker)
    {
        print("changed")
        
        self.fanpageDownPicker.isEnabled = true
        
        let value = picker.getTextField().text
        let fanpage = FanpageGamves()
        for cat in Global.categories_gamves {
            if cat.name == value
            {
                self.category = cat
            }
        }
        
        var fanArray = [String]()
        for fan in self.category.fanpages
        {
            fanArray.append(fan.name)
        }
        let fanpages = fanArray as! NSMutableArray
        self.fanpageDownPicker.setData(fanpages as! [Any])
        self.fanpageDownPicker.setPlaceholder("Tap to choose category...")

        self.fanpageDownPicker.addTarget(self, action: #selector(selectedFanpage), for: UIControlEvents.valueChanged )

        self.fanpageDownPicker.becomeFirstResponder()
        
                
    }

    func selectedFanpage(picker: DownPicker)
    {

        let value = picker.getTextField().text
        print(value)
        
        self.typeDownPicker.isEnabled = true

        self.typeDownPicker.becomeFirstResponder()

    }


    func selectedType(picker: DownPicker)
    {

		self.videoContainerView.isHidden = false
		self.inputVideoRowView.isHidden = false
		self.previewVideoRowView.isHidden = false

    	let value = picker.getTextField().text

    	if value == "Youtube"
    	{

			self.youtubeUrlTextField.isHidden = false
			self.checkUrlButton.isHidden = false

    	} else if value == "Local"
    	{
			self.recordButton.isHidden = false
			self.uploadButton.isHidden = false
    	}
  
    }

     
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


	func handleCheck()
    {

		self.activityIndicatorView?.startAnimating()

    	self.getVideoDataUser(videoId: "C7i4SoN58Sk", completionHandler: { ( restul:Bool ) -> () in   		

    		self.thumbnailView.image = self.thumbnailImage
			self.titleTextField.text = self.videoTitle			

			self.getVideoDescription(videoId: "C7i4SoN58Sk", completionHandlerDesc: { ( restul:Bool ) -> () in

				self.descriptionTextField.text = self.videoDescription

				self.activityIndicatorView?.stopAnimating()

			})

		})

    }

	func handleSave()
    {

    }
   
   	func handleRecord()
    {

    }

    func handleUpload()
    {

    }

}
