//
//  Gradients.swift
//  ShallTV
//
//  Created by Jose Vigil on 6/10/16.
//  Copyright ÂŠ 2016 ShallTV Network. All rights reserved.
//
  
import Foundation
import UIKit
  
    class Gradients
    {      
  
        let colors = 
        [ 
            "background": 
            [
                UIColor(red: 192.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 35.0/255.0, green: 2.0/255.0, blue: 2.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_0": 
            [
                UIColor(red: 28.0/255.0, green: 157.0/255.0, blue: 15.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 200.0/255.0, green: 163.0/255.0, blue: 16.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_1": 
            [
                UIColor(red: 22.0/255.0, green: 255.0/255.0, blue: 227.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 22.0/255.0, green: 227.0/255.0, blue: 191.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_2": 
            [
                UIColor(red: 227.0/255.0, green: 22.0/255.0, blue: 215.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 56.0/255.0, green: 137.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_3": 
            [
                UIColor(red: 238.0/255.0, green: 112.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 238.0/255.0, green: 56.0/255.0, blue: 77.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_4": 
            [
                UIColor(red: 90.0/255.0, green: 56.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 236.0/255.0, green: 56.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_5": 
            [
                UIColor(red: 65.0/255.0, green: 238.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 56.0/255.0, green: 238.0/255.0, blue: 153.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_6": 
            [
                UIColor(red: 241.0/255.0, green: 238.0/255.0, blue: 9.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 9.0/255.0, green: 200.0/255.0, blue: 241.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_7": 
            [
                UIColor(red: 220.0/255.0, green: 86.0/255.0, blue: 23.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 69.0/255.0, green: 149.0/255.0, blue: 20.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_8": 
            [
                UIColor(red: 145.0/255.0, green: 21.0/255.0, blue: 79.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 243.0/255.0, green: 127.0/255.0, blue: 250.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_9": 
            [
                UIColor(red: 18.0/255.0, green: 220.0/255.0, blue: 45.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 190.0/255.0, green: 20.0/255.0, blue: 254.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_10": 
            [
                UIColor(red: 241.0/255.0, green: 238.0/255.0, blue: 9.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 9.0/255.0, green: 200.0/255.0, blue: 241.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_11": 
            [
                UIColor(red: 241.0/255.0, green: 238.0/255.0, blue: 9.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 9.0/255.0, green: 200.0/255.0, blue: 241.0/255.0, alpha: 1.0).cgColor 
            ],
            "gradient_12": 
            [
                UIColor(red: 21.0/255.0, green: 250.0/255.0, blue: 79.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 99.0/255.0, green: 232.0/255.0, blue: 41.0/255.0, alpha: 1.0).cgColor 
            ],
            "signin": 
            [
                UIColor(red: 96.0/255.0, green: 95.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 57.0/255.0, green: 87.0/255.0, blue: 155.0/255.0, alpha: 1.0).cgColor 
            ],
            "daily": 
            [
                UIColor(red: 96.0/255.0, green: 95.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 65.0/255.0, alpha: 1.0).cgColor 
            ],
            "trending": 
            [
                UIColor(red: 192.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 35.0/255.0, green: 2.0/255.0, blue: 2.0/255.0, alpha: 1.0).cgColor 
            ],
            "play_background": 
            [
                UIColor(red: 96.0/255.0, green: 95.0/255.0, blue: 84.0/255.0, alpha: 0.9).cgColor,
                UIColor(red: 67.0/255.0, green: 65/255.0, blue: 58/255.0, alpha: 0.9).cgColor                 
            ]
        ]             
  
        func getGradientByDescription(_ desc : String) -> CAGradientLayer
        {
            let gl:CAGradientLayer
            gl = CAGradientLayer()
            gl.colors = [ colors[desc]![0], colors[desc]![1]]
            gl.locations = [ 0.0, 1.1]
            return gl
        }
         
    }
