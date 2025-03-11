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
    @Environment(\.colorScheme) var colorScheme
    
    // Custom colors
    private let accentColor = Color(red: 0.3, green: 0.7, blue: 0.9)
    private let confirmButtonColor = Color(red: 0.2, green: 0.8, blue: 0.4)
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color.black : Color(red: 0.95, green: 0.95, blue: 1.0),
                    colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.2) : Color(red: 0.85, green: 0.9, blue: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                if phoneCommunicator.isAlarmSet {
                    // Alarm set view
                    VStack(spacing: 8) {
                        Image(systemName: "alarm.fill")
                            .font(.system(size: 24))
                            .foregroundColor(accentColor)
                        
                        Text("Alarm Set")
                            .font(.headline)
                            .foregroundColor(accentColor)
                        
                        Text("\(getDateIndicator(from: Alarm.fixDate(brokenDate: selectedTime)))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Alarm.fixDate(brokenDate: selectedTime), formatter: customDateFormatter(dateStyle: .none, timeStyle: .short))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primary.opacity(0.05))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                } else {
                    // Time picker view
                    VStack(spacing: 10) {
                        Text("Set Alarm")
                            .font(.headline)
                            .foregroundColor(accentColor)
                            .padding(.top, 5)
                        
                        DatePicker("Select Time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding(.vertical, 5)
                        
                        Button(action: {
                            print("Confirm Time pressed")
                            Alarm.set(for: Alarm.fixDate(brokenDate: selectedTime))
                            phoneCommunicator.setAlarmTime(Alarm.fixDate(brokenDate: selectedTime))
                            
                            // Add haptic feedback
                            WKInterfaceDevice.current().play(.success)
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Set Alarm")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(confirmButtonColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: confirmButtonColor.opacity(0.4), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    }
                }
            }
            .padding()
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

