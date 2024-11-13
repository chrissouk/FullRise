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
            self.displayTime = (applicationContext["alarmTime"] as? String) ?? ""
            
            if self.displayTime == "" {
                self.isAlarmSet = false
                
                // confirm alarm has been stopped
                let alarmStateDict = ["isAlarmSet" : false]
                do {
                    try session.updateApplicationContext(alarmStateDict)
                    print("Updated application context: \(alarmStateDict)")
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
    
    func sendAlarmTime(_ time: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let alarmTimeString = dateFormatter.string(from: time)
        
        self.displayTime = alarmTimeString

        let alarmTimeDict: [String: Any] = ["alarmTime": alarmTimeString]
        print("set alarmTimeDict: \(alarmTimeDict)")
        do {
            try session.updateApplicationContext(alarmTimeDict)
            print("Application Context Updated: \(session.applicationContext)")
        } catch {
            print("Error updating application context: \(error.localizedDescription)")
        }
    }
}
