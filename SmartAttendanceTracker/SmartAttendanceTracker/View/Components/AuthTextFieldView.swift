import SwiftUI

struct AuthTextFieldView: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .primaryColor : .gray)

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(
                                isFocused ? .gray.opacity(0) : .gray.opacity(1))
                    }

                    if isSecure {
                        SecureField("", text: $text)
                            .focused($isFocused)
                            .foregroundColor(.primaryColorDark)
                            .accentColor(.primaryColorDark)
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                            .foregroundColor(.primaryColorDark)
                            .accentColor(.primaryColorDark)
                    }

                }

            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10).stroke(
                    errorMessage != nil
                        ? .red
                        : (isFocused ? .primaryColor : .gray.opacity(0.8)),
                    lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.05), value: isFocused)

            // Display error message if it exists
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.leading, 40)
            }
        }
    }
}

#Preview {
    AuthTextFieldView(
        icon: "person",
        placeholder: "Enter your username",
        text: .constant(""),
        errorMessage: "Username is required."
    )
}
