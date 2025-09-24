//
//  Alarm.swift
//  FullRise
//
//  Created by Chris Souk on 10/28/24.
//

import Foundation
import WatchKit
import UserNotifications
import WatchConnectivity

class Alarm: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {
    
    // MARK: - Fields
    
    var time: Date? = nil
    var isRinging: Bool = false
    private let hapticTypes: [WKHapticType] = [.failure, .notification, .success, .retry]
    private let intervalRanges: [(min: Double, max: Double)] = [
        (0.1, 0.3),
        (0.5, 0.8),
        (1.0, 1.5),
        (0.3, 0.6)
    ]
    
    // WKExtendedRuntimeSession
    var session: WKExtendedRuntimeSession?

    // MARK: - Session Handling
    
    func startSession(at _time: Date) {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start(at: _time)
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session started")
        isRinging = true
        Task {
            await ring()
            extendedRuntimeSession.notifyUser(hapticType: .failure)
        }
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session will expire")
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: (any Error)?) {
        print("Session invalidated with reason: \(reason)")
    }
    
    // MARK: - Time Preparation
    
    public static func getPreviousAlarmTime() -> Date {
        guard let previousAlarm = UserDefaults.standard.object(forKey: "previousAlarm") as? Date else {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 8
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date()
        }
        return previousAlarm
    }
    
    public static func fix(date: Date) -> Date {
        let now = Date()
        let brokenComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        var fixedComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
        fixedComponents.hour = brokenComponents.hour
        fixedComponents.minute = brokenComponents.minute
        
        var validationDate = Calendar.current.date(from: fixedComponents)!
        if validationDate < now {
            fixedComponents.day! += 1
            validationDate = Calendar.current.date(from: fixedComponents)!
        }
        return validationDate
    }
    
    // MARK: - Alarm Handling
    
    func set(for _time: Date) {
        time = _time
        UserDefaults.standard.set(_time, forKey: "previousAlarm")
        print("Alarm set for \(_time)")
        
        let timeInterval = _time.timeIntervalSince(Date())
        if timeInterval <= 0 {
            print("Alarm is for now or in the past")
            Task {
                await ring()
            }
        } else {
            startSession(at: _time)
        }
    }
    
    func ring() async {
        
        isRinging = true
        
        let limit = 28.0 * 60.0                 // if alarm is not stopped after 28 minutes of ringing,
        var elapsed = 0.0                       // stop execution and allow .notifyUser() to be called,
                                                // preventing background activity notices.
        while self.isRinging && elapsed < limit {
            let randomHaptic = hapticTypes.randomElement() ?? .notification
            WKInterfaceDevice.current().play(randomHaptic)
            
            let randomRange = intervalRanges.randomElement() ?? (0.5, 1.0)
            let randomInterval = Double.random(in: randomRange.min...randomRange.max)
            
            elapsed += randomInterval
            try? await Task.sleep(nanoseconds: UInt64(randomInterval * 1_000_000_000))
        }
        
    }
    
    func stop() {
        isRinging = false
        print("Alarm stopped")
        if let session = session {
            if session.state == .scheduled {
                session.invalidate()
                self.session = nil
            }
        }
    }
}
