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

class YVideo {
    var image = UIImage()
    var title = String()
    var url = String()
    var description = String()
    var videoId = String()
}

class SearchController: UITableViewController, UISearchResultsUpdating  {
   
    
    var newVideoController:NewVideoController!
    
    var searchURL = String()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var videoDetailsDict : [Int:YVideo]!
    
    var cellId = "CellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar    
        
        self.videoDetailsDict = [Int:YVideo]()
        
        self.tableView.register(SearchCell.self, forCellReuseIdentifier: self.cellId)
        
    }
    
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        
        searchController.searchBar.resignFirstResponder()
        
        if !searchController.searchBar.text!.isEmpty
        {
        
            var urlString:String = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,description,channelTitle,thumbnails))&order=viewCount&q=\(searchController.searchBar.text!)&type=video&maxResults=25&key=\(Global.api_key)"
            
            let urlwithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(urlwithPercentEscapes!, method: .get)
                .responseJSON { response in
                    
                    print("Success: \(response.result.isSuccess)")
                    
                    switch response.result {
                    case .success:                    
                        
                        let json = JSON(response.result.value!)
                        
                        if let items = json["items"].array {
                        
                            var i = 0
                            
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
                                            
                                            DispatchQueue.global().async
                                            {
                                                self.tableView.reloadData()
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

  
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        var c = 0
        if self.videoDetailsDict != nil
        {
           c = self.videoDetailsDict.count
            print(c)
            if c>0
            {
                print("mas uno")
            }
        }
        return c
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellId) as! SearchCell
        
        let index = indexPath.row as Int
        
        print(self.videoDetailsDict.count)
        
        if let yVideo = self.videoDetailsDict[index] as! YVideo?
        {
            
            cell.descLabel.text = yVideo.description
            
            cell.titleLabel.text = yVideo.title
            
            if  yVideo.image != nil
            {
                cell.thumbnailImageView.image = yVideo.image
            }
            
        }  
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}





