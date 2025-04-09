import SwiftUI

struct SettingsHeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .padding(.top, 40)

            Text("Settings")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 40)
        .background(Color.primaryColor)
        .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}


#Preview {
    SettingsHeaderView()
}
