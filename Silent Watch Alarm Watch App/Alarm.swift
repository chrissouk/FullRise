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


class Alarm: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {
    
    // Fields
    
    var time: Date? = nil
    
    var triggerTimer: Timer?
    var triggerInterval: TimeInterval = 1.0
    
    
    // WKExtendedRuntime Handling
    var session: WKExtendedRuntimeSession?

    func startSession(at _time: Date) {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start(at: _time)
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        print("Session invalidated with reason: \(reason)")
        
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session started")
        trigger()
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session will expire")
    }
    
    
    // Time preparation
    
    public static func getPreviousAlarmTime() -> Date {
        guard let previousAlarm = UserDefaults.standard.object(forKey: "previousAlarm") as? Date else {
            /* If there's not previous alarm, default to the nearest 0800 */
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 8
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date() // Fallback to current date
        }
        return previousAlarm
    }
    
    public static func fix(date: Date) -> Date {
    /* Reset the date so it keeps its the time, but changes the date to be within the next 24 hours */
        
        let now = Date()
        print("Now: \(now)")
        // Extract components from the selected date
        let brokenComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        print(brokenComponents)
        // Create a new date with today's date but with the selected time
        var fixedComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
        fixedComponents.hour = brokenComponents.hour
        fixedComponents.minute = brokenComponents.minute
        print(fixedComponents)
        // Create a date for the selected time today
        let validationDate = Calendar.current.date(from: fixedComponents)!
        print(validationDate)
        // Check if the selected time is in the past
        if validationDate < now {
            // If the selected time is in the past, set it for the next day
            fixedComponents.day! += 1
        }
        print(Calendar.current.date(from: fixedComponents)!)
        return Calendar.current.date(from: fixedComponents)!
    }
    
    
    // Alarm handling
    
    func set(for _time: Date) {
        
        /* Save time to this instance and as the "previousAlarm" time stored in storage */
        time = _time
        UserDefaults.standard.set(_time, forKey: "previousAlarm")
        
        print("Alarm set for \(_time)")
        
        // set the alarm
        let timeInterval = _time.timeIntervalSince(Date())
        
        if timeInterval <= 0 {
            // If the alarm time is in the past or right now, trigger the alarm immediately
            print("Alarm is for now or in the past")
            trigger()
        } else {
            startSession(at: _time)
        }
    }
    
    func trigger() {
        WKInterfaceDevice.current().play(.notification)
        
        triggerTimer?.invalidate()
        triggerTimer = Timer.scheduledTimer(withTimeInterval: triggerInterval, repeats: false) { _ in
            self.trigger() // Trigger the alarm again after 1 second
            print("Alarm triggered")
        }
    }

    func stop() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
            
        triggerTimer?.invalidate() // Stop the snooze timer
        
        print("Alarm stopped")
        
        if (session != nil) {
            session!.invalidate()
        }
    }
    
}

