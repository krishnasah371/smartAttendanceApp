import Foundation

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let loginData = LoginRequest(email: email, password: password)
        let bodyData = try JSONEncoder().encode(loginData)
        
        do {
            return try await APIClient.shared.request(.login, body: bodyData)
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occurred while logging in.")
        }
    }
    
    func signup(name: String, email: String, password: String, role: UserRole) async throws -> SignupResponse {
        let signupData = SignupRequest(name: name, email: email, password: password, role: role.rawValue)
        let bodyData = try JSONEncoder().encode(signupData)
        
        do {
            return try await APIClient.shared.request(.signup, body: bodyData)
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occurred while signing up.")
        }
    }
}
