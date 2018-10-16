//
//  UISearch+Extension.swift
//  gamves
//
//  Created by Jose Vigil on 12/5/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    private var textField: UITextField? {
        return subviews.first?.subviews.flatMap { $0 as? UITextField }.first
    }
    
    private var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.flatMap{ $0 as? UIActivityIndicatorView }.first
    }
    
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let newActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = UIColor.white
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
