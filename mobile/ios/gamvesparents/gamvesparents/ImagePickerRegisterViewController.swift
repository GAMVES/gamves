//
//  ImagePickerRegisterViewController.swift
//  gamvesparents
//
//  Created by Jose Vigil on 05/01/2019.
//  Copyright © 2019 Gamves Parents. All rights reserved.
//

import UIKit
import RSKImageCropper


class ImagePickerRegisterViewController: UIViewController,
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
        label.backgroundColor = UIColor.cyan
        return label
    }()

     let photoContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.green
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
        label.backgroundColor = UIColor.gray
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

    let phoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.backgroundColor = UIColor.brown
        return label
    }()

    let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Phone number"
        tf.translatesAutoresizingMaskIntoConstraints = false  
        tf.backgroundColor = UIColor.white 
        tf.font = UIFont.boldSystemFont(ofSize: 20)     
        tf.layer.cornerRadius = 10.0
        tf.tag = 0
        return tf
    }()

    let bottomView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.yellow
        view.translatesAutoresizingMaskIntoConstraints = false        
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.yellow
        return view
    }()

    let imagePicker = UIImagePickerController()

    var smallImage = UIImage()

    var croppedImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.imagePicker.delegate = self

        self.view.backgroundColor = UIColor.gamvesColor

        self.view.addSubview(self.topView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.topView)        
        
        self.view.addSubview(self.photoContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.photoContainerView)

        self.view.addSubview(self.messageLabel)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.messageLabel)
        
        self.view.addSubview(self.phoneLabel)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.phoneLabel)

        self.view.addSubview(self.phoneTextField)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.phoneTextField)  

        self.view.addSubview(self.finishButton)
        self.view.addConstraintsWithFormat("H:|-60-[v0]-60-|", views: self.finishButton)       

        self.view.addSubview(self.bottomView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)

        var metricsPicker = [String:Int]()

        let width:Int = Int(self.view.frame.size.width)
        let height:Int = Int(self.view.frame.size.height)
        let photoSize = width / 3        

        metricsPicker["photoSize"] = photoSize  

        if (self.type == .Son) {
            metricsPicker["sonHeight"] = 40
        } else {
            metricsPicker["sonHeight"] = 0
        }           

        self.view.addConstraintsWithFormat("V:|[v0(100)]-20-[v1(photoSize)][v2(40)][v3(sonHeight)][v4(sonHeight)]-10-[v5(60)][v6]|", views: 
            self.topView,
            self.photoContainerView,
            self.messageLabel,
            self.phoneLabel,
            self.phoneTextField,
            self.finishButton,
            self.bottomView,
            metrics: metricsPicker)

        photoContainerView.addSubview(self.pictureImageView)
        photoContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.pictureImageView)
        photoContainerView.addConstraintsWithFormat("H:|-photoSize-[v0(photoSize)]-photoSize-|", views: 
            self.pictureImageView, 
            metrics: metricsPicker)                      

        self.topView.addSubview(self.titleLabel)        
        self.topView.addConstraintsWithFormat("H:|[v0]|", views: self.titleLabel)
        self.topView.addConstraintsWithFormat("V:|-40-[v0(80)]|", views: 
            self.titleLabel)

        self.setScreen()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /*let imagePhone = UIImage(named: "phone")
        let rightImageView = UIImageView(image: imagePhone)
        let height = self.finishButton.frame.height * 0.2
        let width = height
        let xPos = self.finishButton.frame.width - width
        let yPos = (self.finishButton.frame.height - height) / 2

        rightImageView.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        self.finishButton.addSubview(rightImageView)*/

    }

     func setScreen() {

        var title = String()
        var message = String()        
        var buttonTitle = String()
        var phoneTitle = String()
        var imageName = String()        
        
        title = "Your Image"
        message = "Choose your image"
        buttonTitle = "  Save image ad phone"
        phoneTitle = "  Your phone number"
        imageName = "your_photo"

        self.titleLabel.text = title
        self.pictureImageView.image = UIImage(named: imageName)
        self.messageLabel.text = message
        self.phoneLabel.text = phoneTitle
        self.finishButton.setTitle(buttonTitle, for: .normal)
    }


    @objc func handleFinish() {

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
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
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
