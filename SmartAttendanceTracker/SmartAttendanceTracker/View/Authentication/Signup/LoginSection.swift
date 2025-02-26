import SwiftUI

struct LoginSection: View {
    var body: some View {
        NavigationStack {
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.primaryColorDark)
                NavigationLink("Login", destination: LoginView())
                    .fontWeight(.bold)
                    .foregroundColor(.primaryColor)
            }
            .padding(.bottom, 70)
        }
    }
}

#Preview {
    LoginSection()
}

