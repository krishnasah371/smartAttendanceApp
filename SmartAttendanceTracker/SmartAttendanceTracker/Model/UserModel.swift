//
//  UserModel.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/7/25.
//

import Foundation

enum UserRole: String, Codable, Identifiable {
    case teacher
    case student
    var id: String { self.rawValue }
}

struct UserModel: Codable, Identifiable {
    var id: String
    let email: String
    let name: String
    let role: UserRole
}

