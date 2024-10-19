//
//  ContinuousTimePicker.swift
//  Silent Watch Alarm
//
//  Created by Chris Souk on 10/14/24.
//


import SwiftUI

struct ContinuousTimePicker: View {
    @State private var selectedHour = 0
    @State private var selectedMinute = 0
    
    let hours = Array(0...23)
    let minutes = Array(0...59)
    
    var body: some View {
        HStack {
            // Hour Picker
            Picker(selection: $selectedHour, label: Text("Hour")) {
                ForEach(0..<hours.count, id: \.self) { index in
                    Text("\(hours[index])").tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100)
            .onChange(of: selectedHour) {
                // Wrap around logic for hours
                if selectedHour >= hours.count {
                    selectedHour = 0
                } else if selectedHour < 0 {
                    selectedHour = hours.count - 1
                }
            }
            
            // Minute Picker
            Picker(selection: $selectedMinute, label: Text("Minute")) {
                ForEach(0..<minutes.count, id: \.self) { index in
                    Text("\(minutes[index])").tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100)
            .onChange(of: selectedMinute) {
                // Wrap around logic for minutes
                if selectedMinute >= minutes.count {
                    selectedMinute = 0
                } else if selectedMinute < 0 {
                    selectedMinute = minutes.count - 1
                }
            }
        }
    }
}

struct ContinuousTimePicker_Previews: PreviewProvider {
    static var previews: some View {
        ContinuousTimePicker()
    }
}
