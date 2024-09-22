//
//  ContentView.swift
//  Silent Watch Alarm
//
//  Created by Chris Souk on 9/5/24.
//

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
                Text("Alarm Set for: \(alarmTime!, formatter: dateFormatter)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                
                Button(action: {
                    alarmTime = nil
                    sendStopMessage()
                }) {
                    Label("Cancel Alarm", systemImage: "alarm.slash")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 200, height: 60)
                .background(Color(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)))
                .cornerRadius(25)
            } else {
                if !showTimePicker {
                    Button(action: {
                        showTimePicker = true
                    }) {
                        Label("Set Alarm", systemImage: "clock")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 60)
                    .background(Color(UIColor(red: 0.6, green: 0.6, blue: 0.2, alpha: 1.0)))
                    .cornerRadius(25)
                    
                    Button(action: {
                        sendStopMessage()
                    }) {
                        Label("Stop Alarm", systemImage: "stop")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 60)
                    .background(Color.red)
                    .cornerRadius(25)
                }
                
                if showTimePicker {
                    DatePicker("Select Time", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .scaleEffect(3)
                        .padding(40)
                    
                    Button("Confirm Time") {
                        alarmTime = selectedDate // Set the alarm time
                        sendAlarmInfo()
                        showTimePicker = false
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 60)
                    .background(Color(UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)))
                    .cornerRadius(25)
                    
                    Button("Cancel") {
                        showTimePicker = false // Hide the time picker without saving
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 60)
                    .background(Color(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)))
                    .cornerRadius(25)
                }
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
