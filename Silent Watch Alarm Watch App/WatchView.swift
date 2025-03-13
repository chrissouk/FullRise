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
    
    // Custom colors
    private let accentColor = Color(red: 0.3, green: 0.7, blue: 0.9)
    private let confirmButtonColor = Color(red: 0.2, green: 0.8, blue: 0.4)
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    phoneCommunicator.isAlarmSet ?
                    Color(red: 0.1, green: 0.1, blue: 0.2) :
                        Color(red: 0.5, green: 0.8, blue: 0.95),
                    phoneCommunicator.isAlarmSet ?
                    Color(red: 0.15, green: 0.15, blue: 0.35) :
                        Color(red: 0.7, green: 0.85, blue: 0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                if phoneCommunicator.isAlarmSet {
                    // Alarm set view
                    VStack(spacing: 8) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.9, green: 0.9, blue: 1.0))
                            .shadow(color: Color(red: 0.5, green: 0.6, blue: 0.9).opacity(0.8), radius: 10, x: 0, y: 0)
                        
                        Text("Alarm Set")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.9))
                        
                        Text("\(getDateIndicator(from: Alarm.fixDate(brokenDate: selectedTime)))")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        Text("\(Alarm.fixDate(brokenDate: selectedTime), formatter: customDateFormatter(dateStyle: .none, timeStyle: .short))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.7))
                            
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal)
                    
                } else {
                    // Time picker view
                    VStack(spacing: 10) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.3))
                            .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.2).opacity(0.5), radius: 5, x: 0, y: 0)
                        
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

