//
//  ContentView.swift
//  Silent Watch Alarm Watch App
//
//  Created by Chris Souk on 9/5/24.
//

// TODO: consider creating a fallback; if my watch dies, trigger the alarm on my phone
// TODO: ensure functionality with sleep mode by adding notifications—-only they can run in the background
// TODO: add shortcut compatibility

import SwiftUI
import AVFoundation
import WatchKit
import WatchConnectivity
import UserNotifications

struct ContentView: View {
    
    let session = WCSession.default
    
    @State private var alarmTime: Date? = nil
    @State private var selectedDate: Date = {
        if let savedDate = UserDefaults.standard.object(forKey: "selectedDate") as? Date {
            return savedDate // Load saved date
        } else {
            // Default to 8 AM the next day
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 8 // Set hour to 8 AM
            components.minute = 0 // Set minute to 0
            return Calendar.current.date(from: components) ?? Date() // Use current date as fallback
        }
    }()
    @State private var showTimePicker = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var snoozeTimer: Timer?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    var body: some View {
        VStack {
            if alarmTime != nil {
                Text("Alarm Set for: \(alarmTime!, formatter: dateFormatter)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
            } else {
                if !showTimePicker {
                    Button(action: {
                        showTimePicker = true
                    }) {
                        Label("Set Alarm", systemImage: "clock")
                    }
                    .background(Color(UIColor(red: 0.6, green: 0.6, blue: 0.2, alpha: 1.0)))
                    .cornerRadius(25)
                    .padding()
                }
                
                if showTimePicker {
                    DatePicker("Select Time", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .padding()
                    
                    Button("Confirm Time") {
                        // Get the current date and time
                        let now = Date()
                        
                        // Extract components from the selected date
                        let selectedComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
                        
                        // Create a new date with today's date but with the selected time
                        var nextAlarmComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
                        nextAlarmComponents.hour = selectedComponents.hour
                        nextAlarmComponents.minute = selectedComponents.minute
                        
                        // Create a date for the selected time today
                        guard let selectedTimeToday = Calendar.current.date(from: nextAlarmComponents) else { return }
                        
                        // Check if the selected time is in the past
                        if selectedTimeToday < now {
                            // If the selected time is in the past, set it for the next day
                            nextAlarmComponents.day! += 1
                        }
                        
                        // Update selectedDate with the adjusted date
                        selectedDate = Calendar.current.date(from: nextAlarmComponents) ?? now
                        
                        // Now set the alarm
                        setAlarm(for: selectedDate)
                        showTimePicker = false
                    }
                    .background(Color(UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)))
                    .cornerRadius(25)
                    .padding()
                    
                    Button("Cancel") {
                        showTimePicker = false // Hide the time picker without saving
                    }
                    .background(Color(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)))
                    .cornerRadius(25)
                    .padding()
                }
            }
        }
        .onAppear {
            WatchSessionManager.shared // Activate the Watch session manager
            setupNotificationObserver() // Listen for the stop alarm message
            requestNotificationPermission() // Request permission for notifications
        }
    }
    
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
    
    // Set up the alarm and schedule a local notification
    func setAlarm(for _alarmTime: Date) {
        // Send info to phone
        alarmTime = _alarmTime
        sendAlarmInfo()
        
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
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play alarm sound: \(error.localizedDescription)")
        }
    }
    
    func triggerHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    func snoozeAlarm() {
        snoozeTimer?.invalidate()
        snoozeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.triggerAlarm() // Trigger the alarm again after 1 second
        }
    }
    
    func stopAlarm() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        alarmTime = nil
        snoozeTimer?.invalidate() // Stop the snooze timer
        audioPlayer?.stop() // Stop the sound
        print("Alarm stopped")
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

    // Listen for the "Stop Alarm" notification from the phone
    func setupNotificationObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("StopAlarmNotification"), object: nil, queue: .main) { _ in
            stopAlarm()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("SetAlarmNotification"), object: nil, queue: .main) { notification in
            if let receivedTime = notification.object as? Date {
                setAlarm(for: receivedTime)
                print("Alarm time received and set: \(receivedTime)")
            }
        }
    }
    
    func sendAlarmInfo() {
        let dict: [String : Any] = ["data": "Alarm!", "time": selectedDate]
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("Phone is not reachable.")
        }
    }
    
    func sendStopMessage() {
        let dict: [String : Any] = ["data": "Stop!"]
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("Phone is not reachable.")
        }
    }
}

#Preview {
    ContentView()
}
