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
        print("WCSession activationDidCompleteWith activationState: \(activationState)")
    }

    func setupWCSession() {
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    // Listen for the "Stop Alarm" notification from the phone
    func setupObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("StopAlarmNotification"), object: nil, queue: .main) { _ in
            Alarm.stop()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("SetAlarmNotification"), object: nil, queue: .main) { notification in
            if let receivedTime = notification.object as? Date {
                Alarm.set(for: receivedTime)
                print("Alarm time received and set: \(receivedTime)")
            }
        }
    }
    
    func sendMessage(subject: String, contents: Any = "") {
        let dict: [String : Any] = ["subject": subject, "contents": contents]
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("Phone is not reachable.")
        }
    }
}
