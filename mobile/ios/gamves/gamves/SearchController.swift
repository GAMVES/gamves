//
//  SearchController.swift
//  gamves
//
//  Created by Jose Vigil on 12/4/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import SwiftyJSON
import NVActivityIndicatorView

protocol VidewVideoProtocol {
    func openVideoById(id: Int)
}

protocol TableViewCellDelegate : class {
    func button_1_tapped(_ sender: SearchGridImageCell)
    func button_2_tapped(_ sender: SearchGridImageCell)
    func button_3_tapped(_ sender: SearchGridImageCell)
}

class RowGalleryImage {
    
    var image_1 = SearchImage()
    var image_2 = SearchImage()
    var image_3 = SearchImage()
    
}

class SearchImage {
    var image = UIImage()
    var url = String()
    var objectId = String()
    var fanpageId = Int()
    var thumbnailLink = String()
    var link = String()
    var checked = Bool()
    var title = String()
}


class YVideo {
    var image = UIImage()
    var title = String()
    var url = String()
    var description = String()
    var videoId = String()
    var duration = String()
}

public enum SearchType {
    case isImageGallery
    case isSingleImage
    case isVideo
}

class SearchController: UIViewController, 
    UITableViewDelegate, UITableViewDataSource,
    UISearchResultsUpdating, UISearchBarDelegate,
    XMLParserDelegate,
    VidewVideoProtocol,
    UIBarPositioningDelegate,
    TableViewCellDelegate
{   

    var delegateMedia:MediaDelegate?
    
    var mediaController: MediaController!
    
    var termToSearch = String()
    
    var tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    /*var searchBar : UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()*/
    
    var newVideoController:NewVideoController!
    
    var searchURL = String()
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var videoDetailsDict : [Int:YVideo]!
    var filteredVideos = [YVideo]()
    var videos = [YVideo]()
    
    var cellVideoSearch = "cellVideoSearch"
    var cellImageSearch = "cellImageSearch"
    var cellGallerySearch = "cellGallerySearch"
    var cellId = "cellId"

    var delegateSearch:SearchProtocol!   

    var parser = XMLParser()
    var resultArr = [String]()
    
    var isSuggestion = Bool()
    var type:SearchType!
    var searchImages = [SearchImage]()
    var rowGalleryImage = RowGalleryImage()
    var rowGalleryImages = [RowGalleryImage]()
    var activityIndicatorView:NVActivityIndicatorView?
    var imagesSelected = Dictionary<String, UIImage>()
    
    var start = Int()
    var end = Int()
    var lastTerm = String()
    
    var gridButtonTag = Int()
    
    var multiselect = Bool()

    var countSelected = Int()
    
    var buttonView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.start = 11
        self.end = 22
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)

        let btnleft : UIButton = UIButton(frame: CGRect(x:0, y:0, width:35, height:35))
        btnleft.setTitleColor(UIColor.white, for: .normal)
        btnleft.contentMode = .left

        btnleft.setImage(UIImage(named :"arrow_back_white"), for: .normal)
                    btnleft.addTarget(self, action: #selector(goBack), for: .touchDown)
        let backBarButon: UIBarButtonItem = UIBarButtonItem(customView: btnleft)

        self.navigationItem.setLeftBarButtonItems([backBarButon], animated: false)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.tableView)
        
        if multiselect {
            
            
            let width = self.view.frame.width

            self.buttonView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 50))
            self.buttonView.backgroundColor = UIColor.gamvesBlackColor
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: width-40, height: 50))
            button.setTitle("Add Images", for: .normal)
            let image = UIImage(named: "add_white")
            button.setImage(image, for: .normal)
            button.addTarget(self, action: #selector(handleSaveImages), for: .touchUpInside)
            self.buttonView.addSubview(button)
            
            self.view.addSubview(buttonView)
            
            self.view.addConstraintsWithFormat("V:|[v0][v1(50)]|", views:
                self.tableView,
                buttonView)
            self.view.addConstraintsWithFormat("H:|[v0]|", views: buttonView)
            
            self.buttonView.isHidden = true
            
        } else {
            
            self.view.addConstraintsWithFormat("V:|[v0]|", views: self.tableView)
            
        }
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Youtube Videos"
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.barTintColor = UIColor.gamvesColor
        self.searchController.searchBar.tintColor = .white
        
        self.tableView.tableHeaderView = self.searchController.searchBar
      
        definesPresentationContext = true
           
        self.videoDetailsDict = [Int:YVideo]()
    
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        self.tableView.register(SearchVideoCell.self, forCellReuseIdentifier: self.cellVideoSearch)
        self.tableView.register(SearchSingleImageCell.self, forCellReuseIdentifier: self.cellImageSearch)
        self.tableView.register(SearchGridImageCell.self, forCellReuseIdentifier: self.cellGallerySearch)
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.termToSearch != nil {
            
            self.searchController.isActive = true
            
            self.searchController.searchBar.becomeFirstResponder()
            
            self.searchController.searchBar.text = self.termToSearch
            
        }
    }
    
    func goBack()
    {
        print("back")
        _ = navigationController?.popViewController(animated: true)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        
        if !self.searchController.searchBar.text!.isEmpty {
            
            isSuggestion = true
            resultArr = [String]()        
            self.findSuggestion(stringToSearch: searchController.searchBar.text!)
        } else {
            
            resultArr.removeAll()
            self.tableView.reloadData()
        }      
    }
    
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {              
        if !searchController.searchBar.text!.isEmpty {
            isSuggestion = true
            resultArr = [String]()        
            self.findSuggestion(stringToSearch: searchController.searchBar.text!)
        } else {
            resultArr.removeAll()
            self.tableView.reloadData()
        }
    } 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var c = 0
        
        if isSuggestion {
            
            c = resultArr.count 
        } else {        
            
            if type == SearchType.isVideo {
                
                if self.videoDetailsDict != nil {
                    
                    c = self.videoDetailsDict.count                
                    if c>0 {
                        print("mas uno")
                    }
                }
                
            } else if type == SearchType.isSingleImage {
                
                c =  self.searchImages.count
                
            } else if type == SearchType.isImageGallery {
                
                c = self.rowGalleryImages.count
            }
            
        }
        return c
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        
        let index = indexPath.row as Int
        var cell = UITableViewCell()
        
        if isSuggestion {
            
            cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath)
            cell.textLabel?.text = resultArr[index] as String
            
        } else {
            
            if type == SearchType.isVideo {
            
                var cellv = tableView.dequeueReusableCell(withIdentifier: self.cellVideoSearch) as! SearchVideoCell
                
                if let yVideo = self.videoDetailsDict[index] as! YVideo? {               
                    cellv.descLabel.text = yVideo.description
                    cellv.titleLabel.text = yVideo.title
                    cellv.timeLabel.text = yVideo.duration
                    cellv.delegate = self
                    
                    if  yVideo.image != nil {
                        
                        cellv.thumbnailImageView.image = yVideo.image
                        cellv.thumbnailImageView.tag = index
                        
                    }                
                }
                
                return cellv
                
            } else if type == SearchType.isSingleImage {
                
                
                var cells = tableView.dequeueReusableCell(withIdentifier: self.cellImageSearch) as! SearchSingleImageCell
                
                if let searchImage = self.searchImages[index] as! SearchImage? {
                    
                    if  searchImage.image != nil {
                        
                        cells.thumbnailImageView.image = searchImage.image
                        cells.thumbnailImageView.tag = index
                        
                        if multiselect {
                        
                            if searchImage.checked
                            {
                                cells.checkLabel.isHidden = false
                                cells.isHighlighted = false
                            } else
                            {
                                cells.checkLabel.isHidden = true
                                cells.isHighlighted = true
                            }
                        }
                        
                    }
                }
                return cells
                
            } else if type == SearchType.isImageGallery {
             
                var cellg = tableView.dequeueReusableCell(withIdentifier: self.cellGallerySearch) as! SearchGridImageCell
                
                if let gallery = self.rowGalleryImages[index] as! RowGalleryImage? {
                    
                    cellg.button_1.setImage(gallery.image_1.image, for: .normal)
                    cellg.button_2.setImage(gallery.image_2.image, for: .normal)
                    cellg.button_3.setImage(gallery.image_3.image, for: .normal)
                
                    gridButtonTag = gridButtonTag + 3
                    
                    print(gridButtonTag)
                    
                    cellg.delegate = self
                    
                }
                return cellg
                
            }
            
        }
        return cell
    }
    
    func button_1_tapped(_ sender: SearchGridImageCell){
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        let rowId = tappedIndexPath[1]
        let imageId = (3 * rowId)
        let searchImage = self.searchImages[imageId] as SearchImage
        
        delegateMedia?.didPickImage!(searchImage.image)
        self.popBackToView()
    }
    func button_2_tapped(_ sender: SearchGridImageCell){
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        let rowId = tappedIndexPath[1]
        let imageId = (3 * rowId) + 1
        print(imageId)
        let searchImage = self.searchImages[imageId] as SearchImage
        
        delegateMedia?.didPickImage!(searchImage.image)
        self.popBackToView()
    }
    func button_3_tapped(_ sender: SearchGridImageCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let rowId = tappedIndexPath[1]
    
        let imageId = (3 * rowId) + 2
        let searchImage = self.searchImages[imageId] as SearchImage

        delegateMedia?.didPickImage!(searchImage.image)
        self.popBackToView()
    }
    
    func popBackToView() {
        if let viewControllers = self.navigationController?.viewControllers {
            if viewControllers.count > 3 {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            } else {
                // fail
            }
        }
    }
    
    func handleSaveImages() {
        
        let titles = self.imagesSelected.keys
        
        var finalImages = [UIImage]()
        
        for t in titles {
            finalImages.append(self.imagesSelected[t]!)
        }
        
        delegateMedia?.didPickImages!(finalImages)
        self.popBackToView()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()
        
        if isSuggestion {
        
            height = 40
        
        } else {
            
            
            if type == SearchType.isVideo {
                
                height = 90
                
            } else if type == SearchType.isImageGallery {
                
                let imageWidth = self.view.frame.width / 3
                
                height = imageWidth
                
            } else if type == SearchType.isSingleImage {
                
                let iw = self.view.frame.width
             
                let imageHeight = iw * 9 / 16
                
                height = imageHeight
                
            }
        }
        return height        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchController.searchBar.endEditing(true)
        let index = indexPath.row as Int        
        
        if isSuggestion {
            
            var sg = resultArr[index]
            
            self.isSuggestion = false
            
            self.resultArr.removeAll()
            
            self.lastTerm = sg
            
            if type == SearchType.isVideo {
        
                self.findVideoFromSuggestion(suggestion: sg)
                
            } else if type == SearchType.isImageGallery {
                
                self.findImagesFromSuggestion(suggestion: sg, isSingle: false)
                
            } else if type == SearchType.isSingleImage {
                
                self.findImagesFromSuggestion(suggestion: sg, isSingle: true)
            }
        
        } else {
         
            if type == SearchType.isVideo {
            
                if let yVideo = self.videoDetailsDict[index] as! YVideo? {
                    
                    let videoId = yVideo.videoId
                    
                    self.delegateSearch.setResultOfsearch(videoId: videoId,
                        title: yVideo.title, 
                        description : yVideo.description,
                        duration : yVideo.duration,
                        image : yVideo.image)
                    
                    self.tableView.tableHeaderView = nil
                    self.popBackToView()
                    
                }
            

            } else if type == SearchType.isSingleImage {

                if multiselect {
                
                    let title = self.searchImages[index].title as String
                    
                    if self.searchImages[index].checked {
                    
                        self.searchImages[index].checked = false
                        countSelected = countSelected - 1
                        
                        self.imagesSelected.removeValue(forKey: title)
                        
                    } else {
            
                        if countSelected < 5 {
                            
                            self.searchImages[index].checked = true
                            countSelected = countSelected + 1
                            
                            let title = self.searchImages[index].title as String
                            
                            self.imagesSelected[title] =  self.searchImages[index].image
                            
                        }
                        
                    }
                    
                    self.tableView.reloadData()
                    
                } else  {
                
                    let searchImage = self.searchImages[index] as SearchImage
                    
                    delegateMedia?.didPickImage!(searchImage.image)
                    self.popBackToView()
                
                }
            }
        }    
    }  
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if type == SearchType.isVideo {
            
            let lastElement = self.videoDetailsDict.count - 1
            if indexPath.row == lastElement {
            
            }
            
        } else if type == SearchType.isImageGallery {
            
            let lastElement = self.rowGalleryImages.count - 1
            if indexPath.row == lastElement {
                
                if self.end < 88 {
                    
                    self.start = self.start + 11
                    self.end = self.start + 11
                    self.findImagesFromSuggestion(suggestion: self.lastTerm, isSingle: false)
                    
                }
                
            }
            
        } else if type == SearchType.isSingleImage {
            
            let lastElement = self.searchImages.count - 1
            if indexPath.row == lastElement {
             
                if self.end < 88 {
                
                    self.start = self.start + 11
                    self.end = self.start + 11
                    self.findImagesFromSuggestion(suggestion: self.lastTerm, isSingle: true)
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func findSuggestion(stringToSearch: String) {
        
        let googleURL = "http://suggestqueries.google.com/complete/search?output=toolbar&hl=tr&ie=utf8&oe=utf8&q="
        let searchURL = URL(string: googleURL + stringToSearch.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        parser = XMLParser(contentsOf: searchURL!)!
        
        self.parser.delegate = self as! XMLParserDelegate
        let success:Bool = self.parser.parse()
       
        if success {
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } else {
            print("parser error")
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {        
        if (elementName == "suggestion") {
            let suggestion : String = attributeDict["data"]!
            resultArr.append(suggestion)
        }
     }


    func findVideoFromSuggestion(suggestion: String) {
        
        isSuggestion = false        
        searchController.searchBar.isLoading = true
        
        self.activityIndicatorView?.startAnimating()
        
        var urlString:String = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,description,channelTitle,thumbnails))&order=viewCount&q=\(suggestion)&type=video&maxResults=50&key=\(Global.api_key)"
        
        let urlwithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(urlwithPercentEscapes!, method: .get)
            .responseJSON { response in                
                print("Success: \(response.result.isSuccess)")                
                switch response.result {
                case .success:                
                    let json = JSON(response.result.value!)                    
                    if let items = json["items"].array {                    
                        var i = 0                        
                        var countItems = items.count                        
                        for item in items {                            
                            var yv = YVideo() 
                            if let idItem = item["id"].dictionary {                                                                                            
                                if idItem["videoId"]?.stringValue != nil {
                                    let videoId = idItem["videoId"]?.stringValue as! String                                    
                                    yv.videoId = videoId                                    
                                }                       
                            }                        
                            
                            if let snippetDict = item["snippet"].dictionary {
                                
                                print(snippetDict)                       
                                yv.title = snippetDict["title"]?.stringValue as! String                                
                                print(yv.title)                                
                                yv.description = (snippetDict["description"]?.stringValue as AnyObject) as! String
                                print(yv.description)                                
                                
                                var thumbnails = snippetDict["thumbnails"]?.dictionary
                                var dfault = thumbnails?["default"]?.dictionary                                
                                var thumbUrl =  dfault?["url"]?.stringValue as! String                                
                                yv.url = thumbUrl                                
                                print(thumbUrl)
                                
                                let thUrl = URL(string: thumbUrl)!
                                let sessionCover = URLSession(configuration: .default)                                
                                print(thUrl)                                
                                let downloadCover = sessionCover.dataTask(with: thUrl) {
                                    (data, response, error) in
                                    
                                    guard error == nil else {
                                        print(error!)
                                        return
                                    }
                                    guard let data = data else {
                                        print("Data is empty")
                                        return
                                    }
                                    
                                    if error == nil {
                                        
                                        yv.image = UIImage(data:data)!
                                        self.videoDetailsDict[i] = yv
                                        self.searchDuration(id: i)
                                        
                                        if i == (countItems-1) {
                                            self.searchController.searchBar.isLoading = false
                                        }
                                        
                                        i = i + 1                                        
                                    }
                                    
                                }
                                downloadCover.resume()                       
                            }                            
                        }
                    }             
                break
                case .failure(let error):
                print(error)
            }
        }
    }
    
    func searchDuration(id:Int) {
        
        DispatchQueue.main.async {
            
            var yv:YVideo = self.videoDetailsDict[id]!
            
            let videoId = yv.videoId
            
            var urlString:String = "https://www.googleapis.com/youtube/v3/videos?id=\(videoId)&part=contentDetails&key=\(Global.api_key)"
            
            let urlwithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(urlwithPercentEscapes!, method: .get)
                .responseJSON { response in
                    
                print("Success: \(response.result.isSuccess)")
                
                if response.result.isSuccess {
                    
                    let json = JSON(response.result.value!)
                    if let items = json["items"].array {
                        
                        if let contentDetails = items[0]["contentDetails"].dictionary {
                            
                            let duration = contentDetails["duration"] as! JSON
                            
                            let dateString = String(describing: duration)
                            
                            let durFormat = self.getYoutubeFormattedDuration(duration: dateString)
                            
                            self.videoDetailsDict[id]!.duration = durFormat
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.activityIndicatorView?.stopAnimating()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func getYoutubeFormattedDuration(duration: String) -> String {
        
        let formattedDuration = duration.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.characters.count > 0 ? duration + ":" : duration
            if component.characters.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        
        return duration
        
    }


    func openVideoById(id: Int)
    {
        
        if let yVideo = videoDetailsDict[id] as! YVideo? {

            let videoId = yVideo.videoId
            var youTubePlayerController = YouTubePlayerController()
            youTubePlayerController.videoId = videoId
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            navigationController?.pushViewController(youTubePlayerController, animated: true)         
        }
        
    }
    
    func findImagesFromSuggestion(suggestion: String, isSingle: Bool) {
        
        isSuggestion = false
        
        searchController.searchBar.isLoading = true
        self.activityIndicatorView?.startAnimating()
        
        var urlString:String = "https://www.googleapis.com/customsearch/v1?key=\(Global.api_key)&cx=\(Global.search_engine)&q=\(suggestion)&searchType=image&start=\(self.start)&end=\(self.end)&alt=json"
        
        print(urlString)
        
        let urlwithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(urlwithPercentEscapes!, method: .get)
            .responseJSON { response in
                
                print("Success: \(response.result.isSuccess)")
                
                switch response.result {
                case .success:
                    
                    let json = JSON(response.result.value!)
                    if let items = json["items"].array {
                        
                        var i = 0
                        var countItems = items.count
                        
                        print(countItems)
                        
                        var countr = 0
                        
                        for item in items {
                            
                            var image = SearchImage()
                            
                            image.link = item["link"].stringValue as! String
                            
                            image.title = item["title"].stringValue as! String
                            
                            if let imageDict = item["image"].dictionary {
                                
                                print(imageDict)
                                
                                image.thumbnailLink = imageDict["thumbnailLink"]?.stringValue as! String
                                
                                let thUrl = URL(string: image.thumbnailLink)!
                                let sessionCover = URLSession(configuration: .default)
                                print(thUrl)
                                
                                let downloadCover = sessionCover.dataTask(with: thUrl) {
                                    (data, response, error) in
                                    
                                    guard error == nil else {
                                        print(error!)
                                        return
                                    }
                                    guard let data = data else {
                                        print("Data is empty")
                                        return
                                    }
                                    
                                    if error == nil {
                                        
                                        image.image = UIImage(data:data)!
                                        
                                        if !isSingle {
                                        
                                            
                                            countr = countr + 1
                                            
                                            if countr == 1 {

                                                self.rowGalleryImage = RowGalleryImage()
                                                
                                                self.rowGalleryImage.image_1 = image
                                            
                                            } else if countr == 2 {
                                             
                                                self.rowGalleryImage.image_2 = image
                                                
                                            } else if countr == 3 {
                                                
                                                self.rowGalleryImage.image_3 = image
                                                
                                                self.rowGalleryImages.append(self.rowGalleryImage)
                                                
                                                countr = 0
                                                
                                                //DispatchQueue.main.async(execute: {
                                                //    self.tableView.reloadData()
                                                //})
                                                
                                                
                                            }
                                            
                                        }
                                        
                                        self.searchImages.append(image)
                                        
                                        if i == (countItems-1) {
                                            
                                            //Agregar resto cuando sea no multiplo de 3
                                            
                                            if !isSingle {
                                            
                                                if countr == 0, countr == 1, countr == 2 {
                                                    
                                                    self.rowGalleryImages.append(self.rowGalleryImage)
                                                    
                                                }
                                            }
                                            
                                            self.searchController.searchBar.isLoading = false
                                            
                                            DispatchQueue.main.async(execute: {
                                                
                                                if self.multiselect {
                                                    self.buttonView.isHidden = false
                                                }
                                                
                                                self.tableView.reloadData()
                                                self.activityIndicatorView?.stopAnimating()
                                            })
                                            
                                        }
                                        
                                        i = i + 1
                                    }
                                    
                                }
                                downloadCover.resume()
                            }
                        }
                    }
                    break
                case .failure(let error):
                    print(error)
                }
        }
    }
}


