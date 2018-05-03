//
//  CGFloat+Extension.swift
//  gamves
//
//  Created by XCodeClub on 2018-04-15.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//


import UIKit

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
