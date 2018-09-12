//
//  Double+Extensions.swift
//  gamves
//
//  Created by XCodeClub on 2018-09-11.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import Foundation


public extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}
