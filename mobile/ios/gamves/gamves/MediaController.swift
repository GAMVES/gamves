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
import AWSS3
import AWSCore

@objc public protocol MediaDelegate {
    @objc optional func didPickImage(_ image: UIImage)
    @objc optional func didPickImages(_ images: [UIImage])
    @objc optional func didPickVideo(url: URL, data: Data, thumbnail: UIImage)
}

public enum MediaType {
    case selectImage
    case selectVideo
}

class MediaController: UIViewController, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate
{
    
    var thumbnail = UIImage()
    var videoData = Data()
    
    var type: MediaType!
    var searchType: SearchType!

    let mediaPicker = UIImagePickerController()
    
    var strongSelf: MediaController?
    var imagePicker: UIImagePickerController! = UIImagePickerController()
    
    var delegate: MediaDelegate?
    
    var delegateSearch:SearchProtocol?
    
    var isImageMultiSelection = Bool()
    
    let backgroundView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()
    
    let msgLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 3
        label.text = "Record a video or choose from an existing one from the phone library"
        return label
    }()
    
    let bottomView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()
    
    //////
    
    var urlRecorded:URL!
    var isLocalVideo = Bool()
    
    let layoutContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()
    
    //@IBOutlet weak var videoLayer: UIView!
    let videoLayer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.lightGray
        return v
    }()
    
    //@IBOutlet weak var frameContainerView: UIView!
    
    let frameContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.backgroundColor = UIColor.blue
        return v
    }()
    
    
    //@IBOutlet weak var imageFrameView: UIView!
    
    let imageFrameView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.lightGray
        return v
    }()
    
    
    let startEndContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let startLabel: UILabel = {
        let label = UILabel()
        label.text = "Start: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //@IBOutlet weak var startView: UIView!
    
    let startView: UIView = {
        let label = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //@IBOutlet weak var startTimeText: UITextField!
    
    let startTimeText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    
    let separatorView: UIView = {
        let label = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = UIColor.green
        return label
    }()
    
    let endLabel: UILabel = {
        let label = UILabel()
        label.text = "End: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    //@IBOutlet weak var endView: UIView!
    
    let endView: UIView = {
        let label = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //@IBOutlet weak var endTimeText: UITextField!
    
    let endTimeText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let cropVideoRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.gamvesColor
        return view
    }()
    
    //@IBOutlet weak var cropButton: UIButton!
    
    lazy var cropButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setTitle("Crop Video and save", for: UIControlState())
        button.backgroundColor = UIColor.gambesDarkColor
        button.addTarget(self, action: #selector(handleCrop), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    let saveVideoRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.gamvesColor
        return view
    }()
    
    //@IBOutlet weak var cropButton: UIButton!
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setTitle("Save Video without cropping", for: UIControlState())
        button.backgroundColor = UIColor.gambesDarkColor
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    let trimBottomSeparatorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.gamvesColor
        return v
    }()
    
    
    var isPlaying = true
    var isSliderEnd = true
    var playbackTimeCheckerTimer: Timer! = nil
    let playerObserver: Any? = nil
    
    let exportSession: AVAssetExportSession! = nil
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    var asset: AVAsset!
    
    var url:NSURL! = nil
    var startTime: CGFloat = 0.0
    var stopTime: CGFloat  = 0.0
    var thumbTime: CMTime!
    var thumbtimeSeconds: Int!
    
    var videoPlaybackPosition: CGFloat = 0.0
    var cache:NSCache<AnyObject, AnyObject>!
    var rangeSlider: RangeSlider! = nil

    lazy var searchController: SearchController = {
        let search = SearchController()
        search.mediaController = self
        return search
    }()
    
    var termToSearch = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gamvesColor
        
        self.view.addSubview(self.backgroundView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.backgroundView)
        self.view.addConstraintsWithFormat("V:|[v0]|", views: self.backgroundView)
        
        //self.trimmerView.isHidden = true
        
        self.backgroundView.addSubview(self.msgLabel)
        self.backgroundView.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: self.msgLabel)
        
        self.backgroundView.addSubview(self.bottomView)
        self.backgroundView.addConstraintsWithFormat("H:|[v0]|", views: self.bottomView)
        
        self.view.addConstraintsWithFormat("V:|-50-[v0(100)][v1]|", views: self.msgLabel, self.bottomView)
        
        self.mediaPicker.delegate = self
        
    }
    
    func shoOptions() {
        
        let actionSheet = self.optionsActionSheet
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    func handleCrop() {
        let start = Float(startTimeText.text!)
        let end   = Float(endTimeText.text!)
        self.cropVideo(sourceURL1: self.urlRecorded as! NSURL, startTime: start!, endTime: end!)
    }
    
    func handleSave() {
        
        self.videoData = try! Data(contentsOf: self.urlRecorded, options: [])
        self.thumbnail = self.urlRecorded.generateThumbnail()
        
        self.delegate?.didPickVideo?(url: self.urlRecorded, data: self.videoData, thumbnail: self.thumbnail)
        
        //self.navigationController?.popViewController(animated: true)
        //self.navigationController?.popToRootViewController(animated: true)
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }

    }
    
    func setTrimmerView() {
        
        self.view.addSubview(self.layoutContainer)
        self.view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.layoutContainer)
        self.view.addConstraintsWithFormat("V:|-20-[v0]|", views: self.layoutContainer)
        
        print(self.view.frame.width)
        let width = self.view.frame.width - 40
        
        let videoHeight = width * 9 / 16
        
        let playMetrics = ["videoHeight":videoHeight]
        
        self.layoutContainer.addSubview(self.videoLayer)
        self.layoutContainer.addConstraintsWithFormat("H:|[v0]|", views: self.videoLayer)
        
        self.layoutContainer.addSubview(self.frameContainerView)
        self.layoutContainer.addConstraintsWithFormat("H:|[v0]|", views: self.frameContainerView)
        
        self.layoutContainer.addSubview(self.startEndContainerView)
        self.layoutContainer.addConstraintsWithFormat("H:|[v0]|", views: self.startEndContainerView)
        
        self.layoutContainer.addSubview(self.cropVideoRowView)
        self.layoutContainer.addConstraintsWithFormat("H:|[v0]|", views: self.cropVideoRowView)
        
        self.layoutContainer.addSubview(self.saveVideoRowView)
        self.layoutContainer.addConstraintsWithFormat("H:|[v0]|", views: self.saveVideoRowView)
        
        self.layoutContainer.addSubview(self.trimBottomSeparatorView)
        self.layoutContainer.addConstraintsWithFormat("H:|[v0]|", views: self.trimBottomSeparatorView)
        
        self.layoutContainer.addConstraintsWithFormat("V:|[v0(videoHeight)]-50-[v1(40)]-30-[v2(40)]-40-[v3]-10-[v4(40)]-10-[v5(40)]", views:
          self.videoLayer,
          self.frameContainerView,
          self.startEndContainerView,
          self.trimBottomSeparatorView,
          self.cropVideoRowView,
          self.saveVideoRowView,
          metrics: playMetrics)
        
        self.startEndContainerView.addSubview(self.startLabel)
        self.startEndContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.startLabel)
        
        self.startEndContainerView.addSubview(self.startView)
        self.startEndContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.startView)
        
        self.startEndContainerView.addSubview(self.separatorView)
        self.startEndContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.separatorView)
        
        self.startEndContainerView.addSubview(self.endLabel)
        self.startEndContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.endLabel)
        
        self.startEndContainerView.addSubview(self.endView)
        self.startEndContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.endView)
        
        self.startEndContainerView.addConstraintsWithFormat("H:|-20-[v0(50)][v1(70)][v2][v3(50)][v4(70)]-20-|", views:
            self.startLabel,
            self.startView,
            self.separatorView,
            self.endLabel,
            self.endView)
        
        self.frameContainerView.addSubview(self.imageFrameView)
        self.frameContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.imageFrameView)
        self.frameContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.imageFrameView)
        
        self.startView.addSubview(self.startTimeText)
        self.startView.addConstraintsWithFormat("H:|[v0]|", views: self.startTimeText)
        self.startView.addConstraintsWithFormat("V:|[v0]|", views: self.startTimeText)
        
        self.endView.addSubview(self.endTimeText)
        self.endView.addConstraintsWithFormat("H:|[v0]|", views: self.endTimeText)
        self.endView.addConstraintsWithFormat("V:|[v0]|", views: self.endTimeText)
        
        self.cropVideoRowView.addSubview(self.cropButton)
        self.cropVideoRowView.addConstraintsWithFormat("H:|[v0]|", views: self.cropButton)
        self.cropVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.cropButton)
        
        self.saveVideoRowView.addSubview(self.saveButton)
        self.saveVideoRowView.addConstraintsWithFormat("H:|[v0]|", views: self.saveButton)
        self.saveVideoRowView.addConstraintsWithFormat("V:|[v0]|", views: self.saveButton)
        
        //Whole layout view
        //layoutContainer.layer.borderWidth = 1.0
        //layoutContainer.layer.borderColor = UIColor.white.cgColor
        
        cropButton.layer.cornerRadius   = 5.0
        
        //Hiding buttons and view on load
        cropButton.isHidden         = true
        startView.isHidden          = true
        endView.isHidden            = true
        frameContainerView.isHidden = true
        
        //Style for startTime
        startTimeText.layer.cornerRadius = 5.0
        startTimeText.layer.borderWidth  = 1.0
        startTimeText.layer.borderColor  = UIColor.white.cgColor
        
        //Style for endTime
        endTimeText.layer.cornerRadius = 5.0
        endTimeText.layer.borderWidth  = 1.0
        endTimeText.layer.borderColor  = UIColor.white.cgColor
        
        imageFrameView.layer.cornerRadius = 5.0
        imageFrameView.layer.borderWidth  = 1.0
        imageFrameView.layer.borderColor  = UIColor.white.cgColor
        imageFrameView.layer.masksToBounds = true
        
        player = AVPlayer()
        
        //Allocating NsCahe for temp storage
        self.cache = NSCache()
        player = AVPlayer()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setType(type: MediaType) {
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
            self.urlRecorded = info[UIImagePickerControllerMediaURL] as! URL
            
            let chosenVideo = info[UIImagePickerControllerMediaURL] as! URL
            
            self.videoData = try! Data(contentsOf: chosenVideo, options: [])
            
            self.thumbnail = self.urlRecorded.generateThumbnail()
            
            DispatchQueue.main.async() {
                self.setTrimmerView()
            }
        
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //print("appeared")
        
        var showOptions = Bool()
        
        if type == MediaType.selectVideo {
        
            if isLocalVideo {
                
                setupTrimmer()
                isLocalVideo = false
                showOptions = false
                
            } else {
                
                showOptions = true
            }
            
        } else if type == MediaType.selectImage {
            
            showOptions = true
            
        }
        
        
        if showOptions {
            self.shoOptions()
        }
        
        
    }
    
    func setupTrimmer() {
        
        print(urlRecorded)
        
        asset   = AVURLAsset.init(url: self.urlRecorded as URL)
        
        thumbTime = asset.duration
        thumbtimeSeconds      = Int(CMTimeGetSeconds(thumbTime))
        
        print(thumbTime)
        print(thumbtimeSeconds)
        
        self.viewAfterVideoIsPicked()
        
        let item:AVPlayerItem = AVPlayerItem(asset: asset)
        player                = AVPlayer(playerItem: item)
        playerLayer           = AVPlayerLayer(player: player)
        
        print(videoLayer.bounds)
        
        playerLayer.frame     = videoLayer.bounds
        
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        player.actionAtItemEnd   = AVPlayerActionAtItemEnd.none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnVideoLayer))
        self.videoLayer.addGestureRecognizer(tap)
        self.tapOnVideoLayer(tap: tap)
        
        videoLayer.layer.addSublayer(playerLayer)
        player.play()
        
    }
    
    //Tap action on video player
    func tapOnVideoLayer(tap: UITapGestureRecognizer) {
        
        if isPlaying {
            self.player.play()
        } else {
            self.player.pause()
        }
        isPlaying = !isPlaying
    }
    
    
    func viewAfterVideoIsPicked()
    {
        //Rmoving player if alredy exists
        if(playerLayer != nil) {
            playerLayer.removeFromSuperlayer()
        }
        
        self.createImageFrames()
        
        //unhide buttons and view after video selection
        cropButton.isHidden         = false
        startView.isHidden          = false
        endView.isHidden            = false
        frameContainerView.isHidden = false
        
        
        isSliderEnd = true
        print(startTimeText)
        
        startTimeText.text = "\(0.0)"
        print(endTimeText)
        print(thumbtimeSeconds)
        endTimeText.text   = "\(thumbtimeSeconds!)"
        self.createRangeSlider()
    }
    
    
    //MARK: CreatingFrameImages
    func createImageFrames()
    {
        print(asset)
        
        //creating assets
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = kCMTimeZero;
        assetImgGenerate.requestedTimeToleranceBefore   = kCMTimeZero;
        
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = asset.duration
        let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
        let maxLength         = "\(thumbtimeSeconds)" as NSString
        
        let thumbAvg  = thumbtimeSeconds/6
        var startTime = 1
        var startXPosition:CGFloat = 0.0
        
        //loop for 6 number of frames
        for _ in 0...5
        {
            
            let imageButton = UIButton()
            
            let w = self.view.frame.width - 40
            
            print(w)
            
            let xPositionForEach = CGFloat(w)/6
            
            print(xPositionForEach)
            
            imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(self.imageFrameView.frame.height))
            
            print(xPositionForEach)
            
            do {
                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                imageButton.setImage(image, for: .normal)
            }
            catch
                _ as NSError
            {
                print("Image generation failed with error (error)")
            }
            
            startXPosition = startXPosition + xPositionForEach
            startTime = startTime + thumbAvg
            
            print(startTime)
            
            imageButton.isUserInteractionEnabled = false
            
            imageFrameView.addSubview(imageButton)
        }
        
    }
    
    //Create range slider
    func createRangeSlider()
    {
        //Remove slider if already present
        let subViews = self.frameContainerView.subviews
        for subview in subViews{
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        
        rangeSlider = RangeSlider(frame: frameContainerView.bounds)
        frameContainerView.addSubview(rangeSlider)
        rangeSlider.tag = 1000
        
        //Range slider action
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        
        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.rangeSlider.trackHighlightTintColor = UIColor.clear
            self.rangeSlider.curvaceousness = 1.0
        }
        
    }
    
    //MARK: rangeSlider Delegate
    func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        
        self.player.pause()
        
        if(isSliderEnd == true)
        {
            rangeSlider.minimumValue = 0.0
            rangeSlider.maximumValue = Double(thumbtimeSeconds)
            
            rangeSlider.upperValue = Double(thumbtimeSeconds)
            isSliderEnd = !isSliderEnd
            
        }
        
        startTimeText.text = "\(rangeSlider.lowerValue)"
        endTimeText.text   = "\(rangeSlider.upperValue)"
        
        print(rangeSlider.lowerLayerSelected)
        if(rangeSlider.lowerLayerSelected)
        {
            self.seekVideo(toPos: CGFloat(rangeSlider.lowerValue))
            
        }
        else
        {
            self.seekVideo(toPos: CGFloat(rangeSlider.upperValue))
            
        }
        
        print(startTime)
    }
    
    //Seek video when slide
    func seekVideo(toPos pos: CGFloat) {
        self.videoPlaybackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), self.player.currentTime().timescale)
        self.player.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
        if(pos == CGFloat(thumbtimeSeconds))
        {
            self.player.pause()
        }
    }
    
    //Trim Video Function
    func cropVideo(sourceURL1: NSURL, startTime:Float, endTime:Float)
    {
        let manager                 = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        guard let mediaType         = "mp4" as? String else {return}
        guard (sourceURL1 as? NSURL) != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String
        {
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")
            
            let start = startTime
            let end = endTime
            print(documentDirectory)
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                //let name = hostent.newName()
                outputURL = outputURL.appendingPathComponent("1.mp4")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileTypeMPEG4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                    
                    //self.saveToCameraRoll(URL: outputURL as NSURL!)
                    
                    self.videoData = try! Data(contentsOf: outputURL, options: [])
                    
                    self.thumbnail = outputURL.generateThumbnail()
                    
                    self.delegate?.didPickVideo?(url: outputURL, data: self.videoData, thumbnail: self.thumbnail)
                    
                    DispatchQueue.main.async() {
                        
                        if let navController = self.navigationController {
                            navController.popViewController(animated: true)
                        }
                        
                    }
                    
                case .failed:
                    print("failed \(exportSession.error)")
                    
                case .cancelled:
                    print("cancelled \(exportSession.error)")
                    
                default: break
                }}}}
    
    //Save Video to Photos Library
    func saveToCameraRoll(URL: NSURL!) {
        
        /*PHPhotoLibrary.shared().performChanges({
         PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL as URL)
         }) { saved, error in
         if saved {
         let alertController = UIAlertController(title: "Cropped video was successfully saved", message: nil, preferredStyle: .alert)
         let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
         alertController.addAction(defaultAction)
         self.present(alertController, animated: true, completion: nil)
         }}*/
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image:
        UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismiss(animated: true, completion: nil)
        
        self.strongSelf = nil // let me go
    }
    
}

