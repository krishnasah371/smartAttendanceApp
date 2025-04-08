import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case badResponse
    case decodingError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check the endpoint."
        case .badResponse:
            return "The server returned an invalid response."
        case.decodingError:
            return "Failed to decode data. The response format may have changed."
        case .serverError(let message):
            return message
        }
    }
}
