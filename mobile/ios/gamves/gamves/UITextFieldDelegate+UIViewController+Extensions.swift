//
//  UIViewController+Extensions.swift
//  gamves
//
//  Created by Jose Vigil on 10/8/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import Foundation
import UIKit

var tbKeyboard : UIToolbar?
var tfLast : UITextField?

// move UI for keyboard placement
var tfCurrent : UITextField?
var kbHeight : CGFloat = 0.0
var vToMoveOriginalY : CGFloat = -999.0
var vToMove : UIView? {
    didSet {
        svToMove = nil
    }
}
var svToMove : UIScrollView?

 
extension UIViewController : UITextFieldDelegate {
    
    // set all of the UITextFields' delegate to the view controller (self)
    // if no view is passed in, start w/ the self.view
    func prepTextFields(inView view : UIView? = nil) {
        
        // cycle thru all the subviews looking for text fields
        for v in view?.subviews ?? self.view.subviews {
        
            if let tf = v as? UITextField {
                // set the delegate and return key to 'Next'
                tf.delegate = self
                tf.returnKeyType = .next
                // save the last text field for later
                if tfLast == nil || tfLast!.tag < tf.tag {
                    tfLast = tf
                }
            }
            else if v.subviews.count > 0 { // recursive
                prepTextFields(inView: v)
            }
        }
        
        // Set the last text field's return key to 'Send'
        // * view == nil - only do this on the end of
        // the original call (not recursive calls)
        if view == nil {
            tfLast?.returnKeyType = .send
            tfLast = nil
        }
        
    }
    
    // make the first UITextField (tag=0) the first responder
    // if no view is passed in, start w/ the self.view
    func firstTFBecomeFirstResponder(view : UIView? = nil) {
        for v in view?.subviews ?? self.view.subviews {
            print(v.tag)
            if v is UITextField, v.tag == 0 {
                (v as! UITextField).becomeFirstResponder()
            }
            else if v.subviews.count > 0 { // recursive
                firstTFBecomeFirstResponder(view: v)
            }
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // if there's no tool bar, create it
        /*if tbKeyboard == nil {
            tbKeyboard = UIToolbar.init(frame: CGRect.init(x: 0, y: 0,
                            width: self.view.frame.size.width, height: 44))
            let bbiPrev = UIBarButtonItem.init(title: "Previous",
                            style: .plain, target: self, action: #selector(doBtnPrev))
            let bbiNext = UIBarButtonItem.init(title: "Next", style: .plain,
                            target: self, action: #selector(doBtnNext))
            let bbiSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                            target: nil, action: nil)
            let bbiSubmit = UIBarButtonItem.init(title: "Submit", style: .plain,
                            target: self, action: #selector(UIViewController.doBtnSubmit))
            tbKeyboard?.items = [bbiPrev, bbiNext, bbiSpacer, bbiSubmit]
        }
        
        // set the tool bar as this text field's input accessory view
        textField.inputAccessoryView = tbKeyboard*/
        
        return true
    }
    
    // search view's subviews
    // if no view is passed in, start w/ the self.view
    func findTextField(withTag tag : Int,
                       inViewsSubviewsOf view : UIView? = nil) -> UITextField? {
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
    
    func doBtnPrev(_ sender: Any) {
        let _ = makeTFFirstResponder(next: false)
    }
    
    func doBtnNext(_ sender: Any) {
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
    
    func doBtnSubmit(_ sender: Any) {
        submitForm()
    }
 
    func submitForm() {
        self.view.endEditing(true)
        // override me
    }
    
    /////////////
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func trueYBottom(ofView view : UIView) -> CGFloat {
        var bot : CGFloat = 0.0
        
        var v : UIView? = view
        
        while v != nil {
            if v!.frame.origin.y > 0 {
                bot += v!.frame.origin.y
            }
            v = v!.superview
        }
        
        return bot
    }
    
    func checkFormPlacement() {
        guard vToMove != nil else { return }
        
        var firstTime = false
        if svToMove == nil {
            svToMove = UIScrollView.init(frame: vToMove!.frame)
            svToMove?.alwaysBounceVertical = true
            svToMove?.contentSize = CGSize.init(width: (svToMove?.frame.size.width)!, height: (vToMove?.frame.size.height)!)
            vToMove?.superview?.addSubview(svToMove!)
            svToMove?.addSubview(vToMove!)
            firstTime = true
        }
        
        var rect = vToMove!.frame
        if vToMoveOriginalY == -999.0 {
            vToMoveOriginalY = rect.origin.y
        }
        if let tf = tfCurrent {
            let bottomOfTF = trueYBottom(ofView: tf) + tf.frame.size.height + 30 // 30 is buffer
            //            let topOfKB = rect.size.height - kbHeight
            //            if  bottomOfTF > topOfKB || rect.origin.y < 0 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    if firstTime {
                        rect.size.height = (vToMove?.frame.size.height)! - kbHeight
                        svToMove?.frame = rect
                    }
                    svToMove?.contentOffset = CGPoint.init(x: 0.0, y: max(vToMoveOriginalY, bottomOfTF - kbHeight))
                    //                        rect.origin.y = min(topOfKB - bottomOfTF, vToMoveOriginalY)
                    //                        vToMove!.frame = rect
                })
            }
            //            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification){
        var info = notification.userInfo!
        if let h = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size.height {
            kbHeight = h
            checkFormPlacement()
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        guard vToMove != nil else { return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                var rect = self.view.frame
                rect.origin.y = 0
                vToMove!.frame = rect
            })
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField){
        tfCurrent = textField
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField){
        tfCurrent = nil
    }
    
} 


