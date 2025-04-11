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
    
    enum BeaconSetupMode {
        case none
        case scan
        case existing
    }
    
    @State private var selectedBeaconMode: BeaconSetupMode = .none
    @State private var isBeaconAttached: Bool = false
    @State private var beaconId: String? = nil
    
    @State private var existingBeacons: [BluetoothDevice] = []
    @State private var isFetchingBeacons = false
    
    func fetchExistingBeacons() {
        isFetchingBeacons = true
        selectedBeaconMode = .existing
        
        // Simulated API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.existingBeacons = [
                BluetoothDevice(id: UUID(), name: "Hall A Beacon"),
                BluetoothDevice(id: UUID(), name: "Room 204 Beacon")
            ]
            isFetchingBeacons = false
        }
        
        // 👉 Replace with real API call using URLSession if needed
    }
    
    struct BeaconOption {
        let label: String
        let mode: BeaconSetupMode
        let action: () -> Void
    }
    
    
    let allDays: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        ScrollView {
            
            let beaconOptions: [BeaconOption] = [
                BeaconOption(label: "🔍 Scan a Device", mode: .scan) {
                    selectedBeaconMode = .scan
                },
                BeaconOption(label: "🗂 Setup Existing Beacon", mode: .existing) {
                    fetchExistingBeacons()
                    selectedBeaconMode = .existing
                },
                BeaconOption(label: "🚫 Skip for Now (Use My Phone)", mode: .none) {
                    selectedBeaconMode = .none
                    isBeaconAttached = false
                    beaconId = nil
                }
            ]
            
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
                    
                    // Beacon Selection Section
                    VStack() {
                        Text("Attach a Beacon Device")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(beaconOptions, id: \.label) { option in
                                    Button {
                                        option.action()
                                    } label: {
                                        Text(option.label)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(
                                                selectedBeaconMode == option.mode
                                                ? Color.primaryColorDark
                                                : Color.gray.opacity(0.15)
                                            )
                                            .foregroundColor(selectedBeaconMode == option.mode ? .white : .primaryColorDark)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                    }
                    if (selectedBeaconMode == .existing) {
                        if isFetchingBeacons {
                            ProgressView("Loading existing beacons...")
                                .padding(.top)
                                                    } else {
                                                        VStack(alignment: .leading, spacing: 8) {
                                                            Text("Select a Beacon:")
                                                                .font(.subheadline)
                                                                .padding(.top, 6)
                            
                                                            ForEach(existingBeacons) { beacon in
                                                                Button {
                                                                    beaconId = beacon.id.uuidString
                                                                    isBeaconAttached = true
                                                                } label: {
                                                                    HStack {
                                                                        Text(beacon.name)
                                                                        Spacer()
                                                                        if beaconId == beacon.id.uuidString {
                                                                            Image(systemName: "checkmark.circle.fill")
                                                                                .foregroundColor(.green)
                                                                        }
                                                                    }
                                                                    .padding(8)
                                                                    .background(Color.gray.opacity(0.1))
                                                                    .cornerRadius(8)
                                                                }
                                                            }
                                                        }
                                                    }
                        } else if (selectedBeaconMode == .scan) {
                            BLEScanView(bleManager: bleManager, onBeaconSelected: {_ in })
                        }
                        
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
    }


//
//#Preview {
//    RegisterNewClassView()
//}
