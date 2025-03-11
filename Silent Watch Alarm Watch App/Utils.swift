//
//  Utils.swift
//  FullRise
//
//  Created by Chris Souk on 10/20/24.
//

import Foundation

public func customDateFormatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = dateStyle
    formatter.timeStyle = timeStyle
    formatter.timeZone = TimeZone.current
    return formatter
}

public func getDateIndicator(from alarmTime: Date) -> String {
    var dateIndicator: String = ""
    
    if Calendar.current.isDateInTomorrow(alarmTime) {
        dateIndicator = "Tomorrow"
    } else if Calendar.current.isDateInToday(alarmTime) {
        dateIndicator = "Today"
    } else {
        dateIndicator = customDateFormatter(dateStyle: .short, timeStyle: .none).string(from: alarmTime)
    }
    
    return dateIndicator
}
