//
//  CommunicationLogic.swift
//  FullRise
//
//  Created by Chris Souk on 10/28/24.
//

import Foundation
import WatchConnectivity

// Listen for the "Stop Alarm" notification from the phone
func setupNotificationObserver() {
    NotificationCenter.default.addObserver(forName: NSNotification.Name("StopAlarmNotification"), object: nil, queue: .main) { _ in
        stopAlarm()
    }
    NotificationCenter.default.addObserver(forName: NSNotification.Name("SetAlarmNotification"), object: nil, queue: .main) { notification in
        if let receivedTime = notification.object as? Date {
            setAlarm(for: receivedTime)
            print("Alarm time received and set: \(receivedTime)")
        }
    }
}

func sendAlarmInfo(session: WCSession, selectedDate: Date) {
    let dict: [String : Any] = ["data": "Alarm!", "time": selectedDate]
    if session.isReachable {
        session.sendMessage(dict, replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    } else {
        print("Phone is not reachable.")
    }
}

func sendStopMessage(session: WCSession) {
    let dict: [String : Any] = ["data": "Stop!"]
    if session.isReachable {
        session.sendMessage(dict, replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    } else {
        print("Phone is not reachable.")
    }
}
