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
    
    let session = WCSession.default
    
    var body: some View {
        VStack {
            Button(action: {
                sendStopMessage()
            }) {
                Label("Stop Alarm", systemImage: "alarm.stop")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 200, height: 60)
            .background(Color.red)
            .cornerRadius(25)
        }
        .onAppear {
            WatchSessionManager.shared // Initialize the session manager
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
