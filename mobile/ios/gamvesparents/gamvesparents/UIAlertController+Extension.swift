//
//  UIAlertController+Extension.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-05-20.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit

public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
