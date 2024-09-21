//
//  ContentView.swift
//  Silent Watch Alarm
//
//  Created by Chris Souk on 9/5/24.
//

import SwiftUI
import AVFoundation
import WatchKit
import WatchConnectivity

struct ContentView: View {
    
    @State private var alarmActive = false
    @State private var selectedDate = Date()
    @State private var showTimePicker = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var snoozeTimer: Timer?
    
    let session = WCSession.default
    
    var body: some View {
        VStack {
            if !showTimePicker {
                Button(action: {
                    showTimePicker.toggle() // Toggle time picker
                }) {
                    Label("Set Alarm", systemImage: "clock")
                }
                .background(Color(UIColor(red: 0.6, green: 0.6, blue: 0.2, alpha: 1.0)))
                .cornerRadius(25)
                .padding()

                Button(action: stopAlarm) {
                    Label("Stop Alarm", systemImage: "stop.fill")
                }
                .background(Color(UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)))
                .cornerRadius(25)
            }

            // Time Picker for WatchOS
            if showTimePicker {
                DatePicker("Select Time", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .padding()

                Button("Confirm Time") {
                    alarmActive = true
                    startAlarm()
                    showTimePicker = false // Hide time picker after selection
                }
                .background(Color(UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)))
                .padding()
                .cornerRadius(25)
            }
        }
    }
    
    // Check if the current time matches the alarm time
    func startAlarm() {
        let currentDate = Date()
        let selectedTime = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
        let currentTime = Calendar.current.dateComponents([.hour, .minute], from: currentDate)
        
        // If the selected time is equal to the current time, trigger the alarm
        if selectedTime == currentTime {
            triggerAlarm()
        } else {
            // Schedule a timer to check the time every second
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
                if selectedTime == now {
                    timer.invalidate() // Stop the timer
                    triggerAlarm()
                }
            }
        }
    }
    
    // Trigger the alarm with sound and haptics
    func triggerAlarm() {
        playAlarmSound() // Play sound
        triggerHaptic() // Vibrate on the Apple Watch
        
        // Automatically snooze after 1 second
        snoozeAlarm()
    }

    // Play custom alarm sound
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
    
    // Trigger a haptic vibration (for Apple Watch)
    func triggerHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    // Snooze the alarm for 1 second
    func snoozeAlarm() {
        snoozeTimer?.invalidate() // Cancel any previous snooze
        snoozeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.triggerAlarm() // Trigger the alarm again after 1 second
        }
    }
    
    // Stop the alarm and reset everything
    func stopAlarm() {
        alarmActive = false
        snoozeTimer?.invalidate() // Stop the snooze timer
        audioPlayer?.stop() // Stop the sound
        print("Alarm stopped")
    }
}


#Preview {
    ContentView()
}
