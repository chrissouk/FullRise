//
//  ContentView.swift
//  Silent Watch Alarm
//
//  Created by Chris Souk on 9/5/24.
//

import SwiftUI
import UserNotifications
import WatchConnectivity
import Foundation

struct ContentView: View {
    
    let session = WCSession.default
    
    var body: some View {
        VStack {
            Button(action: {
                let dict: [String : Any] = ["data": "Stop!"]
                session.sendMessage(dict, replyHandler: nil)
            }) {
                Label("Stop Alarm", systemImage: "alarm.stop")
            }
            .font(.headline) // Set font size (can also use .largeTitle, .title, etc.)
            .foregroundColor(.white) // Set font color
            .padding() // Add padding around the text
            .frame(width: 200, height: 60) // Adjust button size
            .background(Color.red) // Set button background color
            .cornerRadius(25) // Rounded corners
        }
    }
}



#Preview {
    ContentView()
}
