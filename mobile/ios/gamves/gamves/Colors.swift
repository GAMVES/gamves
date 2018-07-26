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

    static let gamvesColorLittleDarker = UIColor.rgb(105, green: 205, blue: 239)

    static let gamvesTurquezeColor = UIColor.rgb(26, green: 188, blue: 156)
    static let gamvesCyanColor = UIColor.rgb(0, green: 175, blue: 239)    
    static let gamvesYellowColor = UIColor.rgb(255, green: 204, blue: 41)    
    static let gamvesGreenColor = UIColor.rgb(168, green: 207, blue: 69)
    static let gamvesFucsiaColor = UIColor.rgb(255, green: 41, blue: 192)

    static let gamvesLightBlueColor = UIColor.rgb(93, green: 182, blue: 255)
    static let gamvesChatBubbleBlueColor = UIColor.rgb(90, green: 87, blue: 88)
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

    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }

}
