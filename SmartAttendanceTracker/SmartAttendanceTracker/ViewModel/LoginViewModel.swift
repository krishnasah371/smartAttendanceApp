import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil

    @Published var isAuthenticated: Bool = false

    var isFormValid: Bool {
        emailError == nil && passwordError == nil && !email.isEmpty && !password.isEmpty
    }

    // MARK: - Validation

    func validateEmail() {
        if email.isEmpty {
            emailError = "Email is required."
        } else if email.count < 5 {
            emailError = "Email must be at least 5 characters long."
        } else {
            emailError = nil
        }
    }

    func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required."
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters long."
        } else if !isValidPassword(password) {
            passwordError = "Password must contain at least one uppercase, one lowercase, one number, and one special character (@$!%*?&)."
        } else {
            passwordError = nil
        }
    }

    func validateForm() -> Bool {
        validateEmail()
        validatePassword()
        return isFormValid
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex =
        #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }

    // MARK: - Login

    func login() async {
        guard validateForm() else {
            errorMessage = "Please fix the errors in the form."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await AuthService.shared.login(email: email, password: password)
            print("Login response: \(response)")

            if response.success,
               let token = response.token,
               let user = response.user {
                AuthManager.shared.saveToken(token)
                AuthManager.shared.saveUser(UserModel(from: user))
                isAuthenticated = true
            } else {
                errorMessage = mapErrorMessage(response.error ?? response.message ?? "Invalid credentials.")
                print("Login failed: \(errorMessage ?? "Unknown error")")
            }

        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
            print("Login error: \(errorMessage ?? "Unknown error")")
        } catch {
            errorMessage = "An unexpected error occurred. Please try again later."
        }

        isLoading = false
    }

    // MARK: - Error Formatting

    private func mapErrorMessage(_ error: String) -> String {
        switch error.lowercased() {
        case "invalid credentials":
            return "The email or password is incorrect."
        case "user not found":
            return "No account found with this email."
        case "account locked":
            return "Your account has been locked. Please contact support."
        default:
            return formatErrorMessage(error)
        }
    }

    private func formatErrorMessage(_ error: String) -> String {
        let formattedMessage = error.prefix(1).capitalized + error.dropFirst()
        return formattedMessage.replacingOccurrences(of: "_", with: " ")
    }
}
