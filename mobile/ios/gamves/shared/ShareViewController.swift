//
//  ShareViewController.swift
//  shared
//
//  Created by Jose Vigil on 21/10/2018.
//  Copyright © 2018 Gamves. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Parse

import os.log

class ShareViewController: SLComposeServiceViewController {
    
    private var url: NSURL?
    private var userDecks = [Deck]()
    fileprivate var selectedDeck: Deck?

    var userDefault = UserDefaults(suiteName: "group.com.gamves.share")!
    
    var userId = String()
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
       
        for i in 1...3 {
            let deck = Deck()
            deck.title = "Deck \(i)"
            userDecks.append(deck)
        }
        selectedDeck = userDecks.first
        
        //Back4app
       /* let configuration = ParseClientConfiguration {
            $0.applicationId = "45cgsAjYqwQQRctQTluoUpVvKsHqrjCmvh72UGBx"
            $0.clientKey = "FNRCkl1ou1wjX4j8uzhnavxNAna2OH8pjmTYPvvF"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        
        if let user = PFUser.current() {

            self.userId = (PFUser.current()?.objectId)!
            
        } else {
            // Default screen you set in info plist.
            
            var username = userDefault.string(forKey: "gamves_shared_extension_user")
            var password = userDefault.string(forKey: "gamves_shared_extension_password")
            
            // Defining the user object
            PFUser.logInWithUsername(inBackground: username!, password: password!, block: {(userPF, error) -> Void in
                
                if let error = error as NSError? {
                    
                } else
                {
                    self.userId = userPF!.objectId!                   
                }
            })
            
        }*/
        //self.placeholder = " Place Holder Text"
        //self.textView.text = ""
        //self.textView.isEditable = false
        
    }
    
    
    
   /* override func viewDidAppear(_ animated: Bool) {
        
        self.placeholder = " Place Holder Text"
        
        self.textView.text = ""
        self.textView.isEditable = false
    }*/
    
   
    
    private func setupUI() {
        let imageView = UIImageView(image: UIImage(named: "gamves_icons_white"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        navigationController?.navigationBar.topItem?.titleView = imageView
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = UIColor(red:0.97, green:0.44, blue:0.12, alpha:1.00)
    }
    

    override func didSelectPost() {
        
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            
            for (index, _) in (item.attachments?.enumerated())! {
                
                if let itemProvider = item.attachments?[index] as? NSItemProvider {
                    
                    if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {
                        
                        itemProvider.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil, completionHandler: { (url, error) -> Void in
                            
                            //if let string = (string as? String), let shareURL = URL(string: string) {
                                // send url to server to share the link
                            
                                //let urlString = url as! String
                                
                                //print(urlString)
                            
                                if self.extensionContext != nil {
                            
                                    let url = URL(string: "gamves://")!
                                    
                                    self.extensionContext?.open(url, completionHandler: { (success) in
                                        
                                        if (!success) {
                                            print("error: failed to open app from Today Extension")
                                        }
                                        
                                    })
                                }
                                    
                                //self.extensionContext?.open(URL(string: "gamves://")!, completionHandler: nil)

                                /*var videoShared:PFObject = PFObject(className: "VideoShared")
                                videoShared["userId"] = self.userId
                                videoShared["videoUrl"] = urlString
                            
                                videoShared.saveInBackground(block: { (result, error) in
                                    
                                    print(result)
                                
                                })*/
                                
                                //print (shareURL.absoluteString)
                                
                                //self.url = NSURL(string: shareURL.absoluteString)
                                
                                /*if #available(iOSApplicationExtension 10.0, *) {
                                    os_log("%{public}@", "Hello World!", urlString)
                                } else {
                                    // Fallback on earlier versions
                                }*/                            
                            
                                //self.userDefault.set(urlString, forKey: "extensionUrl")
                                //self.userDefault.synchronize()
                            
                                //if let url = URL(string: "gamves://gamves?code=\(urlString)") {
                                    
                                //if let url = URL(string: "gamves://gamves?code=56156") {
                                    
                                    //if #available(iOS 10.0, *) {
                                        
                                        //if(extensionContext.canOpenURL(url)) {
                                            
                                        //self.extensionContext?.open(url, completionHandler: {(success) in
                                                
                                                //completion(success, url.absoluteString) //this needs to stick around
                                                
                                                
                                            //})
                                        //}
                                        
                                    //} else { // < iOS 10.0
                                        
                                        //completion(UIApplication.shared.openURL(url), url.absoluteString)
                                    //}
                                //}
                            
                                
                            //}
                            
                        })
                    }
                }
            }
            //self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
                    
        
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
       
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @objc func openURL(_ url: URL) {
        return
    }
    
    func openContainerApp() {
        var responder: UIResponder? = self as UIResponder
        let selector = #selector(ShareViewController.openURL(_:))
        
        
        if #available(iOSApplicationExtension 10.0, *) {
            os_log("%{public}@", "LLEGA")
        }
        
        while responder != nil {
            if responder!.responds(to: selector) && responder != self {
                responder!.perform(selector, with: URL(string: "gamves://url")!)
                return
            }
            responder = responder?.next
        }
    }

    override func configurationItems() -> [Any]! {
        /*if let deck = SLComposeSheetConfigurationItem() {
            deck.title = "Selected Deck"
            deck.value = selectedDeck?.title
            deck.tapHandler = {
                let vc = ShareSelectViewController()
                vc.userDecks = self.userDecks
                vc.delegate = self
                self.pushConfigurationViewController(vc)
            }
            return [deck]
        }
        return nil*/
        
        var array = [Any]()
        
        let deck = SLComposeSheetConfigurationItem()
        deck?.title = "Select Category"
        deck?.value = selectedDeck?.title
        deck?.tapHandler = {
            let vc = ShareSelectViewController()
            vc.userDecks = self.userDecks
            vc.delegate = self
            self.pushConfigurationViewController(vc)
        }
        //return [deck]
        array.append(deck)
        
        let deck1 = SLComposeSheetConfigurationItem()
        deck1?.title = "Select Fanpage"
        deck1?.value = selectedDeck?.title
        deck1?.tapHandler = {
            let vc = ShareSelectViewController()
            vc.userDecks = self.userDecks
            vc.delegate = self
            self.pushConfigurationViewController(vc)
        }
        //return [deck]
        array.append(deck1)
    
        return array
    }

}

extension ShareViewController: ShareSelectViewControllerDelegate {
    func selected(deck: Deck) {
        selectedDeck = deck
        reloadConfigurationItems()
        popConfigurationViewController()
    }
}
