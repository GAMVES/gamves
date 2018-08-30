//
//  UIViewController+Extensions.swift
//  gamves
//
//  Created by Jose Vigil on 10/8/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import Foundation
import UIKit
var tbKeyboardLogin : UIToolbar?
var tfLastLogin : UITextField?

extension LoginController : UITextFieldDelegate {
    
    // set all of the UITextFields' delegate to the view controller (self)
    // if no view is passed in, start w/ the self.view
    func prepTextFields(inView views : [UIView]? = nil) {
        
        for view in views!
        {
            // cycle thru all the subviews looking for text fields
            for v in view.subviews ?? self.view.subviews {
                
                if let tf = v as? UITextField {
                    // set the delegate and return key to 'Next'
                    tf.delegate = self
                    tf.returnKeyType = .next
                    // save the last text field for later
                    if tfLastLogin == nil || tfLastLogin!.tag < tf.tag {
                        tfLastLogin = tf
                    }
                }
                else if v.subviews.count > 0 { // recursive
                    prepTextFields(inView: [v])
                }
            }
        }
        
        // Set the last text field's return key to 'Send'
        // * view == nil - only do this on the end of
        // the original call (not recursive calls)
        if view == nil {
            tfLastLogin?.returnKeyType = .send
            tfLastLogin = nil
        }
    }
    
    // make the first UITextField (tag=0) the first responder
    // if no view is passed in, start w/ the self.view
    func firstTFBecomeFirstResponder(view : UIView? = nil)
    {
        for v in view?.subviews ?? self.view.subviews {
            if v is UITextField, v.tag == 0 {
                (v as! UITextField).becomeFirstResponder()
            }
            else if v.subviews.count > 0 { // recursive
                firstTFBecomeFirstResponder(view: v)
            }
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        
        if tbKeyboardLogin == nil {
            
            tbKeyboardLogin = UIToolbar.init(frame: CGRect.init(x: 0, y: 0,
                                                           width: self.view.frame.size.width, height: 44))
            let bbiPrev = UIBarButtonItem.init(title: "Previous",
                                               style: .plain, target: self, action: #selector(doBtnPrev))
            
            let bbiNext = UIBarButtonItem.init(title: "Next", style: .plain,
                                               target: self, action: #selector(doBtnNext))
            
            let bbiSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            
            let bbiSubmit = UIBarButtonItem.init(title: "Close", style: .plain,
                                                 target: self, action:#selector(NewVideoController.doBtnClose))
            
            tbKeyboardLogin?.items = [bbiPrev, bbiNext, bbiSpacer, bbiSubmit]
            
        }
        
        // if there's no tool bar, create it
        /*if tbKeyboardProfile == nil {
            tbKeyboardProfile = UIToolbar.init(frame: CGRect.init(x: 0, y: 0,
                                                           width: self.view.frame.size.width, height: 44))
            let bbiPrev = UIBarButtonItem.init(title: "Previous",
                                               style: .plain, target: self, action: #selector(doBtnPrev))
            let bbiNext = UIBarButtonItem.init(title: "Next", style: .plain,
                                               target: self, action: #selector(doBtnNext))
            let bbiSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            let bbiSubmit = UIBarButtonItem.init(title: "Submit", style: .plain,
                                                 target: self, action: #selector(UIViewController.doBtnSubmit))
            tbKeyboardProfile?.items = [bbiPrev, bbiNext, bbiSpacer, bbiSubmit]
        }*/
        
        // set the tool bar as this text field's input accessory view
        textField.inputAccessoryView = tbKeyboardLogin
        return true
    }
    
    // search view's subviews
    // if no view is passed in, start w/ the self.view
    func findTextField(withTag tag : Int,
                       inViewsSubviewsOf view : UIView? = nil) -> UITextField? 
    {
    
        for v in view?.subviews ?? self.view.subviews {
            
            // found a match? return it
            if v is UITextField, v.tag == tag {
                return (v as! UITextField)
            }
            else if v.subviews.count > 0 { // recursive
                if let tf = findTextField(withTag: tag, inViewsSubviewsOf: v) {
                    return tf
                }
            }
        }
        return nil // not found

    }
    
    // make the next (or previous if next=false) text field the first responder
    func makeTFFirstResponder(next : Bool) -> Bool {
        
        // find the current first responder (text field)
        if let fr = self.view.findFirstResponder() as? UITextField {
            
            // find the next (or previous) text field based on the tag
            if let tf = findTextField(withTag: fr.tag + (next ? 1 : -1)) {
                tf.becomeFirstResponder()
                return true
            }
        }
        return false
    }
    
    @objc func doBtnPrev(_ sender: Any) {
        let _ = makeTFFirstResponder(next: false)
    }
    
    @objc func doBtnNext(_ sender: Any) {
        let _ = makeTFFirstResponder(next: true)
    }
    
    // delegate method
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // when user taps Return, make the next text field first responder
        if makeTFFirstResponder(next: true) == false {
            // if it fails (last text field), submit the form
            submitForm()
        }
        
        return false
    }
    
    func doBtnClose(_ sender: Any) {
        submitForm()
    }
    
    func submitFormEnter() {
        self.view.endEditing(true)
        // override me
    }
    
} 

