import Foundation

class APIClient {
    static let shared = APIClient()
    private let baseURL = "http://192.168.1.96:3000/api"

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
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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

        let (data, response) = try await URLSession.shared.data(for: request)

        guard response is HTTPURLResponse else {
            throw NetworkError.badResponse
        }

        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            print("📥 Received Success Response: \(decodedResponse)")
            return decodedResponse
        } catch {
            do {
                let apiErrorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                let errorMsg = apiErrorResponse.error ?? apiErrorResponse.message ?? "An unknown error occurred."
                print("❌ API Error Response: \(errorMsg)")
                throw NetworkError.serverError(errorMsg)
            } catch {
                print("❌ Failed to decode error response: \(error.localizedDescription)")
                throw NetworkError.badResponse
            }
        }
    }
}
