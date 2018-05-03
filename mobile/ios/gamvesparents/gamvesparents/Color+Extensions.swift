//
//  Extensions.swift
//  youtube
//
//  Created by Jose Vigil on 12/12/17.
//

import UIKit


extension UIColor {

    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }


    func rgb() -> [CGFloat] {
        
        var rgb = [CGFloat]()

        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0

        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            
            let iRed = fRed * 255.0
            let iGreen = fGreen * 255.0
            let iBlue = fBlue * 255.0
            
            let iAlpha = fAlpha * 255.0
            
            rgb.append(iRed)
            rgb.append(iGreen)
            rgb.append(iBlue)            

        } 
        
        return rgb
    }

    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }

}











