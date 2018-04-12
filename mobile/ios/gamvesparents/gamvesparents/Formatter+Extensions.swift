//
//  Formatter+Extensions.swift
//  gamves
//
//  Created by Jose Vigil on 07/02/2018.
//  Copyright © 2018 letsbuildthatapp. All rights reserved.
//

import UIKit

extension Formatter {
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    static let dateComponents: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.zeroFormattingBehavior = .default
        formatter.allowsFractionalUnits = false
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        return formatter
    }()
}
