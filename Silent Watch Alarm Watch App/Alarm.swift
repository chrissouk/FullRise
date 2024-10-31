//
//  Alarm.swift
//  FullRise
//
//  Created by Chris Souk on 10/28/24.
//

import Foundation
import WatchKit
import UserNotifications
import WatchConnectivity


class Alarm {
    
    var time: Date? = nil
    
    var triggerTimer: Timer?
    var triggerInterval: TimeInterval = 1.0
    
    public static func getPreviousAlarmTime() -> Date {
        if let previousAlarm = UserDefaults.standard.object(forKey: "previousAlarm") as? Date {
            // reset previous alarm to have a date within the next 24 hours
            let now = Date()
            
            // Extract components from the selected date
            let previousAlarmComponents = Calendar.current.dateComponents([.hour, .minute], from: previousAlarm)
            
            // Create a new date with today's date but with the selected time
            var nextAlarmComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
            nextAlarmComponents.hour = previousAlarmComponents.hour
            nextAlarmComponents.minute = previousAlarmComponents.minute
            
            // Create a date for the selected time today
            let nextAlarm = Calendar.current.date(from: nextAlarmComponents)!
            
            // Check if the selected time is in the past
            if nextAlarm < now {
                // If the selected time is in the past, set it for the next day
                nextAlarmComponents.day! += 1
            }
            
            return Calendar.current.date(from: nextAlarmComponents) ?? now
            
        } else {
            // Default to 8 AM the next day
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 8
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date() // Fallback to current date
        }
    }
    
    func set(for _time: Date) {
        
        // save time
        time = _time
        
        UserDefaults.standard.set(time, forKey: "previousAlarm")
        
        print("Alarm set for \(_time)")
        
        // set the alarm
        let timeInterval = _time.timeIntervalSince(Date())
        
        if timeInterval <= 0 {
            // If the alarm time is in the past or right now, trigger the alarm immediately
            print("Alarm is for now or in the past")
            trigger()
        } else {
            // Schedule a local notification
            Notifications.schedule(for: _time)
            // Set a timer that triggers the alarm at the exact time interval
            Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { timer in
                self.trigger()
            }
        }
    }

    // Trigger the alarm with sound and haptics
    func trigger() {
        WKInterfaceDevice.current().play(.notification)
        
        triggerTimer?.invalidate()
        triggerTimer = Timer.scheduledTimer(withTimeInterval: self.triggerInterval, repeats: false) { _ in
            self.trigger() // Trigger the alarm again after 1 second
        }
    }

    func stop() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        triggerTimer?.invalidate() // Stop the snooze timer
        print("Alarm stopped")
    }
}

