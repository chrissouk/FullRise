//
//  WatchCommunicator.swift
//  FullRise
//
//  Created by Chris Souk on 11/12/24.
//

import WatchConnectivity

class WatchCommunicator: NSObject, WCSessionDelegate, ObservableObject {
    
    // Fields
    
    @Published var displayTime: String = ""
    @Published var isAlarmSet: Bool = false
    
    let session = WCSession.default
    
    
    // WCSession Handling
      
    func setupWCSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if activationState == .activated {
            print("Phone's application context: \(session.applicationContext)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        WCSession.default.activate()
        print("Session became inactive, alarm state saved.")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
        print("Session deactivated, alarm state saved.")
    }
    
    // Input (set alarm)
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        print("Received application context: \(applicationContext)")
        
        DispatchQueue.main.async {
            self.displayTime = (applicationContext["alarmTime"] as? String) ?? ""
            self.isAlarmSet = (applicationContext["isAlarmSet"] as? Bool) ?? false
            
            print("displayTime: \((applicationContext["alarmTime"] as? String) ?? "")")
            
//            self.saveAlarmState()
            
//            if self.displayTime != "" {
//                self.isAlarmSet = true
//                
//                // confirm alarm has been set
//                let alarmStateDict = ["isAlarmSet" : true]
//                do {
//                    try session.updateApplicationContext(alarmStateDict)
//                    print("Updated application context: \(alarmStateDict)")
//                } catch {
//                    print("Error updating application context: \(error)")
//                }
//                
//                // save the alarm state so it doesn't disappear
//                self.saveAlarmState()
//            }
        }
        
    }
    
    
    // Output (stop alarm)
    
    func stopAlarm() {
        let context: [String: Any] = ["alarmTime": "", "isAlarmSet": true, "timestamp": Date().timeIntervalSince1970] /* don't change isAlarmSet yet, wait for watch's confirmation */
        do {
            try session.updateApplicationContext(context)
            print("Updated application context: \(session.applicationContext)")
        } catch {
            print("Error updating application context: \(error)")
        }
        
    }
    
}
