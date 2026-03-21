import Foundation

enum Endpoint {
    case login
    case signup
    case getClasses
    case getAllClasses
    case registerInAClass
    case enrollInAClass(classId: Int) // 👈 dynamic ID
    case updateBLE(classId: Int)
    case updateAttendence(classId: Int, studentId: Int,state:String)
    case getAttendenceForDate(classId: Int, date: String)
    case getUser
    case getStudentsForClass(classId: Int)
    case getActiveClassForBeacon(bleId: String)
    


    var path: String {
        switch self {
        case .getUser: return "/me"
        case .login: return "/auth/login"
        case .signup: return "/auth/register"
        case .getClasses: return "/classes/"
        case .getAllClasses: return "/classes/public"
        case .registerInAClass: return "/classes/register"
        case .enrollInAClass(let classId): return "/classes/\(classId)/enroll"
        case .updateBLE(let classId): return "/classes/\(classId)/ble"
        case .updateAttendence(let classId, let studentId, let state): return "/classes/\(classId)/attendance/mark"
        case .getAttendenceForDate(let classId, let date): return "/classes/\(classId)/attendance/\(date)"
        case .getStudentsForClass(let classId): return "/classes/\(classId)/students"
        case .getActiveClassForBeacon(let bleId): return "/classes/active-by-beacon?ble_id=\(bleId)"
        }
    }

    var method: String {
        switch self {
        case .login, .signup,.enrollInAClass,.registerInAClass: return "POST"
        case .getClasses,.getAllClasses,.getAttendenceForDate,.getStudentsForClass,.updateBLE, .getUser, .getActiveClassForBeacon: return "GET"
        case .updateAttendence: return "POST"
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .getClasses,.enrollInAClass,.registerInAClass,.getUser, .getActiveClassForBeacon:
            return true
        default:
            return false
        }
    }
}
