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

struct ClassEnrollResponse: Codable {
    let message: String?
}

struct ClassRegistrationResponse: Codable {
    let message: String?
}

struct ClassRegistrationPayload: Codable {
    let name: String
    let schedule: String // JSON string
    let ble_id: String
    let timezone: String
    let start_date: String
    let end_date: String
}

struct SuccessResponse: Codable {
    let message: String?
}

struct AttendenceResponse: Codable{
    let userid: Int
    let date: String
    let status: String
}
