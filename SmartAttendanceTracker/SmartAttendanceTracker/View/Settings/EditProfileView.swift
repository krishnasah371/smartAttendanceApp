import SwiftUI

struct EditProfileView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userEmail") var userEmail: String = ""

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                SettingsHeaderView()

                VStack(spacing: 16) {
                    TextField("Full Name", text: $userName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                    TextField("Email", text: $userEmail)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                    Button("Save") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryColorDark)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

#Preview {
    EditProfileView()
}
