//
//  TeacherClassAttendanceSummaryView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/9/25.
//

import SwiftUI

struct TeacherClassAttendanceSummaryView: View {
    let classId: UUID
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
                let viewModel = AttendanceViewModel(
                    classId: classId,
                    date: date,
                    // TODO: Data given by backend
                    allStudents: [
                        UserModel(id: "alice@school.com", email: "alice@school.com", name: "Alice Johnson", role: .student),
                        UserModel(id: "bob@school.com", email: "bob@school.com", name: "Bob Smith", role: .student),
                        UserModel(id: "charlie@school.com", email: "charlie@school.com", name: "Charlie Singh", role: .student),
                        UserModel(id: "dave@school.com", email: "dave@school.com", name: "Dave Lee", role: .student),
                        UserModel(id: "eve@school.com", email: "eve@school.com", name: "Eve Carter", role: .student),
                        UserModel(id: "fatima@school.com", email: "fatima@school.com", name: "Fatima Khan", role: .student)
                    ],
                    initialPresentIds: attendanceRecordsByDate[date] ?? []
                )
                AttendanceViewForDate(viewModel: viewModel, onSave: {
                    //TODO: Update Attendence Records on file ... only on save
                })
            }
        }
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

//#Preview {
//    TeacherClassAttendanceSummaryView()
//}
