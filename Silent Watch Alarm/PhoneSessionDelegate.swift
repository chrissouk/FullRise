//
//  PhoneSessionDelegate.swift
//  Silent Watch Alarm
//
//  Created by Chris Souk on 9/21/24.
//

import WatchConnectivity

class PhoneSessionDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        session.activate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let data = message["data"] as? String, data == "Stop!" {
            NotificationCenter.default.post(name: NSNotification.Name("StopAlarmNotification"), object: nil)
        }
        if let data = message["data"] as? String, data == "Alarm!" {
            NotificationCenter.default.post(name: NSNotification.Name("SetAlarmNotification"), object: message["time"] as? Date)
        }
    }
}
