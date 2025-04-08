import SwiftUI


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
