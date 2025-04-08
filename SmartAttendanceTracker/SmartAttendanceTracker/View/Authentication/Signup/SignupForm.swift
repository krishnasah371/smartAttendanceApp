import SwiftUI

struct SignUpForm: View {
    @ObservedObject var viewModel: SignupViewModel
    @State private var navigateToDashboard = false
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create an account")
                    .foregroundColor(.primaryColorDarker)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                Text(
                    "Welcome! Register to get started."
                )
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)
                .foregroundColor(.primaryColor)
                .padding(.top, -10)

                // Email and Password Fields
                AuthTextFieldView(
                    icon: "person", placeholder: "Full Name",
                    text: $viewModel.name,
                    errorMessage: viewModel.nameError
                )
                .onChange(of: viewModel.name) { _, newValue in
                    viewModel.validateName()
                }

                AuthTextFieldView(
                    icon: "person", placeholder: "Your fisk email",
                    text: $viewModel.email, errorMessage: viewModel.emailError
                )
                .onChange(of: viewModel.email) { _, newValue in
                    viewModel.validateEmail()
                }

                AuthTextFieldView(
                    icon: "lock", placeholder: "A weak password recommended",
                    text: $viewModel.password,
                    isSecure: true, errorMessage: viewModel.passwordError
                )
                .onChange(of: viewModel.password) { _, newValue in
                    viewModel.validatePassword()
                }

                AuthTextFieldView(
                    icon: "lock", placeholder: "Confirm your weak password",
                    text: $viewModel.confirmPassword, isSecure: true,
                    errorMessage: viewModel.confirmPasswordError
                )
                .onChange(of: viewModel.confirmPassword) { _, newValue in
                    viewModel.validateConfirmPassword()
                }

                // Show Error Message (if any)
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }

                // Signup Button
                Button(action: {
                    Task {
                        await viewModel.signup()
                        if viewModel.errorMessage == nil {
                            sessionManager.isLoggedIn = true
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            LoadingSpinner(size: 20, lineWidth: 3)
                        } else {
                            Text("Signup")
                        }
                    }
                    .frame(height: 20)  // Matches LoginForm button height
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryColor)
                    .cornerRadius(10)
                }
                .disabled(!viewModel.isFormValid)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            .offset(y: -130)

            .navigationDestination(isPresented: $navigateToDashboard) {
                LoginView()
            }
        }
    }
}

//#Preview {
//    SignUpForm(viewModel: SignupViewModel())
//}
