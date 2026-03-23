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
    case getMyAttendance(classId: Int)
    case getClassAttendance(classId: Int)
    case updateAttendanceRecord(classId: Int, attendanceId: Int)
    


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
        case .updateAttendence(let classId, _, _): return "/classes/\(classId)/attendance/mark"
        case .getAttendenceForDate(let classId, let date): return "/classes/\(classId)/attendance/by-date?date=\(date)"
        case .getStudentsForClass(let classId): return "/classes/\(classId)/students"
        case .getActiveClassForBeacon(let bleId): return "/classes/active-by-beacon?ble_id=\(bleId)"
        case .getMyAttendance(let classId): return "/classes/\(classId)/attendance/me"
        case .getClassAttendance(let classId): return "/classes/\(classId)/attendance"
        case .updateAttendanceRecord(let classId, let attendanceId):
            return "/classes/\(classId)/attendance/\(attendanceId)"
        }
    }

    var method: String {
        switch self {
        case .login, .signup,.enrollInAClass,.registerInAClass: return "POST"
        case .getClasses,.getAllClasses,.getAttendenceForDate,.getStudentsForClass,.updateBLE, .getUser, .getActiveClassForBeacon, .getMyAttendance, .getClassAttendance: return "GET"
        case .updateAttendence: return "POST"
        case .updateAttendanceRecord: return "PUT"
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .getClasses,.enrollInAClass,.registerInAClass,.getUser, .getActiveClassForBeacon, .getAttendenceForDate, .getStudentsForClass, .getMyAttendance, .getClassAttendance, .updateAttendanceRecord:
            return true
        default:
            return false
        }
    }
}
