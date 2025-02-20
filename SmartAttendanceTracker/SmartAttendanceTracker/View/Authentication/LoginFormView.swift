import SwiftUI

struct LoginFormView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome back!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                Text("Enter your email and password to login.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, -10)

                // Email and Password Fields
                AuthTextFieldView(
                    icon: "person", placeholder: "Your username", text: $viewModel.username)
                AuthTextFieldView(
                    icon: "lock", placeholder: "Your password", text: $viewModel.password,
                    isSecure: true)

                // Forgot Password Link
                HStack {
                    Spacer()
                    NavigationLink(destination: ContentView()) {
                        Text("Forgot password?")
                            .foregroundColor(.primaryAccentColor)
                            .font(.subheadline)
                            .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }

                // Login Button
                NavigationLink(destination: ContentView()) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryAccentColor)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 30)
            .offset(y: -180)
        }
    }
}

#Preview {
    LoginFormView(viewModel: LoginViewModel())
}

