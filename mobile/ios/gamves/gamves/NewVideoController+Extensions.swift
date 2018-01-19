//
//  UIViewController+Extensions.swift
//  gamves
//
//  Created by Jose Vigil on 10/8/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import Foundation
import UIKit

var tbKeyboardNewvideo : UIToolbar?
var tfLastNewVideo : UITextField?
var tvLastNewVideo : UITextView?


extension NewVideoController : UITextFieldDelegate, UITextViewDelegate {
    
    
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
                    if tfLastNewVideo == nil || tfLastNewVideo!.tag < tf.tag {
                        tfLastNewVideo = tf
                    }
                }
                
                else if let tv = v as? UITextView {
                    // set the delegate and return key to 'Next'
                    tv.delegate = self
                    tv.returnKeyType = .next
                    // save the last text field for later
                    if tvLastNewVideo == nil || tvLastNewVideo!.tag < tv.tag {
                        tvLastNewVideo = tv
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
            tfLastNewVideo?.returnKeyType = .send
            tfLastNewVideo = nil
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
        self.createMenu(textObj: textField)
        textField.inputAccessoryView = tbKeyboardNewvideo
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.createMenu(textObj: textView)
        textView.inputAccessoryView = tbKeyboardNewvideo
        return true
    }
    
    func createMenu(textObj: AnyObject) {
        
        self.current = textObj
        
        var scroll = Int()
         
        if textObj as! NSObject == youtubeUrlTextField {
        
            scroll = 60
        
        } else if textObj as! NSObject == titleTextField {
         
            scroll = 90
        
        } else if textObj as! NSObject == descriptionTextView {
            
            scroll = 140
        }
        
        scrollView.setContentOffset(CGPoint(x:0, y:scroll), animated: false)
        
        if tbKeyboardNewvideo == nil {
            
            tbKeyboardNewvideo = UIToolbar.init(frame: CGRect.init(x: 0, y: 0,
                                                                   width: self.view.frame.size.width, height: 44))
            let bbiPrev = UIBarButtonItem.init(title: "Previous",
                                               style: .plain, target: self, action: #selector(doBtnPrev))
            
            let bbiNext : UIBarButtonItem?
            
            if textObj as! NSObject == descriptionTextView {
                
                bbiNext = UIBarButtonItem.init(title: "Finish", style: .plain,
                                               target: self, action: #selector(doBtnFinish))
            } else {
                
                bbiNext = UIBarButtonItem.init(title: "Next", style: .plain,
                                               target: self, action: #selector(doBtnNext))
            }
            
            let bbiSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            
            
            let bbiSubmit = UIBarButtonItem.init(title: "Close", style: .plain,
                                                 target: self, action: #selector(NewVideoController.doBtnClose))
            
            tbKeyboardNewvideo?.items = [bbiPrev, bbiNext!, bbiSpacer, bbiSubmit]
        }
    }
    
    // search view's subviews
    // if no view is passed in, start w/ the self.view
    /*func findTextField(withTag tag : Int,
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

    }*/
    
    // make the next (or previous if next=false) text field the first responder
    /*func makeTFFirstResponder(next : Bool) -> Bool {
        
        // find the current first responder (text field)
        if let fr = self.view.findFirstResponder() as? UITextField {
            
            // find the next (or previous) text field based on the tag
            if let tf = findTextField(withTag: fr.tag + (next ? 1 : -1)) {
                tf.becomeFirstResponder()
                return true
            }
        }
     
        return false
    }*/
    
    func doBtnPrev(_ sender: Any) {
        
        //if (self.current?.isKind(of: UITextField()))! {
        
        if (self.current === youtubeUrlTextField) {
            
            submitForm()
            
        } else if (self.current === titleTextField) {
         
            youtubeUrlTextField.becomeFirstResponder()
            
        } else if (self.current === descriptionTextView) {
         
            titleTextField.becomeFirstResponder()
            
        }     
        
    }
    
    func doBtnNext(_ sender: Any) {
        
        if (self.current === youtubeUrlTextField) {
            
            titleTextField.becomeFirstResponder()
            
        } else if (self.current === titleTextField) {
            
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    
    func doBtnFinish(_ sender: Any) {
        submitForm()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    public func textViewShouldReturn(_ textView: UITextView) -> Bool {
        submitForm()
        return false
    }
    
    func doBtnClose(_ sender: Any) {        
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: false)
        submitForm()
    }
    
    func submitForm() {
        self.view.endEditing(true)
        // override me
    }
    
} 



