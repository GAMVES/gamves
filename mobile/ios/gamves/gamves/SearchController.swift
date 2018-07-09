///  SearchController.swift
//  gamves
//
//  Created by Jose Vigil on 12/4/17.
//

import UIKit
import Parse
import Alamofire
import AVFoundation
import SwiftyJSON
import NVActivityIndicatorView
import PopupDialog

/*protocol VidewVideoProtocol {
    func openVideoById(id: Int)
}*/

protocol TableViewCellDelegate : class {
    func button_1_tapped(_ sender: SearchGridImageCell)
    func button_2_tapped(_ sender: SearchGridImageCell)
    func button_3_tapped(_ sender: SearchGridImageCell)
}

class RowGalleryImage {
    
    var image_1 = SearchImage()
    var image_2 = SearchImage()
    var image_3 = SearchImage()
    
}

class SearchImage {
    var image = UIImage()
    var url = String()
    var objectId = String()
    var fanpageId = Int()
    var thumbnailLink = String()
    var link = String()
    var checked = Bool()
    var title = String()
    var type:SearchActionType!
}


class YVideo {
    var image = UIImage()
    var title = String()
    var url = String()
    var description = String()
    var videoId = String()
    var duration = String()
}

public enum SearchType {
    case isImageGallery
    case isSingleImage
    case isSingleImageDelete
    case isVideo
}


public enum SearchSize {    
    case noSize
    case imageSmall
    case imageLarge    
}

public enum UploadType {
    case youtube
    case local
}

protocol SearchProtocol {
    func setResultOfsearch(videoId: String, title: String, description : String, duration : String, image : UIImage)
    func setVideoSearchType(type: UploadType)
}

