//
//  Int+Extension.swift
//  gamves
//
//  Created by Jose Vigil on 10/14/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import Foundation
import UIKit
import GameKit

extension Int
{

    func createRandonNumber() -> Int
    {
        let randomNum:UInt32 = arc4random_uniform(100) // range is 0 to 99
        // convert the UInt32 to some other  types
        let randomTime:TimeInterval = TimeInterval(randomNum)
        let someInt:Int = Int(randomNum)
        //let someString:String = String(randomNum) //string works too
        return someInt
    }
    
    func randomBetween(min: Int, max: Int) -> Int {
        return GKRandomSource.sharedRandom().nextInt(upperBound: max - min) + min
    }
}
