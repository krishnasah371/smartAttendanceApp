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
    var name: String
    var email: String
    var role: UserRole
}


extension UserModel {
    init(from user: User) {
        self.id = user.id
        self.name = user.name
        self.email = user.email
        self.role = UserRole(rawValue: user.role) ?? .student
    }
}


