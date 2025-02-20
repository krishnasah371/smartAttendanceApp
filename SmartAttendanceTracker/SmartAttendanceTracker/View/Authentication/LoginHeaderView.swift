import SwiftUI

struct LoginHeaderView: View {
    var body: some View {
        ZStack {

            /**
                Top Section -- LOGO and HEADER
             */
            VStack {
                Image(systemName: "wifi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .padding(.top, 80)

                // Pushes content to the top
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 350)
            .background(Color.primaryAccentColor)
            .foregroundColor(.white)
            .cornerRadius(30)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    LoginHeaderView()
}
