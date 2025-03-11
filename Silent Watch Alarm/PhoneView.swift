//
//  PhoneView.swift
//  FullRise
//
//  Created by Chris Souk on 11/9/24.
//

import SwiftUI
import UserNotifications
import WatchConnectivity

struct PhoneView: View {
    @StateObject private var watchCommunicator = WatchCommunicator()
    @Environment(\.colorScheme) var colorScheme
    
    let session = WCSession.default
    
    // Custom colors
    private let accentColor = Color(red: 0.3, green: 0.7, blue: 0.9)
    private let stopButtonColor = Color(red: 0.9, green: 0.3, blue: 0.3)
    
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
            
            VStack(spacing: 30) {
                // App logo/header
                VStack(spacing: 5) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 50))
                        .foregroundColor(accentColor)
                    
                    Text("FullRise")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Main content
                if watchCommunicator.displayTime != "" {
                    // Alarm is set
                    VStack(spacing: 20) {
                        Image(systemName: "alarm.fill")
                            .font(.system(size: 60))
                            .foregroundColor(accentColor)
                            .padding(.bottom, 10)
                        
                        Text("Alarm Set For")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text(watchCommunicator.displayTime)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.bottom, 20)
                        
                        Button(action: {
                            watchCommunicator.stopAlarm()
                            // Add haptic feedback
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                    .font(.headline)
                                Text("Turn Off Alarm")
                                    .font(.headline)
                            }
                            .frame(width: 220, height: 60)
                            .background(stopButtonColor)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .shadow(color: stopButtonColor.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.primary.opacity(0.05))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                } else {
                    // No alarm set
                    VStack(spacing: 20) {
                        Image(systemName: "applewatch")
                            .font(.system(size: 60))
                            .foregroundColor(accentColor)
                            .padding(.bottom, 10)
                        
                        Text("No Alarm Set")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Set your alarm on your Apple Watch")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 30))
                            .foregroundColor(accentColor)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.primary.opacity(0.05))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Footer
                Text("Sync with your Apple Watch")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .onAppear {
            WCSession.default.activate()
            watchCommunicator.setupWCSession()
        }
    }
}

#Preview {
    PhoneView()
}

