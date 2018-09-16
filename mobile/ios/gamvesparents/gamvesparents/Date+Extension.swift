//
//  Date+Extension.swift
//  gamvesparents
//
//  Created by Jose Vigil on 23/01/2018.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}


extension Date {

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }

    var startOfWeek: Date? {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }

    ////////////

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

    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

}
