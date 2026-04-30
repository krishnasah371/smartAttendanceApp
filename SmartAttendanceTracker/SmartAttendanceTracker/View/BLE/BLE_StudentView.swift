//
//  BLE_StudentView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//

import SwiftUI


struct BLE_StudentView: View {
    @StateObject private var bleManager = BLEManager()
    let user: UserModel
    let inSessionClasses: [ClassModel]
    let otherClasses: [ClassModel]
    let allClasses : [ClassModel]
    @State private var  bannerMessage: String?
    let updateClassStatus: () -> Void
    @State private var showEnrollPage = false
    @State private var bannerColor = Color.green
    var body: some View {
        NavigationStack {
            ScrollView {
                if bannerMessage != nil {
                    Text(bannerMessage!)
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(bannerColor)
                        .cornerRadius(20)
                }
                VStack {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 10)
                        .offset(x: -15)
                    
                    // Pushes content to the top
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(30)
                .ignoresSafeArea()
                VStack(spacing: 24) {
                    
                    // Enroll Button
                    Button {
                        // navigate to enrollment view
                        showEnrollPage = true
                    } label: {
                        Text("Enroll in a Class")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColorDark)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // In Session Classes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Classes in Session")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryColorDark)
                            .padding(.horizontal)
                        
                        if inSessionClasses.isEmpty {
                            Text("None")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(inSessionClasses) { classModel in
                                BLE_ClassActionCardView(
                                    classInfo: classModel,
                                    isOngoing: true,
                                    userRole: .student,
                                    onPrimaryTap: {
                                        // TODO: Attendence
                                        updateAttendance(for : classModel.id)
                                        
                                    },
                                    onSecondaryTap: nil
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Other Classes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Other Classes")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryColorDark)
                            .padding(.horizontal)
                        
                        ForEach(otherClasses) { classModel in
                            BLE_ClassActionCardView(
                                classInfo: classModel,
                                isOngoing: false,
                                userRole: .student,
                                onPrimaryTap: {
                                    // Attend class
                                    // TODO: ADD LOGIC TO ATTEND CLASS
                                    updateAttendance(for: classModel.id)
                                },
                                onSecondaryTap: nil
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background(Color.white)
            .ignoresSafeArea()
            .navigationDestination(isPresented: $showEnrollPage) {
                EnrollInAClassView(
                    availableClasses: allClasses,
                    enrolledClassIDs: Set((inSessionClasses+otherClasses).map(\.id)),
                    didEnrollInClass: updateClassStatus
                )
                
            }
        }
    }
    
    
    
    func hasCheckedInToday(classId: Int) -> Bool {
        let key = "BLEClass_\(user.id)_\(classId)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        if let savedDate = UserDefaults.standard.string(forKey: key), savedDate == today {
            return true
        }
        return false
    }
    
    func markCheckedIn(classId: Int) {
        let key = "BLEClass_\(user.id)_\(classId)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        UserDefaults.standard.set(today, forKey: key)
    }
    
    @State var timer: Timer?
    @State var elapsedTime: TimeInterval = 0
    
    func startRepeatingTask() {
        // Reset elapsed time and stop any existing timer before starting a new one
        // This prevents multiple timers from running simultaneously
        elapsedTime = 0
        timer?.invalidate()
        
        // Start a new timer that fires every 2 seconds for up to 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { t in
            
            // If no devices found yet, just increment time and check timeout
            guard self.bleManager.discoveredDevices.count > 0 else {
                self.elapsedTime += 2
                if self.elapsedTime >= 30 {
                    t.invalidate()
                    print("✅ Done after 30 seconds")
                }
                return
            }
            
            // Loop through all discovered BLE devices
            for device in self.bleManager.discoveredDevices {
                let hardwareId = device.hardwareId
                
                // Skip devices with empty hardware IDs
                guard !hardwareId.isEmpty else { continue }
                
                Task {
                    do {
                        let response: ActiveClassResponse = try await APIClient.shared.request(
                            .getActiveClassForBeacon(bleId: hardwareId)
                        )
                        
                        if let activeClass = response.classInfo {
                            print("🔍 Found active class: \(activeClass.name) (id: \(activeClass.id)) for user: \(self.user.id)")
                            
                            let alreadyCheckedIn = await MainActor.run {
                                self.hasCheckedInToday(classId: activeClass.id)
                            }
                            
                            print("🔍 Already checked in: \(alreadyCheckedIn) for class: \(activeClass.id), user: \(self.user.id)")
                            
                            if !alreadyCheckedIn {
                                do {
                                    // Try to mark attendance
                                    _ = try await AttendenceService.shared.updateStudentAttendence(
                                        classId: activeClass.id,
                                        studentId: self.user.id,
                                        state: "present",
                                        bleId: hardwareId
                                    )
                                    // Success — update UI
                                    await MainActor.run {
                                        self.markCheckedIn(classId: activeClass.id)
                                        self.timer?.invalidate()
                                        self.bannerColor = .green
                                        self.bannerMessage = "✅ Attendance recorded for \(activeClass.name)!"
                                
                                    }
                                } catch {
                                    // Could be "already marked today" from backend — still refresh UI
                                    await MainActor.run {
                                        self.timer?.invalidate()
                                        self.bannerColor = .green
                                        self.bannerMessage = "⚠️ Attendance already recorded for \(activeClass.name)!"
                                        self.updateClassStatus()
                                    }
                                }
                            } else {
                                // Already checked in locally — still refresh UI
                                await MainActor.run {
                                    self.timer?.invalidate()
                                    self.bannerColor = .green
                                    self.bannerMessage = "⚠️ Already attended \(activeClass.name) today!"
                                    self.updateClassStatus()
                                }
                            }
                        }
                    } catch {
                        // No active class for this beacon — silently ignore
                        print("ℹ️ No active class for beacon: \(hardwareId)")
                    }
                }
            }
            
            // Increment elapsed time and stop after 30 seconds
            self.elapsedTime += 2
            if self.elapsedTime >= 30 {
                t.invalidate()
                print("✅ Done after 30 seconds")
            }
        }
    }
        
        func updateAttendance(for classId: Int) {
            if hasCheckedInToday(classId: classId) {
                bannerColor = .red
                bannerMessage = "❌ You've already recorded attendance for this class today."
                return
            }
            else{
                
                bleManager.startScanning()
                startRepeatingTask()
                if bleManager.isScanning {
                    if bleManager.discoveredDevices.count > 0 {
                        for device in bleManager.discoveredDevices {
                            print(device.id)
                            if device.id == "EDB2D681-23BB-4EBA-69E7-F11063BC4664" {
                                bannerColor = .green
                                bannerMessage = "Congrats! Attendance Recorded!!! "
                            }
                        }
                    }
                }
                
            }
            
        }
        
}
//#Preview {
//    BLERegisterStudentView()
//}
