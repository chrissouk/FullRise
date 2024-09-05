//
//  ContentView.swift
//  Silent Watch Alarm Watch App
//
//  Created by Chris Souk on 9/5/24.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding(.vertical, 10)
            Button("Set Off Alarm", systemImage: "clock", action: {
                var i = 0
                triggerNotification()
            })
                .background(Color(UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)))
                .cornerRadius(25)
                
        }
    }
    
    func triggerNotification() {
        // get permission to trigger notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permission granted")
                // actually trigger notification
                let content = UNMutableNotificationContent()
                content.title = "Hello!"
                content.body = "This is a notification triggered by the button."
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
        
    
}

#Preview {
    ContentView()
}
