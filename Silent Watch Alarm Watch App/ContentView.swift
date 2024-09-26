//
//  ContentView.swift
//  Silent Watch Alarm Watch App
//
//  Created by Chris Souk on 9/5/24.
//

import SwiftUI
import AVFoundation
import WatchKit
import WatchConnectivity
import UserNotifications

struct ContentView: View {
    
    let session = WCSession.default
    
    @State private var alarmTime: Date? = nil
    @State private var selectedDate = Date()
    @State private var showTimePicker = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var snoozeTimer: Timer?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
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
        }
    }
    
    // Check if the current time matches the alarm time
    func setAlarm(for _alarmTime: Date) {
        alarmTime = _alarmTime
        sendAlarmInfo()
        
        print("alarm set for \(_alarmTime)")
        
        let currentDate = Date()
        let selectedTime = Calendar.current.dateComponents([.hour, .minute], from: _alarmTime)
        let currentTime = Calendar.current.dateComponents([.hour, .minute], from: currentDate)
        
        if selectedTime == currentTime {
            triggerAlarm()
        } else {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
                if selectedTime == now {
                    timer.invalidate()
                    triggerAlarm()
                }
            }
        }
    }
    
    // Trigger the alarm with sound and haptics
    func triggerAlarm() {
        if alarmTime == Date() {
            playAlarmSound() // Play sound
            triggerHaptic() // Vibrate the Apple Watch
            
            snoozeAlarm() // Automatically snooze after 1 second
        }
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
