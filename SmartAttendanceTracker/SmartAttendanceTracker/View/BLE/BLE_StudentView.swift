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
        let key = "BLEClass_\(classId)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        if let savedDate = UserDefaults.standard.string(forKey: key), savedDate == today {
            return true
        }
        return false
    }
    
    func markCheckedIn(classId: Int) {
        let key = "BLEClass_\(classId)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        UserDefaults.standard.set(today, forKey: key)
    }
    
    @State var timer: Timer?
    @State var elapsedTime: TimeInterval = 0
    
    func startRepeatingTask() {
        elapsedTime = 0 // reset
        timer?.invalidate() // stop any existing timer
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { t in
            // ✅ Your repeating task here
            if bleManager.isScanning {
                if bleManager.discoveredDevices.count > 0 {
                    for device in bleManager.discoveredDevices {
                        
                     if device.id == "EDB2D681-23BB-4EBA-69E7-F11063BC4664" {
                            bannerColor = .green
                            bannerMessage = "Congrats! Attendance Recorded!!! "
                        }
                        print(device)
                    }
                }
            }
            
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
