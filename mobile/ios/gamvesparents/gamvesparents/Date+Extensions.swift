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

extension Date {
    
    var time: String { return Formatter.time.string(from: self) }
    
    var year:    Int { return Calendar.autoupdatingCurrent.component(.year,   from: self) }
    var month:   Int { return Calendar.autoupdatingCurrent.component(.month,  from: self) }
    var day:     Int { return Calendar.autoupdatingCurrent.component(.day,    from: self) }
    
    var elapsedTime: String {
        if timeIntervalSinceNow > -60.0  { return "Just Now" }
        if isInToday                 { return "Today at \(time)" }
        if isInYesterday             { return "Yesterday at \(time)" }
        return (Formatter.dateComponents.string(from: Date().timeIntervalSince(self)) ?? "") + " ago"
    }
    var isInToday: Bool {
        return Calendar.autoupdatingCurrent.isDateInToday(self)
    }
    var isInYesterday: Bool {
        return Calendar.autoupdatingCurrent.isDateInYesterday(self)
    }
}
