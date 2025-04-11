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
    @State var closeBluetoothSearch = true
    @State private var isScanning = false
    @State private var showTimeZonePicker = false
    @StateObject private var bleManager = BLEManager()
    @State private var fetchError: String?
    
    enum BeaconSetupMode {
        case none
        case scan
    }
    
    @State private var selectedBeaconMode: BeaconSetupMode = .none
    @State private var beaconId: String = ""
    
    @State private var existingBeacons: [BluetoothDevice] = []
    @State private var isFetchingBeacons = false
    
    
    struct BeaconOption {
        let label: String
        let mode: BeaconSetupMode
        let action: () -> Void
    }
    
    
    let allDays: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        ScrollView {
            
            let beaconOptions: [BeaconOption] = [
                BeaconOption(label: "🔍 Scan a Device", mode: .scan) {
                    selectedBeaconMode = .scan
                },
                BeaconOption(label: "🚫 Skip for Now (Use My Phone)", mode: .none) {
                    selectedBeaconMode = .none
                    beaconId = ""
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
                    if (selectedBeaconMode == .scan) {
                        BLEScanView(bleManager: bleManager, onBeaconSelected: {_ in }, closeBluetoothSearch: closeBluetoothSearch )
                    }
                    
                }
                
                // Final Register Button
                Button(action: {
                    Task{
                        await registerAClass()
                    }
                    
                }){
                    Text("Register Class")
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
        private func buildClassRegistrationPayload() -> ClassRegistrationPayload {
            // Step 1: Convert schedule entries to [String: [String]]
            var scheduleDict: [String:[String]] = [:]
            for entry in scheduleEntries {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HHmm" // 24-hour format
                timeFormatter.timeZone = selectedTimeZone // use user-selected timezone
                timeFormatter.locale = Locale(identifier: "en_US_POSIX")
                let start = timeFormatter.string(from: entry.startTime) // e.g., "0930"
                let end = timeFormatter.string(from: entry.endTime)     // e.g., "1130"
                let timeRange =  "\(start)-\(end)"

                for day in entry.days {
                    let capitalizedDay = day.capitalized
                    scheduleDict[capitalizedDay,default: []].append(timeRange)
                }
            }
            
            // Step 2: Convert scheduleDict to a JSON string
            print ("Schedule Data: \(scheduleDict)")
            // Step 3: Format dates
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let payload = ClassRegistrationPayload(
                name: className,
                schedule: scheduleDict,
                ble_id: beaconId,
                timezone: selectedTimeZone.identifier,
                start_date: dateFormatter.string(from: startDate),
                end_date: dateFormatter.string(from: endDate)
            )
            
            return payload
        }
        private func registerAClass() async
        {
            let classRegistrationData = buildClassRegistrationPayload()
            
            print(classRegistrationData)
            closeBluetoothSearch = true
            do {
                let response = try await ClassService.shared.registerANewClass(classRegistrationPayload:classRegistrationData)
                print("response = ",response?.message)
            }  catch let error as NetworkError {
                self.fetchError = error.localizedDescription
            } catch {
                self.fetchError = error.localizedDescription
            }
            onRegister()
        }
        
    }
//
//#Preview {
//    RegisterNewClassView()
//}
