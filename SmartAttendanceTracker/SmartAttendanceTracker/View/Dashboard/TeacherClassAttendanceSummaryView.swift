//
//  TeacherClassAttendanceSummaryView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/9/25.
//

import SwiftUI

struct TeacherClassAttendanceSummaryView: View {
    let classId: Int
    let className: String

    @State private var showStudentView = false
    @State private var attendanceRecordsByDate: [Date: [String]] = [Date():["alice@school.com", "Shyam@gmail.com"]] // [date: presentEmails]
    @State private var isAttendanceViewActive = false
    @State private var selectedDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header + Toggle
            HStack {
                Text("📖 \(className)")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Picker("View", selection: $showStudentView) {
                    Text("Class Records").tag(false)
                    Text("Student Records").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 250)
            }

            Divider()

            // Class Records View
            if !showStudentView {
                Text("📅 Class Sessions")
                    .font(.headline)

                ForEach(attendanceRecordsByDate.keys.sorted(by: >), id: \.self) { date in
                    Button {
                        selectedDate = date
                        isAttendanceViewActive = true
                    } label: {
                        HStack {
                            Text(formatted(date))
                            Spacer()
                            let presentCount = attendanceRecordsByDate[date]?.count ?? 0
                            //TODO: Data will be given by backend
//                            Text("\(presentCount)/\(students.count) Present")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(10)
                    }
                }
            } else {
                // Placeholder for Student Records
                Text("👨‍🎓 Student Records coming soon...")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $isAttendanceViewActive) {
            if let date = selectedDate {
            }
        }
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
