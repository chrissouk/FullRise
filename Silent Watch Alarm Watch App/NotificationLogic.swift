//
//  NotificationLogic.swift
//  FullRise
//
//  Created by Chris Souk on 10/28/24.
//

import UserNotifications

// Request permission to show notifications
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Notification permission error: \(error)")
        } else {
            print("Notification permission granted: \(granted)")
        }
    }
}

// Schedule a local notification
func scheduleNotification(at date: Date) {
    let content = UNMutableNotificationContent()
    content.title = "Silent Alarm"
    content.body = "Open to turn off!"
    content.sound = UNNotificationSound.default
    content.interruptionLevel = .timeSensitive
    
    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Failed to schedule notification: \(error.localizedDescription)")
        } else {
            print("Notification scheduled for \(date)")
        }
    }
}
