//
//  Colors.swift
//  gamves
//
//  Created by Jose Vigil on 9/22/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import Foundation
import UIKit

extension UIColor
{
    static let gamvesSeparatorColor = UIColor.rgb(220, green: 220, blue: 220)
    static let gamvesColor = UIColor.rgb(0, green: 175, blue: 239)
    static let gambesDarkColor = UIColor.rgb(0, green: 123, blue: 176)
    static let gamvesBlackColor = UIColor.rgb(55, green: 52, blue: 53)
    static let gamvesBackgoundColor = UIColor.rgb(228, green: 239, blue: 245)

    static let gamvesTurquezeColor = UIColor.rgb(26, green: 188, blue: 156)
    static let gamvesCyanColor = UIColor.rgb(0, green: 175, blue: 239)    
    static let gamvesYellowColor = UIColor.rgb(255, green: 204, blue: 41)
    static let gamvesGreenColor = UIColor.rgb(168, green: 207, blue: 69)
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}