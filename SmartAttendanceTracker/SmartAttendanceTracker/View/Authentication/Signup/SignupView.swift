import SwiftUI

struct SignupView: View {
    let role: UserRole
    @StateObject private var viewModel: SignupViewModel

    init(role: UserRole) {
        self.role = role
        _viewModel = StateObject(wrappedValue: SignupViewModel(role: role))
    }

    var body: some View {
        NavigationStack {
            VStack {
                AuthHeaderView()
                SignUpForm(viewModel: viewModel)
                Spacer()
                LoginSection()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.white)
        }
    }
}


//#Preview {
//    SignupView()
//}
