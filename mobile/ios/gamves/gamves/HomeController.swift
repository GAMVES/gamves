///
//  ViewController.swift
//  youtube
//
//  Created by Brian Voong on 6/1/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Parse
import PopupDialog

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var popup:PopupDialog! = nil
    
    let homeCellId = "homeCellId"
    let feedCellId = "feedCellId"
    let profileCellId = "profileCellId"
    
    //let titles = ["Home", "Trending", "Community", "Profile"]
    let titles = ["Home", "Community", "Profile"]
    
    var cellFree:FeedCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = "  Home"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel
        
        setupCollectionView()
        setupMenuBar()
        setupNavBarButtons()
        
        //Global.buildPopup(viewController:self, title: "Hola", message: "Este es un mensaje")
        
    }
    
    override func viewDidLayoutSubviews() {
        //print("did")
    }
    
    func setupCollectionView()
    {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(HomeCell.self, forCellWithReuseIdentifier: homeCellId)
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: feedCellId)
        collectionView?.register(ProfileCell.self, forCellWithReuseIdentifier: profileCellId)
    
        collectionView?.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)
        
        collectionView?.isPagingEnabled = true
        
        //collectionView?.alwaysBounceVertical = false
    }
    
    func setupNavBarButtons() {
        let searchImage = UIImage(named: "search_icon")?.withRenderingMode(.alwaysOriginal)
        let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))
        
        let moreButton = UIBarButtonItem(image: UIImage(named: "nav_more_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        
        navigationItem.rightBarButtonItems = [moreButton, searchBarButtonItem]
    }
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()
    
    func handleMore() {
        //show menu
        settingsLauncher.showSettings()
    }
    
    func showControllerForSetting(_ setting: Setting) {
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func handleSearch() {
        scrollToMenuIndex(2)
    }
    
    func scrollToMenuIndex(_ menuIndex: Int)
    {
        
        let indexPath = IndexPath(item: menuIndex, section: 0)
        
        collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
        
        setTitleForIndex(menuIndex)
        
        self.reloadFeed(index: menuIndex)
        
    }
    
    fileprivate func setTitleForIndex(_ index: Int) {
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = "  \(titles[index])"
        }

    }
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.homeController = self
        return mb
    }()
    
    fileprivate func setupMenuBar() {
        navigationController?.hidesBarsOnSwipe = true
        
        let redView = UIView()
        redView.backgroundColor = UIColor.rgb(230, green: 32, blue: 31)
        view.addSubview(redView)
        view.addConstraintsWithFormat("H:|[v0]|", views: redView)
        view.addConstraintsWithFormat("V:[v0(50)]", views: redView)
        
        view.addSubview(menuBar)
        view.addConstraintsWithFormat("H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat("V:[v0(50)]", views: menuBar)
        
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 3
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        setTitleForIndex(Int(index))
        
        self.reloadFeed(index: Int(index))
    }
    
    func reloadFeed(index : Int)
    {
        if cellFree != nil && index == 1
        {
            cellFree.reloadCollectionView()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier: String
        if indexPath.item == 0
        {
            identifier = homeCellId
        } else if indexPath.item == 1
        {
            identifier = feedCellId
        } else
        {
            identifier = profileCellId
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if indexPath.item == 1
        {
            cellFree = cell as! FeedCell
            cellFree.homeController = self
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
    
    /*override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        if indexPath.item == 1
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellId, for: indexPath) as! FeedCell
            
            DispatchQueue.main.async
            {
                //cell.collectionView.reloadData()
                cell.reloadCollectionView()
            }
        
        }
        
    }*/
    
    
    lazy var chatLauncher: ChatViewController = {
        let launcher = ChatViewController()
        launcher.homeController = self
        return launcher
    }()
    
    func openChat(room: String, chatId:Int64, users:[GamvesParseUser])
    {
        self.chatLauncher.chatId = chatId
        self.chatLauncher.gamvesUsers = users
        self.chatLauncher.delegateFeed = cellFree
        self.chatLauncher.room = room
        chatLauncher.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(self.chatLauncher, animated: true)
    }
    
    lazy var selectContactViewController: SelectContactViewController = {
        let selector = SelectContactViewController()
        selector.homeController = self
        return selector
    }()
    
    func selectContact(group: Bool)
    {
        selectContactViewController.isGroup = group
        selectContactViewController.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(selectContactViewController, animated: true)
    }
    
    lazy var groupNameViewController: GroupNameViewController = {
        let groupName = GroupNameViewController()
        groupName.homeController = self
        return groupName
    }()
    
    func selectGroupName(users: [GamvesParseUser])
    {
        groupNameViewController.view.backgroundColor = UIColor.white
        groupNameViewController.gamvesUsers = users
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(groupNameViewController, animated: true)
    }
        
}






