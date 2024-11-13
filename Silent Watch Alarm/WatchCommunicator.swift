//
//  WatchCommunicator.swift
//  FullRise
//
//  Created by Chris Souk on 11/12/24.
//

import WatchConnectivity

class WatchCommunicator: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var displayTime: String = ""
    @Published var isAlarmSet: Bool = false
    
    let session = WCSession.default
       
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if activationState == .activated {
            restoreAlarmState()
            print("Phone's application context: \(session.applicationContext)")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        print("Received application context: \(applicationContext)")
        
        DispatchQueue.main.async {
            self.displayTime = (applicationContext["alarmTime"] as? String) ?? ""
            print("displayTime: \((applicationContext["alarmTime"] as? String) ?? "")")
            
            if self.displayTime != "" {
                self.isAlarmSet = true
                
                // confirm alarm has been set
                let alarmStateDict = ["isAlarmSet" : true]
                do {
                    try session.updateApplicationContext(alarmStateDict)
                    print("Updated application context: \(alarmStateDict)")
                } catch {
                    print("Error updating application context: \(error)")
                }
                
                // save the alarm state so it doesn't disappear
                self.saveAlarmState()
            }
        }
        
    }
    
    func stopAlarm() {
        let stopAlarmDict: [String: Any] = ["alarmTime": ""]
        do {
            try session.updateApplicationContext(stopAlarmDict)
            print("Updated application context: \(session.applicationContext)")
        } catch {
            print("Error updating application context: \(error)")
        }
        
        saveAlarmState()
    }

    func setupWCSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // Save alarm state to UserDefaults (or any persistent storage)
    private func saveAlarmState() {
        let alarmStateDict: [String: Any] = ["alarmTime": displayTime, "isAlarmSet": isAlarmSet]
        UserDefaults.standard.setValue(alarmStateDict, forKey: "alarmState")
        print("Alarm state saved to UserDefaults: \(alarmStateDict)")
    }

    // Restore the saved alarm state from UserDefaults
    private func restoreAlarmState() {
        DispatchQueue.main.async {
            if let savedState = UserDefaults.standard.dictionary(forKey: "alarmState") {
                self.displayTime = savedState["alarmTime"] as? String ?? ""
                self.isAlarmSet = savedState["isAlarmSet"] as? Bool ?? false
                print("Restored alarm state: \(savedState)")
            }
        }
    }

    // Save the alarm state when the session becomes inactive
    func sessionDidBecomeInactive(_ session: WCSession) {
        WCSession.default.activate()
        saveAlarmState()
        print("Session became inactive, alarm state saved.")
    }

    // Save the alarm state when the session is deactivated
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
        saveAlarmState()
        print("Session deactivated, alarm state saved.")
    }
    
    
    func clearAlarmState() {
        // Clear alarm state from UserDefaults
        UserDefaults.standard.removeObject(forKey: "alarmState")
        displayTime = ""
        isAlarmSet = false
        
        // Optionally, you can reset the session's application context as well.
        do {
            try session.updateApplicationContext(["alarmTime": "", "isAlarmSet": false])
            print("Cleared alarm state and updated application context.")
        } catch {
            print("Error clearing application context: \(error.localizedDescription)")
        }

        print("Alarm state cleared.")
    }
    
}
