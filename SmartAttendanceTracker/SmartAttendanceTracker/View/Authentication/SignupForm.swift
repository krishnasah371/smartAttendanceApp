import SwiftUI

struct SignUpForm: View {
    @ObservedObject var viewModel: SignupViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create an account")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                Text(
                    "Welcome! Register to get started."
                )
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)
                .foregroundColor(.gray)
                .padding(.top, -10)

                // Email and Password Fields
                AuthTextFieldView(
                    icon: "person", placeholder: "Full Name",
                    text: $viewModel.fullname)
                AuthTextFieldView(
                    icon: "person", placeholder: "Your fisk email",
                    text: $viewModel.email)
                AuthTextFieldView(
                    icon: "lock", placeholder: "A weak password recommended",
                    text: $viewModel.password,
                    isSecure: true)
                AuthTextFieldView(
                    icon: "lock", placeholder: "Confirm your weak password",
                    text: $viewModel.confirmPassword, isSecure: true)

                // Login Button
                NavigationLink(destination: DashboardView()) {
                    Text("Signup")
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
            .padding(.horizontal, 20)
            .offset(y: -130)
        }
    }
}

#Preview {
    SignUpForm(viewModel: SignupViewModel())
}
