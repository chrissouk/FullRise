//
//  Alarm.swift
//  FullRise
//
//  Created by Chris Souk on 10/28/24.
//

import Foundation
import AVFAudio
import WatchKit
import UserNotifications
import WatchConnectivity


class Alarm {
    
    public static var time: Date? = nil
    public static var snoozeTimer: Timer?
    public static var audioPlayer: AVAudioPlayer?
    
    public static func set(for _time: Date, session: WCSession, selectedDate: Date) {
        // Send info to phone
        time = _time
        sendAlarmInfo(session: session, selectedDate: selectedDate)
        
        // Save selected time
        UserDefaults.standard.set(_time, forKey: "selectedDate")
        
        print("Alarm set for \(_time)")
        
        // Calculate time interval until the alarm time
        let currentDate = Date()
        let timeInterval = _time.timeIntervalSince(Date())
        
        if timeInterval <= 0 {
            // If the alarm time is in the past or right now, trigger the alarm immediately
            print("Alarm is for now or in the past")
            self.trigger()
        } else {
            // Schedule a local notification
            scheduleNotification(at: _time)
            // Set a timer that triggers the alarm at the exact time interval
            Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { timer in
                self.trigger()
            }
        }
    }

    // Trigger the alarm with sound and haptics
    public static func trigger() {
        WKInterfaceDevice.current().play(.notification)
        
        self.snooze() // Automatically snooze after 1 second
    }

    public static func snooze() {
        self.snoozeTimer?.invalidate()
        self.snoozeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.trigger() // Trigger the alarm again after 1 second
        }
    }

    public static func stop() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        self.time = nil
        self.snoozeTimer?.invalidate() // Stop the snooze timer
        self.audioPlayer?.stop() // Stop the sound
        print("Alarm stopped")
    }
}

