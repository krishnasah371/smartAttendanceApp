import Foundation

enum Endpoint {
    case login
    case signup
    case getClasses

    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .signup: return "/auth/register"
        case .getClasses: return "/classes"
        }
    }

    var method: String {
        switch self {
        case .login, .signup: return "POST"
        case .getClasses: return "GET"
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .getClasses:
            return true
        default:
            return false
        }
    }
}
