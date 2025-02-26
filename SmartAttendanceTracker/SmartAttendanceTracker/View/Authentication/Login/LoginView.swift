import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {

            VStack {
                AuthHeaderView()
                LoginForm(viewModel: viewModel)
                Spacer()
                SignupSection()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.white) 
        }
    }
}

#Preview {
    LoginView()
}
