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
    private let dayAccentColor = Color(red: 0.2, green: 0.6, blue: 0.9)
    private let nightAccentColor = Color(red: 0.4, green: 0.5, blue: 0.9)
    
    var body: some View {
        ZStack {
            // Background gradient that changes based on alarm state
            if watchCommunicator.displayTime != "" {
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
                    ForEach(0..<30) { _ in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                            .frame(width: CGFloat.random(in: 1...3))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height/1.5)
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
                
                // Add subtle cloud effect for day mode
                Image(systemName: "cloud.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.white.opacity(0.6))
                    .position(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height * 0.2)
                
                Image(systemName: "cloud.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color.white.opacity(0.5))
                    .position(x: UIScreen.main.bounds.width * 0.7, y: UIScreen.main.bounds.height * 0.15)
            }
            
            VStack(spacing: 30) {
                // App logo/header
                VStack(spacing: 5) {
                    // Conditional icon based on alarm state
                    if watchCommunicator.displayTime != "" {
                        // Moon icon when alarm is set
                        Image(systemName: "moon.fill")
                            .font(.system(size: 70))
                            .foregroundColor(Color(red: 0.9, green: 0.9, blue: 1.0))
                            .shadow(color: Color(red: 0.5, green: 0.6, blue: 0.9).opacity(0.8), radius: 15, x: 0, y: 0)
                            .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.7).opacity(0.6), radius: 8, x: 0, y: 0)
                            .padding(.bottom, 5)
                    } else {
                        // Sun icon when no alarm is set
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 70))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.3))
                            .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.2).opacity(0.8), radius: 15, x: 0, y: 0)
                            .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.6), radius: 8, x: 0, y: 0)
                            .padding(.bottom, 5)
                    }
                    
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Main content
                if watchCommunicator.displayTime != "" {
                    // Alarm is set
                    VStack(spacing: 20) {
                        Image(systemName: "alarm.fill")
                            .font(.system(size: 60))
                            .foregroundColor(nightAccentColor)
                            .padding(.bottom, 10)
                        
                        Text("Alarm Set For")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.9))
                        
                        Text(watchCommunicator.displayTime)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
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
                            .fill(watchCommunicator.displayTime != "" ?
                                Color.white.opacity(0.1) :
                                Color.primary.opacity(0.05))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                } else {
                    // No alarm set
                    VStack(spacing: 20) {
                        Image(systemName: "applewatch")
                            .font(.system(size: 60))
                            .foregroundColor(dayAccentColor)
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
                            .foregroundColor(dayAccentColor)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(watchCommunicator.displayTime != "" ?
                                Color.white.opacity(0.1) :
                                Color.primary.opacity(0.1))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Footer
                Text("Sync with your Apple Watch")
                    .font(.caption)
                    .foregroundColor(watchCommunicator.displayTime != "" ? .white.opacity(0.7) : .secondary)
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

