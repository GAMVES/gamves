//
//  UINavigationController+Extension.swift
//  gamves
//
//  Created by XCodeClub on 2018-03-19.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit

extension UINavigationController {
    func popViewControllerWithHandler(completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: true)
        CATransaction.commit()
    }
    func pushViewController(viewController: UIViewController, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
}
