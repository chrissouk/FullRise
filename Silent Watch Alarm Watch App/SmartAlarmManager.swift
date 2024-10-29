//
//  SmartAlarmManager.swift
//  FullRise
//
//  Created by Chris Souk on 10/21/24.
//


import WatchKit

class SmartAlarmManager: NSObject, WKExtendedRuntimeSessionDelegate {
    
    var session: WKExtendedRuntimeSession?

    func startSmartAlarmSession() {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
    }

    func stopSmartAlarmSession() {
        session?.invalidate()
    }

    // Delegate methods
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Smart alarm session started")
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Smart alarm session will expire soon")
        triggerAlarm()
    }

    func extendedRuntimeSessionDidInvalidate(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Smart alarm session ended")
    }

    func triggerAlarm() {
        // Your alarm logic
        print("Alarm triggered!")
    }
}