class SearchController: UIViewController, 
    UITableViewDelegate, UITableViewDataSource,
    UISearchResultsUpdating, UISearchBarDelegate,
    XMLParserDelegate,    
    UIBarPositioningDelegate,
    TableViewCellDelegate,
    CustomSearchControllerDelegate
{   
     
    
    //https://www.appcoda.com/custom-search-bar-tutorial
    //var customDelegate: CustomSearchControllerDelegate!

    var customSearchController: CustomSearchController!
    
    var delegateMedia:MediaDelegate?
    
    var mediaController: MediaController!
    
    var termToSearch = String()
    
    var tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    var newVideoController:NewVideoController!
    
    var searchURL = String()
    
    //var searchController = UISearchController(searchResultsController: nil)
    
    var videoDetailsDict : [Int:YVideo]!
    var filteredVideos = [YVideo]()
    var videos = [YVideo]()
    
    var cellVideoSearch = "cellVideoSearch"
    var cellImageSearch = "cellImageSearch"
    var cellGallerySearch = "cellGallerySearch"
    var cellId = "cellId"

    var delegateSearch:SearchProtocol!   

    var parser = XMLParser()
    var trends = [GamvesTrendCategory]()    
    
    var isSuggestion = Bool()
    var isInitial = Bool()
    var type:SearchType!
    var searchSize:SearchSize!
    var searchImages = [SearchImage]()
    var rowGalleryImage = RowGalleryImage()
    var rowGalleryImages = [RowGalleryImage]()
    var activityIndicatorView:NVActivityIndicatorView?
    var imagesSelected = Dictionary<String, UIImage>()
    
    var start = Int()
    var end = Int()
    var lastTerm = String()
    
    var gridButtonTag = Int()
    
    var multiselect = Bool()

    var countSelected = Int()
    
    var buttonView = UIView()

    var buttonAddRemove:UIButton!
    var buttonCancel:UIButton!
    var buttonClear:UIButton!

    let cellHeight = 150  

    var videoSelectedScope = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.isInitial = true

        self.start = 11
        self.end = 22
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)

        let btnleft : UIButton = UIButton(frame: CGRect(x:0, y:0, width:35, height:35))
        btnleft.setTitleColor(UIColor.white, for: .normal)
        btnleft.contentMode = .left

        btnleft.setImage(UIImage(named :"arrow_back_white"), for: .normal)
                    btnleft.addTarget(self, action: #selector(goBack), for: .touchDown)
        let backBarButon: UIBarButtonItem = UIBarButtonItem(customView: btnleft)

        self.navigationItem.setLeftBarButtonItems([backBarButon], animated: false)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: self.tableView)
        
        if multiselect {
            
            let width = self.view.frame.width

            self.buttonView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 50))
            self.buttonView.backgroundColor = UIColor.gamvesBlackColor

            let w:CGFloat!

            if self.searchImages.count == 0 {
                w = width-40 
            } else {
                w = width/3
            }

            self.buttonAddRemove = UIButton(frame: CGRect(x: 0, y: 0, width: w, height: 50))
            self.buttonAddRemove.setTitle("Add Images", for: .normal)
            let image = UIImage(named: "add_white")
            self.buttonAddRemove.setImage(image, for: .normal)
            self.buttonAddRemove.addTarget(self, action: #selector(handleSaveImages), for: .touchUpInside)
            self.buttonView.addSubview(self.buttonAddRemove)
            
            self.view.addSubview(buttonView)
            
            self.view.addConstraintsWithFormat("V:|[v0][v1(50)]|", views:
                self.tableView,
                buttonView)

            self.view.addConstraintsWithFormat("H:|[v0]|", views: buttonView)
            
            self.buttonView.isHidden = true
            
        } else {
            
            self.view.addConstraintsWithFormat("V:|[v0]|", views: self.tableView)            
        }
        
        definesPresentationContext = true
           
        self.videoDetailsDict = [Int:YVideo]()
    
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        self.tableView.register(SearchVideoCell.self, forCellReuseIdentifier: self.cellVideoSearch)
        self.tableView.register(SearchSingleImageCell.self, forCellReuseIdentifier: self.cellImageSearch)
        self.tableView.register(SearchGridImageCell.self, forCellReuseIdentifier: self.cellGallerySearch)
        
        self.activityIndicatorView = Global.setActivityIndicator(container: self.view, type: NVActivityIndicatorType.ballSpinFadeLoader.rawValue, color: UIColor.gambesDarkColor)//,x: 0, y: 0, width: 80.0, height: 80.0)

        let homeImage = "background_vertical"
        let image = UIImage(named: homeImage)        

        self.title = "SEARCH VIDEO"

        self.tableView.backgroundView = UIImageView(image: image!)              

        self.tableView.register(CustomHeader.self, forHeaderFooterViewReuseIdentifier: "CustomHeader")
        self.tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        self.configureCustomSearchController()
    }   
  
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
        
        print(self.termToSearch)
        
        if !self.termToSearch.isEmpty {
            
            self.customSearchController.isActive = true
            
            self.customSearchController.customSearchBar.text = self.termToSearch
            
            print(self.termToSearch)

            if self.type == SearchType.isImageGallery ||  self.type == SearchType.isSingleImage ||  self.type == SearchType.isSingleImageDelete {
            
                var single = Bool()
                if self.type == SearchType.isSingleImage {
                    single = true
                }
                
                self.lastTerm = self.termToSearch

                if self.searchImages.count == 0 {

                    self.findImagesFromSuggestion(suggestion: self.termToSearch, isSingle: single)

                } else {

                    
                    self.addDeletButtons()

                    self.customSearchController.customSearchBar.isHidden = true
                    self.activityIndicatorView?.stopAnimating()

                }
                
            } else if self.type == SearchType.isVideo {
                
                self.findVideoFromSuggestion(suggestion:  self.termToSearch, videoId: String())
                
            }
            
        } else {


            self.loadTrends()

        }
    }


    func addDeletButtons() {

        self.buttonAddRemove.setTitle("Remove Images", for: .normal)

        let image = UIImage(named: "delete_white")
        
        self.buttonAddRemove.setImage(image, for: .normal)
        self.buttonAddRemove.addTarget(self, action: #selector(handleRemove), for: .touchUpInside)
        self.buttonView.isHidden = false


        let w = self.view.frame.width / 3

        self.buttonClear = UIButton(frame: CGRect(x: 0, y: 0, width: w, height: 50))
        self.buttonClear.setTitle("Clear", for: .normal)
        let imageClear = UIImage(named: "clear_all_white")
        self.buttonClear.setImage(imageClear, for: .normal)
        self.buttonClear.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        self.buttonView.addSubview(self.buttonClear)


        self.buttonCancel = UIButton(frame: CGRect(x: 0, y: 0, width: w, height: 50))
        self.buttonCancel.setTitle("Cancel", for: .normal)
        let imageCancel = UIImage(named: "cancel_rounded_white")
        self.buttonCancel.setImage(imageCancel, for: .normal)
        self.buttonCancel.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        self.buttonView.addSubview(self.buttonCancel)


        self.buttonView.addConstraintsWithFormat("H:|-30-[v0]-30-[v1]-10-[v2]|", views: 
            self.buttonAddRemove, self.buttonClear, self.buttonCancel)

        self.buttonView.addConstraintsWithFormat("V:|[v0]|", views: self.buttonAddRemove)
        self.buttonView.addConstraintsWithFormat("V:|[v0]|", views: self.buttonClear)
        self.buttonView.addConstraintsWithFormat("V:|[v0]|", views: self.buttonCancel)
        
      }

    func configureCustomSearchController() {

        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x:0.0, y:0.0, width:self.tableView.frame.size.width, height:80.0), searchBarFont: UIFont(name: "Futura", size: 26.0)!, searchBarTextColor: UIColor.orange, searchBarTintColor: UIColor.black)
        
        self.customSearchController.customSearchBar.placeholder = "  Search video here ..."

        self.customSearchController.customSearchBar.showsScopeBar = true

        self.customSearchController.customSearchBar.scopeButtonTitles = ["Terms", "Youtube url"]

        self.customSearchController.customDelegate = self

        self.tableView.tableHeaderView = self.customSearchController.customSearchBar     
        
    }


    func handleRemove() {
    
        var finalImages = [UIImage]()
        var removedImages = [UIImage]()      

        for image in searchImages {

            if !image.checked {
                finalImages.append(image.image)
            } else {
                removedImages.append(image.image)
            }            
        }

        print(removedImages.count)
        
        delegateMedia?.didPickImages!(finalImages)
        
        delegateMedia?.didPickRemovedImages!(removedImages)
        
        self.goBack()

    }

    func handleClear() {

        for image in searchImages {

            image.checked = false
        }

        self.tableView.reloadData()

    }

    func handleCancel() {

        self.goBack()
    }

    
    func goBack()
    {
        self.isInitial = true
        print("back")
        _ = navigationController?.popViewController(animated: true)
    }  
    
    
    // MARK: CustomSearchControllerDelegate functions
    
    func didStartSearching() {
        print("")
    }
    
    
    func didTapOnSearchButton() {
        print("")
    }
    
    
    func didTapOnCancelButton() {
        print("")   
    }
    
    
    func didChangeSearchText(searchText: String) {        

        if !self.customSearchController.customSearchBar.text!.isEmpty {       
            
            isSuggestion = true
            isInitial = false
            
            self.trends = [GamvesTrendCategory]()

            if self.videoSelectedScope == 1 {

                let text = self.customSearchController.customSearchBar.text

                let chunks = text?.components(separatedBy: "//")

                print(chunks)

                self.findVideoFromSuggestion(suggestion: String(), videoId: chunks![2])

            } else {

                self.findSuggestion(stringToSearch:
                self.customSearchController.customSearchBar.text!)
            }
            
        } else {

            self.loadInitialAgain()
            //self.trends.removeAll()
            //self.tableView.reloadData()
        }    

    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        print("")
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        print("")
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("")   
    }
    
    
    // MARK: UISearchResultsUpdating delegate function
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("")
    }
    
     func didEndSearching() {
        print("")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("")
    }
    

    func searchBarCancelButtonClicked() {    

        self.customSearchController.customSearchBar.text = ""   
        self.loadInitialAgain()
    }

    func loadInitialAgain()
    {
        self.isSuggestion = true
        self.isInitial = true

        self.trends = [GamvesTrendCategory]()
        self.trends = Global.trends_stored

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

        
    }

    func filterSearchController(id: Int) {
       self.videoSelectedScope = id
    }

    /*func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        
        if !self.customSearchController.searchBar.text!.isEmpty {
            isSuggestion = true
            self.trends = [GamvesTrendCategory]()        
            self.findSuggestion(stringToSearch: customSearchController.searchBar.text!)
        } else {
            
            self.trends.removeAll()
            self.tableView.reloadData()
        }     
         
    }*/
    
    /*@available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {       

        if !searchController.searchBar.text!.isEmpty {

            if !Global.containsSwearWord(text: self.customSearchController.customSearchBar.text! , swearWords: Global.listOfSwearWords ) {

                isSuggestion = true
                self.trends = [GamvesTrendCategory]()        
                self.findSuggestion(stringToSearch: searchController.searchBar.text!)

            } else {

                self.customSearchController.customSearchBar.text = ""

            }

        } else {
            self.trends.removeAll()
            self.tableView.reloadData()
        }
    }*/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var countSections = Int()

        if isInitial {

            countSections = self.trends.count

        } else {                 
                    
            countSections = 1                                             
        }

        return countSections
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {      

        var headerView = UITableViewHeaderFooterView()

        if !isInitial {
            return headerView
        }

        if section == 0 {

            let customView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeader") as! CustomHeader
            customView.sectionNumber = section
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openHelp))
            customView.helpImageView.isUserInteractionEnabled = true
            customView.helpImageView.addGestureRecognizer(tapGestureRecognizer)
            customView.firstLabel.text = self.trends[section].name
            
            return customView

        } else {

            headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView            
            headerView.textLabel?.text = self.trends[section].name
            headerView.textLabel?.backgroundColor = UIColor.white
            headerView.backgroundView?.backgroundColor = UIColor.gray
        }

        return headerView
        
    }

    // https://github.com/Orderella/PopupDialog

    func openHelp() { 
        
        // Prepare the popup assets
        let title = "THIS IS THE DIALOG TITLE"
        let message = "This is the message section of the popup dialog default view"
        let image = UIImage(named: "gamves_icons_white")

        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: image)

        // Create buttons
        let buttonOne = CancelButton(title: "CANCEL") {
            print("You canceled the car dialog.")
        }

        // This button will not the dismiss the dialog
        let buttonTwo = DefaultButton(title: "ADMIRE CAR", dismissOnTap: false) {
            print("What a beauty!")
        }

        let buttonThree = DefaultButton(title: "BUY CAR", height: 60) {
            print("Ah, maybe next time :)")
        }

        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo, buttonThree])

        // Present dialog
        self.present(popup, animated: true, completion: nil)

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = CGFloat()
        
        if !isInitial {
           return 0
        }

        if section == 0 {
            height = 120
        } else {
            height = 40
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var c = 0
        
        if isSuggestion {

            if isInitial {
            
                c = self.trends[section].trend.count 

            } else {

                c = self.trends.count
            }

        } else {        
            
            if type == SearchType.isVideo {
                
                if self.videoDetailsDict != nil {
                    
                    c = self.videoDetailsDict.count                
                    if c>0 {
                        print("mas uno")
                    }
                }
                
            } else if type == SearchType.isSingleImage ||  self.type == SearchType.isSingleImageDelete {
                
                c =  self.searchImages.count
                
            } else if type == SearchType.isImageGallery {
                
                c = self.rowGalleryImages.count
            }
            
        }
        return c
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(self.type)
        
        let index = indexPath.row as Int
        let section = indexPath.section as Int
        var cell = UITableViewCell()
        
        if isSuggestion {
            
            cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath)

            var tr = GamvesTrend()

            if isInitial {
                tr = self.trends[section].trend[index] as GamvesTrend
            } else {
                tr.name = self.trends[index].name
            }
            cell.textLabel?.text = tr.name
            
        } else {
            
            if type == SearchType.isVideo {
            
                var cellv = tableView.dequeueReusableCell(withIdentifier: self.cellVideoSearch) as! SearchVideoCell
                
                if let yVideo = self.videoDetailsDict[index] as! YVideo? {     

                    cellv.descLabel.text = yVideo.description
                    cellv.titleLabel.text = yVideo.title
                    print(yVideo.duration)
                    cellv.timeLabel.text = yVideo.duration
                    cellv.cellHeight = self.cellHeight
                    cellv.playImageButton.tag = index
                    
                    cellv.playImageButton.addTarget(self, action:#selector(playPause(button:)), for: .touchUpInside)

                    var yv:YVideo = self.videoDetailsDict[index]!
            
                    let videoId = yv.videoId

                    cellv.videoId = videoId
                    
                    //cellv.delegate = self
                    
                    if  yVideo.image != nil {
                        
                        cellv.thumbnailImageView.image = yVideo.image
                        cellv.thumbnailImageView.tag = index
                        
                    }

                    if index % 2 == 0 {
                        cellv.contentView.backgroundColor = UIColor.white
                    } else {
                        cellv.contentView.backgroundColor = UIColor.gamvesBackgoundColor
                    
                    }
                }
                
                return cellv
                
            } else if type == SearchType.isSingleImage || type == SearchType.isSingleImageDelete {
                
                var cells = tableView.dequeueReusableCell(withIdentifier: self.cellImageSearch) as! SearchSingleImageCell
                
                if let searchImage = self.searchImages[index] as! SearchImage? {
                    
                    if  searchImage.image != nil {
                        
                        cells.thumbnailImageView.image = searchImage.image
                        cells.thumbnailImageView.tag = index
                        
                        if multiselect {
                            
                            if type == SearchType.isSingleImageDelete {
                                
                                cells.actionType = SearchActionType.isDelete
                                cells.checkLabel.isHidden = true
                                cells.name = searchImage.title
                                
                                cells.checkLabel.text = "x"
                                cells.checkLabel.layer.backgroundColor = UIColor.red.cgColor
                                
                                
                            } else if type == SearchType.isSingleImage {
                                
                                cells.actionType = SearchActionType.isCheck
                            }
                        
                            if searchImage.checked
                            {
                                cells.checkLabel.isHidden = false
                                cells.isHighlighted = false
                            } else
                            {
                                cells.checkLabel.isHidden = true
                                cells.isHighlighted = true
                            }
                            
                            
                        } else {
                            
                            cells.checkLabel.isHidden = true
                        }
                        
                    }
                }
                return cells
                
            } else if type == SearchType.isImageGallery {
             
                var cellg = tableView.dequeueReusableCell(withIdentifier: self.cellGallerySearch) as! SearchGridImageCell
                
                print(rowGalleryImages.count)
                
                if let gallery = self.rowGalleryImages[index] as! RowGalleryImage? {
                    
                    cellg.button_1.setImage(gallery.image_1.image, for: .normal)
                    cellg.button_2.setImage(gallery.image_2.image, for: .normal)
                    cellg.button_3.setImage(gallery.image_3.image, for: .normal)
                
                    gridButtonTag = gridButtonTag + 3
                    
                    print(gridButtonTag)
                    
                    cellg.delegate = self
                    
                }
                return cellg
                
            }
            
        }
        return cell
    }


     func playPause(button: UIButton) {  
    
        let index = button.tag

        let indexPath = IndexPath(item: index, section: 0)        

        let cellv = tableView.cellForRow(at: indexPath) as! SearchVideoCell

        //let rowid:Int = Int((sender.view?.tag)!) 

        cellv.videoPlayer.isHidden = true

        cellv.loadVideo()
                

        //if delegate != nil {
            
            //delegate?.openVideoById(id: rowid)

        //}        

    }
    
    func button_1_tapped(_ sender: SearchGridImageCell){
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        let rowId = tappedIndexPath[1]
        let imageId = (3 * rowId)
        let searchImage = self.searchImages[imageId] as SearchImage
        
        delegateMedia?.didPickImage!(searchImage.image)
        self.popBackToView()
    }
    func button_2_tapped(_ sender: SearchGridImageCell){
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        let rowId = tappedIndexPath[1]
        let imageId = (3 * rowId) + 1
        print(imageId)
        let searchImage = self.searchImages[imageId] as SearchImage
        
        delegateMedia?.didPickImage!(searchImage.image)
        self.popBackToView()
    }
    func button_3_tapped(_ sender: SearchGridImageCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let rowId = tappedIndexPath[1]
    
        let imageId = (3 * rowId) + 2
        let searchImage = self.searchImages[imageId] as SearchImage

        delegateMedia?.didPickImage!(searchImage.image)
        self.popBackToView()
    }
    
    func popBackToView() {
        if let viewControllers = self.navigationController?.viewControllers {
            if viewControllers.count > 3 {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            } else {
                // fail
            }
        }
    }
    
    func handleSaveImages() {
        
        let titles = self.imagesSelected.keys
        
        var finalImages = [UIImage]()
        
        for t in titles {
            finalImages.append(self.imagesSelected[t]!)
        }
        
        delegateMedia?.didPickImages!(finalImages)
        self.popBackToView()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()
        
        if isSuggestion {
        
            height = 40
        
        } else {            
            
            if type == SearchType.isVideo {
                
                height = CGFloat(self.cellHeight)
                
            } else if type == SearchType.isImageGallery {
                
                let imageWidth = self.view.frame.width / 3
                
                height = imageWidth
                
            } else if self.type == SearchType.isSingleImage ||  self.type == SearchType.isSingleImageDelete  {
                
                let iw = self.view.frame.width
             
                let imageHeight = iw * 9 / 16
                
                height = imageHeight
                
            }
        }
        return height        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.customSearchController.customSearchBar.endEditing(true)
        
        let index = indexPath.row as Int    
        let section = indexPath.section as Int      
        
        if isSuggestion {
            
            var tr = GamvesTrend()
            if isInitial {
            
                tr = self.trends[section].trend[index] as GamvesTrend
            
            } else {
            
                tr.name = self.trends[index].name                

            }
            
            self.isSuggestion = false
            
            self.trends.removeAll()
            
            self.lastTerm = tr.name
            
            print(lastTerm)
            
            if type == SearchType.isVideo {
        
                self.findVideoFromSuggestion(suggestion: tr.name, videoId: String())

                self.isInitial = false
                
            } else if type == SearchType.isImageGallery {
                
                self.findImagesFromSuggestion(suggestion: tr.name, isSingle: false)
                
            } else if type == SearchType.isSingleImage {
                
                self.findImagesFromSuggestion(suggestion: tr.name, isSingle: true)
            }

            self.customSearchController.customSearchBar.text = tr.name
        
        } else {
         
            if type == SearchType.isVideo {
            
                if let yVideo = self.videoDetailsDict[index] as! YVideo? {
                    
                    let videoId = yVideo.videoId
                    
                    self.delegateSearch.setResultOfsearch(videoId: videoId,
                        title       : yVideo.title,
                        description : yVideo.description,
                        duration    : yVideo.duration,
                        image       : yVideo.image)
                    
                    self.tableView.tableHeaderView = nil
                    
                    self.popBackToView()
                    
                }
            

            } else if type == SearchType.isSingleImage ||  self.type == SearchType.isSingleImageDelete {

                if multiselect {
                    
                    var relaod = Bool()
                
                    let title = self.searchImages[index].title as String                   
                    
                    if self.searchImages[index].checked {
                    
                        self.searchImages[index].checked = false
                        countSelected = countSelected - 1
                        
                        self.imagesSelected.removeValue(forKey: title)
                        
                    } else {
            
                        if self.countSelected < 5 ||  self.type == SearchType.isSingleImageDelete {
                            
                            self.searchImages[index].checked = true
                            countSelected = countSelected + 1
                            
                            let title = self.searchImages[index].title as String
                            
                            self.imagesSelected[title] =  self.searchImages[index].image
                            
                        }
                        
                    }
                    
                    if !relaod {
                        self.tableView.reloadData()
                    }
                    
                } else  {
                
                    self.isInitial = true

                    let searchImage = self.searchImages[index] as SearchImage
                    
                    delegateMedia?.didPickImage!(searchImage.image)
                    self.popBackToView()
                
                }
            }
        }    
    }  
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print(type)
        
        if type == SearchType.isVideo {
            
            let lastElement = self.videoDetailsDict.count - 1
            if indexPath.row == lastElement {
            
            }
            
        } else if type == SearchType.isImageGallery {
            
            let lastElement = self.rowGalleryImages.count - 1

            if indexPath.row == lastElement {
                
                if self.end < 88 {
                    
                    self.start = self.start + 11
                    self.end = self.start + 11
                    self.findImagesFromSuggestion(suggestion: self.lastTerm, isSingle: false)
                    
                }
                
            }
            
        } else if type == SearchType.isSingleImage {
            
            let lastElement = self.searchImages.count - 1

            if indexPath.row == lastElement {
             
                if self.end < 88 {
                
                    self.start = self.start + 11
                    self.end = self.start + 11
                    self.findImagesFromSuggestion(suggestion: self.lastTerm, isSingle: true)
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func findSuggestion(stringToSearch: String) {
        
        let googleURL = "http://suggestqueries.google.com/complete/search?output=toolbar&hl=tr&ie=utf8&oe=utf8&q="
        let searchURL = URL(string: googleURL + stringToSearch.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        self.parser = XMLParser(contentsOf: searchURL!)!
        
        self.parser.delegate = self as! XMLParserDelegate
        let success:Bool = self.parser.parse()
       
        if success {
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } else {
            print("parser error")
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {        
        if (elementName == "suggestion") {
            let suggestion : String = attributeDict["data"]!
            let trend = GamvesTrendCategory()
            trend.name = suggestion
            self.trends.append(trend)
        }
     }	

    func loadTrends()
    {       

        self.activityIndicatorView?.startAnimating()

        let queryCategoryTrends = PFQuery(className:"CategoryTrends")
        queryCategoryTrends.findObjectsInBackground { (trendCategoryPF, error) in
            
            if error != nil
            {
                
                print("error")
                
            } else
            {
                
                if let trendCategoryPF = trendCategoryPF
                {

                    var countCats = 0

                    var countTrendsCategory = trendCategoryPF.count
                    
                    print(countTrendsCategory)
                    
                    for trendCat in trendCategoryPF {
                        
                        let gamvesTrendCategory = GamvesTrendCategory()
                        gamvesTrendCategory.name = trendCat["name"] as! String
                        gamvesTrendCategory.description = trendCat["description"] as! String
                        gamvesTrendCategory.objectId = trendCat.objectId!

                        let trendRealtion = trendCat["trend"] as! PFRelation
                        let trendsQuery = trendRealtion.query()                        
                        trendsQuery.findObjectsInBackground(block: { (trendsPF, error) in
                            
                            if error != nil
                            {
                                print("error")
                                
                            } else {
                        
                                
                                if let trendsPF = trendsPF
                                {
                                    var countTrends = trendsPF.count
                                    
                                    print(countTrends)
                                    
                                    for trendPF in trendsPF {

                                        let trend = GamvesTrend()
                                        trend.name = trendPF["name"] as! String
                                        trend.description = trendPF["description"] as! String
                                        trend.objectId = trendPF.objectId!

                                        gamvesTrendCategory.trend.append(trend)

                                    }

                                }

                                self.trends.append(gamvesTrendCategory)

                                if countCats == ( countTrendsCategory - 1 ) {

                                    Global.trends_stored = self.trends

                                    self.activityIndicatorView?.stopAnimating()
                                    self.tableView.reloadData()

                                }

                                countCats = countCats + 1
                            }
                        })
                        
                    }

                    self.isSuggestion = true           
                    
                    self.tableView.reloadData()
                }
            }
        }
    }



    func findVideoFromSuggestion(suggestion: String, videoId:String) {
        
        isSuggestion = false        
        self.customSearchController.customSearchBar.isLoading = true
        
        self.activityIndicatorView?.startAnimating()

        var urlString = String()
        
        if videoId.isEmpty {
        
            urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,description,channelTitle,thumbnails))&order=viewCount&q=\(suggestion)&type=video&maxResults=50&key=\(Global.api_key)"
        
        } else {

            urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id,snippet(title,description,channelTitle,thumbnails))&order=viewCount&id=\(videoId)&type=video&maxResults=50&key=\(Global.api_key)"
        }
                 
        let urlwithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(urlwithPercentEscapes!, method: .get)
            .responseJSON { response in                
                print("Success: \(response.result.isSuccess)")                
                switch response.result {
                case .success:                
                    let json = JSON(response.result.value!)                    
                    if let items = json["items"].array {                    
                        var i = 0                        
                        var countItems = items.count                        
                        for item in items {                            
                            var yv = YVideo() 
                            if let idItem = item["id"].dictionary {                                                                                            
                                if idItem["videoId"]?.stringValue != nil {
                                    let videoId = idItem["videoId"]?.stringValue as! String                                    
                                    yv.videoId = videoId                                    
                                }                       
                            }                        
                            
                            if let snippetDict = item["snippet"].dictionary {
                                
                                print(snippetDict)                       
                                yv.title = snippetDict["title"]?.stringValue as! String                                
                                print(yv.title)                                
                                yv.description = (snippetDict["description"]?.stringValue as AnyObject) as! String
                                print(yv.description)                                
                                
                                var thumbnails = snippetDict["thumbnails"]?.dictionary
                                var dfault = thumbnails?["default"]?.dictionary                                
                                var thumbUrl =  dfault?["url"]?.stringValue as! String                                
                                yv.url = thumbUrl                                
                                print(thumbUrl)
                                
                                let thUrl = URL(string: thumbUrl)!
                                let sessionCover = URLSession(configuration: .default)                                
                                print(thUrl)                                
                                let downloadCover = sessionCover.dataTask(with: thUrl) {
                                    (data, response, error) in
                                    
                                    guard error == nil else {
                                        print(error!)
                                        return
                                    }
                                    guard let data = data else {
                                        print("Data is empty")
                                        return
                                    }
                                    
                                    if error == nil {
                                        
                                        yv.image = UIImage(data:data)!     

                                        let videoId = yv.videoId                                  
                                        
                                        self.searchDuration(videoId: videoId, completionHandler: { ( videoTime ) -> () in

                                            yv.duration = videoTime

                                            self.videoDetailsDict[i] = yv

                                            if i == (countItems-1) {
                                                
                                                self.customSearchController.customSearchBar.isLoading = false

                                                DispatchQueue.main.async {
                                                    self.tableView.reloadData()
                                                    self.activityIndicatorView?.stopAnimating()
                                                }

                                            }
                                            
                                            i = i + 1      

                                        })
                                        
                                                                          
                                    }
                                    
                                }
                                downloadCover.resume()                       
                            }                            
                        }
                    }             
                break
                case .failure(let error):
                print(error)
            }
        }
    }
    
    func searchDuration(videoId:String, completionHandler : @escaping (_ videoTime:String) -> ()) {              
        
        var urlString:String = "https://www.googleapis.com/youtube/v3/videos?id=\(videoId)&part=contentDetails&key=\(Global.api_key)"
        
        let urlwithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(urlwithPercentEscapes!, method: .get)
            .responseJSON { response in
                
            print("Success: \(response.result.isSuccess)")
            
            if response.result.isSuccess {
                
                let json = JSON(response.result.value!)
                if let items = json["items"].array {
                    
                    if let contentDetails = items[0]["contentDetails"].dictionary {
                        
                        let duration = contentDetails["duration"] as! JSON
                        
                        let dateString = String(describing: duration)
                        
                        let durFormat = self.getYoutubeFormattedDuration(duration: dateString)

                        completionHandler(durFormat)
                        
                        //self.videoDetailsDict[id]!.duration = durFormat
                        
                        //DispatchQueue.main.async {
                        //    self.tableView.reloadData()
                        //    self.activityIndicatorView?.stopAnimating()
                        //}
                    }
                }
            }
        }       
    }
    
    
    func getYoutubeFormattedDuration(duration: String) -> String {
        
        let formattedDuration = duration.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.characters.count > 0 ? duration + ":" : duration
            if component.characters.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        
        return duration
        
    }


    func openVideoById(id: Int) {
        
        if let yVideo = videoDetailsDict[id] as! YVideo? {

            let videoId = yVideo.videoId

            /*var youTubePlayerController = YouTubePlayerController()
            youTubePlayerController.videoId = videoId
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            navigationController?.pushViewController(youTubePlayerController, animated: true)*/
        }
        
    }
    
    func findImagesFromSuggestion(suggestion: String, isSingle: Bool) {
        
        self.customSearchController.customSearchBar.isLoading = true
        self.activityIndicatorView?.startAnimating()
        
        var size = String()
        
        if self.searchSize == SearchSize.imageLarge {
            size = "imgSize=large&"
        } else if self.searchSize == SearchSize.imageSmall {
            size = ""
        } else if self.searchSize == SearchSize.noSize {
            size = ""
        }
        
        var urlString:String = "https://www.googleapis.com/customsearch/v1?key=\(Global.api_key)&cx=\(Global.search_engine)&q=\(suggestion)&searchType=image&\(size)start=\(self.start)&end=\(self.end)&alt=json"
        
        print(urlString)
        
        let urlwithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(urlwithPercentEscapes!, method: .get)
            .responseJSON { response in
                
                //print("Success: \(response.result.isSuccess)")
                
                switch response.result {
                case .success:
                    
                    let json = JSON(response.result.value!)
                    if let items = json["items"].array {
                        
                        var i = 0
                        var countItems = items.count
                        
                        //print(countItems)
                        
                        var countr = 0
                        
                        for item in items {
                            
                            var image = SearchImage()
                            
                            image.link = item["link"].stringValue as! String
                            
                            image.title = item["title"].stringValue as! String
                            
                            if let imageDict = item["image"].dictionary {
                                
                                //print(imageDict)
                                
                                image.thumbnailLink = imageDict["thumbnailLink"]?.stringValue as! String
                                
                                //print(image.link)
                                
                                let thUrl = URL(string: image.link)!
                                let sessionCover = URLSession(configuration: .default)
                                //print(thUrl)
                                
                                let downloadCover = sessionCover.dataTask(with: thUrl) {
                                    (data, response, error) in
                                    
                                    guard error == nil else {
                                        print(error!)
                                        return
                                    }
                                    guard let data = data else {
                                        print("Data is empty")
                                        return
                                    }
                                    
                                    if error == nil {
                                        
                                        image.image = UIImage(data:data)!
                                        
                                        if !isSingle {
                                            
                                            countr = countr + 1
                                            
                                            if countr == 1 {

                                                self.rowGalleryImage = RowGalleryImage()
                                                
                                                self.rowGalleryImage.image_1 = image
                                            
                                            } else if countr == 2 {
                                             
                                                self.rowGalleryImage.image_2 = image
                                                
                                            } else if countr == 3 {
                                                
                                                self.rowGalleryImage.image_3 = image
                                                
                                                self.rowGalleryImages.append(self.rowGalleryImage)
                                                
                                                countr = 0
                                                
                                                //DispatchQueue.main.async(execute: {
                                                //    self.tableView.reloadData()
                                                //})
                                                
                                                
                                            }
                                            
                                        } else  {
                                            self.isSuggestion = false
                                        }
                                        
                                        self.searchImages.append(image)
                                        
                                        if i == (countItems-1) {
                                            
                                            //Agregar resto cuando sea no multiplo de 3
                                            
                                            if !isSingle {
                                            
                                                if countr == 0, countr == 1, countr == 2 {
                                                    
                                                    self.rowGalleryImages.append(self.rowGalleryImage)
                                                    
                                                }
                                            }
                                            
                                            self.customSearchController.customSearchBar.isLoading = false
                                            
                                            DispatchQueue.main.async(execute: {
                                                
                                                if self.multiselect {
                                                    self.buttonView.isHidden = false
                                                }
                                                
                                                self.tableView.reloadData()
                                                self.activityIndicatorView?.stopAnimating()
                                            })
                                            
                                        }
                                        
                                        i = i + 1
                                    }
                                    
                                }
                                downloadCover.resume()
                            }
                        }
                    }
                    break
                case .failure(let error):
                    print(error)
                }
        }
    }
}


class HeaderView: UITableViewHeaderFooterView{

    override
    init(reuseIdentifier: String?){
        super.init(reuseIdentifier: reuseIdentifier)
        self.backgroundView = UIView()
        self.backgroundView!.backgroundColor = UIColor.clear
    }

    required
    init?(coder: NSCoder){
        super.init(coder: coder)!
    }
    
}

