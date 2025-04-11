//
//  UserModel.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/7/25.
//

import Foundation

enum UserRole: String, Codable {
    case student
    case teacher
    case admin
}

struct UserModel: Codable, Identifiable {
    var id: Int
    let email: String
    let name: String
    let role: UserRole
}


extension UserModel {
    init(from user: User) {
        self.id = user.id
        self.name = user.name
        self.email = user.email
        self.role = UserRole(rawValue: user.role) ?? .student
    }
}




// MARK: For attendence for each class
struct StudentListResponse: Codable {
    let students: [StudentInClassModel]
}

struct StudentInClassModel: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let enrolled_at: String
}
