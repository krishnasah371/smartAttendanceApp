import SwiftUI

@MainActor
class SignupViewModel: ObservableObject {
    let role: UserRole
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var nameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?

    @Published var isRegistrationSuccess: Bool = false

    init(role: UserRole) {
        self.role = role
    }

    var isFormValid: Bool {
        emailError == nil && passwordError == nil && confirmPasswordError == nil
            && !name.isEmpty && !email.isEmpty && !password.isEmpty
            && !confirmPassword.isEmpty
    }

    // MARK: - Validation

    func validateName() {
        nameError = name.isEmpty ? "Name is required." : nil
    }

    func validateEmail() {
        if email.isEmpty {
            emailError = "Email is required."
        } else if !isValidEmail(email) {
            emailError = "Invalid email format"
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

    func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = "Confirm password is required."
        } else if confirmPassword != password {
            confirmPasswordError = "Passwords do not match."
        } else {
            confirmPasswordError = nil
        }
    }

    func validateForm() -> Bool {
        validateName()
        validateEmail()
        validatePassword()
        validateConfirmPassword()
        return isFormValid
    }

    // MARK: - Signup + Auto-login
    func signup() async {
        guard validateForm() else {
            errorMessage = "Please fix the errors in the form"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await AuthService.shared.signup(
                name: name,
                email: email,
                password: password,
                role: role
            )

            print("✅ Signup response: \(response)")

            if response.success == true {
                isRegistrationSuccess = true

                // ✅ Auto-login
                let loginResponse = try await AuthService.shared.login(
                    email: email, password: password
                )
                print("🔑 Login after signup: \(loginResponse)")

                if loginResponse.success,
                   let token = loginResponse.token,
                   let user = loginResponse.user {
                    AuthManager.shared.saveToken(token)
                    AuthManager.shared.saveUser(UserModel(from: user))
                    isAuthenticated = true
                    clearForm()
                } else {
                    errorMessage = mapErrorMessage(
                        loginResponse.error ?? loginResponse.message ?? "Login failed."
                    )
                }
            } else {
                errorMessage = mapErrorMessage(
                    response.error ?? response.message ?? "Signup failed. Please try again."
                )
                print("❌ Signup failed: \(errorMessage ?? "Unknown error")")
            }

        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
            print("❌ Network error: \(errorMessage ?? "Unknown network error")")
        } catch {
            errorMessage = "An unexpected error occurred. Please try again later."
            print("❌ Unexpected error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Helpers

    private func clearForm() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
    }

    private func mapErrorMessage(_ error: String) -> String {
        switch error.lowercased() {
        case "email already exists":
            return "An account with this email already exists."
        case "invalid email":
            return "Please enter a valid email."
        default:
            return formatErrorMessage(error)
        }
    }

    private func formatErrorMessage(_ error: String) -> String {
        return error.prefix(1).capitalized + error.dropFirst()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex =
        #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}
