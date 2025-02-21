import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                AuthHeaderView()
                SignUpForm(viewModel: viewModel)
                Spacer()
                LoginSection()
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    SignupView()
}
