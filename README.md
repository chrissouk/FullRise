# FullRise - Silent Watch Alarm

Never scroll at night again.

Never sleep through your alarm again.

Never wake up your roommate again.

FullRise solves your sleep. Its silent, persistent vibration is only dismissible on your phone. It's the only simple and effective solution for the most common sleep problems.

Now you can put your phone away and actually sleep.

Now you can’t snooze your alarm half-asleep.

Now you can wake up without waking anyone else.

Sleep better tonight with FullRise.

## 🌟 Features

### 🎯 Core Functionality
- **Silent Haptic Alarms**: Uses Apple Watch's advanced haptic engine instead of sound
- **Cross-Platform Sync**: Seamless communication between iPhone and Apple Watch
- **Smart Time Setting**: Automatically schedules alarms for the next occurrence (today or tomorrow)
- **Randomized Patterns**: Non-repetitive vibration patterns to prevent habituation

### ⌚ Apple Watch Features
- **Intuitive Time Picker**: Wheel-style time selection with night-themed UI
- **Advanced Haptic Patterns**: 
  - 4 different haptic types (failure, notification, success, retry)
  - Randomized intervals (0.2-1.5 seconds)
  - 20% chance of triple-burst sequences for maximum effectiveness
- **Extended Runtime**: Uses `WKExtendedRuntimeSession` to ensure alarms work in background
- **Visual Feedback**: Animated confirmation with checkmark and star effects
- **Persistent Storage**: Remembers your last alarm time across app launches

### 📱 iPhone Companion App
- **Remote Control**: Turn off alarms directly from your iPhone
- **Real-time Status**: Shows current alarm time and status
- **Installation Helper**: Built-in guidance for installing the Watch app
- **Night Theme**: Beautiful gradient background with animated stars

### 🔧 Technical Features
- **Background Execution**: Alarm continues working even when watch is sleeping
- **Notification Fallback**: Local notifications as backup alarm method
- **Automatic Time Correction**: Intelligently schedules alarms for next occurrence
- **Session Management**: Robust handling of Watch Connectivity sessions
- **Error Handling**: Graceful fallbacks and error recovery

## 🚀 Getting Started

### Prerequisites
- iOS 15.0+ / watchOS 8.0+
- Xcode 14.0+
- Apple Watch paired with iPhone
- Apple Developer Account (for device installation)

### Installation

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/yourusername/fullrise.git
   cd fullrise
   \`\`\`

2. **Open in Xcode**
   \`\`\`bash
   open "FullRise.xcodeproj"
   \`\`\`

3. **Configure signing**
   - Select your development team in Project Settings
   - Update bundle identifiers if needed

4. **Build and run**
   - Select your iPhone as the target device
   - Build and run the project (⌘+R)
   - The Watch app will automatically install when you run the iPhone app

### First Time Setup

1. **Install Watch App**
   - Open the Apple Watch app on your iPhone
   - Scroll to the bottom and find "FullRise"
   - Tap "Install" next to the app

2. **Grant Permissions**
   - Allow notification permissions when prompted
   - This enables backup notifications if haptic feedback fails

3. **Set Your First Alarm**
   - Open FullRise on your Apple Watch
   - Use the time picker to select your wake-up time
   - Tap "Set Alarm" to confirm

## 🎮 How to Use

### Setting an Alarm
1. Open FullRise on your Apple Watch
2. Use the wheel picker to select your desired wake-up time
3. Tap "Set Alarm" - you'll see a confirmation animation
4. The alarm is automatically set for the next occurrence of that time

### Stopping an Alarm
- Open the FullRise app **on your iPhone** and tap "Turn Off Alarm"

## 🏗️ Project Structure

\`\`\`
FullRise/
├── Silent Watch Alarm/                # iPhone App
│   ├── PhoneView.swift                # Main iPhone interface
│   ├── WatchCommunicator.swift        # iPhone-to-Watch communication
│   ├── Utils.swift                    # Shared utilities
│   └── Silent_Watch_AlarmApp.swift    # iPhone app entry point
├── Silent Watch Alarm Watch App/      # Apple Watch App
│   ├── WatchView.swift                # Main Watch interface
│   ├── Alarm.swift                    # Core alarm logic & haptics
│   ├── PhoneCommunicator.swift        # Watch-to-iPhone communication
│   ├── Notifications.swift            # Notification handling
│   ├── Utils.swift                    # Watch-specific utilities
│   └── Silent_Watch_AlarmApp.swift    # Watch app entry point
└── Assets/                            # App icons and images
\`\`\`

## 🔧 Technical Details

### Haptic Patterns
The app uses sophisticated haptic patterns to maximize wake-up effectiveness:

- **4 Haptic Types**: `.failure`, `.notification`, `.success`, `.retry`
- **Variable Intervals**: 0.2-1.5 seconds between vibrations
- **Burst Patterns**: 20% chance of triple-burst sequences
- **Randomization**: Prevents habituation to repetitive patterns

### Communication Protocol
iPhone and Apple Watch communicate using `WatchConnectivity`:

\`\`\`swift
// Setting alarm from Watch to iPhone
let context = ["alarmTime": "08:00", "isAlarmSet": true, "timestamp": Date().timeIntervalSince1970]
try session.updateApplicationContext(context)

// Stopping alarm from iPhone to Watch  
let context = ["alarmTime": "", "isAlarmSet": false, "timestamp": Date().timeIntervalSince1970]
try session.updateApplicationContext(context)
\`\`\`

### Background Execution
Uses `WKExtendedRuntimeSession` to ensure alarms work reliably:

\`\`\`swift
func startSession(at time: Date) {
    session = WKExtendedRuntimeSession()
    session?.delegate = self
    session?.start(at: time)
}
\`\`\`
