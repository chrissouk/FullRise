//
//  WatchView.swift
//  FullRise
//
//  Created by Chris Souk on 11/9/24.
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

struct WatchView: View {
    
    @State public static var alarm: Alarm = Alarm()
    @State private var displayedTime: Date = Alarm.getPreviousAlarmTime()
    @State private var alarmIsSet: Bool = false
    
    @State private var communicationHandler = CommunicationHandler()
    
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
                    WatchView.alarm.set(for: displayedTime)
//                    communicationHandler.sendMessage(subject: "Alarm!", contents: displayedTime)
                    communicationHandler.sendAlarmTime(displayedTime)
//                    alarmIsSet = true
                }
                .background(Color(UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)))
                .cornerRadius(25)
                .padding()
                
            }
        }
        .onAppear {
            communicationHandler.setupWCSession() // Activate the Watch watchConnectivitySession manager
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
    WatchView()
}
