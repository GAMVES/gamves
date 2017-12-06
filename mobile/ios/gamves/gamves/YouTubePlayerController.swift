//
//  YouTubePlayerController.swift
//  gamves
//
//  Created by Jose Vigil on 12/5/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import YouTubePlayer

class YouTubePlayerController: UIViewController, YouTubePlayerDelegate  {
    
    var videoId = String()


    override func viewDidLoad() {
        super.viewDidLoad()

        let playerFrame = self.view.frame

        var videoPlayer = YouTubePlayerView(frame: playerFrame)
        self.view.addSubview(videoPlayer)

        videoPlayer.delegate = self
        
        print(self.videoId)

        videoPlayer.loadVideoID(self.videoId)

        //videoPlayer.play()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

   

}
