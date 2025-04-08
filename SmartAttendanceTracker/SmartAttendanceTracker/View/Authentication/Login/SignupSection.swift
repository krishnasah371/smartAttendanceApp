import SwiftUI

struct SignupSection: View {
    var body: some View {
        NavigationStack {
            HStack {
                Text("Don’t have an account?")
                    .foregroundColor(.primaryColorDark)
                NavigationLink("Signup Now", destination: WelcomeView())
                    .fontWeight(.bold)
                    .foregroundColor(.primaryColor)
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    SignupSection()
}
