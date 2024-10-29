//
//  Utils.swift
//  FullRise
//
//  Created by Chris Souk on 10/20/24.
//

import Foundation

public func isDateTomorrow(_ date: Date) -> Bool {
    return Calendar.current.isDateInTomorrow(date)
}

public func isDateToday(_ date: Date) -> Bool {
    return Calendar.current.isDateInToday(date)
}

public func customDateFormatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = dateStyle
    formatter.timeStyle = timeStyle
    formatter.timeZone = TimeZone.current
    return formatter
}

public func getDateIndicator(from alarmTime: Date) -> String {
    var dateIndicator: String = ""
    
    if isDateTomorrow(alarmTime) {
        dateIndicator = "Tomorrow"
    } else if isDateToday(alarmTime) {
        dateIndicator = "Today"
    } else {
        dateIndicator = customDateFormatter(dateStyle: .short, timeStyle: .none).string(from: alarmTime)
    }
    
    return dateIndicator
}
