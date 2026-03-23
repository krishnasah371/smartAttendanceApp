import SwiftUI


struct ClassInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let attendancePercentage: Int
}

struct DashboardView: View {
    let user: UserModel
    let classes: [ClassModel]
    @State private var selectedClass: ClassModel?
    @State private var showRegisterOrJoinClassPage = false
    let updateClassStatus: () -> Void

    var totalAttendance: Int {
        classes.map(\.attendancePercentage).reduce(0, +) / max(1, classes.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                     
                    // Welcome
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.primaryColorDark)
                        
                        Text("Welcome, \(user.name) 👋")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryColorDark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                        
                    Text(user.role == .teacher
                        ? "📊 Average Class Attendance: \(totalAttendance)%"
                        : "📊 My Overall Attendance: \(totalAttendance)%")
                        .font(.headline)
                        .foregroundColor(.primaryColorDarker)
                    
                    // Button
                    Button {
                        showRegisterOrJoinClassPage = true
                    } label: {
                        Text(user.role == .teacher ? "Register a New Class" : "Enroll in a New Class")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColorDark)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    TodayScheduleView(classes: classes)
                    // Your Classes
                    
                    ForEach(classes) { classInfo in
                        ClassesSummaryView(
                                classInfo: classInfo,
                                userRole: user.role,
                                onTap: {
                                    selectedClass = classInfo
                                }
                            )
                    }

                    // Schedule Today
                    
                    Spacer(minLength: 40)
                }
                .padding()
                .navigationDestination(item: $selectedClass) { classModel in
                    if user.role == .teacher {
                        TeacherClassAttendanceSummaryView(classId: classModel.id, className: classModel.name)
                    } else {
                        StudentClassStatsView(classModel: classModel)
                    }
                }
                .navigationDestination(isPresented: $showRegisterOrJoinClassPage) {
                    if user.role == .teacher {
                        RegisterNewClassView( onRegister: {
                            // TODO: Handle Register
                            showRegisterOrJoinClassPage = false
                            updateClassStatus() //refresh class list
                        })
                        
                    } else {
                        EnrollInAClassView(availableClasses: classes, enrolledClassIDs:Set(classes.map(\.id)), didEnrollInClass: updateClassStatus)
                    }
                }
            }
            .refreshable {
                //pull down to refresh classes and attendance data
                updateClassStatus()
            }
            .background(Color.white)
            
        }
        
    }
        
}




struct StudentClassStatsView: View {
    let classModel: ClassModel
    
    // Holds the fetched attendance data
    @State private var attendanceRecords: [MyAttendanceRecord] = []
    @State private var percentage: Int = 0
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header — class name and overall percentage
                VStack(alignment: .leading, spacing: 8) {
                    Text(classModel.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryColorDark)
                    
                    Text("Taught by: \(classModel.teacherName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Big attendance percentage display
                    HStack {
                        Text("Overall Attendance:")
                            .font(.headline)
                        Spacer()
                        Text("\(percentage)%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(percentage >= 75 ? .green : .red)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(12)
                }
                
                Divider()
                
                // Attendance history list
                Text("📅 Attendance History")
                    .font(.headline)
                
                if isLoading {
                    // Show loading spinner while fetching
                    HStack {
                        Spacer()
                        ProgressView("Loading...")
                        Spacer()
                    }
                    .padding()
                } else if attendanceRecords.isEmpty {
                    Text("No attendance records yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Each attendance record as a row
                    ForEach(attendanceRecords, id: \.id) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(formatDate(record.timestamp))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(record.isManual ? "Manual entry" : "Auto-detected via beacon")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Present/Absent badge
                            Text(record.status == "present" ? "✅ Present" : "❌ Absent")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(record.status == "present" ? .green : .red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(record.status == "present" ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("My Attendance")
        .navigationBarTitleDisplayMode(.inline)
        // Fetch data when view appears
        .task {
            await loadAttendance()
        }
    }
    
    // Fetches the student's attendance for this class from backend
    private func loadAttendance() async {
        do {
            let data = try await AttendenceService.shared.getMyAttendance(classId: classModel.id)
            await MainActor.run {
                self.attendanceRecords = data.attendance ?? []
                self.percentage = data.percentage
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("❌ Failed to load attendance: \(error)")
        }
    }
    
    // Converts ISO timestamp like "2026-03-21T23:06:29Z" to "Mar 21, 2026"
    private func formatDate(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestamp) {
            let display = DateFormatter()
            display.dateStyle = .medium
            return display.string(from: date)
        }
        return timestamp
    }
}
