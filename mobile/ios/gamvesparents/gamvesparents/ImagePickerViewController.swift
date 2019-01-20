//
//  ImagePickerViewController.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-05-20.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit
import RSKImageCropper

protocol ImagesPickerProtocol {
   func didpickImage(type:ProfileImagesTypes, smallImage:UIImage, croppedImage:UIImage)  
   func saveYouImageAndPhone(phone:String)
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
RSKImageCropViewControllerDelegate,
UITextFieldDelegate  {

    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()
    
    var imageCropVC = RSKImageCropViewController()
    
    var type:ProfileImagesTypes!

    var imagesPickerProtocol:ImagesPickerProtocol!

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

    let phoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false        
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 3
        //label.backgroundColor = UIColor.brown
        return label
    }()

    let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "    Cellphone number"
        tf.translatesAutoresizingMaskIntoConstraints = false  
        tf.backgroundColor = UIColor.white 
        tf.font = UIFont.boldSystemFont(ofSize: 20)     
        tf.layer.cornerRadius = 10.0
        tf.tag = 0
        tf.keyboardType = UIKeyboardType.decimalPad
        return tf
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

        self.view.addSubview(self.scrollView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.scrollView)        
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.scrollView)     

        self.view.backgroundColor = UIColor.gamvesColor

        self.scrollView.addSubview(self.topView)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.topView)        
        
        self.scrollView.addSubview(self.photoContainerView)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.photoContainerView)

        self.scrollView.addSubview(self.messageLabel)
        self.scrollView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.messageLabel)
        
        self.scrollView.addSubview(self.phoneLabel)
        self.scrollView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.phoneLabel)

        self.scrollView.addSubview(self.phoneTextField)
        self.scrollView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.phoneTextField)  

        self.scrollView.addSubview(self.finishButton)
        self.scrollView.addConstraintsWithFormat("H:|-60-[v0]-60-|", views: self.finishButton)       

        self.scrollView.addSubview(self.bottomView)
        self.scrollView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)

        var metricsPicker = [String:Int]()

        let width:Int = Int(self.view.frame.size.width)
        let height:Int = Int(self.view.frame.size.height)
        let photoSize = width / 3        

        metricsPicker["photoSize"] = photoSize  

        if (self.type == .You) {
            metricsPicker["phoneHeight"] = 40
            metricsPicker["phoneGap"] = 30
        } else {
            metricsPicker["phoneHeight"] = 0
            metricsPicker["phoneGap"] = 10
        }           

        self.scrollView.addConstraintsWithFormat(
            "V:|-20-[v0(100)]-20-[v1(photoSize)][v2(40)][v3(phoneHeight)][v4(phoneHeight)]-phoneGap-[v5(60)][v6]|", views: 
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

        self.setScreenByType()        

        // Do any additional setup after loading the view.

        if self.type == .You {

            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            self.scrollView.addGestureRecognizer(tap)
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func keyboardWillShow(notification:NSNotification){

        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }

    func setScreenByType() {

        var title = String()
        var message = String()
        var buttonTitle = String()        
        var imageName = String()

        switch self.type {
            
            case .Son?: 

                    title = "Child Image"
                    message = "Pick up an image for your son by touching the (+) add image"
                    buttonTitle = "  Select child Image"
                    imageName = "son_photo"

                    break
                
            case .Family?:

                    title = "Family Image"
                    message = "Choose a family image where the three of you are present"
                    buttonTitle = "  Select Family Image"
                    imageName = "family_photo"

                    break

            case .You?:

                    title = "Your Image"
                    message = "Choose your image"
                    buttonTitle = "  Select Your Image"
                    buttonTitle = "  Save image and phone"
                    imageName = "your_photo"    
                    let phoneTitle = "  Your phone number"    
                    self.phoneLabel.text = phoneTitle            

                    break

            case .Spouse?:

                    title = "spouse Image"
                    message = "Choose your spouse image"
                    buttonTitle = "  Select Your Spouse Image"
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
    }

    @objc func handleFinish() {
        
        print(self.type)
        print(self.croppedImage)
        print(self.smallImage)
        print(self.imagesPickerProtocol)      

        switch self.type {                

            case .You?:               
                
                self.imagesPickerProtocol.didpickImage(type: self.type,
                        smallImage: self.smallImage,
                        croppedImage:self.croppedImage)
                
                let phoneNumber = phoneTextField.text
                self.imagesPickerProtocol.saveYouImageAndPhone(phone: phoneNumber!)
               
                break
                
            case .Son?:              

                    self.type = ProfileImagesTypes.Family                

                    self.setScreenByType()

                    break
                
            case .Family?:

                    self.type = ProfileImagesTypes.You                

                    self.setScreenByType()

                    self.navigationController?.popViewController(animated: true)
                    
                    break       

            case .Spouse?:

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
            self.imageCropVC = RSKImageCropViewController(image: image, cropMode: .circle)
            self.imageCropVC.delegate = self
            self.navigationController?.pushViewController(imageCropVC, animated: true)         
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

    @objc func dismissKeyboard() {
        self.scrollView.endEditing(true)
    }


}
