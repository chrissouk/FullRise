//
//  PhoneCommunicator.swift
//  FullRise
//
//  Created by Chris Souk on 11/12/24.
//

import Foundation
import WatchConnectivity

class PhoneCommunicator: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var displayTime: String = ""
    @Published var isAlarmSet: Bool = false
    
    let session = WCSession.default
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if activationState == .activated {
            print("Watch's application context: \(session.applicationContext)")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        print("Received application context: \(applicationContext)")
        
        DispatchQueue.main.async {
            self.displayTime = ""
            
            if self.displayTime == "" {
                self.isAlarmSet = false
                
                // confirm alarm has been stopped
                let context = ["alarmTime:": "", "isAlarmSet": false, "timestamp": Date()]
                do {
                    try session.updateApplicationContext(context)
                    print("Updated application context: \(context)")
                } catch {
                    print("Error updating application context: \(error)")
                }
            }
        }
        
    }
    
    func setupWCSession() {
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    func setAlarmTime(_ time: Date) {
        
        guard session.isReachable else {
            print("Session is not reachable; cannot send alarm time.")
            return
        }
        
        self.isAlarmSet = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let alarmTimeString = dateFormatter.string(from: time)
        
        self.displayTime = alarmTimeString

        let context: [String: Any] = ["alarmTime": alarmTimeString, "isAlarmSet": true, "timestamp": Date()]
        print("set alarmTimeDict: \(context)")
        do {
            try session.updateApplicationContext(context)
            print("Application Context Updated: \(session.applicationContext)")
        } catch {
            print("Error updating application context: \(error.localizedDescription)")
        }
    }
}
