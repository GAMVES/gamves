//
//  UITabbar+Extension.swift
//  gamvesparents
//
//  Created by Jose Vigil on 26/12/2018.
//  Copyright © 2018 Gamves Parents. All rights reserved.
//

import Foundation
import UIKit

extension UITabBar {

    private struct AssociatedKey {
        static var unselectedItemTintColor = "UITabBar.UnselectedItemTintColor"
    }

    @nonobjc
    var unselectedItemTintColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.unselectedItemTintColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.unselectedItemTintColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let color = newValue {
                setUnselectedItemTintColor(color)
            }
        }
    }

    private func setUnselectedItemTintColor(_ color: UIColor) {
        items?.forEach {
            $0.image = $0.image?.withRenderingMode(.alwaysOriginal)
            $0.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: color], for: .normal)
            $0.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: tintColor], for: .selected)
        }
    }
}
