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
    
    @State public static var alarmTime: Date?
    @State public static var communicationHandler = CommunicationHandler()
    
    @State private var alarmTimeSelection: Date = {
        if let savedDate = UserDefaults.standard.object(forKey: "alarmTimeSelection") as? Date {
            return savedDate // Load saved date
        } else {
            // Default to 8 AM the next day
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 8 // Set hour to 8 AM
            components.minute = 0 // Set minute to 0
            return Calendar.current.date(from: components) ?? Date() // Use current date as fallback
        }
    }()
    
    var body: some View {
        VStack {
            if ContentView.alarmTime != nil {
                // Display the time the alarm is set
                Text("Alarm Set for \(getDateIndicator(from: ContentView.alarmTime!)) at \(ContentView.alarmTime!, formatter: customDateFormatter(dateStyle: .none, timeStyle: .short))")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                
            } else {
                DatePicker("Select Time", selection: $alarmTimeSelection, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .padding()
                
                Button("Confirm Time") {
                    // Get the current date and time
                    let now = Date()
                    
                    // Extract components from the selected date
                    let selectedComponents = Calendar.current.dateComponents([.hour, .minute], from: alarmTimeSelection)
                    
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
                    
                    // Update alarmTimeSelection with the adjusted date
                    alarmTimeSelection = Calendar.current.date(from: nextAlarmComponents) ?? now
                    
                    // Now set the alarm
                    ContentView.alarmTime = alarmTimeSelection
                    ContentView.communicationHandler.sendMessage(subject: "alarm!", contents: alarmTimeSelection)
                    Alarm.set(for: alarmTimeSelection)
                }
                .background(Color(UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)))
                .cornerRadius(25)
                .padding()
                
            }
        }
        .onAppear {
            ContentView.communicationHandler.setupWCSession() // Activate the Watch watchConnectivitySession manager
            ContentView.communicationHandler.setupObserver() // Listen for the stop alarm message
            Notifications.requestPermission() // Request permission for notifications
        }
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Track when your session starts.
        print("session started!")
    }


    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Finish and clean up any tasks before the session ends.
        print("session will expire!")
    }
        
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        // Track when your session ends.
        // Also handle errors here.
        print("session invalidated!")
    }
    
}

#Preview {
    ContentView()
}
