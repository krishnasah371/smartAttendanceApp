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

      func loadAttendance() async throws -> Set<Int>{
          do {
              let attendenceForDate = try await AttendenceService.shared.getAllAttendence(classId: classId, date: date) ?? []
              for each in attendenceForDate {
                  if each.status == "present" {
                      presentStudentIds.insert(each.userid)
                  }
              }
              self.studentsInClass  = try await AttendenceService.shared.getStudentsForClass(classId: classId) ?? []
              return self.presentStudentIds
          } catch {
              throw NetworkError.serverError("Some error.")
          }
    }
    
    func loadAllStudents() async throws{
        do {
            let attendenceForDate = try await AttendenceService.shared.getAllAttendence(classId: classId, date: date) ?? []
            for each in attendenceForDate {
                if each.status == "present" {
                    presentStudentIds.insert(each.userid)
                }
            }
            self.studentsInClass  = try await AttendenceService.shared.getStudentsForClass(classId: classId) ?? []
//            return self.presentStudentIds
        } catch {
            throw NetworkError.serverError("Some error.")
        }
    }
         
    func save() {
        // TODO: Save in server after edit
        func fetchAllClassesView() async {
            do {
                for student in studentsInClass {
                    if presentStudentIds.contains(student.id) {
                        let fetched = try await AttendenceService.shared.updateStudentAttendence(classId: classId, studentId: student.id, state: "present")
                    } else{
                        let fetched = try await AttendenceService.shared.updateStudentAttendence(classId: classId, studentId: student.id, state: "absent")
                    }
                }
            } catch let error as NetworkError {
                self.fetchError = error.localizedDescription
            } catch {
                self.fetchError = error.localizedDescription
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
