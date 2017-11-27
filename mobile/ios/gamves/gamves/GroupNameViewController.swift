//
//  GroupNameViewController.swift
//  gamves
//
//  Created by Jose Vigil on 10/22/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit
import DownPicker
import Parse
import ParseLiveQuery
import GameKit
import NVActivityIndicatorView

class GroupNameViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{

    var homeController: HomeController?
    
    var gamvesUsers = [GamvesParseUser]()
    
    let cellId = "cellGroupId"
    
    let imagePicker = UIImagePickerController()
    
    var selectedImageView = UIImageView()
    
    var chatId = Int()
    var chatFeed:PFObject!
    var chatIdStr = String()
    
    var arrayIds = [String]()
    
    var activityView: NVActivityIndicatorView!
    
    let newGroupContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var checkLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var cameraContainerView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickImageFromImage)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    lazy var cameraImageView: UIImageView = {
        let cameraImageView = UIImageView()
        cameraImageView.image = UIImage(named: "camera")
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraImageView.contentMode = .scaleAspectFit
        cameraImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickImageFromBackground)))
        cameraImageView.isUserInteractionEnabled = true
        cameraImageView.isUserInteractionEnabled = true
        return cameraImageView
    }()
    
    let userTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "New group subject"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 20)
        //tf.backgroundColor = UIColor.gray
        tf.tag = 0
        return tf
    }()
    
    let usersContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.lightGray
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        
        self.userTextField.delegate = self
        
        self.view.addSubview(self.newGroupContainerView)
        self.view.addSubview(self.usersContainerView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.newGroupContainerView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.usersContainerView)
        
        self.view.addConstraintsWithFormat("V:|[v0(120)][v1]|", views: self.newGroupContainerView, self.usersContainerView)

        self.newGroupContainerView.addSubview(self.cameraContainerView)
        self.newGroupContainerView.addSubview(self.userTextField)
        
        self.view.addConstraintsWithFormat("V:|-10-[v0(100)]-10-|", views: self.cameraContainerView)
        self.view.addConstraintsWithFormat("V:|-35-[v0(50)]-35-|", views: self.userTextField)
        
        self.cameraContainerView.addSubview(self.cameraImageView)
    
        self.cameraContainerView.addConstraintsWithFormat("H:|-20-[v0(60)]-20-|", views: self.cameraImageView)
        self.cameraContainerView.addConstraintsWithFormat("V:|-20-[v0(60)]-20-|", views: self.cameraImageView)
        
        self.view.addConstraintsWithFormat("H:|-10-[v0(100)]-20-[v1]-20-|", views: self.cameraContainerView, self.userTextField)
        
        self.usersContainerView.addSubview(self.collectionView)
        
        self.usersContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
        self.usersContainerView.addConstraintsWithFormat("V:|-40-[v0(180)]|", views: self.collectionView)
        
        self.collectionView.register(GroupUserCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
        
        self.collectionView.isPagingEnabled = true
        
        self.collectionView.reloadData()
        
        self.checkLabel =  Global.createCircularLabel(text: "✓", size: 80, fontSize: 40.0, borderWidth: 3.0, color: UIColor.gamvesColor)
        
        self.view.addSubview(self.checkLabel)
        
        let pX = self.view.frame.width - 110.0
        
        let metricsChecked = ["checkdPadding": pX]
        
        self.view.addConstraintsWithFormat("H:|-checkdPadding-[v0(80)]|", views: self.checkLabel, metrics: metricsChecked)
        self.view.addConstraintsWithFormat("V:|-90-[v0(80)]|", views: self.checkLabel)
        
        self.checkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveGroup)))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(saveGroup))
        self.checkLabel.isUserInteractionEnabled = true
        self.checkLabel.addGestureRecognizer(tapGesture)
        
        
        self.activityView = Global.setActivityIndicator(container: self.usersContainerView, type: NVActivityIndicatorType.ballPulse.rawValue, color: UIColor.gray)
        
        
        /*let floaty = Floaty()
        floaty.buttonImage =  UIImage(named: "checked")!
        
        let yPadding = self.view.frame.height - 190
        
        let xPadding = 30.0
        
        floaty.paddingY = yPadding
        floaty.paddingX = CGFloat(xPadding)
        
        self.view.addSubview(floaty)
        floaty.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveGroup)))*/
        
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.userTextField.resignFirstResponder()  //if desired
        
        self.submitForm()
        
        return false
    }
    
    func saveGroup(sender: UITapGestureRecognizer)
    {
        
        self.activityView.startAnimating()
        
        self.submitForm()
        
        let random = Int()
        
        self.chatId = Global.getRandomInt() //self.randomBetween(min:10000000, max:1000000000)
        
        self.chatFeed = PFObject(className: "ChatFeed")
        
        self.chatFeed["chatId"] = self.chatId
        
        self.chatFeed["isVideoChat"] = false
        
        self.chatFeed["room"] = self.userTextField.text
        
        let groupImageFile:PFFile!
    
        var imageGroup = UIImage()
        
        if self.cameraContainerView == nil
        {
            imageGroup = UIImage(named: "community")!
        } else
        {
            imageGroup = self.cameraContainerView.image!
        }
        
        groupImageFile = PFFile(data: UIImageJPEGRepresentation(imageGroup, 1.0)!)
        
        for user in self.gamvesUsers
        {
            let objectsIds = user.gamvesUser.objectId!
            self.arrayIds.append(objectsIds)
        }
    
        if let userId = PFUser.current()?.objectId!
        {
            self.arrayIds.append(userId)
        }
        
        let members = String(describing: self.arrayIds)
        
        self.chatFeed["members"] = members
        
        self.chatFeed.setObject(groupImageFile, forKey: "thumbnail")
        
        self.chatIdStr = String(self.chatId) as String
        
        self.chatFeed.saveInBackground(block: { (saved, error) in
            
            if error == nil
            {
                
                Global.addChannels(userIds: self.arrayIds, channel: self.chatIdStr, completionHandlerChannel: { ( resutl ) -> () in
                    
                    
                    if var username = Global.userDictionary[(PFUser.current()?.objectId)!]?.name
                    {
                        
                        if let groupName = self.userTextField.text
                        {
                            let params = ["channels": String(self.chatId), "title": "New group", "alert": "\(username) added you to a group \(groupName)"] as [String : Any]
                            
                            print(params)
                            
                            PFCloud.callFunction(inBackground: "push", withParameters: params) { (resutls, error) in
                                
                                if self.homeController != nil
                                {
                                    
                                    self.activityView.stopAnimating()
                                    
                                    self.homeController?.openChat(room: groupName, chatId: self.chatId, users: self.gamvesUsers)
                                }
                                
                                
                                print(resutls)
                                
                            }
                        }
                    }
                })
            }
        })
    }

    
    func clickImageFromBackground(sender: UITapGestureRecognizer)
    {
        handleYourPhotoImageView(sender: sender)
    }
    
    func clickImageFromImage(sender: UITapGestureRecognizer)
    {
        handleYourPhotoImageView(sender: sender)
    }
    
    func handleYourPhotoImageView(sender: UITapGestureRecognizer)
    {
        
        self.selectedImageView = (sender.view as? UIImageView)!
        
        let ac = UIAlertController(title: "Select Input", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        ac.addAction(cancelAction)
        
        ac.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }))
        
        ac.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (UIAlertAction) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }))
        
        let popover = ac.popoverPresentationController
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        present(ac, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            
            let imageLow = image.lowestQualityJPEGNSData as Data
            var smallImage = UIImage(data: imageLow)
            
            self.cameraImageView.isHidden = true
            
            self.cameraContainerView.image = smallImage
            
            Global.setRoundedImage(image: self.cameraContainerView, cornerRadius: 50, boderWidth: 2, boderColor: UIColor.black)
            
            self.cameraContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickImageFromBackground)))

        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        print(gamvesUsers.count)
        return gamvesUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GroupUserCollectionViewCell
        
        cell.nameLabel.text = gamvesUsers[indexPath.item].name
        
        cell.profileImageView.image = gamvesUsers[indexPath.item].avatar
        
        Global.setRoundedImage(image: cell.profileImageView, cornerRadius: 40, boderWidth: 2, boderColor: UIColor.lightGray)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: 100, height: 180)
    }

}
