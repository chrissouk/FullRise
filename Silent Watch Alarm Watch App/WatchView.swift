//
//  WatchView.swift
//  FullRise
//  Created by Chris Souk on 11/9/24.
//

import SwiftUI
import AVFoundation
import WatchKit
import WatchConnectivity
import UserNotifications

struct WatchView: View {
    @State private var selectedTime: Date = Alarm.getPreviousAlarmTime()
    @StateObject private var phone = PhoneCommunicator()
    
    // Custom colors
    private let nightAccentColor = Color(red: 0.4, green: 0.5, blue: 0.9)
    
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
            createStarEffect()
            
            VStack(spacing: 8) {
                // Moon icon (common to both views)
                Image(systemName: "moon.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 1.0))
                    .shadow(color: Color(red: 0.5, green: 0.6, blue: 0.9).opacity(0.8), radius: 10)
                    .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.7).opacity(0.6), radius: 5)
                    .zIndex(1)
                    
                
                if phone.isAlarmSet {
                    alarmSetView()
                } else {
                    timePickerView()
                }
            }
            .padding()
        }
        .onAppear {
            setupApp()
        }
    }
    
    // MARK: - Subviews
    
    private func alarmSetView() -> some View {
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
        .padding(.bottom, 7)
    }
    
    private func timePickerView() -> some View {
        VStack(spacing: 4) {
            DatePicker("Select Time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 70)
                .padding(.vertical, 4)
                .accentColor(nightAccentColor)
            
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
                        phone.setAlarmTime(Alarm.fixDate(brokenDate: selectedTime))
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
                .background(nightAccentColor)
                .foregroundColor(.white)
                .cornerRadius(20)
                .shadow(color: nightAccentColor.opacity(0.4), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            .padding(.top, 3)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.7))
        )
        .padding(.horizontal)
        .padding(.top, 6)
    }
    
    // MARK: - Helper Methods
    
    private func setupApp() {
        phone.setupWCSession()
        if Alarm.time != nil {
            phone.setAlarmTime(Alarm.time!)
        }
        Notifications.requestPermission()
        generateStars()
    }
    
    private func generateStars() {
        let screenWidth = WKInterfaceDevice.current().screenBounds.width
        let screenHeight = WKInterfaceDevice.current().screenBounds.height / 1.5
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
    
    private func createStarEffect() -> some View {
        ZStack {
            ForEach(stars.indices, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(stars[index].opacity))
                    .frame(width: stars[index].size, height: stars[index].size)
                    .position(stars[index].position)
            }
        }
    }
    
    private func setAlarmWithAnimation() {
        withAnimation(.spring()) {
            showConfirmation = true
            
            // Add haptic feedback
            WKInterfaceDevice.current().play(.success)
            
            // Delay to show confirmation animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                print("Confirm Time pressed")
                let fixedDate = Alarm.fixDate(brokenDate: selectedTime)
                Alarm.set(for: fixedDate)
                phone.setAlarmTime(fixedDate)
                showConfirmation = false
            }
        }
    }
}

#Preview {
    WatchView()
}

struct Star {
    let position: CGPoint
    let opacity: Double
    let size: CGFloat
}
