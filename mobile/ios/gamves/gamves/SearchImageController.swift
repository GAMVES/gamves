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

/*protocol VidewVideoProtocol {
    func openVideoById(id: Int)
}

class YVideo {
    var image = UIImage()
    var title = String()
    var url = String()
    var description = String()
    var videoId = String()
    var duration = String()
}*/


class SearchImageController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UISearchResultsUpdating, UISearchBarDelegate,
    XMLParserDelegate,
    UIBarPositioningDelegate     
{   

    
    var searchImages = [SearchImage]()
    
    var takePicturesController:TakePicturesController!
    
    var termToSearch = String()
    
    var tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    var searchBar : UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    var newFanpageController:NewFanpageController!
    
    var searchURL = String()
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var videoDetailsDict : [Int:YVideo]!
    var filteredVideos = [YVideo]()
    var videos = [YVideo]()
    
    
    var delegateSearch:SearchProtocol!   

    var parser = XMLParser()
    var resultArr = [String]()
    
    var isSuggestion = Bool()

    var activityIndicatorView:NVActivityIndicatorView?
    
    var cellId:String = "SearchCellId"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let btnleft : UIButton = UIButton(frame: CGRect(x:0, y:0, width:35, height:35))
        btnleft.setTitleColor(UIColor.white, for: .normal)
        btnleft.contentMode = .left

        btnleft.setImage(UIImage(named :"arrow_back_white"), for: .normal)
                    btnleft.addTarget(self, action: #selector(goBack), for: .touchDown)
        let backBarButon: UIBarButtonItem = UIBarButtonItem(customView: btnleft)

        self.navigationItem.setLeftBarButtonItems([backBarButon], animated: false)
  
        self.view.addSubview(self.collectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.tableView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.tableView) 

        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Images"
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
       
        self.tableView.tableHeaderView = self.searchController.searchBar
    
    
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)

        print(termToSearch)
        
        self.collectionView.register(SearchImageCell.self, forCellWithReuseIdentifier: cellId)
        
        
    }
    
    func goBack()
    {
        print("back")
        _ = navigationController?.popViewController(animated: true)
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        if !self.searchBar.text!.isEmpty {
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
            if self.videoDetailsDict != nil {
                c = self.videoDetailsDict.count                
                if c>0 {
                    print("mas uno")
                }
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
            var cellS = tableView.dequeueReusableCell(withIdentifier: self.cellIdSearch) as! SearchCell
            print(self.videoDetailsDict.count)        
            if let yVideo = self.videoDetailsDict[index] as! YVideo? {               
                cellS.descLabel.text = yVideo.description                
                cellS.titleLabel.text = yVideo.title
                cellS.timeLabel.text = yVideo.duration
                //cellS.delegate = self
                if  yVideo.image != nil {
                    cellS.thumbnailImageView.image = yVideo.image
                    cellS.thumbnailImageView.tag = index
                }                
            }            
            return cellS
        }                
        return cell
    }   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat()
        if isSuggestion {
            height = 40
        } else {
            height = 90
        }
        return height        
    }
    
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchImageCell
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchController.searchBar.endEditing(true)
        
        //Seleccionar o si es en grupo adjuntar
        
        if let ySearch = self.searchImages[index] as! SearchImage? {
        
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
            self.tableView.reloadData()
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
        
        var urlString:String = "https://www.googleapis.com/customsearch/v1?key=\(Global.api_key)&cx=\(Global.search_engine)&q=\(suggestion)&searchType=image&alt=json"
        
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
                            
                            var image = SearchImage()
                            
                            image.link = item["link"].stringValue as! String
                            
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
                                        self.searchImages[i] = image
                                        
                                        self.tableView.reloadData()
                                        
                                        if i == (countItems-1) {
                                            self.searchController.searchBar.isLoading = false
                                            self.activityIndicatorView?.stopAnimating()
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



