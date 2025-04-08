import SwiftUI

@MainActor
class SignupViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var nameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?

    @Published var isRegistrationSuccess: Bool = false
    @Published var isAuthenticated: Bool = false

    var isFormValid: Bool {
        emailError == nil && passwordError == nil && confirmPasswordError == nil
            && !name.isEmpty && !email.isEmpty && !password.isEmpty
            && !confirmPassword.isEmpty
    }

    // Validate name field
    func validateName() {
        if name.isEmpty {
            nameError = "name is required."
        } else {
            nameError = nil
        }
    }

    // Validate the email field
    func validateEmail() {
        if email.isEmpty {
            emailError = "Email is required."
        } else if !isValidEmail(email) {
            emailError = "Invalid email format"
        } else {
            emailError = nil
        }
    }

    // Validate password field
    func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required."
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters long."
        } else if !isValidPassword(password) {
            passwordError =
                "Password must contain at least one uppercase, one lowercase, one number, and one special character (@$!%*?&)."
        } else {
            passwordError = nil
        }
    }

    // Validate confirm password field
    func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = "Confirm password is required."
        } else if confirmPassword != password {
            confirmPasswordError = "Passwords do not match."
        } else {
            confirmPasswordError = nil
        }
    }

    // Validate entire form
    func validateForm() -> Bool {
        validateEmail()
        validatePassword()
        validateConfirmPassword()

        return isFormValid
    }

    // Signup function
    func signup() async {
        guard validateForm() else {
            errorMessage = "Please fix the errors in the form"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            var response = try await AuthService.shared.signup(
                name: name, email: email, password: password)
            print(name, email, password)
            print("✅ Signup successful: \(response)")  // ✅ Debug success response
            
            // TODO: Remove only for testing
            response.success = (response.message == "User registered successfully")

            if response.success == true {
                isRegistrationSuccess = true
                clearForm()
            } else {
                errorMessage = mapErrorMessage(
                    response.error ?? response.message
                        ?? "Signup failed. Please try again.")
                print("❌ Signup failed: \(errorMessage ?? "Unknown error")")  // ✅ Debug failure message
            }
            
            var loginResponse = try await AuthService.shared.login(
                email: email, password: password)
            print("Login response: \(loginResponse)")
            
            // TODO: Temporary testing, remove:
            loginResponse.success = !(loginResponse.token?.isEmpty ?? true)
            
            if loginResponse.success == true, let token = loginResponse.token {
                AuthManager.shared.saveToken(token)
                isAuthenticated = true
                clearForm()
            } else {
                errorMessage = mapErrorMessage(
                    response.error ?? loginResponse.message ?? "Invalid credentials."
                )
                print("Login failed: \(errorMessage ?? "Unknown error")")
            }
            
            
        } catch let networkError as NetworkError {
            errorMessage = networkError.localizedDescription
            print("❌ Network error: \(errorMessage ?? "Unknown network error")")  // ✅ Debug network error

        } catch {
            errorMessage =
                "An unexpected error occurred. Please try again later."
            print("❌ Unexpected error: \(error.localizedDescription)")  // ✅ Debug unexpected errors
        }

        isLoading = false
        // TODO: Log in here after verifying how we get user's name and all other info from server for each user.
        
        
    }

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
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(
            with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex =
            #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(
            with: password)
    }
}
