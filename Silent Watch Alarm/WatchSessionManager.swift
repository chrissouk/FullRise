//
//  WatchSessionManager.swift
//  Silent Watch Alarm
//
//  Created by Chris Souk on 9/21/24.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("set up the session from the phone")
    }

    func setupWCSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let data = message["subject"] as? String, data == "Stop!" {
            NotificationCenter.default.post(name: NSNotification.Name("StopAlarmNotification"), object: nil)
        }
        if let data = message["subject"] as? String, data == "Alarm!" {
            NotificationCenter.default.post(name: NSNotification.Name("SetAlarmNotification"), object: message["content"] as? Date)
        }

    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