private extension MediaController {
    
    var optionsActionSheet: UIAlertController {
        
        let actionSheet = UIAlertController(title: Strings.Title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            if self.type == .selectImage {
                
                let takePhotoAction = UIAlertAction(title: Strings.TakePhoto, style: UIAlertActionStyle.default) { (_) -> Void in
                    
                    self.mediaPicker.sourceType = UIImagePickerControllerSourceType.camera
                    self.mediaPicker.mediaTypes = [kUTTypeImage as String]
                    self.present(self.mediaPicker, animated: true, completion: nil)
                    
                }
                takePhotoAction.setValue(UIImage(named: "camera_black"), forKey: "image")

                
                let chooseExistingAction = UIAlertAction(title: self.chooseExistingText, style: UIAlertActionStyle.default) { (_) -> Void in
                    
                    self.mediaPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    self.mediaPicker.mediaTypes = self.chooseExistingMediaTypes
                    self.present(self.mediaPicker, animated: true, completion: nil)
                }
                chooseExistingAction.setValue(UIImage(named: "sdcard"), forKey: "image")
                
                
                let searchExistingAction = UIAlertAction(title: self.searchExistingText, style: UIAlertActionStyle.default) { (_) -> Void in
                    
                    self.searchController.type = self.searchType
                    self.searchController.termToSearch = self.termToSearch
                    self.searchController.delegateMedia = self.delegate
                    self.searchController.multiselect = self.isImageMultiSelection
                    self.searchController.delegateSearch = self.delegateSearch
                    self.searchController.view.backgroundColor = UIColor.white
                    self.navigationController?.navigationBar.tintColor = UIColor.white
                    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
                    self.navigationController?.pushViewController(self.searchController, animated: true)
                    
                }
                searchExistingAction.setValue(UIImage(named: "download"), forKey: "image")
                
                actionSheet.addAction(takePhotoAction)
                actionSheet.addAction(chooseExistingAction)
                actionSheet.addAction(searchExistingAction)
                
                
            } else if self.type == .selectVideo {
                
                let takeVideoAction = UIAlertAction(title: Strings.TakeVideo, style: UIAlertActionStyle.default) { (_) -> Void in
                    
                    self.isLocalVideo = true
                    
                    self.mediaPicker.sourceType = UIImagePickerControllerSourceType.camera
                    self.mediaPicker.mediaTypes = [kUTTypeMovie as String]
                    self.present(self.mediaPicker, animated: true, completion: nil)
                    
                }
                takeVideoAction.setValue(UIImage(named: "camera_black"), forKey: "image")
                
                let chooseExistingAction = UIAlertAction(title: self.chooseExistingText, style: UIAlertActionStyle.default) { (_) -> Void in
                    
                    self.isLocalVideo = true
                
                    self.mediaPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    self.mediaPicker.mediaTypes = self.chooseExistingMediaTypes
                    self.present(self.mediaPicker, animated: true, completion: nil)
                    
                }
                chooseExistingAction.setValue(UIImage(named: "sdcard"), forKey: "image")
                
                let searchExistingAction = UIAlertAction(title: self.searchExistingText, style: UIAlertActionStyle.default) { (_) -> Void in
                    
                    self.searchController.type = SearchType.isVideo
                    self.searchController.termToSearch = self.termToSearch
                    self.searchController.delegateMedia = self.delegate
                    self.searchController.delegateSearch = self.delegateSearch
                    self.searchController.view.backgroundColor = UIColor.white
                    self.navigationController?.navigationBar.tintColor = UIColor.white
                    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
                    self.navigationController?.pushViewController(self.searchController, animated: true)
                    
                }
                searchExistingAction.setValue(UIImage(named: "download"), forKey: "image")
                
                actionSheet.addAction(takeVideoAction)
                actionSheet.addAction(chooseExistingAction)
                actionSheet.addAction(searchExistingAction)
                
            }
        }
        
        self.addCancelActionToSheet(actionSheet)
        
        return actionSheet
    }
    
    
    func addCancelActionToSheet(_ actionSheet: UIAlertController) {
        
        let cancel = Strings.Cancel
        let cancelAction = UIAlertAction(title: cancel, style: UIAlertActionStyle.cancel) { (_) -> Void in

            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        
        }
    
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
    
    var searchExistingText: String {
        
        let t = self.type
        switch t! {
        case .selectImage:
            return Strings.SearchPhoto
        case .selectVideo:
            return Strings.SearchVideo
        default:
            break
        }
    }
    
    // MARK: - Constants
    
    struct Strings {
        
        static let Title = NSLocalizedString("Media input types", comment: "")
        
        static let TakeVideo = NSLocalizedString("Record with Camera", comment: "")
        static let ChooseVideo = NSLocalizedString("Choose existing", comment: "")
        static let SearchVideo = NSLocalizedString("Internet", comment: "")
        
        static let ChoosePhoto = NSLocalizedString("Choose existing", comment: "")
        static let TakePhoto = NSLocalizedString("Camera", comment: "")
        static let SearchPhoto = NSLocalizedString("Internet", comment: "")
        
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

