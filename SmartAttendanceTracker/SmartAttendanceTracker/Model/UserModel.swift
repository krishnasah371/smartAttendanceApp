//
//  UserModel.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/7/25.
//

import Foundation

enum UserRoles: String, Codable {
    case teacher
    case student
    case admin
}

struct UserModel: Codable {
    let email: String
    let name: String
    let role: UserRoles
}
