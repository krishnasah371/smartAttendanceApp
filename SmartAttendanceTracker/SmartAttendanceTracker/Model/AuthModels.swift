import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}


struct LoginResponse: Codable {
    var success: Bool?
    let token: String?
    let message: String?
    let error: String?
}

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
