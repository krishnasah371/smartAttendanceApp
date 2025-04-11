import Foundation

// MARK: -Login Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}


struct LoginResponse: Codable {
    let token: String?
    let success: Bool
    let user: User?
    let message: String?
    let error: String?
}

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let role: String
}


// MARK: -Login Models
struct SignupRequest: Codable {
    let name: String
    let email: String
    let password: String
    let role: String
}

struct SignupResponse: Codable {
    var success: Bool?
    let message: String?
    let error: String?
}
