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
    
    @StateObject private var alarm: Alarm = Alarm()
    @State private var selectedTime: Date = Alarm.getPreviousAlarmTime()
    
    @StateObject private var phoneCommunicator = PhoneCommunicator()
    
    var body: some View {
        VStack {
            if phoneCommunicator.isAlarmSet {
                // Display the time the alarm is set
                Text("Alarm Set for \(getDateIndicator(from: selectedTime)) at \(selectedTime, formatter: customDateFormatter(dateStyle: .none, timeStyle: .short))")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center) 
                
            } else {
                DatePicker("Select Time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                
                Button("Confirm Time") {
                    print("Confirm Time pressed")
                    alarm.set(for: selectedTime)
                    phoneCommunicator.sendAlarmTime(selectedTime)
                }
                .background(Color(UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)))
                .cornerRadius(25)
                .padding()
                
            }
        }
        .onAppear {
            phoneCommunicator.setupWCSession() // Activate the Watch watchConnectivitySession manager
            if alarm.time != nil {
                phoneCommunicator.sendAlarmTime(alarm.time!)
            }
            Notifications.requestPermission() // Request permission for notifications
        }
    }
    
}

#Preview {
    WatchView()
}
