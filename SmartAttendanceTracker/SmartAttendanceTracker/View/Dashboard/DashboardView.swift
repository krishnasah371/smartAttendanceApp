// View/Dashboard/DashboardView.swift
import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .padding()

                // Add your dashboard content here
                Text("This is the main screen of the app.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            NavigationLink(destination: SignupView()) {
                Text("Settings")
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