/*
extension UIViewController {
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func trueYBottom(ofView view : UIView) -> CGFloat {
        var bot : CGFloat = 0.0
        
        var v : UIView? = view
        
        while v != nil {
            if v!.frame.origin.y > 0 {
                bot += v!.frame.origin.y
            }
            v = v!.superview
        }
        
        return bot
    }
    
    func checkFormPlacement() {
        guard vToMove != nil else { return }
        
        var firstTime = false
        if svToMove == nil {
            svToMove = UIScrollView.init(frame: vToMove!.frame)
            svToMove?.alwaysBounceVertical = true
            svToMove?.contentSize = CGSize.init(width: (svToMove?.frame.size.width)!, height: (vToMove?.frame.size.height)!)
            vToMove?.superview?.addSubview(svToMove!)
            svToMove?.addSubview(vToMove!)
            firstTime = true
        }
        
        var rect = vToMove!.frame
        if vToMoveOriginalY == -999.0 {
            vToMoveOriginalY = rect.origin.y
        }
        if let tf = tfCurrent {
            let bottomOfTF = trueYBottom(ofView: tf) + tf.frame.size.height + 30 // 30 is buffer
//            let topOfKB = rect.size.height - kbHeight
//            if  bottomOfTF > topOfKB || rect.origin.y < 0 {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        if firstTime {
                            rect.size.height = (vToMove?.frame.size.height)! - kbHeight
                            svToMove?.frame = rect
                        }
                        svToMove?.contentOffset = CGPoint.init(x: 0.0, y: max(vToMoveOriginalY, bottomOfTF - kbHeight))
//                        rect.origin.y = min(topOfKB - bottomOfTF, vToMoveOriginalY)
//                        vToMove!.frame = rect
                    })
                }
//            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification){
        var info = notification.userInfo!
        if let h = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size.height {
            kbHeight = h
            checkFormPlacement()
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        guard vToMove != nil else { return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                var rect = self.view.frame
                rect.origin.y = 0
                vToMove!.frame = rect
            })
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField){
        tfCurrent = textField
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField){
        tfCurrent = nil
    }
}*/
