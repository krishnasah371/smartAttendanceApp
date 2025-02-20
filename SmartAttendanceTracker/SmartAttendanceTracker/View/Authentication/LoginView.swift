import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            LoginHeaderView()
            LoginFormView(viewModel: viewModel)
            SignupSection()
        }
    }
}

#Preview {
    LoginView()
}
