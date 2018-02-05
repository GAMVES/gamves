//
//  Date+Extensions.swift
//  gamves
//
//  Created by Jose Vigil on 05/02/2018.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit


extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
