//
//  WatchView.swift
//  FullRise
//
//  Created by Chris Souk on 11/9/24.
//

import SwiftUI
import AVFoundation
import WatchKit
import WatchConnectivity
import UserNotifications

struct WatchView: View {
    
    @State private var selectedTime: Date = Alarm.getPreviousAlarmTime()
    
    @StateObject private var phoneCommunicator = PhoneCommunicator()
    
    var body: some View {
        VStack {
            if phoneCommunicator.isAlarmSet {
                // Display the time the alarm is set
                Text("Alarm Set for \(getDateIndicator(from: Alarm.fixDate(brokenDate: selectedTime))) at \(Alarm.fixDate(brokenDate: selectedTime), formatter: customDateFormatter(dateStyle: .none, timeStyle: .short))")
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
                    Alarm.set(for: Alarm.fixDate(brokenDate: selectedTime))
                    phoneCommunicator.setAlarmTime(Alarm.fixDate(brokenDate: selectedTime))
                }
                .background(Color(UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)))
                .cornerRadius(25)
                .padding()
                
            }
        }
        .onAppear {
            phoneCommunicator.setupWCSession() // Activate the Watch watchConnectivitySession manager
            if Alarm.time != nil {
                phoneCommunicator.setAlarmTime(Alarm.time!)
            }
            Notifications.requestPermission() // Request permission for notifications
        }
    }
    
}

#Preview {
    WatchView()
}
