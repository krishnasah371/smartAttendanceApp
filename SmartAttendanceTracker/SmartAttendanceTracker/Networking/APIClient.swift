import Foundation

class APIClient {
    static let shared = APIClient()
    private let baseURL = "http://172.20.10.1:3000/api"

    private init() {}

    func request<T: Codable>(
        _ endpoint: Endpoint,
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint.path)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if endpoint.requiresAuth {
            if let token = AuthManager.shared.getToken() {
                print("🔐 Attaching token to request")
                if endpoint.method == "GET" {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "X-Authorization")
                    request.setValue("true", forHTTPHeaderField: "isIOS")
                }

            } else {
                print("❌ Token missing for authenticated request")
            }
        }

        if let body = body {
            request.httpBody = body
            if let jsonString = String(data: body, encoding: .utf8) {
                print("📤 Sending Request to \(url): \(jsonString)")
            }
        }
        print("🔗 Full URL being called: \(request.url?.absoluteString ?? "nil")")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard response is HTTPURLResponse else {
            throw NetworkError.badResponse
        }

        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse

        } catch let decodingError {
            print("❌ JSON Decoding Failed: \(decodingError)")
            
            // Attempt to decode known API error
            if let apiErrorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                let errorMsg = apiErrorResponse.error ?? apiErrorResponse.message ?? "An unknown error occurred."
                print("❌ API Error Response: \(errorMsg)")
                throw NetworkError.serverError(errorMsg)
            }

            // Log raw response just in case
            if let raw = String(data: data, encoding: .utf8) {
                print("📦 Raw response that failed decoding:\n\(raw)")
            }

            throw NetworkError.decodingFailed
        }
    }
}
