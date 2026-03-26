//
//  AttendenceViewModel.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/9/25.
//

import Foundation



class AttendanceViewModel: ObservableObject {
    let classId: Int
    let date: String
    @Published var presentStudentIds: Set<Int>
    @Published var studentsInClass:[StudentInClassModel]
    // Maps student ID to their attendance record ID for this date
    @Published var attendanceRecordIds: [Int: Int] = [:]
    private var recordIdMap: [Int: Int] = [:]
    private var fetchError: String?
    
    init(classId: Int, date: Date) {
        self.classId = classId
        let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
        self.date = formatter.string(from: date)
        self.studentsInClass = []
        self.presentStudentIds = []
//        self.allStudents = allStudents
//        self.presentStudentIds = Set(initialPresentIds)
//        self.presentStudentIdsArray = Array(initialPresentIds)
        
            Task {
                try await loadAttendance()
            }
    }

    func updateAttendence(for studentId: Int) {
        if presentStudentIds.contains(studentId) {
            presentStudentIds.remove(studentId)
        } else {
            presentStudentIds.insert(studentId)
        }
    }

    func loadAttendance() async throws -> Set<Int> {
        do {
            // Fetch data on background thread (network call)
            let attendenceForDate = try await AttendenceService.shared.getAllAttendence(classId: classId, date: date) ?? []
            let students = try await AttendenceService.shared.getStudentsForClass(classId: classId) ?? []
            
            // Calculate present IDs before switching to main thread
            var newPresentIds = Set<Int>()
            var newRecordIds: [Int: Int] = [:]  // studentId -> attendanceRecordId
            
            
            for each in attendenceForDate {
                        // Map student ID to their attendance record ID
                        // To let teacher update the right record
                        newRecordIds[each.studentId] = each.id
                        
                        if each.status == "present" {
                            newPresentIds.insert(each.studentId)
                        }
                    }
            print("📋 Record IDs loaded: \(newRecordIds)")
            
            // Switch to main thread before updating @Published variables
            let finalPresentIds = newPresentIds
            let finalStudents = students
            let finalRecordIds = newRecordIds
            await MainActor.run {
                self.presentStudentIds = finalPresentIds
                self.studentsInClass = finalStudents
                self.attendanceRecordIds = finalRecordIds
            }
            self.recordIdMap = newRecordIds
            return newPresentIds
        } catch {
            throw NetworkError.serverError("Some error.")
        }
    }
    
    func loadAllStudents() async throws{
        do {
            let attendenceForDate = try await AttendenceService.shared.getAllAttendence(classId: classId, date: date) ?? []
            for each in attendenceForDate {
                if each.status == "present" {
                    presentStudentIds.insert(each.studentId)
                }
            }
            self.studentsInClass  = try await AttendenceService.shared.getStudentsForClass(classId: classId) ?? []
//            return self.presentStudentIds
        } catch {
            throw NetworkError.serverError("Some error.")
        }
    }
         
    func save() {
        // Capture record IDs BEFORE entering the async Task
        // This ensures we read the current value, not a stale one
        let currentRecordIds = recordIdMap
        let currentPresentIds = presentStudentIds
        let currentStudents = studentsInClass
        
        Task {
            do {
                for student in currentStudents {
                    let newStatus = currentPresentIds.contains(student.id) ? "present" : "absent"
                    print("🔍 Student \(student.id), recordIds: \(currentRecordIds)")
                    
                    if let recordId = currentRecordIds[student.id] {
                        let body = try JSONEncoder().encode(UpdateAttendanceBody(
                            status : newStatus,
                            isManual: true,
                        ))
                        _ = try await APIClient.shared.request(
                            .updateAttendanceRecord(classId: classId, attendanceId: recordId),
                            body: body
                        ) as SuccessResponse
                    } else {
                        // No existing attendance record for this student
                            // They were never detected by beacon — they remain absent
                            // Teachers can only modify existing records, not create new ones
                            // (Creating new records requires beacon validation)
                            print("ℹ️ No record for student \(student.id) — leaving as absent")
                    }
                }
                print("✅ Attendance saved successfully")
                _ = try await loadAttendance()
            } catch let error as NetworkError {
                self.fetchError = error.localizedDescription
                print("❌ Save failed: \(error.localizedDescription)")
            } catch {
                self.fetchError = error.localizedDescription
                print("❌ Save failed: \(error.localizedDescription)")
            }
        }
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
