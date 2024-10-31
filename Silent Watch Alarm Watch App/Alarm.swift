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
    
//    public static var time: Date? = nil
    public static var triggerTimer: Timer?
    public static var triggerInterval: TimeInterval = 1.0
    
    public static func set(for _time: Date) {
        
        // Save selected time
        UserDefaults.standard.set(_time, forKey: "alarmTimeSelection")
        
        print("Alarm set for \(_time)")
        
        // Calculate time interval until the alarm time
        let timeInterval = _time.timeIntervalSince(Date())
        
        if timeInterval <= 0 {
            // If the alarm time is in the past or right now, trigger the alarm immediately
            print("Alarm is for now or in the past")
            self.trigger()
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
    public static func trigger() {
        WKInterfaceDevice.current().play(.notification)
        
        self.triggerTimer?.invalidate()
        self.triggerTimer = Timer.scheduledTimer(withTimeInterval: self.triggerInterval, repeats: false) { _ in
            self.trigger() // Trigger the alarm again after 1 second
        }
    }

    public static func stop() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        self.triggerTimer?.invalidate() // Stop the snooze timer
        print("Alarm stopped")
    }
}

