import SwiftUI

struct LoginForm: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var navigateToDashboard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome back!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                    .foregroundColor(.primaryColorDarker)

                Text("Enter your email and password to login.")
                    .font(.subheadline)
                    .padding(.top, -10)
                    .foregroundColor(.primaryColor)

                // Email and Password Fields
                AuthTextFieldView(
                    icon: "person",
                    placeholder: "Your username",
                    text: $viewModel.username,
                    errorMessage: viewModel.usernameError
                )
                .onChange(of: viewModel.username) { _, _ in
                    viewModel.validateUsername()
                }

                AuthTextFieldView(
                    icon: "lock",
                    placeholder: "Your password",
                    text: $viewModel.password,
                    isSecure: true,
                    errorMessage: viewModel.passwordError
                )
                .onChange(of: viewModel.password) { _, _ in
                    viewModel.validatePassword()
                }

                // Forgot Password Link
                HStack {
                    Spacer()
                    NavigationLink(destination: ForgotPasswordView()) {
                        Text("Forgot password?")
                            .foregroundColor(.primaryColor)
                            .font(.subheadline)
                            .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }

                // Show the error message if any
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

                // Login Button
                Button(action: {
                    Task {
                        await viewModel.login()
                        if viewModel.isAuthenticated {
                            navigateToDashboard = true
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            LoadingSpinner(size: 20, lineWidth: 3)
                        } else {
                            Text("Login")
                        }
                    }
                    .frame(height: 20)
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
            .offset(y: -180)

            .navigationDestination(isPresented: $navigateToDashboard) {
                DashboardView()
            }
        }
    }
}

#Preview {
    LoginForm(viewModel: LoginViewModel())
}
