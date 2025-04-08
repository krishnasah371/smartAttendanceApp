import Foundation

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let loginData = LoginRequest(email: email, password: password)
        let bodyData = try JSONEncoder().encode(loginData)
        
        do {
            return try await APIClient.shared.request(.login, method: "POST", body: bodyData)
        } catch let networkError as NetworkError {
            // Handle API error message
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occured while logging in.")
        }
    }
    
    func signup(name: String, email: String, password: String) async throws -> SignupResponse {
        let signupData = SignupRequest(name: name, email: email, password: password)
        let bodyData = try JSONEncoder().encode(signupData)
        
        do {
            return try await APIClient.shared.request(.signup, method: "POST", body: bodyData)
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occured while signing up.")
        }
    }
}
