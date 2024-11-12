//
//  CommunicationHandler.swift
//  FullRise
//
//  Created by Chris Souk on 10/28/24.
//

import Foundation
import WatchConnectivity

class CommunicationHandler: NSObject, WCSessionDelegate {
    
    let session = WCSession.default
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("set up the session from the phone")
        if activationState == .activated {
            // Safe to access/update context here
            print("Watch's application context:")
            print(session.applicationContext)
        }
        
        let initializeAlarm: [String: Any] = ["alarmTime": ""]
        do {
            try session.updateApplicationContext(initializeAlarm)
            print("Application Context Updated")
            print(session.applicationContext)
        } catch {
            print("Error updating application context: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
    }
    

    func setupWCSession() {
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
//    func sendMessage(subject: String, contents: Any = "") {
//        let dict: [String : Any] = ["subject": subject, "contents": contents]
//        if session.isReachable {
//            session.sendMessage(dict, replyHandler: nil) { error in
//                print("Error sending message: \(error.localizedDescription)")
//            }
//            print("message sent: \(dict)")
//        } else {
//            print("Phone is not reachable.")
//        }
//    }
    
    func sendAlarmTime(_ time: Date) {
        print("running sendAlarmTime")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let alarmTimeString = dateFormatter.string(from: time)

        let alarmTimeDict: [String: Any] = ["alarmTime": alarmTimeString]
        print("set alarmTimeDict: \(alarmTimeDict)")
        do {
            try session.updateApplicationContext(alarmTimeDict)
            print("Application Context Updated")
            print(session.applicationContext)
        } catch {
            print("Error updating application context: \(error.localizedDescription)")
        }
    }
}
