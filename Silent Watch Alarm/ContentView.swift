//
//  ContentView.swift
//  Silent Watch Alarm
//
//  Created by Chris Souk on 9/5/24.
//

// TODO: set up an observer that will remove the cancel button only when the watch confirms the alarm has been canceled.

import SwiftUI
import UserNotifications
import WatchConnectivity


struct ContentView: View {
    
    @State private var alarmTime: Date? = nil
    @State private var showTimePicker = false
    @State private var selectedDate = Date()
    
    let session = WCSession.default
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            if alarmTime != nil {
                Text("Alarm Set for \(getDateIndicator(from: alarmTime!)) at \(alarmTime!, formatter: customDateFormatter(dateStyle: .none, timeStyle: .short))")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button(action: {
                    alarmTime = nil
                    sendStopMessage()
                }) {
                    Label("Turn off Alarm", systemImage: "alarm.slash")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 200, height: 60)
                .background(Color(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)))
                .cornerRadius(25)
            } else {
                Text("Set your alarm on your watch!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .onAppear {
            WCSession.default.activate()
            WatchSessionManager.shared // Initialize the session manager
            setupNotificationObserver()
        }
    }
    
    func setupNotificationObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("StopAlarmNotification"), object: nil, queue: .main) { _ in
            alarmTime = nil
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("SetAlarmNotification"), object: nil, queue: .main) { notification in
            if let receivedTime = notification.object as? Date {
                alarmTime = receivedTime
                print("Alarm time received and set: \(receivedTime)")
            }
        }
    }
    
    func sendAlarmInfo() {
        let dict: [String : Any] = ["data": "Alarm!", "time": selectedDate]
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("Watch is not reachable.")
        }
    }
    
    func sendStopMessage() {
        let dict: [String : Any] = ["data": "Stop!"]
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("Watch is not reachable.")
        }
    }
}

#Preview {
    ContentView()
}
