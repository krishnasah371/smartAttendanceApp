import SwiftUI

struct SplashScreenView: View {
    @State private var navigateToLogin = false
    @State private var navigateToDashboard = false
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color (Fills the whole screen)
                Color.primaryColor
                    .ignoresSafeArea()

                VStack {
                    // App logo
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 350)
                        .padding(.bottom, 80)
                        .offset(x: -35)

                    Spacer()

                    LoadingSpinner()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.clear)
                        .ignoresSafeArea()

                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if AuthManager.shared.isLoggedIn {
                        sessionManager.isLoggedIn = true
                    } else {
                        navigateToLogin = true
                    }
                }
            }
                            .navigationDestination(isPresented: $navigateToLogin) {
                                WelcomeView()
                                    .navigationBarBackButtonHidden()
                            }
                            .navigationDestination(isPresented: $navigateToDashboard) {
                                MainTabView()
                                    .navigationBarBackButtonHidden()
                            }
                        }
        .accentColor(.primaryColorDarker)
    }

}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
