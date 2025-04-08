import SwiftUI

/// A reusable header view for authentication screens, providing a visually appealing
/// background and a centered icon.
///
/// `AuthHeaderView` is commonly used in login and signup screens to display a branded
/// top section with a logo and rounded bottom corners.
///
/// Ensure that `primaryAccentColor` is defined in your project's `Color` extension.
struct AuthHeaderView: View {
    var body: some View {
        ZStack {
            VStack {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 80)
                    .offset(x: -15)

                // Pushes content to the top
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(30)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    AuthHeaderView()
}
