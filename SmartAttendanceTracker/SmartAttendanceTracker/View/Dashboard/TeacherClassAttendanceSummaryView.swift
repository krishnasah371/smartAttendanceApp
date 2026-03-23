//
//  TeacherClassAttendanceSummaryView.swift
//  SmartAttendanceTracker
//
//  Created by Krishna Sah Kanu on 4/9/25.
//

import SwiftUI

struct TeacherClassAttendanceSummaryView: View {
    let classId: Int
    let className: String

    // Controls which tab is shown: Class Records or Student Records
    @State private var showStudentView = false
    
    // List of dates when this class had attendance sessions
    @State private var attendanceDates: [Date] = []
    
    // Controls navigation to the detailed attendance view
    @State private var isAttendanceViewActive = false
    
    // The date the teacher tapped on
    @State private var selectedDate: Date?
    
    // List of students enrolled in this class
    @State private var enrolledStudents: [StudentInClassModel] = []

    // Maps student ID to their attendance percentage
    @State private var studentPercentages: [Int: Int] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header row: class name on left, tab picker on right
            HStack {
                Text("📖 \(className)")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                // Toggle between Class Records and Student Records tabs
                Picker("View", selection: $showStudentView) {
                    Text("Class Records").tag(false)
                    Text("Student Records").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 250)
            }

            Divider()

            // CLASS RECORDS TAB — shows list of dates with attendance
            if !showStudentView {
                Text("📅 Class Sessions")
                    .font(.headline)

                if attendanceDates.isEmpty {
                    // Show empty state when no sessions recorded yet
                    Text("No sessions recorded yet.")
                        .foregroundColor(.gray)
                } else {
                    // Each date is a tappable button that opens the attendance detail
                    ForEach(attendanceDates, id: \.self) { date in
                        Button {
                            // Store selected date and trigger navigation
                            selectedDate = date
                            isAttendanceViewActive = true
                        } label: {
                            HStack {
                                Text(formatted(date))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(10)
                        }
                    }
                }
            } else {
                // STUDENT RECORDS TAB — shows each student's attendance percentage
                Text("👨‍🎓 Student Attendance")
                    .font(.headline)
                
                if enrolledStudents.isEmpty {
                    Text("No students enrolled yet.")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(enrolledStudents) { student in
                                HStack {
                                    // Student info on the left
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(student.name)
                                            .font(.headline)
                                        Text(student.email)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    // Attendance percentage on the right
                                    let pct = studentPercentages[student.id] ?? 0
                                    VStack {
                                        Text("\(pct)%")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(pct >= 75 ? .green : .red)
                                        Text("attended")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        // Load attendance dates when this view appears
        .onAppear {
            loadData()
        }
        // Navigate to AttendanceViewForDate when a date is tapped
        .navigationDestination(isPresented: $isAttendanceViewActive) {
            if let date = selectedDate {
                // Pass the selected date and class ID to the detail view
                AttendanceViewForDate(classId: classId, date: date)
            }
        }
    }

    // Loads the list of dates that had attendance sessions
    // Currently uses today — TODO: fetch all unique dates from backend
    func loadData() {
        Task {
            do {
                // Fetch attendance records and students simultaneously
                let response = try await AttendenceService.shared.getClassAttendance(classId: classId)
                let students = try await AttendenceService.shared.getStudentsForClass(classId: classId) ?? []
                let records = response.attendance ?? []
                
                // Extract unique dates for Class Records tab
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                var seen = Set<String>()
                var uniqueDates: [Date] = []
                
                for record in records {
                    let dateOnly = String(record.timestamp.prefix(10))
                    if !seen.contains(dateOnly) {
                        seen.insert(dateOnly)
                        if let date = formatter.date(from: record.timestamp) {
                            uniqueDates.append(date)
                        }
                    }
                }
                
                // Calculate attendance percentage for each student
                // total sessions = number of unique dates
                let totalSessions = seen.count
                var percentages: [Int: Int] = [:]
                
                for student in students {
                    // Count how many times this student was present
                    let presentCount = records.filter {
                        $0.studentId == student.id && $0.status == "present"
                    }.count
                    
                    // Calculate percentage
                    if totalSessions > 0 {
                        percentages[student.id] = (presentCount * 100) / totalSessions
                    } else {
                        percentages[student.id] = 0
                    }
                }
                
                await MainActor.run {
                    self.attendanceDates = uniqueDates.sorted(by: >)
                    self.enrolledStudents = students
                    self.studentPercentages = percentages
                }
            } catch {
                print("❌ Failed to load data: \(error)")
            }
        }
    }
    // Formats a Date object into a readable string like "Mar 21, 2026"
    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
