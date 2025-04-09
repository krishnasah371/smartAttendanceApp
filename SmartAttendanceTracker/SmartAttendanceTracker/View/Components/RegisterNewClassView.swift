//
//  RegisterNewClassView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//

import SwiftUI


struct ClassScheduleEntry: Identifiable, Hashable {
    let id = UUID()
    var days: [String]
    var startTime: Date
    var endTime: Date
}
struct BluetoothDevice: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct RegisterNewClassView: View {
    let onRegister: () -> Void
    @State private var className: String = ""
    @State private var selectedTimeZone = TimeZone.current
    @State private var scheduleEntries: [ClassScheduleEntry] = []
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!

    @State private var scannedDevices: [BluetoothDevice] = []
    @State private var selectedDevice: BluetoothDevice?

    @State private var isScanning = false
    @State private var showTimeZonePicker = false
    @StateObject private var bleManager = BLEManager()

    let allDays: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Register a New Class")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryColorDark)
                
                // Class name
                TextField("Class Name", text: $className)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Time Zone Picker
                VStack(alignment: .leading) {
                    Text("Time Zone")
                        .font(.headline)

                    Button(action: { showTimeZonePicker.toggle() }) {
                        HStack {
                            Text(selectedTimeZone.identifier)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                if showTimeZonePicker {
                    Picker("Time Zone", selection: $selectedTimeZone) {
                        ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { id in
                            Text(id).tag(TimeZone(identifier: id)!)
                        }
                    }
                    .labelsHidden()
                }

                Divider()

                // Schedule entries
                VStack(alignment: .leading, spacing: 10) {
                    Text("Class Schedule")
                        .font(.headline)

                    ForEach($scheduleEntries) { $entry in
                        VStack(spacing: 6) {
                            Text("Select Days")
                                .font(.subheadline)
                                .foregroundColor(.primaryColorDark)

                            // Day toggle buttons
                            ScrollView( .horizontal , showsIndicators: false) {
                                HStack(spacing: 8) {
                                    
                                    ForEach(allDays, id: \.self) { day in
                                        let isSelected = entry.days.contains(day)
                                        
                                        Button(action: {
                                            if isSelected {
                                                entry.days.removeAll { $0 == day }
                                            } else {
                                                entry.days.append(day)
                                            }
                                        }) {
                                            Text(day)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(isSelected ? .white : .primaryColorDark)
                                                .padding()
                                                .background(isSelected ? Color.primaryColorDark : Color.gray.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.bottom)
                                
                            }
                            VStack {
                                DatePicker("Start", selection: $entry.startTime, displayedComponents: .hourAndMinute)
                                    .padding()
                                
                                DatePicker("End", selection: $entry.endTime, displayedComponents: .hourAndMinute)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }

                    Button("Add Time Slot") {
                        scheduleEntries.append(
                            ClassScheduleEntry(days: [], startTime: Date(), endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!)
                        )
                    }
                    .font(.subheadline)
                    .padding(.top, 4)
                }

                // Start + End Dates
                VStack(alignment: .leading) {
                    Text("Start & End Date")
                        .font(.headline)

                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }

                Divider()

                // BLE SCAN Section
                VStack(alignment: .leading) {
                    Text("Bluetooth Beacon")
                        .font(.headline)

                    BLEScanView(bleManager: bleManager)
                }

                // Final Register Button
                Button("Register Class") {
                    //TODO: Fix this to capture and send form data
                    onRegister()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryColorDark)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }

    // Simulated Bluetooth scan
    func scanForBluetoothDevices() {
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            scannedDevices = [
                BluetoothDevice(id: UUID(), name: "Classroom Beacon 1"),
                BluetoothDevice(id: UUID(), name: "Entrance Beacon A")
            ]
            isScanning = false
        }
    }
}

//
//#Preview {
//    RegisterNewClassView()
//}
