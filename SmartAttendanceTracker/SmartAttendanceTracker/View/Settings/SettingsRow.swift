import SwiftUI

struct SettingsRow: View {
    var icon: String
    var title: String
    var color: Color = .primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(.primaryColorDark)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        }
    }
}

#Preview {
    SettingsRow(icon: "bell.fill", title: "View Notifications") {}
}
