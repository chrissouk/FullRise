//
//  ContentView.swift
//  Silent Watch Alarm Watch App
//
//  Created by Chris Souk on 9/5/24.
//

// TODO: consider creating a fallback; if my watch dies, trigger the alarm on my phone
// TODO: ensure functionality with sleep mode by adding notifications—-only they can run in the background
// TODO: add shortcut compatibility

// TODO: fix communication between devices

import SwiftUI
import AVFoundation
import WatchKit
import WatchConnectivity
import UserNotifications

struct ContentView: View {
    
    @State public static var alarm: Alarm = Alarm()
    @State private var displayedTime: Date = Alarm.getPreviousAlarmTime()
    @State private var alarmIsSet: Bool = false
    
    @State public static var communicationHandler = CommunicationHandler()
    
    var body: some View {
        VStack {
            if alarmIsSet {
                // Display the time the alarm is set
                Text("Alarm Set for \(getDateIndicator(from: displayedTime)) at \(displayedTime, formatter: customDateFormatter(dateStyle: .none, timeStyle: .short))")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                
            } else {
                DatePicker("Select Time", selection: $displayedTime, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                
                Button("Confirm Time") {
                    ContentView.alarm.set(for: displayedTime)
                    ContentView.communicationHandler.sendMessage(subject: "Alarm!", contents: displayedTime)
                    alarmIsSet = true
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
