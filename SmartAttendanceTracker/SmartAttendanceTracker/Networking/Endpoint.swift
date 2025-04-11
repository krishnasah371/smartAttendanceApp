import Foundation

enum Endpoint {
    case login
    case signup
    case getClasses
    case getAllClasses
    case registerInAClass
    case enrollInAClass(classId: Int) // 👈 dynamic ID

    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .signup: return "/auth/register"
        case .getClasses: return "/classes"
        case .getAllClasses: return "/classes/public"
        case .enrollInAClass(let classId): return "/classes/\(classId)/enroll"
        case .registerInAClass: return "/classes/register"
        }
    }

    var method: String {
        switch self {
        case .login, .signup,.enrollInAClass,.registerInAClass: return "POST"
        case .getClasses,.getAllClasses: return "GET"
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .getClasses,.enrollInAClass:
            return true
        default:
            return false
        }
    }
}
