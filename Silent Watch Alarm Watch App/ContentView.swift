import SwiftUI
import UserNotifications

// trying to create a sequence of notifications to trigger for a whole 55 seconds, 5 seconds after the button is clicked, to try and make the alarm
//      -> sorta works!
// * trying to test on physical devices, have to buy apple developer membership though. Waiting for dad to get back to me to approve that purchase
// trying to make the watch sim load in a reasonable amount of time
//      -> not sure yet

struct ContentView: View {
    @State private var alarmActive = true // State variable to control the repetition
    
    var body: some View {
        VStack {
            Button(action: {
                requestNotificationPermission()
                for i in 5...60 {
                    triggerNotification(interval: TimeInterval(i))
                }
            }) {
                Label("Set Off Alarm", systemImage: "clock")
            }
            .background(Color(UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)))
            .cornerRadius(25)
            
            Button(action: {
                // Simulate condition being met (e.g., stop repeating)
                stopRepeatingNotification()
            }) {
                Label("Stop Alarm", systemImage: "stop.fill")
            }
            .background(Color(UIColor(red: 0, green: 1.0, blue: 0, alpha: 1.0)))
            .cornerRadius(25)
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permission granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func triggerNotification(interval: TimeInterval) {
        guard alarmActive else { return } // Only trigger if repetition is allowed
        
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.body = "This is a repeating notification."
        content.sound = .defaultCriticalSound(withAudioVolume: 1.0)
        
        // Set the notification to repeat every 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        
        let request = UNNotificationRequest(identifier: "repeatingNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Repeating notification scheduled")
            }
        }
    }
    
    func stopRepeatingNotification() {
        // When the condition is met, cancel the repeating notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["repeatingNotification"])
        alarmActive = false
        print("Repeating notification stopped")
    }
}

#Preview {
    ContentView()
}
