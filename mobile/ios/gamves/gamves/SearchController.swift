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
import YouTubePlayer
import NVActivityIndicatorView

class YVideo {
    var image = UIImage()
    var title = String()
    var url = String()
    var description = String()
    var videoId = String()
}

class SearchController: UITableViewController, 
    UISearchResultsUpdating,
    XMLParserDelegate
    //YouTubePlayerDelegate  
{
   
    
    var newVideoController:NewVideoController!
    
    var searchURL = String()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var videoDetailsDict : [Int:YVideo]!
    var filteredVideos = [YVideo]()
    var videos = [YVideo]()
    
    var cellIdSearch = "cellIdSearch"
    var cellId = "cellId"

    var delegateSearch:SearchProtocol!

    //var youtubePlayer: YouTubePlayerView! 

    var parser = XMLParser()
    var resultArr = [String]()
    
    var isSuggestion = Bool()

    var activityIndicatorView:NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Youtube Videos"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
           
        self.videoDetailsDict = [Int:YVideo]()
        
        self.tableView.register(SearchCell.self, forCellReuseIdentifier: self.cellIdSearch)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)

        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)
        
    }


    
    /*func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredVideos = videos.filter({( video : YVideo) -> Bool in
            return video.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }*/
    
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {      
        
        if !searchController.searchBar.text!.isEmpty
        {
            isSuggestion = true
            
            resultArr = [String]()
        
            self.findSuggestion(stringToSearch: searchController.searchBar.text!)
        } else
        {
            resultArr.removeAll()
            self.tableView.reloadData()
        }

    }

  
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        var c = 0
        
        if isSuggestion
        {
            c = resultArr.count 

        } else {
        
            if self.videoDetailsDict != nil
            {
               c = self.videoDetailsDict.count
                print(c)
                if c>0
                {
                    print("mas uno")
                }
            }
                
        }


        return c
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row as Int
        
        var cell = UITableViewCell()

        if isSuggestion
        {
            cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath)

            cell.textLabel?.text = resultArr[index] as String

        } else 
        {
            var cellS = tableView.dequeueReusableCell(withIdentifier: self.cellIdSearch) as! SearchCell

            print(self.videoDetailsDict.count)

        
            if let yVideo = self.videoDetailsDict[index] as! YVideo?
            {
                
                cellS.descLabel.text = yVideo.description
                
                cellS.titleLabel.text = yVideo.title
                
                if  yVideo.image != nil
                {
                    cellS.thumbnailImageView.image = yVideo.image
                }
                
            }
            
            return cellS

        }
                
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat()
        if isSuggestion
        {
            height = 40
        } else 
        {
            height = 90
        }
        return height
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchController.searchBar.endEditing(true)
        
        let index = indexPath.row as Int
        
        if isSuggestion
        {
            
            var sg = resultArr[index]
            
            isSuggestion = false
            resultArr.removeAll()
            self.tableView.reloadData()

            self.findVideoFromSuggestion(suggestion: sg)

        } else 
        {

            if let yVideo = self.videoDetailsDict[index] as! YVideo?
            {            
                let videoId = yVideo.videoId
                //self.setYoutubePlayer(id: videoId)

                self.delegateSearch.setResultOfsearch(videoId: videoId, 
                    title: yVideo.title, 
                    description : yVideo.description, 
                    image : yVideo.image)            

                self.tableView.tableHeaderView = nil
                
                _ = navigationController?.popToRootViewController(animated: true)
            }

        }      
        
    }

    /*func setYoutubePlayer(id:String)
    {    
        self.youtubePlayer = YouTubePlayerView(frame: self.view.frame)
        self.youtubePlayer.delegate = self
        self.view.addSubview(youtubePlayer)
        self.youtubePlayer.loadVideoID(id)
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func findSuggestion(stringToSearch: String)
    {          
        //You can find about this google url parameters online. For now 'hl' is language parameter.
        let googleURL = "http://suggestqueries.google.com/complete/search?output=toolbar&hl=tr&ie=utf8&oe=utf8&q="
        let searchURL = URL(string: googleURL + stringToSearch.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)

        parser = XMLParser(contentsOf: searchURL!)!
        self.parser.delegate = self as! XMLParserDelegate

        let success:Bool = self.parser.parse()

        if success 
        {
            self.tableView.reloadData()
        } else {
            print("parser error")
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        //This delegate method loops through every suggestion in xml file and parses it
        if (elementName == "suggestion") {
            let suggestion : String = attributeDict["data"]!
            resultArr.append(suggestion)
        }
     }


    func findVideoFromSuggestion(suggestion: String)
    {
        isSuggestion = false
        
        searchController.searchBar.isLoading = true

        self.activityIndicatorView?.startAnimating()
            
        //var urlString:String = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,description,channelTitle,thumbnails))&order=viewCount&q=\(searchController.searchBar.text!)&type=video&maxResults=25&key=\(Global.api_key)"

        var urlString:String = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,description,channelTitle,thumbnails))&order=viewCount&q=\(suggestion)&type=video&maxResults=25&key=\(Global.api_key)"        

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
                        
                        for item in items
                        {                            
                            var yv = YVideo()
                            
                            if let idItem = item["id"].dictionary
                            {
                                print("-------------")
                                
                                print(idItem)
                                
                                if idItem["videoId"]?.stringValue != nil
                                {
                                    let videoId = idItem["videoId"]?.stringValue as! String
                                    
                                    print(videoId)
                                    
                                    yv.videoId = videoId
                                    print(yv.videoId)
                                }
                                
                                
                            }
                        
                            if let snippetDict = item["snippet"].dictionary
                            {
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
                                    
                                    if error == nil
                                    {
                                         yv.image = UIImage(data:data)!
                                              
                                        self.videoDetailsDict[i] = yv
                                        
                                        DispatchQueue.main.async                                           
                                        {
                                            self.tableView.reloadData()
                                        }
                                        
                                        i = i + 1
                                        
                                        if countItems == (i-1)
                                        {
                                            self.searchController.searchBar.isLoading = false

                                            self.activityIndicatorView?.stopAnimating()
                                        }
                                        
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





