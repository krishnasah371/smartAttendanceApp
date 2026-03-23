//
//  AttendenceService.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/11/25.
//

import Foundation


class AttendenceService {
    static let shared = AttendenceService()

    private init() {}

    func updateStudentAttendence(classId: Int, studentId: Int, state:String) async throws -> SuccessResponse {
        do {
            let response:SuccessResponse = try await APIClient.shared.request(.updateAttendence(classId: classId, studentId: studentId, state: state))
            return response
            
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occurred while fetching classes.")
        }
    }
    
    func getAllAttendence(classId: Int,date:String) async throws -> [AttendenceResponse]? {
        do {
            let response:AttendenceListResponse = try await APIClient.shared.request(.getAttendenceForDate(classId: classId, date: date))
            return response.attendance
            
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occurred while fetching classes.")
        }
    }
    
    func getStudentsForClass(classId: Int) async throws -> [StudentInClassModel]? {
        do {
               let response: StudentListResponse = try await APIClient.shared.request(.getStudentsForClass(classId: classId))
               return response.students
           } catch let networkError as NetworkError {
               throw networkError
           } catch {
               throw NetworkError.serverError("Failed to fetch students for class.")
           }
    }
    // Fetches the current student's attendance for a specific class
    // Returns attendance records + percentage calculated by backend
    func getMyAttendance(classId: Int) async throws -> MyAttendanceResponse {
        do {
            let response: MyAttendanceResponse = try await APIClient.shared.request(
                .getMyAttendance(classId: classId)
            )
            return response
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("Failed to fetch your attendance.")
        }
    }
    func getClassAttendance(classId: Int) async throws -> AttendenceListResponse {
        do {
            let response: AttendenceListResponse = try await APIClient.shared.request(
                .getClassAttendance(classId: classId)
            )
            return response
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("Failed to fetch class attendance.")
        }
    }
    
//    func setStudentAttendence() async throws -> [ClassModel]? {
//        do {
//            let response:ClassesResponse = try await APIClient.shared.request(.getAllClasses)
//            return response.classes
//            
//        } catch let networkError as NetworkError {
//            throw networkError
//        } catch {
//            throw NetworkError.serverError("An error occurred while fetching classes.")
//        }
//    }
    
    
//    func enrollInAClass(classId: Int) async throws -> ClassEnrollResponse? {
//        do {
//            let response:ClassEnrollResponse = try await APIClient.shared.request(.enrollInAClass(classId:classId))
//            return response
//            
//        } catch let networkError as NetworkError {
//            throw networkError
//        } catch {
//            throw NetworkError.serverError("An error occurred while fetching classes.")
//        }
//    }
//    func registerANewClass(classRegistrationPayload: ClassRegistrationPayload) async throws -> ClassRegistrationResponse? {
//        do {
//            let bodyData = try JSONEncoder().encode(classRegistrationPayload)
//            
//            print("BodyDATA is: ",bodyData)
//            let response:ClassRegistrationResponse = try await APIClient.shared.request(.registerInAClass, body: bodyData)
//            return response
//            
//        } catch let networkError as NetworkError {
//            throw networkError
//        } catch {
//            throw NetworkError.serverError("An error occurred while fetching classes.")
//        }
//    }
}
