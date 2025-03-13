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
    private let dayAccentColor = Color(red: 0.2, green: 0.6, blue: 0.9)
    private let nightAccentColor = Color(red: 0.4, green: 0.5, blue: 0.9)
    
    // Animation states
    @State private var isAnimating = false
    @State private var showConfirmation = false
    
    var body: some View {
        ZStack {
            // Background gradient that changes based on alarm state
            if phoneCommunicator.isAlarmSet {
                // Night gradient when alarm is set (moon)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.2),
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.15, green: 0.15, blue: 0.35)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Add subtle star effect
                ZStack {
                    ForEach(0..<20) { _ in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                            .frame(width: CGFloat.random(in: 1...2))
                            .position(
                                x: CGFloat.random(in: 0...WKInterfaceDevice.current().screenBounds.width),
                                y: CGFloat.random(in: 0...WKInterfaceDevice.current().screenBounds.height/1.5)
                            )
                    }
                }
            } else {
                // Day gradient when no alarm is set (sun)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.8, blue: 0.6),
                        Color(red: 0.7, green: 0.85, blue: 0.95),
                        Color(red: 0.5, green: 0.8, blue: 0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 8) {
                if phoneCommunicator.isAlarmSet {
                    // Alarm set view
                    VStack(spacing: 6) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 0.9, green: 0.9, blue: 1.0))
                            .shadow(color: Color(red: 0.5, green: 0.6, blue: 0.9).opacity(0.8), radius: 10, x: 0, y: 0)
                            .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.7).opacity(0.6), radius: 5, x: 0, y: 0)
                            .zIndex(1)
                        
                        VStack(spacing: 8) {
                            Text("Alarm Set")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.9))
                                .padding(.top, 4)
                            
                            Text("\(getDateIndicator(from: Alarm.fixDate(brokenDate: selectedTime)))")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            Text("\(Alarm.fixDate(brokenDate: selectedTime), formatter: customDateFormatter(dateStyle: .none, timeStyle: .short))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.7))
                        )
                        .padding(.horizontal)
                        .padding(.top, 25)
                    }
                } else {
                    // Time picker view
                    VStack(spacing: 6) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.3))
                            .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.2).opacity(0.8), radius: 15, x: 0, y: 0)
                            .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.6), radius: 8, x: 0, y: 0)
                            .zIndex(1)
                        
                        VStack(spacing: 4) {
                            
                            DatePicker("Select Time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(height: 70)
                                .padding(.vertical, 4)
                            
                            // Set alarm button
                            Button(action: {
                                withAnimation(.spring()) {
                                    showConfirmation = true
                                    
                                    // Add haptic feedback
                                    WKInterfaceDevice.current().play(.success)
                                    
                                    // Delay to show confirmation animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        print("Confirm Time pressed")
                                        Alarm.set(for: Alarm.fixDate(brokenDate: selectedTime))
                                        phoneCommunicator.setAlarmTime(Alarm.fixDate(brokenDate: selectedTime))
                                        showConfirmation = false
                                    }
                                }
                            }) {
                                HStack {
                                    if showConfirmation {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .transition(.scale.combined(with: .opacity))
                                    } else {
                                        Image(systemName: "bell.fill")
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                    
                                    Text(showConfirmation ? "Confirmed!" : "Set Alarm")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(showConfirmation ? Color.green : confirmButtonColor)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(color: (showConfirmation ? Color.green : confirmButtonColor).opacity(0.4), radius: 5, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                            .padding(.top, 3)
                        }
                        .padding()
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.15))
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            }
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
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

