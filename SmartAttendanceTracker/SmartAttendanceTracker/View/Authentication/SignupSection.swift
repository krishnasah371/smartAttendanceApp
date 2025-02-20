import SwiftUI

struct SignupSection: View {
    var body: some View {
        HStack {
            Text("Don’t have an account?")
            NavigationLink("Signup Now", destination: ContentView())
                .fontWeight(.bold)
                .foregroundColor(.primaryAccentColor)
        }
        .padding(.bottom, 15)
    }
}

#Preview {
    SignupSection()
}


