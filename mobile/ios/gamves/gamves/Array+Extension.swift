//
//  Array+Extension.swift
//  gamves
//
//  Created by Jose Vigil on 10/27/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

extension Array {
    
    mutating func shuffle() {
        for i in 0..<self.count {
            let j = Int(arc4random_uniform(UInt32(self.indices.last!)))
            if i != j {
                self.swapAt(i, j)
            }
        }
    }
    
    var shuffled: Array {
        var copied = Array<Element>(self)
        copied.shuffle()
        return copied
    }
    
    func indexOfObject(object : AnyObject) -> NSInteger {
        return (self as NSArray).index(of: object)
    }
}
