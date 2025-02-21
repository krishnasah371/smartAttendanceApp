import SwiftUI

struct LoginSection: View {
    var body: some View {
        NavigationStack {
            HStack {
                Text("Already have an account?")
                NavigationLink("Login", destination: LoginView())
                    .fontWeight(.bold)
                    .foregroundColor(.primaryAccentColor)
            }
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    LoginSection()
}

