import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case badResponse
    case decodingError
    case serverError(String)
    case unauthorized
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check the endpoint."
        case .badResponse:
            return "The server returned an invalid response."
        case .decodingError:
            return "Failed to decode data. The response format may have changed."
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .noData:
            return "No data returned from the server."
        }
    }
}
