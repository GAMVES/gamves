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
    
    static var fanpageImagesDictionary = Dictionary<Int, [GamvesAlbum]>()
    
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
                            
                            var images = [GamvesAlbum]()
                            
                            let countFanpageAlbums = fanpageAlbums?.count
                            
                            print(countFanpageAlbums)
                            
                            var count = 0
                            
                            for fanpageAlbum in fanpageAlbums!
                            {
                                //print(fanpageAlbum["name"])
                                
                                let album = GamvesAlbum()
                                
                                album.albumPF = fanpageAlbum
                                
                                let id = fanpageAlbum.objectId as! String
                                album.objectId = id
                                
                                var name = fanpageAlbum["name"] as! String
                                album.name = name

                                if fanpageAlbum["description"] != nil {
                                    let desc = fanpageAlbum["description"] as! String
                                    album.description = desc 
                                    name = "\(name)\n\(desc)"
                                    album.name = name
                                }
                                
                                let type = fanpageAlbum["type"] as! String

                                print(type)

                                album.type = type
                                
                                let coverFile = fanpageAlbum["cover"] as! PFFileObject
                                
                                album.source = coverFile.url!
                                
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
                                        
                                        album.cover_image = uiimage!
                                        
                                        images.append(album)
                                        
                                        if (countFanpageAlbums!-1) == count
                                        {
                                            let fanpageId = fanpageAlbum["referenceId"] as! Int
                                            
                                            print(fanpageId)
                                            
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
