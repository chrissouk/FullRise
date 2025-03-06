//
//  PhoneView.swift
//  FullRise
//
//  Created by Chris Souk on 11/9/24.
//


// TODO: set up an observer that will remove the cancel button only when the watch confirms the alarm has been canceled.

import SwiftUI
import UserNotifications
import WatchConnectivity


struct PhoneView: View {
    
    @StateObject private var watchCommunicator = WatchCommunicator()
    
    let session = WCSession.default
    
    var body: some View {
        VStack {
            if watchCommunicator.displayTime != "" {
                Text("Alarm Set for \(watchCommunicator.displayTime)")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Ensure watch app is open when disabling alarm")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button(action: {
                    watchCommunicator.stopAlarm()
                }) {
                    Label("Turn Off Alarm", systemImage: "stop.fill")
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
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
//            Button(action: {
//                watchCommunicator.clearAlarmState()
//            }) {
//                Label("Clear alarm state", systemImage: "xmark.circle.fill")
//            }
//            .font(.headline)
//            .foregroundColor(.white)
//            .padding()
//            .frame(width: 200, height: 60)
//            .background(Color(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)))
//            .cornerRadius(25)
        }
        .onAppear {
            WCSession.default.activate()
            watchCommunicator.setupWCSession()
        }
    }
    

}

#Preview {
    PhoneView()
}
