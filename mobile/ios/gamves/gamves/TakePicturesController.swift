//
//  TakePicturesController.swift
//  gamves
//
//  Created by Jose Vigil on 12/10/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

@objc public protocol TakePicturesDelegate {
    @objc optional func didPickImage(_ image: UIImage)
    @objc optional func didPickVideo(url: URL, data: Data, thumbnail: UIImage)
}

public enum TakePictureType {
    case selectImage
    case selectVideo
}

class TakePictures: UIViewController, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate
{
    
    var type: TakePictureType!
    
    let mediaPicker = UIImagePickerController()
    
    var strongSelf: TakePictures?
    var imagePicker: UIImagePickerController! = UIImagePickerController()
    
    open weak var delegate: TakePicturesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mediaPicker.delegate = self
        let actionSheet = self.optionsActionSheet
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setType(type: TakePictureType)
    {
        self.type = type
    }
    
    func presentCamera()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            let objViewController =  UIApplication.shared.keyWindow?.rootViewController
            
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            objViewController?.present(imagePicker,animated: true,completion: nil)
            strongSelf = self // keep me around
        }
        else
        {
            // error msg
            print ("error displaying Camera")
            //noCamera()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss()
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as NSString as String) {
            
            // Is Image
            let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.delegate?.didPickImage?(chosenImage)
            
        } else if mediaType.isEqual(to: kUTTypeMovie as NSString as String) {
            
            // Is Video
            let url: URL = info[UIImagePickerControllerMediaURL] as! URL
            let chosenVideo = info[UIImagePickerControllerMediaURL] as! URL
            let videoData = try! Data(contentsOf: chosenVideo, options: [])
            let thumbnail = url.generateThumbnail()
            self.delegate?.didPickVideo?(url: url, data: videoData, thumbnail: thumbnail)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image:
        UIImage, editingInfo: [String : AnyObject]?) {
        //print(self.Tag + "image picker controller")
        
        self.dismiss(animated: true, completion: nil)
        strongSelf = nil // let me go
        
    }
}

private extension TakePictures {
    
    var optionsActionSheet: UIAlertController {
        
        let actionSheet = UIAlertController(title: Strings.Title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            if self.type == .selectImage {
                
                let takePhotoAction = UIAlertAction(title: Strings.TakePhoto, style: UIAlertActionStyle.default) { (_) -> Void in
                    
                    self.mediaPicker.sourceType = UIImagePickerControllerSourceType.camera
                    self.mediaPicker.mediaTypes = [kUTTypeImage as String]
                    self.present(self.mediaPicker, animated: true, completion: nil)
                    
                }
                let chooseExistingAction = UIAlertAction(title: self.chooseExistingText, style: UIAlertActionStyle.default) { (_) -> Void in
                    
                    self.mediaPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    self.mediaPicker.mediaTypes = self.chooseExistingMediaTypes
                    self.present(self.mediaPicker, animated: true, completion: nil)
                }
                
                actionSheet.addAction(chooseExistingAction)
                actionSheet.addAction(takePhotoAction)
                
                
            } else if self.type == .selectVideo {
                
                let takeVideoAction = UIAlertAction(title: Strings.TakeVideo, style: UIAlertActionStyle.default) { (_) -> Void in
                    self.mediaPicker.sourceType = UIImagePickerControllerSourceType.camera
                    self.mediaPicker.mediaTypes = [kUTTypeMovie as String]
                    self.present(self.mediaPicker, animated: true, completion: nil)
                }
                actionSheet.addAction(takeVideoAction)
                
                let chooseExistingAction = UIAlertAction(title: self.chooseExistingText, style: UIAlertActionStyle.default) { (_) -> Void in
                    self.mediaPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    self.mediaPicker.mediaTypes = self.chooseExistingMediaTypes
                    self.present(self.mediaPicker, animated: true, completion: nil)
                }
                actionSheet.addAction(chooseExistingAction)
                
            }
        }
        
        self.addCancelActionToSheet(actionSheet)
        
        return actionSheet
    }
    

    func addCancelActionToSheet(_ actionSheet: UIAlertController) {
        let cancel = Strings.Cancel
        let cancelAction = UIAlertAction(title: cancel, style: UIAlertActionStyle.cancel, handler: nil)
        actionSheet.addAction(cancelAction)
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var chooseExistingText: String {
        
        let t = self.type
        switch t! {
        case .selectImage:
            return Strings.ChoosePhoto
        case .selectVideo:
            return Strings.ChooseVideo
        default:
            break
        }
    }
    
    var chooseExistingMediaTypes: [String] {
        
        let t = self.type
        switch t! {
        case .selectImage:
            return [kUTTypeImage as String]
        case .selectVideo:
            return [kUTTypeMovie as String]
        default:
            break
        }
        
    }
    
    // MARK: - Constants
    
    struct Strings {
        
        static let Title = NSLocalizedString("Attach", comment: "Title for a generic action sheet for picking media from the device.")
        
        static let ChoosePhoto = NSLocalizedString("Choose existing photo", comment: "Text for an option that lets the user choose an existing photo in a generic action sheet for picking media from the device.")
        
        static let ChooseVideo = NSLocalizedString("Choose existing video", comment: "Text for an option that lets the user choose an existing photo or video in a generic action sheet for picking media from the device.")
        
        static let TakePhoto = NSLocalizedString("Take a photo", comment: "Text for an option that lets the user take a picture with the device camera in a generic action sheet for picking media from the device.")
        
        static let TakeVideo = NSLocalizedString("Take a video", comment: "Text for an option that lets the user take a video with the device camera in a generic action sheet for picking media from the device.")
        
        static let Cancel = NSLocalizedString("Cancel", comment: "Text for the 'cancel' action in a generic action sheet for picking media from the device.")
    }
    
}

private extension URL {
    
    func generateThumbnail() -> UIImage {
        let asset = AVAsset(url: self)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = 0
        let imageRef = try? generator.copyCGImage(at: time, actualTime: nil)
        let thumbnail = UIImage(cgImage: imageRef!)
        return thumbnail
    }
    
}
