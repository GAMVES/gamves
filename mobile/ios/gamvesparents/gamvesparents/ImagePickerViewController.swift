//
//  ImagePickerViewController.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-05-20.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit
import RSKImageCropper

protocol ProfileImagesPickerProtocol {
   func didpickImage(type:ProfileImagesTypes, smallImage:UIImage, croppedImage:UIImage)  
}

enum ProfileImagesTypes {
    case Son
    case Family
    case You
    case Spouse
}

class ImagePickerViewController: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
RSKImageCropViewControllerDelegate {
    
    var imageCropVC = RSKImageCropViewController()
    
    var type:ProfileImagesTypes!

    var profileImagesPickerProtocol:ProfileImagesPickerProtocol!

    let topView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.yellow
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center        
        return label
    }()

     let photoContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

     lazy var pictureImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "son_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoImageView)))        
        imageView.isUserInteractionEnabled = true     
        imageView.tag = 0           
        return imageView
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    lazy var finishButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "add_image")
        button.setImage(image, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gambesDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleFinish), for: .touchUpInside)
        return button
    }()

    let bottomView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.yellow
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        return view
    }()

    let imagePicker = UIImagePickerController()

    var smallImage = UIImage()

    var croppedImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imagePicker.delegate = self

        self.view.backgroundColor = UIColor.gamvesColor

        self.view.addSubview(topView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: topView)        
        
        self.view.addSubview(photoContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: photoContainerView)

        self.view.addSubview(messageLabel)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: messageLabel)

        self.view.addSubview(finishButton)
        self.view.addConstraintsWithFormat("H:|-60-[v0]-60-|", views: finishButton)
        
        self.view.addSubview(bottomView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: bottomView)

        var metricsPicker = [String:Int]()

        let width:Int = Int(self.view.frame.size.width)
        let height:Int = Int(self.view.frame.size.height)
        let photoSize = width / 3
        
        let padding = (height - (photoSize + 100 + 60)) / 2

        metricsPicker["photoSize"]             =  photoSize
        metricsPicker["padding"]               =  padding

        self.view.addConstraintsWithFormat("V:|[v0(padding)][v1(photoSize)][v2(100)][v3(60)][v4(padding)]|", views: 
            topView,
            photoContainerView,
            messageLabel,
            finishButton,
            bottomView,
            metrics: metricsPicker)

        photoContainerView.addSubview(pictureImageView)
        photoContainerView.addConstraintsWithFormat("V:|[v0]|", views: pictureImageView)
        photoContainerView.addConstraintsWithFormat("H:|-photoSize-[v0(photoSize)]-photoSize-|", views: pictureImageView, metrics: metricsPicker)              

        var metricsTitle = [String:Int]()
        let topTitle = padding / 2

        metricsTitle["topTitle"]             =  topTitle

        topView.addSubview(titleLabel)        
        topView.addConstraintsWithFormat("H:|[v0]|", views: titleLabel)
        topView.addConstraintsWithFormat("V:|-topTitle-[v0(80)]|", views: titleLabel, metrics: metricsTitle)

        self.setScreenByType()        

        // Do any additional setup after loading the view.
    }

    func setScreenByType() {

        var title = String()
        var message = String()
        var buttonTitle = String()
        var imageName = String()

        switch self.type {
            
            case .Son: 

                title = "Child Image"
                message = "Pick up an image for your son by touching the (+) add image"
                buttonTitle = "Select child Image"
                imageName = "son_photo"

                break
            
            case .Family:

                title = "Family Image"
                message = "Choose a family image where the three of you are present"
                buttonTitle = "Select Family Image"
                imageName = "family_photo"

                break

            case .You:

                title = "Your Image"
                message = "Choose your image"
                buttonTitle = "Select Your Image"
                imageName = "your_photo"

                break

             case .Spouse:

                title = "spouse Image"
                message = "Choose your spouse image"
                buttonTitle = "Select Your Spouse Image"
                imageName = "spouse_photo"

                break    
            
            default: break
            
        }

        self.titleLabel.text = title
        self.pictureImageView.image = UIImage(named: imageName)
        self.messageLabel.text = message
        self.finishButton.setTitle(buttonTitle, for: .normal)


    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func handleFinish() {

        self.profileImagesPickerProtocol.didpickImage(type: self.type, smallImage: self.smallImage, croppedImage:self.croppedImage)

        switch self.type {            
            
            case .Son:              

                self.type = ProfileImagesTypes.Family                

                self.setScreenByType()

                break
            
            case .Family:

                self.type = ProfileImagesTypes.You                

                self.setScreenByType()

                self.navigationController?.popViewController(animated: true)
                
                break

            case .You:

                self.type = ProfileImagesTypes.Spouse                

                self.setScreenByType()
               
                break

             case .Spouse:

                self.navigationController?.popViewController(animated: true)               

                break    
            
            default: break
            
        }
        
    }
    
    func setType(type:ProfileImagesTypes){
        self.type = type        
    }

    @objc func handlePhotoImageView(sender: UITapGestureRecognizer)
    {    
        let actionSheet = UIAlertController(title: "Select Input", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheet.addAction(cancelAction)
         
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
             
        }))
         
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
             
        }))        
         
        let popover = actionSheet.popoverPresentationController        
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any


        // iPad spport
        if Global.device.lowercased().range(of:"ipad") != nil {
            
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = self.view.frame

        }
         
        present(actionSheet, animated: true, completion: nil)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage 
        {           
            imageCropVC = RSKImageCropViewController(image: image)
            imageCropVC.delegate = self
            navigationController?.pushViewController(imageCropVC, animated: true)           
        }

        picker.dismiss(animated: true, completion: nil);
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        let imageLow = croppedImage.lowestQualityJPEGNSData as Data
        self.smallImage = UIImage(data: imageLow)!
        
        self.croppedImage = croppedImage

        self.pictureImageView.image = croppedImage

        self.makeRounded(imageView:self.pictureImageView)

        self.finishButton.isEnabled = true
        
        navigationController?.popViewController(animated: true)
    }

    func makeRounded(imageView:UIImageView)
    {
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2            
        imageView.clipsToBounds = true         
        imageView.layer.borderColor = UIColor.gamvesBlackColor.cgColor
        imageView.layer.borderWidth = 3
    } 


}
