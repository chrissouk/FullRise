//
//  AlarmLogic.swift
//  FullRise
//
//  Created by Chris Souk on 10/28/24.
//

import Foundation
import AVFAudio
import WatchKit
import UserNotifications
import WatchConnectivity

// Set up the alarm and schedule a local notification
func setAlarm(for _alarmTime: Date, session: WCSession, selectedDate: Date) {
    // Send info to phone
    ContentView.alarmTime = _alarmTime
    sendAlarmInfo(session: session, selectedDate: selectedDate)
    
    // Save selected time
    UserDefaults.standard.set(_alarmTime, forKey: "selectedDate")
    
    print("Alarm set for \(_alarmTime)")
    
    // Calculate time interval until the alarm time
    let currentDate = Date()
    let timeInterval = _alarmTime.timeIntervalSince(currentDate)
    
    if timeInterval <= 0 {
        // If the alarm time is in the past or right now, trigger the alarm immediately
        print("Alarm is for now or in the past")
        triggerAlarm()
    } else {
        // Schedule a local notification
        scheduleNotification(at: _alarmTime)
        // Set a timer that triggers the alarm at the exact time interval
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { timer in
            triggerAlarm()
        }
    }
}

// Trigger the alarm with sound and haptics
func triggerAlarm() {
    playAlarmSound() // Play sound
    triggerHaptic() // Vibrate the Apple Watch
    
    snoozeAlarm() // Automatically snooze after 1 second
}

func playAlarmSound() {
    guard let soundURL = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3") else {
        print("Alarm sound file not found.")
        return
    }
    
    do {
        let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        audioPlayer.play()
    } catch {
        print("Failed to play alarm sound: \(error.localizedDescription)")
    }
}

func triggerHaptic() {
    WKInterfaceDevice.current().play(.notification)
}

func snoozeAlarm() {
    ContentView.snoozeTimer?.invalidate()
    ContentView.snoozeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        triggerAlarm() // Trigger the alarm again after 1 second
    }
}

func stopAlarm() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
    
    ContentView.alarmTime = nil
    ContentView.snoozeTimer?.invalidate() // Stop the snooze timer
    ContentView.audioPlayer?.stop() // Stop the sound
    print("Alarm stopped")
}
