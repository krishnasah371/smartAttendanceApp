import Foundation

struct APIErrorResponse: Codable {
    let error: String?
    let message: String?
}
