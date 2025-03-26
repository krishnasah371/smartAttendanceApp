import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var usernameError: String? = nil
    @Published var passwordError: String? = nil
    
    @Published var isAuthenticated: Bool = false

    var isFormValid: Bool {
        usernameError == nil && passwordError == nil && !username.isEmpty
            && !password.isEmpty
    }

    // Validate the username field
    func validateUsername() {
        if username.isEmpty {
            usernameError = "Username is required."
        } else if username.count < 5 {
            usernameError = "Username must be at least 5 characters long."
        } else {
            usernameError = nil
        }
    }

    // Validate the password field
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

    // Validate the entire form
    func validateForm() -> Bool {
        validateUsername()
        validatePassword()

        return isFormValid
    }

    // Login function (example)
    func login() async {
        guard validateForm() else {
            errorMessage = "Please fix the errors in the form."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)

            if username == "Admin" && password == "Password1!" {
                errorMessage = nil
                username = ""
                password = ""
                isAuthenticated = true
            } else {
                errorMessage = "Invalid username or password. Please try again."
            }
        } catch {
            errorMessage = "An error occured. Please try again."
        }
        isLoading = false
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex =
            #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(
            with: password)
    }
}
