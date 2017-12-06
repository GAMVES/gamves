//
//  RecordVideoController.swift
//  gamves
//
//  Created by Jose Vigil on 12/6/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

import Photos

//https://www.appcoda.com/avfoundation-swift-guide/

@available(iOS 10.0, *)
class RecordVideoController: UIViewController {
    
    lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        //button.addTarget(self, action: #selector(handleDownButton), for: .touchUpInside)
        return button
    }()

    lazy var capturePreviewView: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        //button.addTarget(self, action: #selector(handleDownButton), for: .touchUpInside)
        return button
    }()
    
    lazy var photoModeButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        //button.addTarget(self, action: #selector(handleDownButton), for: .touchUpInside)
        return button
    }()
    
    lazy var toggleCameraButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        //button.addTarget(self, action: #selector(handleDownButton), for: .touchUpInside)
        return button
    }()
    
    
    lazy var toggleFlashButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        //button.addTarget(self, action: #selector(handleDownButton), for: .touchUpInside)
        return button
    }()
    
    lazy var videoModeButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        //button.addTarget(self, action: #selector(handleDownButton), for: .touchUpInside)
        return button
    }()
    

    let cameraController = CameraController()
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(captureButton)
        self.view.addSubview(capturePreviewView)
        self.view.addSubview(photoModeButton)
        self.view.addSubview(toggleCameraButton)
        self.view.addSubview(toggleFlashButton)
        self.view.addSubview(videoModeButton)
        

        func configureCameraController() {
            if #available(iOS 10.0, *) {
                cameraController.prepare {(error) in
                    if let error = error {
                        print(error)
                    }
                    
                    try? self.cameraController.displayPreview(on: self.capturePreviewView)
                }
            } else {
                // Fallback on earlier versions
            }
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        styleCaptureButton()
        configureCameraController()
        
        // Do any additional setup after loading the view.
    }
    
    func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        }
            
        else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }
    
    func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
            
        case .some(.rear):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
            
        case .none:
            return
        }
    }
    
    func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
