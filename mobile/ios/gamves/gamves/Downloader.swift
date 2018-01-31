//
//  Downloader.swift
//  gamves
//
//  Created by Jose Vigil on 10/25/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Downloader: NSObject
{
    
    static var fanpageImagesDictionary = Dictionary<Int, [FanpageImageGamves]>()
    
    static var quenedImages = Dictionary<Int, Bool>()
    
    static func loadFanpageImages(fanpage:PFObject)
    {
        let fanpageId = fanpage["fanpageId"] as! Int
        
        if self.fanpageImagesDictionary[fanpageId] == nil && self.quenedImages[fanpageId] == nil
        {
            
            self.quenedImages[fanpageId] = true
            
            DispatchQueue.main.async
            {
                
                let relationAlbums = fanpage["albums"] as! PFRelation
                let albumsQuery = relationAlbums.query()                
                if !Global.hasDateChanged()
                {
                    albumsQuery.cachePolicy = .cacheThenNetwork
                }
                albumsQuery.findObjectsInBackground(block: { (fanpageAlbums, error) in
                    
                    if error != nil
                    {
                        print("error")
                        
                    } else {
                        
                        if (fanpageAlbums?.count)! > 0
                        {
                            
                            var images = [FanpageImageGamves]()
                            
                            let countFanpageAlbums = fanpageAlbums?.count
                            
                            print(countFanpageAlbums)
                            
                            var count = 0
                            
                            for fanpageAlbum in fanpageAlbums!
                            {
                                //print(fanpageAlbum["name"])
                                
                                let image = FanpageImageGamves()
                                
                                let id = fanpageAlbum.objectId as! String
                                image.objectId = id
                                
                                let name = fanpageAlbum["name"] as! String
                                image.name = name
                                
                                let coverFile = fanpageAlbum["cover"] as! PFFile
                                
                                image.source = coverFile.url!
                                
                                let catPictureURL = URL(string: coverFile.url!)!
                                
                                //print("IMAGE \(name)")
                                print(catPictureURL)
                                
                                let downloadPicTask = URLSession.shared.dataTask(with: catPictureURL) {
                                    (data, response, error) in
                                    
                                    guard error == nil else {
                                        print(error!)
                                        count = count + 1
                                        return
                                    }
                                    guard let data = data else {
                                        print("Data is empty")
                                        count = count + 1
                                        return
                                    }
                                    
                                    let uiimage = UIImage(data:data)
                                    
                                    if ((uiimage) != nil)
                                    {
                                        
                                        image.cover_image = uiimage!
                                        
                                        images.append(image)
                                        
                                        if (countFanpageAlbums!-1) == count
                                        {
                                            let fanpageId = fanpageAlbum["referenceId"] as! Int
                                            
                                            self.fanpageImagesDictionary[fanpageId] = images
                                        }
                                    }
                                    count = count + 1
                                }
                                downloadPicTask.resume()
                            }
                        }
                    }
                })
            }
        }
    }
    
    
}
