//
//  UINavigationController+Extension.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-09-03.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit

// Swift 3 version, no co-animation (alongsideTransition parameter is nil)
extension UINavigationController {
    public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping (Void) -> Void)
    {
        pushViewController(viewController, animated: animated)

        guard animated, let coordinator = transitionCoordinator else {
            completion()
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}