//
//  CommunicationHandler.swift
//  FullRise
//
//  Created by Chris Souk on 11/9/24.
//

import WatchConnectivity

class CommunicationHandler: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var alarmTime: String = ""
    
    let session = WCSession.default
       
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("set up the session from the phone")
        if activationState == .activated {
            print("Phone's application context:")
            print(session.applicationContext)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Received application context: \(applicationContext)")
        DispatchQueue.main.async {
            self.alarmTime = (applicationContext["alarmTime"] as? String) ?? ""
        }
    }
    
    func stopAlarm() {
        let resetContext: [String: Any] = ["alarmTime": ""]
        do {
            try session.updateApplicationContext(resetContext)
            print("Updated application context: \(resetContext)")
            print(session.applicationContext)
        } catch {
            print("Error updating application context: \(error)")
        }
    }

    func setupWCSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        if let data = message["subject"] as? String, data == "Stop!" {
//            NotificationCenter.default.post(name: NSNotification.Name("StopAlarmNotification"), object: nil)
//        }
//        if let data = message["subject"] as? String, data == "Alarm!" {
//            NotificationCenter.default.post(name: NSNotification.Name("SetAlarmNotification"), object: message["content"] as? Date)
//        }
//    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        WCSession.default.activate()
        print("session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
        print("session deactivated")
    }
    
    
}
