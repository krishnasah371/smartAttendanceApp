import SwiftUI

@MainActor
class SignupViewModel: ObservableObject {
    @Published var fullname: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var fullNameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    
    @Published var isRegistrationSuccess: Bool = false

    var isFormValid: Bool {
        emailError == nil && passwordError == nil && confirmPasswordError == nil
            && !fullname.isEmpty && !email.isEmpty && !password.isEmpty
            && !confirmPassword.isEmpty
    }
    
    // Validate fullname field
    func validateFullname() {
        if fullname.isEmpty {
            fullNameError = "Fullname is required."
        } else {
            fullNameError = nil
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
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            if email == "admin@gmail.com" && password == "Password1!" {
                errorMessage = nil
                fullname = ""
                password = ""
                confirmPassword = ""
                isRegistrationSuccess = true
            } else {
                errorMessage = "Invalid username or password. Please try again."
            }
        } catch {
            errorMessage = "An error occured. Please try again."
        }
        
        isLoading = false
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
