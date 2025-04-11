//
//  AttendenceViewModel.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/9/25.
//

import Foundation



class AttendanceViewModel: ObservableObject {
    let classId: Int
    let date: Date
    let allStudents: [UserModel]

    @Published var presentStudentIds: Set<String>

    init(classId: Int, date: Date, allStudents: [UserModel], initialPresentIds: [String]) {
        self.classId = classId
        self.date = date
        self.allStudents = allStudents
        self.presentStudentIds = Set(initialPresentIds)
    }

    func toggleAttendance(for studentId: String) {
        if presentStudentIds.contains(studentId) {
            presentStudentIds.remove(studentId)
        } else {
            presentStudentIds.insert(studentId)
        }
    }

    func save() {
        // TODO: Save in server after edit
        print("✅ Saving attendance for class: \(classId) on \(formatted(date))")
        print("👥 Present student IDs: \(presentStudentIds)")
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


struct StudentClassRecordViewModel {
    let student: UserModel
    let className: String
    let classId: UUID
    let attendanceRecords: [Date: [String]] // [Date: Present student emails]
}
