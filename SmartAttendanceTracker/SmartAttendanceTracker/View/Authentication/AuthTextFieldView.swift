import SwiftUI

struct AuthTextFieldView: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isFocused ? .primaryAccentColor : .gray)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10).stroke(isFocused ? Color.primaryAccentColor : Color.gray.opacity(0.8), lineWidth: 2))
        .animation(.easeInOut(duration: 0.1), value: isFocused)
    }
}

#Preview {
    AuthTextFieldView(icon: "person", placeholder: "Enter your username", text: .constant(""))
}
