//
//  PhoneView.swift
//  FullRise
//  Created by Chris Souk on 11/9/24.
//

import SwiftUI
import UserNotifications
import WatchConnectivity

struct PhoneView: View {
    @StateObject private var watch = WatchCommunicator()
    @Environment(\.colorScheme) var colorScheme
    
    // Custom colors
    private let nightAccentColor = Color(red: 0.4, green: 0.5, blue: 0.9)
    private let stopButtonColor = Color(red: 0.9, green: 0.3, blue: 0.3)
    
    // Animation states
    @State private var showConfirmation = false
    @State private var stars: [Star] = []
    
    // Background gradient
    private let backgroundGradient = Gradient(colors: [
        Color(red: 0.05, green: 0.05, blue: 0.2),
        Color(red: 0.1, green: 0.1, blue: 0.3),
        Color(red: 0.15, green: 0.15, blue: 0.35)
    ])
    
    var body: some View {
        ZStack {
            // Night gradient background
            LinearGradient(
                gradient: backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Star effect
            ForEach(stars.indices, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(stars[index].opacity))
                    .frame(width: stars[index].size, height: stars[index].size)
                    .position(stars[index].position)
            }
            
            VStack(spacing: 30) {
                // App logo/header
                Image(systemName: "moon.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 1.0))
                    .shadow(color: Color(red: 0.5, green: 0.6, blue: 0.9).opacity(0.8), radius: 15)
                    .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.7).opacity(0.6), radius: 8)
                    .padding(.bottom, 5)
                    .padding(.top, 50)
                
                Spacer()
                
                // Main content with consistent sizing
                ZStack {
                    if watch.displayTime.isEmpty {
                        noAlarmView()
                    } else {
                        alarmSetView()
                    }
                }
                .frame(height: 300) // Fixed height for both views
                
                Spacer()
                
                // Footer
                Text("Sync with your Apple Watch")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .onAppear {
            setupApp()
        }
    }
    
    // MARK: - Subviews
    
    private func alarmSetView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "alarm.fill")
                .font(.system(size: 60))
                .foregroundColor(nightAccentColor)
                .padding(.bottom, 10)
            
            Text(watch.displayTime)
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 10)
            
            Button(action: {
                withAnimation(.spring()) {
                    showConfirmation = true
                    
                    // Add haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Delay to show confirmation animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        watch.stopAlarm()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showConfirmation = false
                        }
                    }
                    
                }
            }) {
                HStack {
                    if showConfirmation {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "stop.fill")
                            .font(.headline)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Text(showConfirmation ? "Alarm Off!" : "Turn Off Alarm")
                        .font(.headline)
                }
                .frame(width: 220, height: 60)
                .background(stopButtonColor)
                .foregroundColor(.white)
                .cornerRadius(30)
                .shadow(color: (stopButtonColor).opacity(0.4), radius: 8, x: 0, y: 4)
            }
        }
        .frame(width: 310, height: 240)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.7))
        )
        .padding(.horizontal, 20)
    }
    
    private func noAlarmView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "applewatch")
                .font(.system(size: 60))
                .foregroundColor(nightAccentColor)
                .padding(.bottom, 10)
            
            Text("No Alarm Set")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Set your alarm on your Apple Watch")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal)
            
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 30))
                .foregroundColor(nightAccentColor)
                .padding(.top, 10)
        }
        .frame(width: 310, height: 240)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.7))
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Methods
    
    private func setupApp() {
        WCSession.default.activate()
        watch.setupWCSession()
        generateStars()
    }
    
    private func generateStars() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height / 1.5
        stars = (0..<30).map { _ in
            Star(
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: CGFloat.random(in: 0...screenHeight)
                ),
                opacity: Double.random(in: 0.1...0.3),
                size: CGFloat.random(in: 1...3)
            )
        }
    }
    
    private func stopAlarmWithAnimation() {
        withAnimation(.spring()) {
            showConfirmation = true
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Delay to show confirmation animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                watch.stopAlarm()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfirmation = false
                }
            }
        }
    }
}

#Preview {
    PhoneView()
}

struct Star {
    let position: CGPoint
    let opacity: Double
    let size: CGFloat
}
