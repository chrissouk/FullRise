//
//  WatchSessionManager.swift
//  Silent Watch Alarm
//
//  Created by Chris Souk on 9/21/24.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    static let shared = WatchSessionManager()

    private override init() {
        super.init()
        setupWCSession()
    }

    private func setupWCSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let data = message["data"] as? String, data == "Stop!" {
            NotificationCenter.default.post(name: NSNotification.Name("StopAlarmNotification"), object: nil)
        }
    }
}
