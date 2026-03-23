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
                // STUDENT RECORDS TAB — coming in next phase
                Text("👨‍🎓 Student Records coming soon...")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }

            Spacer()
        }
        .padding()
        // Load attendance dates when this view appears
        .onAppear {
            loadAttendanceDates()
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
    func loadAttendanceDates() {
        Task {
            do {
                let response = try await AttendenceService.shared.getClassAttendance(classId: classId)
                let records = response.attendance ?? []
                
                // Extract unique dates from attendance records
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                var seen = Set<String>()
                var uniqueDates: [Date] = []
                
                for record in records {
                    let dateOnly = String(record.timestamp.prefix(10)) // "2026-03-21"
                    if !seen.contains(dateOnly) {
                        seen.insert(dateOnly)
                        if let date = formatter.date(from: record.timestamp) {
                            uniqueDates.append(date)
                        }
                    }
                }
                
                await MainActor.run {
                    self.attendanceDates = uniqueDates.sorted(by: >)
                }
            } catch {
                print("❌ Failed to load attendance dates: \(error)")
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
